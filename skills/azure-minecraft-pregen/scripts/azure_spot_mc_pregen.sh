#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  azure_spot_mc_pregen.sh quota <location>
  azure_spot_mc_pregen.sh price <location> <armSkuName>
  azure_spot_mc_pregen.sh create-vm <rg> <vm> <location> <size> <max_price>
  azure_spot_mc_pregen.sh bootstrap <ssh_host> <mc_version>
  azure_spot_mc_pregen.sh install-fabric <ssh_host> <mc_version>
  azure_spot_mc_pregen.sh start-server <ssh_host>
  azure_spot_mc_pregen.sh send <ssh_host> <minecraft_command>
  azure_spot_mc_pregen.sh capture <ssh_host>
  azure_spot_mc_pregen.sh delete-rg <rg>
EOF
}

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 127
  }
}

cmd="${1:-}"
case "$cmd" in
  quota)
    require az
    loc="${2:?location required}"
    az vm list-usage -l "$loc" \
      --query "[?name.value=='lowPriorityCores' || contains(name.value, 'standardFSv2Family') || name.value=='cores'].{name:name.localizedValue,value:currentValue,limit:limit}" \
      -o table
    ;;

  price)
    require curl
    require jq
    loc="${2:?location required}"
    size="${3:?armSkuName required}"
    curl -sG 'https://prices.azure.com/api/retail/prices' \
      --data-urlencode "\$filter=serviceName eq 'Virtual Machines' and armRegionName eq '$loc' and armSkuName eq '$size' and priceType eq 'Consumption'" |
      jq -r '.Items[] | select((.meterName|test("Spot"; "i")) or (.skuName|test("Spot"; "i"))) | {armRegionName,armSkuName,skuName,meterName,retailPrice,unitOfMeasure,currencyCode}'
    ;;

  create-vm)
    require az
    rg="${2:?resource group required}"
    vm="${3:?vm name required}"
    loc="${4:?location required}"
    size="${5:?size required}"
    max_price="${6:?max price required}"
    az group create -n "$rg" -l "$loc" -o table
    az vm create \
      --resource-group "$rg" \
      --name "$vm" \
      --location "$loc" \
      --image Ubuntu2404 \
      --size "$size" \
      --priority Spot \
      --eviction-policy Deallocate \
      --max-price "$max_price" \
      --admin-username azureuser \
      --authentication-type ssh \
      --generate-ssh-keys \
      --public-ip-sku Standard \
      --nsg-rule SSH \
      --os-disk-size-gb 64 \
      --storage-sku StandardSSD_LRS \
      -o json
    az vm show -g "$rg" -n "$vm" -d \
      --query '{name:name,power:powerState,publicIp:publicIps,size:hardwareProfile.vmSize,priority:priority,evictionPolicy:evictionPolicy,maxPrice:billingProfile.maxPrice}' \
      -o json
    ;;

  bootstrap)
    host="${2:?ssh host required, e.g. azureuser@1.2.3.4}"
    mc="${3:?minecraft version required}"
    ssh "$host" "set -euo pipefail
sudo apt-get update
sudo apt-get install -y tmux rsync curl jq unzip ca-certificates gnupg htop net-tools numactl
sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=1
sudo sysctl vm.vfs_cache_pressure=50
sudo sysctl vm.dirty_ratio=10
sudo sysctl vm.dirty_background_ratio=5
sudo sysctl vm.overcommit_memory=1
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
mkdir -p \"\$HOME/mc-server\" \"\$HOME/downloads\"
cd \"\$HOME/downloads\"
curl -fsSL 'https://download.oracle.com/graalvm/25/latest/graalvm-jdk-25_linux-x64_bin.tar.gz' -o graalvm25.tar.gz
sudo mkdir -p /opt/java
sudo tar -xzf graalvm25.tar.gz -C /opt/java
GRAAL_DIR=\$(find /opt/java -maxdepth 1 -type d -name 'graalvm-jdk-25*' | sort | tail -n 1)
sudo update-alternatives --install /usr/bin/java java \"\$GRAAL_DIR/bin/java\" 2500
sudo update-alternatives --set java \"\$GRAAL_DIR/bin/java\"
java -version"
    "$0" install-fabric "$host" "$mc"
    ;;

  install-fabric)
    host="${2:?ssh host required}"
    mc="${3:?minecraft version required}"
    ssh "$host" "set -euo pipefail
cd \"\$HOME/mc-server\"
LOADER=\$(curl -fsSL https://meta.fabricmc.net/v2/versions/loader/$mc | jq -r '.[0].loader.version')
INSTALLER=\$(curl -fsSL https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].version')
curl -fL \"https://maven.fabricmc.net/net/fabricmc/fabric-installer/\$INSTALLER/fabric-installer-\$INSTALLER.jar\" -o fabric-installer.jar
java -jar fabric-installer.jar server -mcversion '$mc' -loader \"\$LOADER\" -downloadMinecraft
printf 'eula=true\n' > eula.txt
cat > server.properties <<'PROPS'
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
PROPS
cat > run.sh <<'RUN'
#!/usr/bin/env bash
set -euo pipefail
cd \"\$(dirname \"\$0\")\"
exec java \
  -Xms3200M -Xmx3200M \
  -XX:+UseG1GC -XX:G1HeapRegionSize=16M -XX:MaxGCPauseMillis=50 \
  -XX:ParallelGCThreads=2 -XX:ConcGCThreads=2 \
  -XX:InitiatingHeapOccupancyPercent=30 \
  -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:+DisableExplicitGC \
  -XX:+UseStringDeduplication -XX:+OptimizeStringConcat \
  -XX:+ExitOnOutOfMemoryError \
  -jar fabric-server-launch.jar nogui
RUN
chmod +x run.sh
mkdir -p config
cat > config/c2me.toml <<'C2ME'
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
C2ME
    ;;

  start-server)
    host="${2:?ssh host required}"
    ssh "$host" "cd ~/mc-server && tmux kill-session -t mc 2>/dev/null || true; tmux new-session -d -s mc './run.sh 2>&1 | tee -a logs/console.log'"
    ;;

  send)
    host="${2:?ssh host required}"
    mc_cmd="${3:?minecraft command required}"
    ssh "$host" "tmux send-keys -t mc '$mc_cmd' Enter"
    ;;

  capture)
    host="${2:?ssh host required}"
    ssh "$host" "tmux capture-pane -t mc -p -S -120 2>/dev/null | tail -n 120; ps -o pid,pcpu,pmem,rss,cmd -C java || true"
    ;;

  delete-rg)
    require az
    rg="${2:?resource group required}"
    az group delete -n "$rg" --yes --no-wait
    az group show -n "$rg" --query '{name:name,provisioningState:properties.provisioningState}' -o json || true
    ;;

  *)
    usage
    exit 2
    ;;
esac
