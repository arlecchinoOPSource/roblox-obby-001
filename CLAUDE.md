# Contributor instructions

- Keep work on a feature branch and provide a reviewable summary before merging.
- Use native Luau. Keep modules small and add dependencies only when the assignment needs them. Pin any new development tools in `rokit.toml`.
- Edit mapped code under `src/`. Use `.server.luau` for server entry points, `.client.luau` for client entry points, and `.luau` for modules. Follow `.editorconfig` and use `--!strict`.
- Treat client input as untrusted. Keep authoritative progress, rewards, inventory, and purchase fulfillment on the server. Shared modules are visible to clients.
- Keep credentials, generated places, and local Studio saves out of Git. Use verified assets with documented provenance when assets enter scope.
- Run the Rojo build and Git whitespace checks before review. Follow [the test plan](docs/TEST_PLAN.md) for Studio behavior and state which checks were observed.
- This assignment ends at infrastructure and smoke verification. Course gameplay, live publishing, and real purchases need a separate assignment.
