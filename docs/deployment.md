# Local Worker and deployment preparation

The game targets Cloudflare Workers and Durable Objects.
This task runs locally. No Cloudflare account or public deployment exists from this work.

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
- The object accepts at most 16 sockets and one aim point per player per tick.
- The pure tick selector returns 50 milliseconds while a live snake exists.
- The selector returns no timer when the arena is idle.
- Each tick sends one visible snapshot per socket.
- Segment indexes keep interpolation stable when the camera clips a body.
- Each tick, join, and disconnect stores a schema checkpoint.
- The checkpoint keeps the complete game state and both PCG seed words.
- Restore removes players whose sockets no longer exist.
- A failed checkpoint read or write stops the arena and closes its sockets.
- A closed connection requires the player to choose **Enter arena** again.

An active game does not request hibernation.
An idle object has no timer and can restore its state from storage and its surviving sockets.
The upstream host-timer probe remains separate from this local game check.
The game does not require RPC or an outgoing WebSocket from an object.

## Owner answers before deployment

1. Select a Cloudflare account and hostname.
2. Set a production compatibility date of `2026-10-01` or later with a current runtime.
3. Check the account's Durable Object limits and costs.
4. Check a deployment bundle and reconnect behavior in that target environment.

`cf-workers-q9` concerns the compiler's tick check.
The current API keeps `tick` in the handler record.
The game uses a pure selector and one `Object.define` call.
A separate sync parameter needs one definition-site change if the owner selects it.

This repository contains no deployment or release script.
Do not publish it during this task.

## Assessed alternative: celld

Celld remains an assessed alternative. The user did not select it.
It does not change the game's requirement for official beni platform APIs.
A celld target needs its own compatibility and operations checks.
Recommendation: keep Cloudflare as the first target.

## Evidence

- [Pinned beni Cloudflare platform](https://github.com/canassa/beni/tree/ab70761e3546db04a5daeffdc82a554e38d30f19/platforms/cloudflare)
- [Pinned beni Workers tools shell](https://github.com/canassa/beni/blob/ab70761e3546db04a5daeffdc82a554e38d30f19/flake.nix)
- [Pinned platform design, section 9.12](https://github.com/canassa/beni/blob/ab70761e3546db04a5daeffdc82a554e38d30f19/docs/design/boundary.md)
