# Snake Arena

A multiplayer snake game frontend in beni.
The current page includes a lobby and an illustrative arena.
Choose a name and color, open the guide, or change the preview controls.
Live multiplayer still needs upstream platform APIs.

All application source is beni.
The build produces JavaScript. The project contains no hand-written JavaScript or TypeScript.

## Run

```sh
nix develop
scripts/dev.sh
```

Open `http://127.0.0.1:4173`.
Press Ctrl-C to stop the local server.
After a source change, stop and restart the command.

The first shell start builds the pinned beni compiler with Zorg.
The shell does not build the game or run its tests.

## Configure

| Variable | Default | Purpose |
|---|---|---|
| `SNAKE_PORT` | `4173` | Local preview port |
| `CHROMIUM_PATH` | `chromium` | Browser binary for tests; set this on macOS |

For direnv, create a local `.envrc`:

```sh
dotenv_if_exists
use flake
```

Run `direnv allow`.
Copy `.env.example` to `.env` if you need local settings.
The server always binds to `127.0.0.1`.

## Develop

```sh
scripts/build.sh
scripts/lint.sh
scripts/test.sh
scripts/all.sh
```

The scripts enter the Nix shell if the pinned tools are not active.
The browser check builds the page, checks its generated modules, and checks its actual rendered HTML.
It uses a temporary local port and stops its server when it exits.

Format beni sources with `beni fmt frontend`.
Install the local commit hooks with `prek install`.
CI uses the same scripts.

| Path | Purpose |
|---|---|
| `frontend/` | Beni frontend, CSS, page shell, and licensed fonts |
| `nix/` | Zorg and beni compiler derivations |
| `scripts/` | Local development and checks |
| `build/page/` | Generated browser assets |
| `docs/` | Capability evidence and deployment design |

## Package

```sh
nix build .#beni
nix build .#frontend
```

`nix build` also builds the frontend package.
The output contains the page, generated modules, CSS, and local fonts.
The font licenses remain beside the fonts.

There is no release or deployment command yet.
See the [deployment design](docs/deployment.md) for Cloudflare Workers, Durable Objects, and the celld assessment.
See the [capability check](docs/capabilities.md) for the remaining API issues.
