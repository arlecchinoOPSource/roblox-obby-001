# Test plan

Run the commands in the repository root. The [README](../README.md) gives the complete workflow.

## Local checks

| Check | Pass condition |
| --- | --- |
| `rokit install` and `rojo --version` | Rokit resolves the project pin and Rojo reports 7.7.1 |
| `rojo build -o build/obby-001.rbxlx` | Rojo writes a place file after `build/` exists |
| `rojo sourcemap --output build/sourcemap.json` | The map lists a Script in ObbyServer, a LocalScript in ObbyClient, and a ModuleScript in ObbyShared |
| `rojo serve --address 127.0.0.1 --port 34872` | Rojo listens locally for Studio |
| `git diff --check` and `git diff --cached --check` | Both exit successfully with no whitespace errors |
| `git check-ignore build/obby-001.rbxlx build/obby-001-local.rbxl` | Both paths are ignored |

## Studio checks

| Check | Pass condition |
| --- | --- |
| Open the built place from disk | Explorer shows the three mapped folders and their scripts at the paths in the README |
| Connect the Rojo plugin | The plugin reports a connection to the local project |
| Play the place | Output shows the server and client messages ending in `v1`, with no errors from the project scripts |
| Change the shared message to `v2` between playtests | Studio receives the local edit and both messages end in `v2` on the next Play, without rebuilding |
| Restore `v1`, save to a local file, and reopen offline from Rojo | The saved place plays with both messages ending in `v1` while Rojo is disconnected |
| Check Script Analysis | The project scripts have no diagnostics |

If the plugin is missing, install the matching plugin and restart Studio. If it cannot connect, confirm that the terminal still shows Rojo listening on port 34872 and check the address in the plugin. If only the server message appears, use Play/Test, then check Output's client and server filters. For stale output, stop Play before editing, confirm the updated module source in Explorer, and start a fresh Play session.
