# Roblox Obby 001

Project 001 establishes the development workflow for a commercial Roblox obstacle course. The place contains a Studio-only Luau smoke test and has no course geometry.

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
| `src/server` | `ServerScriptService.ObbyServer` | Server-only scripts and authoritative state |
| `src/client` | `StarterPlayer.StarterPlayerScripts.ObbyClient` | LocalScripts for player input and presentation |
| `src/shared` | `ReplicatedStorage.ObbyShared` | Modules both sides can read |

Rojo maps `*.server.luau` to Scripts, `*.client.luau` to LocalScripts, and other `*.luau` files to ModuleScripts. Use tabs for Luau indentation, follow `.editorconfig`, and start Luau scripts with `--!strict`. Studio's Script Analysis provides Roblox-aware diagnostics.

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

Run `git diff --check` before staging and `git diff --cached --check` before committing. Keep this setup on `codex/initialize-obby-001` for review. After the repository owner selects a private GitHub destination, add its clone URL as `origin` and push the feature branch with `git push -u origin codex/initialize-obby-001`. An empty GitHub repository needs a separate review base before it can accept a pull request. Coordinate that base with the owner before merging.

See the [game design](docs/GAME_DESIGN.md), [roadmap](docs/ROADMAP.md), and [contributor instructions](AGENTS.md).
