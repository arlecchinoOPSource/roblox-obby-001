# Game design

## Approved first playable prototype

The owner approved the Issue #3 brief and cleared Issue #2 in chat on 2026-11-08, then requested Studio implementation. The approved defaults are a blue training tower, four beginner stages, one earned checkpoint, default movement, desktop keyboard/mouse and landscape phone touch emulation. Physical-device usability is not established by emulation.

The route starts at checkpoint 0, climbs broad ascending landings and short gaps in stages 1–2, earns checkpoint 1 halfway, then follows offset landings and a turning ascent through stages 3–4 to a distinct finish. Each numbered stage contains five landings. These internal route markers are not additional checkpoints. Platforms start at 9 × 9 studs, with 2-stud gaps and 3-stud rises, winding around a central tower support.

Use visible stage numbers, direction cues, striped hazard edges, a START sign, a green CHECKPOINT landing, and a gold FINISH landing. Text accompanies color. Only native Roblox primitives, built-in materials, and text are proposed; no external asset IDs, models, textures, or audio are used by the course.

## Session behavior

The server owns route order, checkpoints, recovery, and finish. Grounded landings must match the next expected route marker, the current character, plausible sampled movement, and landing proximity. Touches and client presentation cannot authorize progress. Duplicate or out-of-order landings cannot advance progress or complete twice.

A fall before checkpoint 1 returns to the entrance; a later fall returns to checkpoint 1. Death and reset preserve the earned checkpoint. Recovery resets intermediate route markers to the checkpoint and clears velocity. The configurable fail depth starts 20 studs below the current safe landing; tune it to permit intended lower landings and catch falls before lower floors. Target controllable recovery within one second of server detection in a local playtest. Repeated failures must cause one recovery per failure.

A valid finish records session completion once and displays “Tower complete.” No reward is granted. Leaving and rejoining clears progress and completion and starts at the entrance.

## Repeatable acceptance run

Run separately with desktop controls and Studio touch emulation:

1. Start a fresh session at checkpoint 0.
2. Traverse stages 1–2 and verify “Checkpoint saved for this session.”
3. Begin stage 3 and deliberately fall past the fail boundary.
4. Verify exactly one recovery at checkpoint 1, retained progress, and controllable movement within the one-second target; record measured timing.
5. Traverse stages 3–4 and verify one finish confirmation.
6. Leave and rejoin; verify checkpoint 0 and cleared completion.

Record the exact touch preset, viewport, orientation, and Studio version. Complete the touch run with emulated movement/jump controls. Additional checks cover repeated touches, rapid falls, death/reset, and duplicate/out-of-order progress. Two-client isolation, adversarial testing, and polish are separate Issues #6–7.

## Deferred tower target

Ten playable areas: Blue, Cyan, Neon Yellow, Yellow, Orange, Red, Dark Red, Purple, Dark Purple, White. Ten obstacles and earned checkpoints per area yield checkpoint IDs 1–100. Entrance checkpoint 0 and the Black summit/reward trigger remain separate. Expand difficulty gradually from wide platforms to tighter landings, moving obstacles, and timing combinations, retaining default desktop/touch movement.

Persistence requires versioned stable checkpoint IDs by UserId, a valid load before progression, distinct missing/failed loads, monotonic UpdateAsync writes, bounded retries, budget-aware saves, and best-effort leave/shutdown saves. Protect existing data during errors and reject stale rollback. Test failures with local mocks before authorized tests isolated from production data; normal rejoin and cross-server restoration must restore the highest saved checkpoint.

After checkpoint 100 and a verified summit crossing, grant session access to every approved shop gear item. Access survives death, clears on leave, and requires crossing the summit again after rejoining at checkpoint 100. Gear effects default to a separate opt-in arena; protect the climb, checkpoints, and spawns. Exclude temporary gear from trading and permanent inventory. All future assets need verified provenance.

Stage-skip offers and all purchase code remain deferred. The later proposal is a dismissible offer after eligible recovery, with cooldown and immediate free retry, targeting a 2-Robux base price. Show actual player pricing. Before launch define delayed-receipt behavior after advancement, completion, or server changes; durable, idempotent server ProcessReceipt fulfillment must be keyed by purchase ID. Issue #8 may review this after multiplayer/touch verification. Expansion, persistence, gear, publishing, and real purchases require separate assignments or authorization.
