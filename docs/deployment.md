# Local Worker and deployment preparation

The game uses Cloudflare Workers and Durable Objects.
Production uses `https://snake-arena.jayson.com.br`.
The public source repository is `https://github.com/jaysonsantos/snake-arena`.

## Build and deploy on push

Every push to `main` starts `.github/workflows/deploy.yml`.
The workflow installs the Nix tools, checks the rules, and runs `scripts/deploy.sh`.
The script selects `wrangler deploy --env production` from the pinned Workers shell.
Wrangler runs the configured `scripts/build.sh` command before upload.
That command compiles both the beni page and the beni Worker.
The production environment declares the custom domain and the `ARENAS` binding.
Its compatibility date stays separate from the older local test runtime.

Set these repository secrets:

| Secret | Purpose |
|---|---|
| `CLOUDFLARE_ACCOUNT_ID` | Select the deployment account |
| `CLOUDFLARE_API_TOKEN` | Deploy the Worker and its custom domain |

Use the Edit Cloudflare Workers token template. Scope it to the deployment account and the `jayson.com.br` zone.
A local OAuth login expires. Use a permanent API token for unattended builds.
Keep the token in GitHub Actions secrets. Keep its value out of source and logs.

The workflow also permits a manual run from the Actions tab.
It serializes production deployments, so two pushes cannot deploy at the same time.
The main CI workflow keeps the known client-close failure visible.
The deploy workflow checks the rules and builds the current source before upload.

## Branch previews

A current Wrangler release supports `wrangler preview`.
The root `previews` block declares `ARENAS` because the game reads that binding from its environment.
Cloudflare gives each preview its own object namespace and storage.
Static assets and class migrations stay at the top level.
See [Preview resource isolation](https://developers.cloudflare.com/workers/previews/resources/).

## Local configuration

`wrangler.jsonc` names `build/worker/_worker.mjs` as the entrypoint.
The beni manifest exports `Arena`. The Worker registers that same class name.
The `ARENAS` binding maps each arena name to one SQLite-backed Durable Object.
The `ASSETS` binding serves `build/page`.
The Worker receives `/arena/*` and `/health` before asset lookup.

The `workers` development shell takes Wrangler, Miniflare, and workerd from the pinned beni revision.
It uses Wrangler 4.93.0, Miniflare 4.20260518.0, and workerd 1.20260518.1.
The local compatibility date is `2026-05-18`, which that runtime accepts.
The shell disables Cloudflare configuration fetches and Wrangler usage metrics.

Run `scripts/dev.sh` to serve the page and sockets on `127.0.0.1:4173`.
The command runs `wrangler dev --local`.
Never use `wrangler dev --remote` for this task.
Stop the command with Ctrl-C after a check.

## Object state and lifecycle

- The object owns player identities, movement, food, scores, and seeded random state.
- The page sends only a join request or an aim point.
- The object checks input size, schema, keys, names, colors, and coordinate bounds.
- Each socket uses the platform's stable socket ID as its player ID.
- The object accepts at most 16 sockets and one join request per player per tick.
- It retains the newest aim point per player and applies it once on the next tick.
- The pure tick selector returns 50 milliseconds while a live snake exists.
- The selector returns no timer when the arena is idle.
- Each tick sends one visible snapshot per socket.
- Segment indexes keep interpolation stable when the camera clips a body.
- Each tick sends snapshots before any checkpoint write.
- Every 20 ticks, or one second of simulation, the object stores a schema checkpoint.
- A join or disconnect stores a checkpoint only when it changes the game state.
- The last death also stores a checkpoint before the arena stops its timer and can hibernate.
- A crash can lose at most one second of simulation after the last successful checkpoint.
- The storage output gate still holds outgoing messages on a checkpoint tick until the write becomes durable.
- The checkpoint keeps the complete game state and both PCG seed words.
- Inputs, snapshots, and checkpoints use the same Color schema from `game/Palette.beni`.
- Each color carries a name, such as `{"name":"moss"}`.
- An unused new arena stores no checkpoint. Its first accepted join stores one.
- Restore removes players whose sockets no longer exist.
- An invalid checkpoint logs a warning, starts a new game, and writes a replacement checkpoint.
- A failed checkpoint write stops the arena and closes its sockets.
- A closed connection requires the player to choose **Enter arena** again.

An active game does not request hibernation.
An idle object has no timer and can restore its state from storage and its surviving sockets.
The upstream host-timer probe remains separate from this local game check.
The game does not require RPC or an outgoing WebSocket from an object.
The Color schema change precedes the first deployment. No stored production data needs conversion.
The current checkpoint key is `arena:v2`. Change its version whenever the stored schema shape changes.
New games use `Clock.now` as the PCG seed. Restored games keep their saved seed.
Beni PR #819 makes the platform answer peer closes before the game handler runs.
The current pin lacks that fix. The game handler removes the departed player and keeps the failed close check.

## Storage write limit for deployment

The local full-arena probe measured 808 writes in 850.1 seconds, or 0.95 writes per second.
The host ran at 18.98 ticks per second. Every checkpoint gap was 20 ticks.
Each checkpoint contained about 24,560 characters. This probe measured normal play with 16 players.

A reconnect loop has a different limit. Each new socket gets a new player ID.
A join writes once. Its leave writes once. Thus, each completed loop causes two writes.
A rate of `R` loops per second causes about `2R` writes per second, plus periodic checkpoints.
The per-socket join limit does not bound this rate across new sockets.
The current implementation has no arena-wide limit for these writes.

Before deployment, set an arena-wide write budget and an upgrade admission limit.
Check the reconnect write rate against the selected account's storage quotas and costs.
Keep this requirement in the deployment task. The normal-play measurement does not cover reconnect abuse.

## Production operations

1. Set the repository deployment secrets for the selected Cloudflare account.
2. Set a production compatibility date of `2026-10-01` or later with a current runtime.
3. Check the account's Durable Object limits and costs.
4. Check a deployment bundle and reconnect behavior in that target environment.

Cesar answered `cf-workers-q9`: `tick` stays in the handler record.
The compiler will reject a tick that waits through `sync_boundary`.
The game already uses a pure selector that never waits.
The `Object.define` call needs no change.

The deployment script builds through Wrangler before upload. No version release script exists.

## Assessed alternative: celld

Celld remains an assessed alternative. The user did not select it.
It does not change the game's requirement for official beni platform APIs.
A celld target needs its own compatibility and operations checks.
Recommendation: keep Cloudflare as the first target.

## Evidence

- [Pinned beni Cloudflare platform](https://github.com/canassa/beni/tree/ab70761e3546db04a5daeffdc82a554e38d30f19/platforms/cloudflare)
- [Pinned beni Workers tools shell](https://github.com/canassa/beni/blob/ab70761e3546db04a5daeffdc82a554e38d30f19/flake.nix)
- [Pinned platform design, section 9.12](https://github.com/canassa/beni/blob/ab70761e3546db04a5daeffdc82a554e38d30f19/docs/design/boundary.md)
