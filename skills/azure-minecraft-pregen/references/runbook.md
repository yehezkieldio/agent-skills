# Azure Spot Minecraft Chunky Runbook

## Known Good Baseline

Observed successful run:

- Azure subscription type: Azure for Students
- Region: `southeastasia`
- Requested `Standard_F4s_v2` failed due Spot/low-priority quota of 3 vCPU.
- Used `Standard_F2s_v2` with Spot, **Deallocate** eviction policy, `--max-price 0.03`.
- VM RAM: about 3.8 GiB, swap 4GB.
- Java: **GraalVM 25** (25.0.3+9.1) with **G1GC** (ZGC fails on 3.8GB RAM).
- Minecraft: Fabric dedicated server `1.21.1`, Fabric Loader `0.19.3`.
- Optimized heap on F2s: `-Xms3000M -Xmx3000M -XX:+UseG1GC -XX:G1HeapRegionSize=16M -XX:MaxGCPauseMillis=50`.
- c2me config: parallelism 2, chunk cache 64K/128K, auto-save PERIODIC, low memory mode, recoverFromErrors=true.
- System tuning: vm.swappiness=1, vm.vfs_cache_pressure=25, dirty_ratio=10, performance governor, THP madvise.
- Server config: view-distance=3, simulation-distance=1, max-chained-neighbor-updates=1000000.
- Server startup: 40-52 seconds.
- Chunk generation rate: 12-17 cps (circle) on terrain-heavy runs, 30+ cps when skipping existing chunks.

Completed Chunky passes:

- `minecraft:the_nether`, center `0 0`, square radius `1000`: ~53,600 chunks.
- `minecraft:the_end`, center `0 0`, circle radius `1000`: ~12,272 chunks.
- `minecraft:overworld`, center `0 0`, circle radius `1000`: ~16,100 chunks.
- `minecraft:overworld`, center `0 0`, circle radius `2000`: ~49,000 chunks.
- `minecraft:overworld`, center `0 0`, circle radius `3000`: ~142,000 chunks.
- `minecraft:overworld`, center `0 0`, circle radius `8000`: ~785,000 chunks (in progress).

## Later-Run Tuning Notes

When the goal is maximum cps on the F2s_v2 box, the most useful server-side tweaks were:

- Lower `vm.vfs_cache_pressure` to 25 instead of 50.
- Drop the heap to `-Xms3000M -Xmx3000M` to leave more room for the OS and native memory.
- Reduce `maxConcurrentChunkLoads` to 128 and the c2me chunk cache to 64K/128K.
- Lower `view-distance` to 3 and `simulation-distance` to 1 for pregen-only runs.
- Keep `chunkSendingSpeedMultiplierPercentage = 0` so Chunky is not rate-limited by vanilla send pacing.

For structure density, the 8k pregen target favored keeping plenty of major and rare structures within range, so later tuning used moderate spacing reductions instead of pruning entire structure families.

## Azure Checks

Check quota:

```bash
az vm list-usage -l "$LOCATION" \
  --query "[?name.value=='lowPriorityCores' || contains(name.value, 'standardFSv2Family') || name.value=='cores'].{name:name.localizedValue,value:currentValue,limit:limit}" \
  -o table
```

Check Spot price:

```bash
curl -sG 'https://prices.azure.com/api/retail/prices' \
  --data-urlencode "\$filter=serviceName eq 'Virtual Machines' and armRegionName eq '$LOCATION' and armSkuName eq '$SIZE' and priceType eq 'Consumption'" |
  jq -r '.Items[] | select((.meterName|test("Spot"; "i")) or (.skuName|test("Spot"; "i")))'
```

Confirm VM is Spot after creation:

```bash
az vm show -g "$RG" -n "$VM" -d \
  --query '{name:name,power:powerState,publicIp:publicIps,size:hardwareProfile.vmSize,priority:priority,evictionPolicy:evictionPolicy,maxPrice:billingProfile.maxPrice}' \
  -o json
```

## VM Creation

Use a dedicated resource group:

```bash
az group create -n "$RG" -l "$LOCATION"
az vm create \
  --resource-group "$RG" \
  --name "$VM" \
  --location "$LOCATION" \
  --image Ubuntu2404 \
  --size "$SIZE" \
  --priority Spot \
  --eviction-policy Deallocate \
  --max-price "$MAX_PRICE" \
  --admin-username azureuser \
  --authentication-type ssh \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --nsg-rule SSH \
  --os-disk-size-gb 64 \
  --storage-sku StandardSSD_LRS
```

## Bootstrap

Install tools and Java:

```bash
sudo apt-get update
sudo apt-get install -y tmux rsync curl jq unzip ca-certificates gnupg htop net-tools
```

Add swap (4GB) and tune system:

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=1
sudo sysctl vm.vfs_cache_pressure=50
sudo sysctl vm.dirty_ratio=10
sudo sysctl vm.dirty_background_ratio=5
sudo sysctl vm.overcommit_memory=1
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
```

Install GraalVM Java 25:

```bash
mkdir -p "$HOME/mc-server" "$HOME/downloads"
cd "$HOME/downloads"
curl -fsSL 'https://download.oracle.com/graalvm/25/latest/graalvm-jdk-25_linux-x64_bin.tar.gz' -o graalvm25.tar.gz
sudo mkdir -p /opt/java
sudo tar -xzf graalvm25.tar.gz -C /opt/java
GRAAL_DIR=$(find /opt/java -maxdepth 1 -type d -name "graalvm-jdk-25*" | sort | tail -n 1)
sudo update-alternatives --install /usr/bin/java java "$GRAAL_DIR/bin/java" 2500
sudo update-alternatives --set java "$GRAAL_DIR/bin/java"
java -version
```

Install Fabric server:

```bash
cd "$HOME/mc-server"
MC=1.21.1
LOADER=$(curl -fsSL "https://meta.fabricmc.net/v2/versions/loader/$MC" | jq -r '.[0].loader.version')
INSTALLER=$(curl -fsSL https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].version')
curl -fL "https://maven.fabricmc.net/net/fabricmc/fabric-installer/$INSTALLER/fabric-installer-$INSTALLER.jar" -o fabric-installer.jar
java -jar fabric-installer.jar server -mcversion "$MC" -loader "$LOADER" -downloadMinecraft
printf "eula=true\n" > eula.txt
```

Suggested `server.properties`:

```properties
server-port=25565
enable-command-block=true
max-players=1
online-mode=false
allow-flight=true
view-distance=4
simulation-distance=2
spawn-protection=0
sync-chunk-writes=false
level-name=world
motd=Azure Chunky pregen
max-chained-neighbor-updates=1000000
```

Optimized `run.sh` for `Standard_F2s_v2` (3.8GB RAM) with **GraalVM + G1GC**:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec java \
  -Xms3200M -Xmx3200M \
  -XX:+UseG1GC -XX:G1HeapRegionSize=16M -XX:MaxGCPauseMillis=50 \
  -XX:ParallelGCThreads=2 -XX:ConcGCThreads=2 \
  -XX:InitiatingHeapOccupancyPercent=30 \
  -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:+DisableExplicitGC \
  -XX:+UseStringDeduplication -XX:+OptimizeStringConcat \
  -XX:+ExitOnOutOfMemoryError \
  -jar fabric-server-launch.jar nogui
```

**CRITICAL: ZGC fails on F2s_v2 with 3600M heap** — `Failed to commit memory (Not enough space)`. ZGC needs significant memory overhead for concurrent collection. G1GC with 3200M heap works reliably on 3.8GB RAM + 4GB swap.

Optimized c2me config (`config/c2me.toml`) — server-only, don't sync back:

```toml
version = 3
globalExecutorParallelism = 2
defaultGlobalExecutorParallelismExpression = "2"
threadPoolPriority = "max"

[fixes]
disableLoggingShutdownHook = true
enforceSafeWorldRandomAccess = false

[noTickViewDistance]
maxConcurrentChunkLoads = 512
chunkSendingSpeedMultiplierPercentage = 0

[ioSystem]
chunkDataCacheSoftLimit = 131072
chunkDataCacheLimit = 262144
replaceImpl = true

[vanillaWorldGenOptimizations]
useDensityFunctionCompiler = true
optimizeAquifer = true
useEndBiomeCache = true
optimizeStructureWeightSampler = true

[generalOptimizations]
midTickChunkTasksInterval = 25000

[generalOptimizations.autoSave]
mode = "PERIODIC"

[chunkSystem]
asyncSerialization = true
recoverFromErrors = true
allowPOIUnloading = true
fluidPostProcessingToScheduledTick = true
filterFluidPostProcessing = true
lowMemoryMode = true
```

## Staging And Mod Filtering

Sync the world:

```bash
rsync -a --info=progress2 --delete --exclude 'session.lock' "$INSTANCE/saves/New World/" "$HOST:~/mc-server/world/"
rsync -a --info=progress2 --delete "$INSTANCE/config/" "$HOST:~/mc-server/config/"
```

Copy `defaultconfigs/` and `datapacks/` if present.

Client-side or server-hostile candidates commonly include:

- Sodium, Iris, Continuity, MoreCulling, EntityCulling, ImmediatelyFast, Reese/Sodium option helpers
- ModMenu, BetterF3, MouseTweaks, Controlling, Searchables, Zoomify
- Xaero map/minimap, Jade, EMI, InventoryProfilesNext/libIPN
- Dynamic FPS, SmoothScroll, UI/tooltip/rendering-only mods

Do not assume all of these are safe to exclude. Some content mods have hard dependencies that look client-ish. Add back dependencies reported by Fabric, for example `simplyswords` requiring `simplytooltips`.

If logs show recoverable unknown block registry warnings for excluded mods, decide whether the user wants exact block preservation or accepts fallback blocks for pregen. For exact world fidelity, add the missing content mods back and reboot.

## Running Chunky

Start server:

```bash
cd ~/mc-server
tmux kill-session -t mc 2>/dev/null || true
tmux new-session -d -s mc './run.sh 2>&1 | tee -a logs/console.log'
```

Wait for:

```text
Done (...s)! For help, type "help"
```

Send commands:

```bash
tmux send-keys -t mc "chunky quiet 120" Enter
tmux send-keys -t mc "chunky world minecraft:overworld" Enter
tmux send-keys -t mc "chunky center 0 0" Enter
tmux send-keys -t mc "chunky radius 8000" Enter
tmux send-keys -t mc "chunky shape circle" Enter
tmux send-keys -t mc "chunky start" Enter
```

For large jobs, batch with save+sync between passes:

```bash
# Batch 1: radius 1000
tmux send-keys -t mc "chunky radius 1000" Enter
tmux send-keys -t mc "chunky start" Enter
# ... wait for completion ...
tmux send-keys -t mc "save-all flush" Enter
# sync back locally
rsync -a --info=progress2 --exclude 'session.lock' "$HOST:~/mc-server/world/" "$INSTANCE/saves/World/"

# Batch 2: radius 2000 (skips existing chunks)
tmux send-keys -t mc "chunky radius 2000" Enter
tmux send-keys -t mc "chunky start" Enter
# ... repeat ...
```

Monitor:

```bash
tmux send-keys -t mc "chunky progress" Enter
tmux capture-pane -t mc -p -S -100 | tail -n 100
ps -o pid,pcpu,pmem,rss,cmd -C java
```

Flush and sync back:

```bash
tmux send-keys -t mc "save-all flush" Enter
rsync -a --info=progress2 --exclude 'session.lock' "$HOST:~/mc-server/world/" "$INSTANCE/saves/New World/"
```

Stop:

```bash
tmux send-keys -t mc "stop" Enter
```

## Watchdog Timeout Recovery

If the server crashes with "A single server tick took 62.48 seconds":

1. Check `logs/latest.log` for the crash reason
2. Restart the server: `tmux new-session -d -s mc './run.sh 2>&1 | tee -a logs/console.log'`
3. Use `chunky continue` to resume from where it left off
4. Increase quiet interval: `chunky quiet 120` or `chunky quiet 180`
5. Consider reducing radius per batch or switching to circle shape (fewer chunks than square)

## Cleanup

Always confirm cleanup status:

```bash
az group delete -n "$RG" --yes --no-wait
az group show -n "$RG" --query '{name:name,provisioningState:properties.provisioningState}' -o json
```

`Deleting` is acceptable for immediate handoff. If cleanup fails, report the resource group name and remaining resources.
