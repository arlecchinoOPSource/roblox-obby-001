# Game design

Roblox Obby 001 is a planned obstacle-course game. Project 001 verifies the development workflow with a Studio-only startup message on the server and on each playing client. Both entry points read the message from a shared Luau module so a single local edit can prove synchronization.

## Future prototype

The proposed first playable loop is to spawn at the start, traverse a short course, respawn at an earned checkpoint after failure, and reach a finish. Course theme, stage count, persistence, rewards, and monetization remain open design decisions.

The server will validate checkpoint and completion claims and own rewards and any future purchase fulfillment. The client will handle input, presentation, and feedback. Replicated modules may contain shared definitions that are safe for all players to inspect.
