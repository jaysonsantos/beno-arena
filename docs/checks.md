# Local check results

Date: `2026-10-23`.
Compiler source: `ab70761e3546db04a5daeffdc82a554e38d30f19`.
The project uses the Workers tools from that same revision.
No account operation or deployment ran.

## Rules and protocol

`scripts/test-rules.sh` passed all 46 assertions.
The checks use fixed ticks and seeded PCG food.
They cover movement, turns, growth, collisions, death food, safe spawn, rejoin, scores, limits, schemas, checkpoints, camera bounds, and interpolation indexes.
They also round-trip every Color through join input, snapshots, and checkpoints. Numeric colors fail.

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
The final `scripts/all.sh` run passed lint, all 46 rule checks, and the browser output checks.
It returned `1` for the close defect after both Worker modes ran.
The suite continues to browser checks after a failed Worker assertion.

The coordinator assigned the platform fixture and fix to the cf-workers worker under [beni issue #724](https://github.com/canassa/beni/issues/724#issuecomment-6352841942).
The game uses no host binding or network substitute.
An explicit `web_socket_auto_reply_to_close` probe also failed to start with the pinned runtime.
The project configuration keeps its original flags.

Transcripts remain in `.scratch/workers/development.log` and `.scratch/workers/release.log`.
Rerun `scripts/test-worker.sh` after the upstream fix and a compiler pin update.

## Browser and frame measurements

`scripts/test-browser.sh` checks generated module syntax and page assets.
Chromium produces desktop `1440×1080` and mobile `390×1900` DOM dumps and screenshots.
The script removes each old PNG before the run. It requires each new PNG to exist and contain data.
At both widths, the DOM must contain the default name, connection note, preview snake class, and Enter arena button.
The script does not detect visual overlap or simulate a browser player on the live network.
I inspected both current screenshots for the separate preview and player controls.

Chromium puts its local singleton socket under the project's temporary directory.
A deep checkout can exceed the Unix socket path limit. The project root works.
Keep test files inside the project, as the task requires.

`scripts/benchmark.sh` renders the actual live view with 16 snakes, 2,880 body samples, and 600 food circles.
The fixture advances interpolation through animation frames. It uses no network.
The shared Linux host uses Chromium's software renderer for this check.

| Measurement | Samples | Median | p95 | Maximum |
|---|---:|---:|---:|---:|
| Frame gap | 237 | 19.656 ms | 26.837 ms | 87.817 ms |
| Callback work | 238 | 5.032 ms | 6.875 ms | 17.146 ms |

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
