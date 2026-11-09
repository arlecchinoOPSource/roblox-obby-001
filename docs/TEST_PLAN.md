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

After building the greybox, confirm the course parts are not stacked at one point. Rojo accepts a `Position` property in model JSON but does not write it to the place, so use `CFrame`.

```sh
rojo build -o build/issue-4-greybox.rbxlx
python3 -I - build/issue-4-greybox.rbxlx <<'PY'
import sys
import xml.etree.ElementTree as ET

positions = set()
for item in ET.parse(sys.argv[1]).getroot().iter("Item"):
    if item.get("class") in ("Part", "SpawnLocation"):
        cf = item.find("Properties/CoordinateFrame[@name='CFrame']")
        if cf is not None:
            positions.add(tuple(round(float(cf.find(axis).text), 2) for axis in "XYZ"))
print("distinct part positions:", len(positions))
assert len(positions) > 100, "course parts are stacked at one point"
PY
```

Expect `distinct part positions: 128`.

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

Dependency: owner approved the Issue #3 brief and cleared Issue #2 in chat. The brief merged in PR #10, and the Issue #2 smoke evidence merged in PR #9. Issues #2 and #3 are closed. The greybox course merged in PR #11, and the owner accepted Issue #4 on 2026-11-09 (see the acceptance entry below).

Mapping: `src/course/Tower.model.json` → `Workspace.Tower`, added together with the project file and README mapping table. The model contains 21 landings: entrance Pad00, four stages of five landings, checkpoint marker Pad10, and finish Pad20. All geometry is native anchored primitives with built-in text/materials; no external assets. Gaps and striped edges mark fall hazards.

Build: `rojo build -o build/issue-4-greybox.rbxlx`. Open that fresh file and verify the model, default movement, readable cues, and traversal to the finish. Progress/recovery logic is excluded from this change; falling restarts at the entrance. Full desktop/touch-control and checkpoint behavior acceptance remain separate from automated movement checks.

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

### Issue #4 main-branch check — 2026-11-09

- Passed: after PR #13 merged, a fresh `rojo build` of `main` (commit `9f88b06`) has 128 course parts at 128 distinct positions. Its `src/` is identical to the branch verified in the position-fix entry above.
- Observed in Studio 0.746.0.7461269 (viewport only, Edit mode): the tower renders as separated landings around a central pillar, with the BLUE TOWER sign, the stage labels, a green CHECKPOINT 1 landing at Pad10 and a FINISH landing at Pad20. Hazard edges are 105 yellow stripe markers.
- Not observed: a person traversing the route with keyboard or touch input, and legibility of the small pad text and thin stripes at play distance. The finish landing color is dark amber (166, 115, 20) against the design's "gold"; judge it in play. The owner accepted Issue #4 afterwards (see the acceptance entry below).

### Issue #4 owner acceptance — 2026-11-09

- The owner playtested the course in Studio and said in chat that they are happy with Issue #4, then asked for checkpoint and respawn mechanics, which are Issue #5.
- The earlier pending items (keyboard or touch input by a person, legibility of the pad text and stripes, the finish color) were not recorded separately and were not observed by the agent. The owner's acceptance covers them. Touch layout is still reviewed in Issue #7.
- Issue #4 is closed.

## Issue #5 progression verification

Dependency: Issue #4 geometry is on `main` (PRs #11 and #13). The owner asked for the checkpoint, respawn, and finish mechanics in chat on 2026-11-09, which assigns Issue #5.

Build: `rojo build -o build/issue-5-progress.rbxlx`, open it in Studio, and use Play/Test (F5). Read `ObbyPad`, `ObbyCheckpoint`, and `ObbyCompleted` from the player's attributes, or watch the message at the top of the screen.

### Issue #5 status — 2026-11-09

Observed in Studio 0.746.0.7461269 with Rojo 7.7.1 builds, one local player, scripted Humanoid movement (`MoveTo` plus jumps) at WalkSpeed 16 / JumpPower 50:

- Passed: a fresh session started with pad 0, checkpoint 0, not completed, on the entrance. The progress RemoteEvent and the client message display were created.
- Passed: walking Pad01–Pad10 advanced progress in order. Landing on Pad10 set checkpoint 10.
- Passed: in a separate run with the client listener attached first, landing on Pad10 delivered "Checkpoint saved for this session." to the client and the label showed it (it had faded by the time it was read back, as designed after 3 seconds).
- Passed: after moving to Pad12, a drop 40 studs below it returned the character to Pad10 within one frame. Progress reset to 10, the checkpoint was kept, velocity was zero, and the character was grounded and Running. One `ObbyPad` change was recorded.
- Passed: setting Humanoid Health to 0 respawned the character on Pad10 after about 7.7 seconds with checkpoint 10 kept and the completion flag unchanged.
- Passed: teleporting onto Pad15 and then Pad20 while progress was 10 changed nothing (progress 10, not completed).
- Passed: walking Pad11–Pad20 set progress 20 and completed true. The client received "Tower complete." and showed it on screen.
- Passed: two rapid drops after completion produced two "Back at the checkpoint." messages (one per drop). A second climb to Pad20 did not send a second "Tower complete." message.
- Passed: stopping and restarting Play started a fresh session at pad 0 and not completed. A drop from Pad04 returned the character to the entrance with checkpoint 0.
- Passed: the Output window showed only the two smoke messages and the existing `rbxassetid://203785492` warning. No script errors.

Not observed:

- Two clients at once (Issue #6), including independent progress and adversarial input.
- A real rejoin by a second player. Restarting Play is the only evidence for a fresh session.
- Keyboard and touch input by a person, and touch layout (Issue #7). Scripted movement is not a control-scheme run.
- Script Analysis diagnostics for the new scripts. Run it in Studio before merging.
- Recovery timing with network latency. The one-second target was met locally with no added latency.

## Issue #6 two-client verification

Dependency: Issue #5 progress mechanics are on `main` (PR #15). The owner asked to begin Issue #6 in chat on 2026-11-09, which assigns it.

Steps to run when Studio can start two clients:

1. Build `rojo build -o build/issue-6-twoclient.rbxlx` and open the file in Studio.
2. In the Test tab choose Clients and Servers, set 2 players, and start. Name them A and B.
3. Check both players start with `ObbyPad` 0, `ObbyCheckpoint` 0, and `ObbyCompleted` false, on the entrance.
4. As A, climb to Pad10. Confirm B's attributes do not change and only A sees "Checkpoint saved for this session."
5. As A, repeat a Pad10 touch, fall, die and respawn. Confirm A returns to Pad10 and B is unchanged.
6. As A, climb to Pad20. Confirm A is completed once and B is not completed.
7. As B, try an out-of-order landing (for example Pad15) and a repeated Pad01 touch. Confirm the server ignores both.
8. Record the Studio version, steps, and results here. File a focused bug with reproduction steps for any failure.

### Issue #6 status — 2026-11-09

- Not observed at that time (superseded by the two-client entry below): the two-client run. The owner reported that every attempt to start a 2-player server test in Studio 0.746.0.7461269 showed "Studio is unable to connect. Check your network connection and try again." The test did not start, so no acceptance criterion that needs two live clients is verified. Issue #6 stays open.
- Passed (rules only, not clients): in Studio's Edit mode, two separate `ProgressRules` states A and B were driven through 19 checks with no failures. A's checkpoint, recovery, finish, repeat touches, and second climb did not change B, and B's skipped, repeated, and out-of-order landings changed nothing and never produced a finish. A fall by B before the checkpoint returned B to the entrance and left A at 20/10/completed.
- Read, not run: `Progress.server.luau` keeps all mutable state in a per-player session table keyed by `Player`, shares only constants, the tower reference, a RemoteEvent, and read-only raycast settings between players, and sends messages with `FireClient` to that session's player. This supports independence but is not a substitute for the two-client run.
- Still not observed: that real characters from two clients are tracked independently, that death, respawn, and the finish message reach only the right client, and that rejoining as a second player starts a fresh session.

### Issue #6 two-client run — 2026-11-09

Observed in Studio 0.746.0.7461269 with a local Clients and Servers test of 2 players (Player1, user ID -1, called A here; Player2, user ID -2, called B). The server had the tower, the progress scripts, and the `ObbyProgress` RemoteEvent, and both clients had the message display. Rojo was not connected; the scripts came from the opened place.

Method: each player's movement (`MoveTo`, jumps, and the `CFrame` changes used for falls and skipped landings) was run from that player's own client, which owns its character. The server was used to read `ObbyPad`, `ObbyCheckpoint`, and `ObbyCompleted`, and to set Humanoid Health to 0. A server-side `MoveTo` on a client-owned character did not move it, so the test does not use that. Messages were collected with a listener on each client's `OnClientEvent`.

- Passed: both players started at pad 0, checkpoint 0, not completed, on the entrance.
- Passed: A walked Pad01–Pad10 and reached pad 10, checkpoint 10. A's client received "Checkpoint saved for this session." B stayed 0/0/not completed and received nothing.
- Passed: A jumped repeatedly on Pad10. Progress stayed 10/10 and no second checkpoint message arrived.
- Passed: A walked to Pad12 and dropped 45 studs below it. A returned to Pad10 (y 33.5, speed 0) with the checkpoint kept. B was unchanged.
- Passed: setting A's Humanoid Health to 0 respawned A on Pad10 after 6.1 seconds (and 7.0 seconds on a later repeat) with checkpoint 10 kept. B kept its original character and stayed 0/0.
- Passed: A walked Pad11–Pad20. A reached pad 20 and completed true, and its screen showed "Tower complete." B stayed not completed and received no finish message.
- Passed: B moved itself onto Pad15 and then Pad20 and stood for 2.5 seconds each. Both landings were ignored (progress 0, not completed).
- Passed: B walked onto Pad01, back to Pad00, and onto Pad01 again. Progress was 1 and advanced once. B then walked Pad02–Pad04 (progress 4).
- Passed: B dropped 45 studs below Pad04 before any checkpoint and returned to the entrance (pad 0, checkpoint 0, y 3.5) with one "Back at the entrance." message. A stayed 10/10/completed.
- Passed: A's client never received B's messages, and B's client never received A's.

Findings:

- Respawn message: after each death A also received "Back at the checkpoint.", which is the fall-recovery message. A controlled death with no fall raised A's count of that message from 3 to 4, and progress was correct. Cause not established. A likely cause is that the respawned character starts on the entrance, below the fall boundary measured from the checkpoint pad, so the fall check can fire before the respawn placement. A death should not look like a fall, and the design asks for one recovery per failure.
- Not explained: during the first server-driven movement attempts, A received "Back at the entrance." seven times and never held progress. This was not reproduced with client-driven movement.
- Not explained: the first kill of A showed no new character within 14 seconds, although A was alive at 100 health when checked afterward. Repeats respawned in 6.1 and 7.0 seconds.

Not observed:

- A second player leaving and rejoining. The 2-player test cannot reconnect a client, so a fresh session on rejoin is still evidence from stopping and restarting Play only.
- Keyboard and touch input by a person. Movement here was scripted from the clients.
- Latency, more than two clients, and adversarial input other than a client moving its own character.
- Script Analysis diagnostics for the progress scripts.

## Issue #7 first-run clarity on desktop and touch

Dependency: Issue #5 progress mechanics are on `main` (PR #15). The owner asked to begin Issue #7 in chat on 2026-11-09, which assigns it.

Steps: open a fresh build in Studio, use the device emulator in the viewport toolbar (desktop "Current device", then phone mode and a preset), and Play/Test. On each setup, complete the course from the entrance to Pad20 using only that control scheme. Check that the checkpoint, respawn, finish, and fall messages are legible and that no interface element covers the touch thumbstick or jump button. Record the preset, the viewport, and the orientation. Record physical-device results separately from emulation.

### Issue #7 status — 2026-11-09

Observed in Studio 0.746.0.7461269 with a build of `main` plus the PR #20 respawn fix (`fix-respawn.rbxlx`). This is a partial run: neither control scheme was used to complete the whole course.

Touch emulation (phone mode, preset iPhone 17 Pro, landscape; the client reported `TouchEnabled` true and a `ViewportSize` of 750 × 381):

- Layout: the client's touch controls were the jump button at (655, 233) sized 70 × 70 and a dynamic thumbstick frame on the left. The progress message label was at (215, 16) sized 320 × 44, top centre. In a screenshot of the playing viewport the label sat clear of the Roblox menu icons, the thumbstick, and the jump button.
- Messages: "Back at the entrance." appeared on screen and was readable at this size. The checkpoint message text was set by a test script to check layout, not earned by landing, so only its placement was checked.
- Touch input: pressing and dragging up on the on-screen thumbstick with the mouse moved the character off the entrance edge. The character fell, was recovered to the entrance, and the fall message appeared.
- Stage text on the pad (START / CHECKPOINT 0) was readable when the camera was near the entrance.

Desktop controls (the Mac keyboard path, "Current device" desktop preset, via Studio's keyboard input tool):

- Passed: holding W for 0.5 seconds moved the character 9.3 studs, and Space raised it 7.2 studs.

Findings:

- Friction, observed: the "BLUE TOWER" sign is a 280 × 100 pixel BillboardGui with AlwaysOnTop and MaxDistance 65. At the spawn on the phone preset it covered roughly a quarter of the screen width beside the thumbstick and hid part of the first stage. A candidate fix is a smaller sign, a shorter MaxDistance, or turning off AlwaysOnTop.
- Risk, calculated and not observed: the message label is a fixed 320 pixels wide and centred. Here its left edge was about 20 pixels from the end of the Roblox menu icons, so a viewport narrower than roughly 710 pixels would overlap them. A scaled width with a maximum, or a position to the right of the menu icons, would avoid this. A narrower preset would confirm it.
- No fixes are required to leave the course as it is for the observed setups. The two items above are candidates for review before release.

Not observed:

- Completing the course with the keyboard, or with the touch controls, from the entrance to Pad20. Movement was checked in short segments only.
- Any physical device, and any other preset, portrait orientation, or tablet.
- Legibility on a real phone screen. The screenshot was taken on a Mac display.
- The checkpoint and finish cues in the phone view as earned in play.
- Script Analysis diagnostics for the progress scripts.
