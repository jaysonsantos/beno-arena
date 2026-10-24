# Beno Arena

A small multiplayer snake game in beni.
Play at [beno-arena.jayson.com.br](https://beno-arena.jayson.com.br).
One Cloudflare Durable Object owns each arena.
The browser sends input and draws interpolated SVG snapshots from the server.
The client buffers 150 milliseconds of snapshots to absorb network gaps and packet bursts.
Steering input still leaves the client on the next input tick.

Eat food to grow. Avoid all snake bodies, including your own, and the arena wall.
A dead snake becomes food. Choose **Rejoin arena** in the game screen to play again.
You keep your name, color, and full screen view.
The score list shows the five longest live snakes.
The initial arena remains a separate illustration until you connect.

![Beno Arena lobby with a separate arena preview and player controls.](docs/screenshot.png)

All game source and test assertions use beni.
The compiler produces JavaScript. Do not edit that output.
The tests reuse beni's unchanged Miniflare driver.

## Run locally

```sh
nix develop .#workers
scripts/dev.sh
```

Open `http://127.0.0.1:4173` in two browser tabs.
Choose a color in each tab. Enter a name, or leave it empty for a random guest name.
Choose **Enter arena**.
Move the pointer, drag a finger, or use the arrow keys.
Choose **Leave arena** to return to the preview.
Press Ctrl-C in the terminal to stop the local Worker.

The shell builds the pinned beni compiler with Zorg on its first use.
The `workers` shell takes Wrangler and Miniflare from that beni revision's own shell.
It adds no second tools pin. The server listens on `127.0.0.1`.
The command uses local workerd. It needs no Cloudflare account.

## Configure

| Variable | Default | Purpose |
|---|---|---|
| `BENO_PORT` | `4173` | Local Worker port |
| `CHROMIUM_PATH` | `chromium` | Browser binary for render checks |

The browser uses `/arena/main/ws`.
The Worker maps each `/arena/<name>/...` route to one named object.
Different arena names use separate state and scores.
The object permits at most 16 sockets.
It runs one simulation step every 50 milliseconds while a snake lives.

The `.envrc` file stays local:

```sh
dotenv_if_exists
eval "$(devenv direnvrc)"
use devenv
```

After you read that file, run `direnv allow`.
You can also run `devenv shell`.
The devenv shell contains the `workers` shell from the flake.
It pulls beni and Zorg from the `jaysonsantos` Cachix cache.
When `CACHIX_AUTH_TOKEN` is set, it pushes new builds to that cache.
The flake keeps the only beni pin.

You can also use `use flake` in `.envrc`.
The default shell supports builds and lint. The `workers` shell also supports local Worker tests.

## Develop

```sh
scripts/build.sh
scripts/lint.sh
scripts/test.sh
scripts/all.sh
scripts/benchmark.sh
```

The scripts select the required Nix shell when necessary.
`test.sh` checks fixed-seed rules, the local Worker with several clients, and desktop and mobile renders.
The Worker checks every client message with the shared schema.
Clients cannot set a snake's position, length, score, or simulation tick.
They send only a join request or an aim point.
The object retains each player's newest aim point and applies it on the next tick.
It accepts at most one join request per player per tick.
The shared Color schema represents each color by name, such as `{"name":"moss"}`.

The compiler pin includes the peer-close fix from [beni PR #819](https://github.com/canassa/beni/pull/819).
The socket checks wait for each aim event before they advance a manual tick.
See the [check results](docs/checks.md).

| Path | Purpose |
|---|---|
| `game/` | Pure rules, seeded random state, and shared schemas |
| `server/` | Worker routing, the authoritative object, sockets, and checkpoints |
| `frontend/` | Lobby, separate preview, live SVG view, CSS, and local fonts |
| `tests/` | Beni rule and transcript checks, plus driver steps |
| `scripts/` | Build, lint, local server, and checks |
| `nix/` | Zorg and beni compiler derivations |
| `build/` | Generated pages, Worker modules, and test programs |
| `.scratch/` | Local caches, transcripts, logs, and screenshots |

Format the source with `beni fmt game server frontend tests`.
Install commit hooks with `prek install`.
CI runs the same scripts.
The `check` guard waits for lint, tests, and build. Branch rules require that guard before a pull request can merge.
Renovate enables automatic merge for minor, patch, pin, and digest updates after the guard passes.

## Package

```sh
nix build .#frontend
nix build .#worker
```

`nix build` also builds the static frontend package.
The output keeps each font license beside its font.
There is no version release command.

## Deploy

Every push to `main` runs `.github/workflows/deploy.yml`.
The workflow checks the rules and runs `scripts/deploy.sh` with the pinned Workers tools.
Wrangler runs `scripts/build.sh` before it uploads the page and Worker.
The production environment uses `beno-arena.jayson.com.br` and its own compatibility date.
Set the `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN` repository secrets before the first workflow deployment.
The API token needs the Edit Cloudflare Workers permissions for the deployment account and domain.

For an authenticated local deployment, run `scripts/deploy.sh`.
For a branch preview, run `wrangler preview` with a current Wrangler release.
The preview uses a separate Durable Object namespace and storage.
The CI test job checks peer closes and input order. The deploy workflow checks the rules before deployment.
See the [deployment notes](docs/deployment.md) and [capability evidence](docs/capabilities.md).

The project uses the [MIT License](LICENSE).
