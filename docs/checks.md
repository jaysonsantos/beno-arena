# Local check results

Date: `2026-10-23`.
Compiler source: `ab70761e3546db04a5daeffdc82a554e38d30f19`.
The project uses the Workers tools from that same revision.
No account operation or deployment ran.

## Rules and protocol

`scripts/test-rules.sh` passed all 42 assertions.
The checks use fixed ticks and seeded PCG food.
They cover movement, turns, growth, collisions, death food, safe spawn, rejoin, scores, limits, schemas, checkpoints, camera bounds, and interpolation indexes.

## Worker and sockets

`scripts/test-worker.sh` runs the unchanged upstream Miniflare driver.
All listeners use `127.0.0.1`. The driver disposes each runtime after the check.
The test source and transcript assertions use beni.

Both development and release builds pass 14 of 15 transcript checks:

- Two clients receive matching ticks, separate identities, visible food, and shared scores.
- A third client receives separate state and scores from another arena.
- The server rejects cross-site upgrades and extra input fields.
- Invalid input returns an error and a close frame with code `1008`.
- An idle object has no tick. Requests complete without runtime errors.

The client close check fails in both modes.
Three clients send a normal close but receive no close reply within the driver's five-second limit.
The object's closed handler calls the public `WebSocket.close` API.
The failed assertion stays in the suite. The suite returns a failure result.
The final `scripts/all.sh` run passed lint, all 42 rule checks, and browser renders.
It returned `1` for the close defect after both Worker modes ran.
The suite continues to browser checks after a failed Worker assertion.

The coordinator assigned the platform fixture and fix to the cf-workers worker under [beni issue #724](https://github.com/canassa/beni/issues/724#issuecomment-6352841942).
The game uses no host binding or network substitute.
An explicit `web_socket_auto_reply_to_close` probe also failed to start with the pinned runtime.
The project configuration keeps its original flags.

Transcripts remain in `.scratch/workers/development.log` and `.scratch/workers/release.log`.
Rerun `scripts/test-worker.sh` after the upstream fix and a compiler pin update.

## Browser and frame measurements

`scripts/test-browser.sh` passed generated module syntax, asset, and browser render checks.
Chromium rendered desktop `1440×1080` and mobile `390×1900` views.
The screenshots show the separate preview and the player controls without overlap.
These checks do not simulate a browser player on the live network.

`scripts/benchmark.sh` renders the actual live view with 16 snakes, 2,880 body samples, and 600 food circles.
The fixture advances interpolation through animation frames. It uses no network.
The shared Linux host uses Chromium's software renderer for this check.

| Measurement | Samples | Median | p95 | Maximum |
|---|---:|---:|---:|---:|
| Frame gap | 221 | 20.379 ms | 28.340 ms | 37.472 ms |
| Callback work | 222 | 5.246 ms | 8.156 ms | 19.018 ms |

These measurements describe this local trace. They do not measure mobile hardware or production performance.
The trace and result remain in `.scratch/benchmark/trace.json` and `.scratch/benchmark/result.json`.
Each browser check stops its owned local server after the check.

## Packages

`nix build .#frontend .#worker --max-jobs 1 --cores 2` passed.
Both packages compile from the pinned beni source with Zorg.
The frontend package includes the page, local fonts, and font licenses.
The Worker package contains the generated module and its runtime imports.

`scripts/dev.sh` also started the local Wrangler server without an account.
The game listener used `127.0.0.1:4173`.
The health route, page, and stylesheet returned successful responses.
The socket route returned `426` without an upgrade request.
Wrangler stopped after the check.

The game repository has no remote. No push ran.
