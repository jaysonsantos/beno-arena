# Beno Arena

- Write all game code in beni.
- Do not write TypeScript or JavaScript.
- Beni-generated JavaScript is the build output. Do not edit it.
- Prepare Cloudflare Workers with Durable Objects as the deployment target.
- Treat celld as an assessed alternative until the user selects it.
- Use only the APIs that beni core and its platforms provide.
- If an API is missing, search the open issues in `canassa/beni`.
- Add the game requirement to an existing issue, or open an issue with evidence and completion criteria.
- Use Cloudflare Workers and Durable Objects for local multiplayer.
- Keep the object tick selector pure. Keep one `Object.define` call.
- Use the pinned beni revision's Workers tools shell. Do not add a second tools pin.
- Check every client input with the shared schema.
- Change the checkpoint key version when the stored schema shape changes.
- Save dirty state before an arena becomes idle.
- Do not use `wrangler dev --remote`.
- Keep the arena preview visibly separate from live multiplayer.
- Keep project instructions in `AGENTS.md`.
- Use small commits with Conventional Commits messages.
- Keep the GitHub repository public at `jaysonsantos/beno-arena`.
- Use the production Wrangler environment for `beno-arena.jayson.com.br`.
- Keep deploy credentials in GitHub Actions secrets.
- Deploy main through `.github/workflows/deploy.yml`.
- Keep every required CI job in the `check` guard's `needs` list.
- Keep `check` as the only required merge status.
- Bind each test server to `127.0.0.1`. Stop it after the test.
- Do not change the beni compiler sources.
- Keep build output and scratch files in the project. Do not use `/tmp`.
- Check `free -g` before a heavy command. Wait if available memory is below 6 GB.
- Run heavy commands under the shared lock and memory limits from the task contract.
- Never use `pkill`, `killall`, or another command that kills processes by pattern.
- Before you kill a PID, check its full command and confirm that this task owns it.
- Write chat output and durable prose in ASD-STE100 Simplified Technical English.

Build and deployment instructions are in `README.md` and `docs/deployment.md`.

## Paths

| Path | Purpose |
|---|---|
| `game/` | Pure rules, interpolation, random state, and shared schemas |
| `server/` | Worker routing, the authoritative object, sockets, and checkpoints |
| `frontend/` | Beni lobby, separate SVG preview, live view, page shell, and CSS |
| `tests/` | Beni rule and transcript checks, plus driver steps |
| `nix/` | Pinned Zorg and beni compiler derivations |
| `scripts/` | Build, local server, lint, and browser checks |
| `build/page/` | Generated static assets |
| `docs/` | Capability evidence and deployment preparation |

## Commands

- Open the cached build and Worker tools: `devenv shell`.
- Use `devenv shell -- <command>` in workflows and script entry points.
- Build the compiler: `nix build .#beni`.
- Build the page and Worker: `scripts/build.sh`.
- Serve the page locally: `scripts/dev.sh`.
- Run lint: `scripts/lint.sh`.
- Run rule, local Worker, and browser checks: `scripts/test.sh`.
- Run both checks: `scripts/all.sh`.
- Package the static page: `nix build`.
- Deploy production: `scripts/deploy.sh`.
- Preview a build: `wrangler preview` with a current Wrangler release.
