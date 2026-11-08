# Roblox Obby 001

Roblox Obby 001 is the foundation for a planned commercial obstacle course. The current milestone proves the path from local Luau source to a playable Studio test place. The place contains a Studio-only smoke test and has no course geometry. The local Rojo build and file watcher have passed. The [test plan](docs/TEST_PLAN.md#verification-status) tracks the remaining Studio checks.

## Start here

| File | What it covers |
| --- | --- |
| [AGENTS.md](AGENTS.md) and [CLAUDE.md](CLAUDE.md) | The same contributor instructions for Codex and Claude Code |
| [default.project.json](default.project.json) and [rokit.toml](rokit.toml) | Studio instance mappings and the pinned Rojo version |
| [Game design](docs/GAME_DESIGN.md) | The smoke test, proposed player loop, and open design decisions |
| [Roadmap](docs/ROADMAP.md) | What belongs in each milestone and how to verify it |
| [Test plan](docs/TEST_PLAN.md) | Repeatable checks, expected results, and current evidence |

While the initial setup is under review, clone its feature branch. Once the setup lands on `main`, a regular clone will pick it up.

```sh
git clone --branch codex/initialize-obby-001 https://github.com/arlecchinoOPSource/roblox-obby-001.git
cd roblox-obby-001
```

## Prerequisites

Install Git, Roblox Studio, and [Rokit](https://github.com/rojo-rbx/rokit). Run these commands from the repository root:

```sh
rokit trust rojo-rbx/rojo
rokit install
rojo --version
```

Expect `Rojo 7.7.1`, pinned in [rokit.toml](rokit.toml). Review the [official release](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1) before trusting the publisher. If Studio needs the matching plugin, close Studio, run `rojo plugin install`, then reopen Studio. That command replaces an existing Rojo-managed plugin.

## Source layout

| Local source | Studio destination | Purpose |
| --- | --- | --- |
| [src/server](src/server) | `ServerScriptService.ObbyServer` | Server-only scripts and authoritative state |
| [src/client](src/client) | `StarterPlayer.StarterPlayerScripts.ObbyClient` | LocalScripts for player input and presentation |
| [src/shared](src/shared) | `ReplicatedStorage.ObbyShared` | Modules both sides can read |

Rojo maps `*.server.luau` to Scripts, `*.client.luau` to LocalScripts, and other `*.luau` files to ModuleScripts. Use tabs for Luau indentation, follow `.editorconfig`, and start Luau scripts with `--!strict`. Studio's Script Analysis provides Roblox-aware diagnostics.

The [shared smoke module](src/shared/SmokeTest.luau) supplies the message used by the [server entry point](src/server/SmokeTest.server.luau) and [client entry point](src/client/SmokeTest.client.luau). Both entry points check `RunService:IsStudio()` before logging. A single message edit exercises the shared, server, and client mappings.

## Build, sync, test, and save

1. Build a local place from the repository root.

   ```sh
   mkdir -p build
   rojo build -o build/obby-001.rbxlx
   ```

   In PowerShell, use `New-Item -ItemType Directory -Force build` to create the directory.

2. In Studio, open `build/obby-001.rbxlx` from your computer. Use this local place for the smoke test.
3. Start Rojo in a terminal and leave it running.

   ```sh
   rojo serve --address 127.0.0.1 --port 34872
   ```

4. In Studio's **Plugins** tab, open **Rojo** and connect to `localhost:34872`. If Studio offers a preview, check that the changes are limited to this project.
5. Open **Output** and run **Play/Test** (F5). Expect both `[Obby 001][Server] Rojo smoke v1` and `[Obby 001][Client] Rojo smoke v1`. **Run** alone does not create a player for the LocalScript.
6. Stop the playtest. With Rojo still connected, change `Rojo smoke v1` to `Rojo smoke v2` in `src/shared/SmokeTest.luau` and save the file. Play again without rebuilding or reopening the place. Both messages should now end in `v2`. Stop, restore `v1` on disk, and confirm Studio receives the restored source.
7. In Studio use **File → Save to File As…** and save a local copy as `build/obby-001-local.rbxl`. Reopen it with Rojo disconnected and Play to check the saved copy. Stop the session and disconnect Rojo, then press Ctrl+C in the server terminal.

Treat the files under `src/` as the source of truth. Rojo syncs disk changes into Studio. Studio edits to mapped scripts do not write back to Git. Build outputs and local place saves are ignored by Git. See the [test plan](docs/TEST_PLAN.md) for expected results and troubleshooting.

## Review and GitHub

Run `git diff --check` before staging and `git diff --cached --check` before committing. Keep each assignment on a feature branch and open a pull request for review before merging. Include a short summary of what changed, which checks ran, and any Studio checks still pending. Review the initial setup in [draft PR #1](https://github.com/arlecchinoOPSource/roblox-obby-001/pull/1).
