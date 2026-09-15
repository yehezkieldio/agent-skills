---
name: azure-spot-mc-pregen
description: Run Minecraft Java Fabric/Chunky world pregeneration on a short-lived Azure Spot VM with Azure CLI, SSH, tmux, rsync, Java setup, Fabric server staging, dimension-by-dimension Chunky execution, incremental sync-back, clean shutdown, and resource-group deletion. Use when the user wants to pregen Minecraft chunks remotely on Azure Spot/low-priority compute, minimize billing risk, handle Spot eviction/retry, copy local saves/mods/config to a VM, or sync generated region files back to a local world.
---

# Azure Spot Minecraft Pregen

## Operating Rules

Keep billing safety first.

- Prefer Azure Spot only. Do not silently fall back to regular priority unless the user explicitly accepts on-demand billing.
- Use an isolated resource group for every run so cleanup is one command.
- Use `--eviction-policy Deallocate` for long-running jobs (pregen, builds) — preserves disk data on eviction for restart. Use `--eviction-policy Delete` only for truly throwaway compute.
- Set `--max-price` below the confirmed Spot Linux meter unless the user chooses otherwise.
- Sync generated world data back locally after each dimension or bounded batch.
- Stop the Minecraft server cleanly with `save-all flush` and `stop`.
- Delete the resource group when work is complete unless the user explicitly wants it kept.

Before doing library/tool syntax lookups, follow the current AGENTS instruction for Context7 when Azure CLI, Fabric, Java, or other library docs are involved.

## Performance Tuning (Verified)

These optimizations brought CPS from ~3 to ~25 (overworld) and ~110 (End) on F2s_v2:

1. **GraalVM Java 25** — required by c2me-opts-natives-math, better JIT than OpenJDK 21
2. **Fabric Loader 0.19.3+** — required by c2me >= 0.4.0 and geckolib >= 4.9
3. **Remove client-only mods** — sodium, entity textures, minimap, EMI, etc. waste server resources
4. **c2me config tuned for pregen** — max parallelism, large caches, native acceleration, 10s mid-tick interval
5. **Correct MC server jar** — wrong version causes TinyRemapper "Unfixable conflicts" crash
6. **G1GC with 3200M heap** — ZGC fails on F2s_v2 (3.8GB RAM)

## Workflow

1. Inspect the local instance.
   - Identify Minecraft version, loader/modpack type, world path, `mods/`, `config/`, `defaultconfigs/`, `datapacks/`.
   - Measure world/mod sizes with `du -sh`.
   - Confirm `Chunky` and `fabric-api` are present or plan to add them.

2. Verify Azure constraints.
   - Check active subscription with `az account show`.
   - Check low-priority quota, total regional vCPU quota, and family quota.
   - Check Spot retail prices for candidate sizes.
   - Pick the fastest Spot size that fits both low-priority quota and family quota.
   - If the requested size fails quota, retry with the best smaller Spot size instead of regular billing.

3. Create the VM.
   - Use a dedicated resource group such as `rg-mc-pregen`.
   - Use SSH key auth.
   - Use Ubuntu LTS, Standard public IP, SSH NSG only.
   - Confirm VM properties after creation: `priority`, `evictionPolicy`, `billingProfile.maxPrice`, `powerState`, public IP.

4. Bootstrap the VM.
   - Install `tmux`, `rsync`, `curl`, `jq`, `unzip`, monitoring basics.
   - Add swap (4GB) to prevent OOM kills during large pregen jobs:
      ```bash
      sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile
      sudo mkswap /swapfile && sudo swapon /swapfile
      echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
      sudo sysctl vm.swappiness=1
      sudo sysctl vm.vfs_cache_pressure=25
      sudo sysctl vm.dirty_ratio=10
      sudo sysctl vm.dirty_background_ratio=5
      sudo sysctl vm.overcommit_memory=1
      ```
   - **Install GraalVM Java 25** (required by c2me-opts-natives-math):
     ```bash
     curl -L -o /tmp/graalvm.tar.gz 'https://download.oracle.com/graalvm/25/latest/graalvm-jdk-25_linux-x64_bin.tar.gz'
     tar -xzf /tmp/graalvm.tar.gz -C /tmp/
     sudo mv /tmp/graalvm-jdk-25* /opt/graalvm-jdk-25
     sudo update-alternatives --install /usr/bin/java java /opt/graalvm-jdk-25/bin/java 2500
     sudo update-alternatives --set java /opt/graalvm-jdk-25/bin/java
     ```
   - **CRITICAL: Download correct MC server jar version** — Fabric installer does NOT download it:
     ```bash
     MC_VER="1.21.1"  # adjust
     MANIFEST_URL=$(curl -s 'https://piston-meta.mojang.com/mc/game/version_manifest_v2.json' | jq -r ".versions[] | select(.id == \"$MC_VER\") | .url")
     SERVER_URL=$(curl -s "$MANIFEST_URL" | jq -r '.downloads.server.url')
     curl -L -o server.jar "$SERVER_URL"
     ```
     Wrong version causes TinyRemapper "Unfixable conflicts" crash.
   - **Install Fabric Loader >= 0.18.3** (required by c2me/geckolib):
     ```bash
     curl -L -o installer.jar 'https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar'
     java -jar installer.jar server -dir . -mcversion $MC_VER -loader 0.19.3
     ```
   - Create `eula.txt`, `server.properties`, and `run.sh`.
   - Use **GraalVM Java 25** (NOT Temurin) for better JIT throughput.
   - Use aggressive JVM flags with **G1GC** (ZGC fails on 3.8GB RAM — needs too much overhead):
        ```bash
        exec /opt/graalvm-jdk-25/bin/java -Xms3200M -Xmx3200M \
          -XX:+UseG1GC -XX:G1HeapRegionSize=16M -XX:MaxGCPauseMillis=50 \
          -XX:ParallelGCThreads=2 -XX:ConcGCThreads=2 \
          -XX:InitiatingHeapOccupancyPercent=30 \
          -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:+DisableExplicitGC \
          -XX:+UseStringDeduplication -XX:+OptimizeStringConcat \
          -XX:+ExitOnOutOfMemoryError \
          -jar fabric-server-launch.jar nogui
        ```
   - **CRITICAL: ZGC fails on F2s_v2 with 3600M heap** — `Failed to commit memory (Not enough space)`. G1GC with 3200M heap works reliably.
   - Size heap to ~3200M on F2s_v2 (3.8GB RAM). AlwaysPreTouch pre-allocates all pages at startup.
   - **Remove client-only mods** to `~/mc-server/mods/client_mods_backup/`:
     ```bash
     cd ~/mc-server/mods
     mkdir -p client_mods_backup
     mv sodium-fabric-*.jar sodium-extra-fabric-*.jar reeses-sodium-options-fabric-*.jar \
        entity_model_features-*.jar entity_texture_features_*.jar \
        continuity-*.jar citresewn-*.jar GpuTape-*.jar modelfix-*.jar \
        appleskin-fabric-*.jar emi-*.jar emi_enchanting-*.jar emi_loot-*.jar emi_ores-*.jar EMIProfessions-*.jar \
        modmenu-*.jar mousetweaks-*.jar \
        xaerominimap-*.jar xaeroworldmap-*.jar \
        zoomify-*.jar libIPN-*.jar shut_up_gl_error-*.jar \
        client_mods_backup/
     ```
     This alone improved CPS from ~3 to ~25 on overworld.
   - Write optimized c2me config (server-only, don't sync back):
     ```toml
     version = 3
     globalExecutorParallelism = 2
     defaultGlobalExecutorParallelismExpression = "max(1, min(cpus / 1.3, (mem_gb - 0.5) / 0.4))"
     threadPoolPriority = "max"

     [fixes]
     disableLoggingShutdownHook = true
     enforceSafeWorldRandomAccess = false

     [noTickViewDistance]
      maxConcurrentChunkLoads = 256
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
     enableBuiltinDFCIntegrations = true

     [vanillaWorldGenOptimizations.nativeAcceleration]
     enabled = true

     [generalOptimizations]
     midTickChunkTasksInterval = 10000

     [generalOptimizations.autoSave]
     mode = "PERIODIC"

     [chunkSystem]
     asyncSerialization = true
     recoverFromErrors = true
     allowPOIUnloading = true
     fluidPostProcessingToScheduledTick = true
     filterFluidPostProcessing = true
     lowMemoryMode = false
     suppressGhostMushrooms = true
     ```

5. Stage files.
   - Rsync the world to `~/mc-server/world/`, excluding `session.lock`.
   - Rsync `config/`, `defaultconfigs/`, and `datapacks/` when present.
   - Do not blindly copy every client mod if the dedicated server fails. Start with a server-focused set, then add hard dependencies reported by Fabric.
    - If world warnings show missing block registry keys for mods intentionally excluded, decide whether to add those mods back or accept recoverable fallback warnings.

### Mod Auditing for Wrong IDs

Many downloaded jars have mismatched filenames vs internal mod IDs. This causes silent failures on Fabric. Audit every jar before staging:

```bash
cd ~/mc-server/mods
for jar in *.jar; do
  id=$(unzip -p "$jar" fabric.mod.json 2>/dev/null | jq -r '.id // "NO_ID"' 2>/dev/null)
  mc=$(unzip -p "$jar" fabric.mod.json 2>/dev/null | jq -r '.depends.minecraft // "?"' 2>/dev/null)
  echo "$id|$mc|$jar"
done | sort
```

Red flags:
- `NO_ID` → Forge/NeoForge mod, incompatible with Fabric
- Internal ID not in filename → wrong jar downloaded
- MC version mismatch → incompatible mod
- Duplicate IDs → conflicting jars

Remove wrong-ID jars and re-download from Modrinth/CurseForge with verified versions.

6. Run and iterate.
   - Start the server in a persistent tmux session.
   - If the session exits, read `logs/latest.log` and `crash-reports/`.
   - Fix hard dependency failures by adding the named mod.
   - Fix OOM exits by lowering heap or adding swap. Avoid repeatedly restarting with the same failing heap.
   - Wait for `Done (...s)! For help, type "help"`.

7. Pregen in bounded passes.
   - Run one dimension at a time.
   - For large pregen jobs (radius > 1000), save and sync back between batches to protect against Spot eviction:
     - Batch 1: radius 1000, save, sync back
     - Batch 2: radius 2000, save, sync back
     - Batch 3+: increase radius incrementally
   - Chunky skips already-generated chunks, so batch boundaries are safe to overlap.
   - Use `chunky quiet 120` for large jobs (reduces server tick pressure during long runs).
   - Use `chunky quiet 30` for small jobs (< 1000 radius).
   - **Chunky dimension syntax** (common mistake — `chunky dimension` does NOT work):
     ```bash
     # Overworld (default, or explicit):
     chunky world Salterra
     chunky world minecraft:overworld

     # Nether:
     chunky world minecraft:the_nether

     # End:
     chunky world minecraft:the_end

     # Then set center/radius/shape and start:
     chunky center 0 0
     chunky radius 1200
     chunky shape circle
     chunky start
     ```
   - For square shapes: `chunky shape square` (covers more area but more chunks).
   - Monitor with `chunky progress` and `ps -C java`.
   - After each task finishes, run `save-all flush` and rsync the world back locally.
   - If the server watchdog kills the process (single tick > 60s), restart and use `chunky continue` with a higher quiet interval.
   - **Sync commands per dimension:**
     ```bash
     # Save and stop
     ssh azureuser@IP "tmux send-keys -t mc 'save-all flush' Enter && sleep 10 && tmux send-keys -t mc 'stop' Enter && sleep 15"

     # Sync overworld
     rsync -avz --delete --exclude 'session.lock' -e "ssh" azureuser@IP:~/mc-server/world/ ~/.minecraft/saves/World/

     # Sync nether
     rsync -avz --delete --exclude 'session.lock' -e "ssh" azureuser@IP:~/mc-server/world/DIM-1/ ~/.minecraft/saves/World/DIM-1/

     # Sync end
     rsync -avz --delete --exclude 'session.lock' -e "ssh" azureuser@IP:~/mc-server/world/DIM1/ ~/.minecraft/saves/World/DIM1/
     ```

8. Handle Spot interruption.
   - If SSH fails, check Azure VM state before assuming eviction:
     ```bash
     az vm show -g rg-mc-pregen -n mc-pregen-f2s -d --query '{power:powerState,publicIp:publicIps}' -o tsv
     ```
   - If VM is `running`, wait briefly and reconnect.
   - If VM is `deallocated` (eviction with Deallocate policy):
     ```bash
     az vm start -g rg-mc-pregen -n mc-pregen-f2s
     # Wait for VM to start, then reconnect and start server
     ssh azureuser@IP "cd ~/mc-server && tmux new-session -d -s mc './run.sh 2>&1 | tee -a logs/console.log'"
     # Chunky task state is lost, but region files are preserved
     # Use chunky continue if prior task exists, or start fresh (existing chunks skipped)
     ```
   - If VM was evicted with Delete policy (data lost):
     ```bash
     # Recreate VM, rsync world from LOCAL sync, restart
     az vm create --eviction-policy Deallocate ... # recreate with Deallocate this time
     rsync -av --delete --exclude 'session.lock' ~/.minecraft/saves/World/ azureuser@IP:~/mc-server/world/
     # Start server and continue pregen (existing chunks skipped)
     ```

9. Close out.
   - Run final `save-all flush`.
   - Rsync `~/mc-server/world/` back into the local save.
   - Send `stop` to the server and verify no Java process remains.
   - Either deallocate the VM with `az vm deallocate` (to keep for later) or delete the resource group with `az group delete --yes --no-wait`.
   - Report exact dimensions, radii, processed chunk counts, local world size, cleanup state, and any non-fatal mod warnings.

## Quick Status Check

For repeated status checks, combine all three in one call:

```bash
# VM status
az vm show -g rg-mc-pregen -n mc-pregen-f2s -d --query '{power:powerState,publicIp:publicIps}' -o tsv

# Chunky progress (fresh from logs, not stale pane output)
ssh azureuser@IP "grep 'Chunky.*Processed\|Chunky.*No tasks\|Chunky.*finished' ~/mc-server/logs/latest.log | tail -3"

# Memory
ssh azureuser@IP "free -h | head -2 && echo '---' && ps -o pid,pcpu,pmem,rss,cmd -C java | head -2"
```

## Expected Performance (F2s_v2, 2 vCPU, 3.8GB RAM)

| Dimension | Radius | Chunks | Time | CPS |
|-----------|--------|--------|------|-----|
| Overworld | 8,000 | 1,002,001 | ~2.5h | 15-25 |
| Nether | 2,000 | 63,001 | ~10m | 60-75 |
| End | 4,000 | 251,001 | ~33m | 100-120 |

The End is fastest (simpler worldgen), Nether is moderate, Overworld is slowest (structure mods, complex terrain).

## Common Errors (Non-Fatal)

- **"Failed to parse either..."** — c2me encountering NBT data from missing mods (ironshulkerbox, twilightforest, quark). Recoverable, skip safely.
- **"Block-attached entity at invalid position"** — Entities with Y coordinates below world floor. Common in deepslate structures. Recoverable.
- **"Unknown registry key"** — Missing mod blocks in chunk palette. c2me falls back to default blocks. Recoverable.
- **"Incompatible mods found"** — Check mod dependency requirements (e.g., c2me needs Fabric Loader >= 0.18.3).

## Helper Script

Use `scripts/azure_spot_mc_pregen.sh` for repeatable command shapes. Read or patch it when the run needs different names, regions, heap, or Minecraft versions.

Common examples:

```bash
scripts/azure_spot_mc_pregen.sh quota southeastasia
scripts/azure_spot_mc_pregen.sh price southeastasia Standard_F2s_v2
scripts/azure_spot_mc_pregen.sh create-vm rg-mc-pregen mc-pregen-f2s southeastasia Standard_F2s_v2 0.03
scripts/azure_spot_mc_pregen.sh bootstrap azureuser@IP 1.21.1
scripts/azure_spot_mc_pregen.sh send azureuser@IP "chunky progress"
scripts/azure_spot_mc_pregen.sh delete-rg rg-mc-pregen
```

## Reference

Read `references/runbook.md` when you need the full command sequence, mod filtering heuristics, or troubleshooting notes from the successful run.
