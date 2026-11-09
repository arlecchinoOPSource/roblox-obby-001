# Test plan

Run the commands in the repository root. The [README](../README.md) gives the complete workflow.

## Verification status

| Check | Project 001 result |
| --- | --- |
| Pinned tools and build | Passed on Apple silicon macOS with Rokit 1.2.0 and Rojo 7.7.1 |
| Source map and built place | Passed. The smoke test scripts were mapped to the expected Roblox classes, and the built place contained the shared message |
| Rojo file watcher | Passed. The loopback Rojo server served a temporary `v2` edit without a rebuild. The source was restored to `v1` |
| Fresh build in Studio | Passed on Studio 0.746.0.7461269 with Rojo 7.7.1. Opened `build/issue-2-fresh.rbxlx` and verified the shared ModuleScript, server Script, and client LocalScript at their mapped DataModel paths. |
| Baseline playtest | Passed. Play/Test on the fresh build produced both `[Obby 001][Server] Rojo smoke v1` and `[Obby 001][Client] Rojo smoke v1`. Output showed no script errors. Studio warned that `rbxassetid://203785492` did not match the requested asset type. |
| Live Rojo sync in Studio | Passed. The Rojo plugin connected to `localhost:34872`. Both scripts logged `v1`, then both logged `v2` after a disk-only change to the shared module, without rebuilding or reopening. Studio received `v1` again after the source was restored. |
| Save and reopen offline | Passed. Studio saved `build/issue-2-saved.rbxl`. After Rojo stopped, Studio reopened the file and both scripts logged `v1` in Play/Test. Studio displayed a file-in-use or read-only warning on reopen. The warning did not prevent the playtest. |
| Script Analysis | Passed. The reopened `issue-2-saved.rbxl` showed zero errors, warnings, information messages, and hints with the current-script filter off. |

## Local checks

| Check | Pass condition |
| --- | --- |
| `rokit install` and `rojo --version` | Rokit resolves the project pin and Rojo reports 7.7.1 |
| `rojo build -o build/obby-001.rbxlx` | Rojo writes a place file after `build/` exists |
| `rojo sourcemap --output build/sourcemap.json` | The map lists a Script in ObbyServer, a LocalScript in ObbyClient, and a ModuleScript in ObbyShared |
| `rojo serve --address 127.0.0.1 --port 34872` | Rojo listens locally for Studio |
| `git diff --check` and `git diff --cached --check` | Both exit successfully with no whitespace errors |
| `git check-ignore build/obby-001.rbxlx build/obby-001-local.rbxl` | Both paths are ignored |
| `git diff --no-index -- AGENTS.md CLAUDE.md` | Both copies of the contributor instructions match |

## Studio checks

| Check | Pass condition |
| --- | --- |
| Open the built place from disk | Explorer shows the three mapped folders and their scripts at the paths in the README |
| Connect the Rojo plugin | The plugin reports a connection to the local project |
| Play the place | Output shows the server and client messages ending in `v1`, with no errors from the project scripts |
| Change the shared message to `v2` between playtests | Studio receives the local edit and both messages end in `v2` on the next Play, without rebuilding |
| Restore `v1`, save to a local file, and reopen offline from Rojo | The saved place plays with both messages ending in `v1` while Rojo is disconnected |
| Check Script Analysis | The project scripts have no diagnostics |

If the plugin is missing, install the matching plugin and restart Studio. If it cannot connect, confirm that the terminal still shows Rojo listening on port 34872 and check the address in the plugin. If only the server message appears, use Play/Test, then check Output's client and server filters. For stale output, stop Play before editing, confirm the updated module source in Explorer, and start a fresh Play session. The smoke test pass condition is the two Output messages. The generated place has no course geometry.

## Issue #4 greybox verification

Dependency: owner approved the Issue #3 brief and cleared Issue #2 in chat. The brief is under review in PR #10; this branch is based on that brief. The Issue #2 GitHub issue remains open, with smoke evidence in PR #9.

Mapping: `src/course/Tower.model.json` → `Workspace.Tower`, added together with the project file and README mapping table. The model contains 21 landings: entrance Pad00, four stages of five landings, checkpoint marker Pad10, and finish Pad20. All geometry is native anchored primitives with built-in text/materials; no external assets. Gaps and striped edges mark fall hazards.

Build: `rojo build -o build/issue-4-greybox.rbxlx`. Open that fresh file and verify the model, default movement, readable cues, and traversal to the finish. Progress/recovery logic is excluded from this branch; falling restarts at the entrance. Full desktop/touch-control and checkpoint behavior acceptance remain separate from automated movement checks.

### Issue #4 status — 2026-11-08

- Passed: pinned Rojo 7.7.1 build to `build/issue-4-greybox.rbxlx`; built XML confirms all 21 route landings, entrance SpawnLocation, and only the original smoke scripts. No progression scripts are included.
- Passed: Git whitespace checks. Course geometry is reused unchanged from the earlier local prototype commit `70ee178`, where automated Humanoid movement at default WalkSpeed 16 / JumpPower 50 traversed all 20 landings. This is historical evidence for the same geometry, not a new standalone-build Play run or a keyboard/touch input run.
- Pending: opening and traversing this fresh geometry-only build in Studio. Launch was requested, but Studio still showed the existing `obby-001.rbxlx` Play session; that session was left untouched. Do not mark the fresh-build Studio acceptance complete.
- Pending: inspect stage text, striped hazard edges, checkpoint and finish cues in that fresh build. Full desktop/touch input verification remains explicitly unobserved.

### Issue #4 position fix — 2026-11-09

- Found: the merged `Tower.model.json` set `Position` on every part. Rojo accepts that property but does not write it to the place, so a Studio check of the main-branch build showed all 128 parts at the origin (one distinct position) and no route.
- Fixed: each part now sets `CFrame` with the tagged form `{"CFrame": {"position": [...], "orientation": [[1,0,0],[0,1,0],[0,0,1]]}}`, which Rojo 7.7.1 builds correctly. Positions and sizes are unchanged from the earlier model.
- Passed: Rojo 7.7.1 build of the fixed model has 128 distinct part positions, Pad00 at (0, 0, 0) and Pad20 at (11, 60, -33). Measured in Studio 0.746.0.7461269: maximum rise between landings 3 studs and maximum edge gap 2 studs.
- Passed: Play/Test of the fixed build. The player spawned on Pad00 at WalkSpeed 16 / JumpPower 50, and scripted Humanoid movement (MoveTo plus jumps) reached Pad20 with health 100. Both smoke messages printed. Studio again logged the unrelated `rbxassetid://203785492` asset-type warning.
- Still pending: a person traversing the route with keyboard or touch input, visual review of the cues, and the checkpoint and finish behavior in Issue #5. This run was scripted movement, not a desktop or touch-control run.
