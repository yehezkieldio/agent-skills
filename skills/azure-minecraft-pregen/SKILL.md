---
name: azure-minecraft-pregen
description: This skill should be used when the user asks to "pregen Minecraft chunks on Azure", "run Chunky on a Spot VM", "spin up a throwaway server to pregenerate my world", "sync generated region files back to my save", or wants to run Minecraft Java Fabric/Chunky world pregeneration on a short-lived Azure Spot VM while minimizing billing risk, handling Spot eviction/retry, and syncing region files back to a local world.
---

# Azure Minecraft Pregen

Run Minecraft Java Fabric/Chunky world pregeneration on a short-lived Azure Spot VM: stage local saves/mods/config onto the VM, run Chunky dimension-by-dimension, sync generated region files back incrementally, and tear the VM down cleanly.

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

These optimizations brought CPS from ~3 to ~25 (overworld) and ~110 (End) on F2s_v2. Apply all of them via `scripts/azure_spot_mc_pregen.sh bootstrap` — the reasoning for each is what matters here, the exact commands live in `references/runbook.md`:

1. **GraalVM Java 25**, not Temurin — required by c2me-opts-natives-math, better JIT than OpenJDK 21.
2. **Fabric Loader 0.19.3+** — required by c2me >= 0.4.0 and geckolib >= 4.9.
3. **Remove client-only mods** (sodium, entity textures, minimap, EMI, etc.) — they waste server resources; this alone improved CPS from ~3 to ~25 on overworld.
4. **c2me config tuned for pregen** — max parallelism, large caches, native acceleration, long mid-tick interval.
5. **Correct MC server jar version** — the Fabric installer does not download it; wrong version causes a TinyRemapper "Unfixable conflicts" crash.
6. **G1GC with a ~3200M heap**, not ZGC — ZGC fails on F2s_v2 (3.8GB RAM) with "Failed to commit memory."

## Workflow

1. Inspect the local instance.
   - Identify Minecraft version, loader/modpack type, world path, `mods/`, `config/`, `defaultconfigs/`, `datapacks/`.
   - Measure world/mod sizes with `du -sh`.
   - Confirm `Chunky` and `fabric-api` are present or plan to add them.

2. Verify Azure constraints.
   - Check active subscription with `az account show`.
   - Check low-priority quota, total regional vCPU quota, and family quota (`scripts/azure_spot_mc_pregen.sh quota <location>`).
   - Check Spot retail prices for candidate sizes (`scripts/azure_spot_mc_pregen.sh price <location> <size>`).
   - Pick the fastest Spot size that fits both low-priority quota and family quota.
   - If the requested size fails quota, retry with the best smaller Spot size instead of regular billing.

3. Create the VM.
   - Use a dedicated resource group and Spot VM via `scripts/azure_spot_mc_pregen.sh create-vm <rg> <vm> <location> <size> <max_price>`.
   - Confirm VM properties after creation: `priority`, `evictionPolicy`, `billingProfile.maxPrice`, `powerState`, public IP (the script already prints these).

4. Bootstrap the VM.
   - Run `scripts/azure_spot_mc_pregen.sh bootstrap <host> <mc_version>` — installs `tmux`/`rsync`/`curl`/`jq`, adds 4GB swap, tunes sysctls, installs GraalVM Java 25, and installs the Fabric server with the tuned `run.sh` and `config/c2me.toml`.
   - Read `references/runbook.md` for the exact command sequence and config file contents if the bootstrap needs adjusting for a different Minecraft version, heap size, or VM size.
   - Remove client-only mods before staging (see Performance Tuning #3). Move them to `~/mc-server/mods/client_mods_backup/` rather than deleting, so they can be restored if the dedicated server needs one back.

5. Stage files.
   - Rsync the world to `~/mc-server/world/`, excluding `session.lock`; rsync `config/`, `defaultconfigs/`, and `datapacks/` when present.
   - Do not blindly copy every client mod if the dedicated server fails to start. Start with a server-focused set, then add hard dependencies reported by Fabric.
   - If world warnings show missing block registry keys for mods intentionally excluded, decide whether to add those mods back or accept recoverable fallback warnings.

### Mod auditing for wrong IDs

Many downloaded jars have mismatched filenames vs. internal mod IDs, which causes silent failures on Fabric. Audit every jar before staging:

```bash
cd ~/mc-server/mods
for jar in *.jar; do
  id=$(unzip -p "$jar" fabric.mod.json 2>/dev/null | jq -r '.id // "NO_ID"' 2>/dev/null)
  mc=$(unzip -p "$jar" fabric.mod.json 2>/dev/null | jq -r '.depends.minecraft // "?"' 2>/dev/null)
  echo "$id|$mc|$jar"
done | sort
```

Red flags: `NO_ID` (Forge/NeoForge mod, incompatible with Fabric), internal ID not matching the filename (wrong jar downloaded), MC version mismatch, or duplicate IDs (conflicting jars). Remove wrong-ID jars and re-download from Modrinth/CurseForge with verified versions.

6. Run and iterate.
   - Start the server in a persistent tmux session with `scripts/azure_spot_mc_pregen.sh start-server <host>`.
   - If the session exits, read `logs/latest.log` and `crash-reports/`.
   - Fix hard dependency failures by adding the named mod. Fix OOM exits by lowering heap or confirming swap is active — avoid repeatedly restarting with the same failing heap.
   - Wait for `Done (...s)! For help, type "help"`.

7. Pregen in bounded passes.
   - Run one dimension at a time using `scripts/azure_spot_mc_pregen.sh send <host> "<chunky command>"`.
   - For large pregen jobs (radius > 1000), save and sync back between batches to protect against Spot eviction: e.g. radius 1000 → save → sync, then radius 2000 → save → sync, increasing incrementally. Chunky skips already-generated chunks, so batch boundaries are safe to overlap.
   - Use `chunky quiet 120` for large jobs (reduces server tick pressure during long runs), `chunky quiet 30` for jobs under 1000 radius.
   - **Chunky dimension syntax** — `chunky dimension` does not work; use `chunky world minecraft:overworld|minecraft:the_nether|minecraft:the_end`, then `chunky center`, `chunky radius`, `chunky shape circle|square`, `chunky start`. Square covers more area for the same radius but generates more chunks.
   - Monitor with `scripts/azure_spot_mc_pregen.sh capture <host>` (Chunky progress + `ps` for the java process).
   - After each task finishes, run `save-all flush` and rsync the world back locally. A world has three sync roots: the overworld at `world/`, the Nether at `world/DIM-1/`, and the End at `world/DIM1/` — each maps to the matching folder in the local save.
   - If the server watchdog kills the process (single tick > 60s), restart and use `chunky continue` with a higher quiet interval instead of starting over.

8. Handle Spot interruption.
   - If SSH fails, check Azure VM state before assuming eviction: `az vm show -g <rg> -n <vm> -d --query '{power:powerState,publicIp:publicIps}' -o tsv`.
   - If `running`, wait briefly and reconnect. If `deallocated` (eviction under the Deallocate policy), restart with `az vm start`, then `start-server` again — Chunky task state is lost but region files are preserved, so use `chunky continue` if a prior task exists, or start fresh (existing chunks are skipped either way).
   - If the VM was evicted under a Delete policy (data lost), recreate the VM with `--eviction-policy Deallocate`, rsync the world from the last local sync back onto it, and resume.

9. Close out.
   - Run final `save-all flush`, rsync `~/mc-server/world/` back into the local save, send `stop`, and verify no Java process remains.
   - Either deallocate the VM (`az vm deallocate`, to keep for later) or delete the resource group (`scripts/azure_spot_mc_pregen.sh delete-rg <rg>`).
   - Report exact dimensions, radii, processed chunk counts, local world size, cleanup state, and any non-fatal mod warnings.

## Expected Performance (F2s_v2, 2 vCPU, 3.8GB RAM)

| Dimension | Radius | Chunks | Time | CPS |
|-----------|--------|--------|------|-----|
| Overworld | 8,000 | 1,002,001 | ~2.5h | 15-25 |
| Nether | 2,000 | 63,001 | ~10m | 60-75 |
| End | 4,000 | 251,001 | ~33m | 100-120 |

The End is fastest (simpler worldgen), Nether is moderate, Overworld is slowest (structure mods, complex terrain). Use these as sizing estimates, not guarantees — they scale with VM size and mod count.

## Common Errors (Non-Fatal)

- **"Failed to parse either..."** — c2me encountering NBT data from missing mods (e.g. ironshulkerbox, twilightforest, quark). Recoverable, skip safely.
- **"Block-attached entity at invalid position"** — entities with Y coordinates below world floor, common in deepslate structures. Recoverable.
- **"Unknown registry key"** — missing mod blocks in the chunk palette; c2me falls back to default blocks. Recoverable.
- **"Incompatible mods found"** — check mod dependency requirements (e.g. c2me needs Fabric Loader >= 0.18.3).

## Additional Resources

- **`scripts/azure_spot_mc_pregen.sh`** — helper for every repeatable command shape (`quota`, `price`, `create-vm`, `bootstrap`, `install-fabric`, `start-server`, `send`, `capture`, `delete-rg`). Read or patch it when a run needs different names, regions, heap, or Minecraft versions.
- **`references/runbook.md`** — the full command sequence, exact config file contents (`run.sh`, `config/c2me.toml`, `server.properties`), mod filtering heuristics, and the known-good baseline from a completed run.
