# Snake Arena

- Write all game code in beni.
- Do not write TypeScript or JavaScript.
- Beni-generated JavaScript is the build output. Do not edit it.
- Prepare Cloudflare Workers with Durable Objects as the deployment target.
- Treat celld as an assessed alternative until the user selects it.
- Use only the APIs that beni core and its platforms provide.
- If an API is missing, search the open issues in `canassa/beni`.
- Add the game requirement to an existing issue, or open an issue with evidence and completion criteria.
- The user authorized frontend, CSS, and Zorg/Nix preparation after the capability report.
- Continue that preparation with existing APIs. Do not invent a network substitute.
- Keep the arena preview visibly separate from live multiplayer.
- Keep project instructions in `AGENTS.md`.
- Use small commits with Conventional Commits messages.
- Do not add a remote, push commits, create a repository, or deploy the game.
- Bind each test server to `127.0.0.1`. Stop it after the test.
- Do not change the beni compiler sources.
- Keep build output and scratch files in the project. Do not use `/tmp`.
- Check `free -g` before a heavy command. Wait if available memory is below 6 GB.
- Run heavy commands under the shared lock and memory limits from the task contract.
- Never use `pkill`, `killall`, or another command that kills processes by pattern.
- Before you kill a PID, check its full command and confirm that this task owns it.
- Write chat output and durable prose in ASD-STE100 Simplified Technical English.

The task contract is `/home/jayson/.local/state/beni-dispatch/snake-arena-prompt.md`.
Read it in full before work.

## Paths

| Path | Purpose |
|---|---|
| `frontend/` | Beni lobby, SVG preview, page shell, and CSS |
| `nix/` | Pinned Zorg and beni compiler derivations |
| `scripts/` | Build, local server, lint, and browser checks |
| `build/page/` | Generated static assets |
| `docs/` | Capability evidence and deployment preparation |

## Commands

- Open the tools: `nix develop`.
- Build the compiler: `nix build .#beni`.
- Build the page: `scripts/build.sh`.
- Serve the page locally: `scripts/dev.sh`.
- Run lint: `scripts/lint.sh`.
- Run browser checks: `scripts/test.sh`.
- Run both checks: `scripts/all.sh`.
- Package the static page: `nix build`.
- Do not release or deploy during this task.
