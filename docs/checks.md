# Local check results

## Current validation

Date: `2026-10-23`.
Compiler source: `31d1025ac92c3a9383a1e355722ffac848910810`.
The project keeps the compiler and Workers tools on this one pin.
It includes the peer-close fix from [beni PR #819](https://github.com/canassa/beni/pull/819).

The rule suite passes 98 assertions. Eleven playback checks cover a 150 millisecond buffer, packet bursts, gaps, respawns, and clock recovery.
A burst does not change the displayed position. Playback advances through a 160 millisecond packet gap.
A slow server does not drain the buffer. Snapshot history stays bounded.

Both Worker build modes pass all 19 socket assertions, 12 storage assertions, and six transcript-parser checks.
The aim fixture waits for each server observer event before its manual tick.
The storage fixture waits for the final zero-player checkpoint before teardown.
The assertions still check the newest aim and the exact peer close codes.

A 15-second local browser sample contains 1,800 movement intervals and no stationary interval.
The earlier local sample contains 45 stationary intervals in the same interval count.
Animation callback median stays at 8.3 milliseconds. The new sample contains no long browser task.
The maximum head step decreases from 1.6 to 1.2 game units.
ArrowUp sends an aim packet with `y = 0` while the delayed view runs.
This comparison covers local play. It does not prove production behavior or input latency.
The browser checks use the 150 millisecond playback buffer. Inputs keep their separate send timer.

## Earlier validation

The following record uses the previous compiler pin. Its close failure is historical.

Date: `2026-10-23`.
Compiler source: `ab70761e3546db04a5daeffdc82a554e38d30f19`.
The project uses the Workers tools from that same revision.
The local test commands need no Cloudflare account.

### Rules and protocol

`scripts/test-rules.sh` passed all 87 assertions.
The checks use fixed ticks and seeded PCG food.
Guest-name checks cover empty input, whitespace, chosen names, protocol acceptance, and variation across seeds.
Self-collision checks cover body contact, safe neck samples, tight turns, the vacated tail, and one corpse drop.
Each page draws its guest name from the browser random seed and keeps it for later joins.
They cover movement, turns, growth, collisions, death food, safe spawn, rejoin, scores, limits, schemas, checkpoints, camera bounds, and interpolation indexes.
They also round-trip every Color through join input, snapshots, and checkpoints. Numeric colors fail.
The review regressions force movement direction, the exact turn limit, score order and length, seed use, safe spawn, and collisions after movement.
They also check body clipping, dead snakes, name length, valid oversized JSON, restored ticks, join limits, aim coalescing, recovery, and checkpoint cadence.
The final death forces a checkpoint before idle hibernation. Its regression restores the dead player and the terminal tick.
All twelve requested rule and protocol mutants compiled and failed these assertions. Five session mutants also compiled and failed.
The spawn fixture puts a tail across the first candidate. Its head stays in the opposite corner.
The head-only spawn mutant R24 fails R21. All rule checks pass when spawn checks all body segments.

### Worker and sockets

`scripts/test-worker.sh` runs the unchanged upstream Miniflare driver.
All listeners use `127.0.0.1`. The driver disposes each runtime after the check.
The test source and transcript assertions use beni.

Both development and release builds pass 18 of 19 socket assertions. All 12 storage assertions and six parser checks pass:

- Two clients receive matching ticks, separate identities, visible food, and shared scores.
- A third client receives separate state and scores from another arena.
- The server rejects cross-site upgrades and extra input fields.
- Invalid input returns an error and a close frame with code `1008`.
- An idle object has no tick. Requests complete without runtime errors.
- Each client receives its welcome and expected joined reply. Repeated joins produce no extra reply in one tick.
- Two aim points before one tick make the snake turn toward the newest point.
- Parser checks detect missing or duplicate replies. They isolate each close receive and require the peer code.

The test Worker uses the same arena handlers as the production Worker.
The production entry supplies empty observers. It does not import the trace or the storage fixtures.
The test entry records one schema event after each successful application save.
The transcript counts these events by arena, tick, and remaining players.
It also records restore state and broadcast order. Fixture setup writes do not enter the application save count.

The storage steps cover a fresh arena, an invalid checkpoint, and stale players.
They send 40 repeated joins across two ticks, then drive a total of 20 ticks.
The checks require one changed join write, one periodic write at tick 20, and one leave write.
The periodic write must follow the broadcast event at tick 20.
Fresh and reset seeds must match a clock value from the previous second.
An invalid checkpoint must log its reset and write a replacement.
An unused fresh arena must not write. Restore must write after it removes stale players.
The test uses public `Storage`, `Object.name`, `Clock`, and `Log` APIs.
All six server mutants compile and fail storage assertions beyond the retained close failure:

| Mutant | Change | Assertion that fails |
|---|---|---|
| W01 | Save every tick | Active checkpoints write only at tick 20 |
| W02 | Move only the due save before broadcast | The checkpoint follows the twentieth broadcast |
| W03 | Save every join | Duplicate joins do not add storage writes |
| W04 | Remove restore saves | Invalid and stale checkpoints require writes |
| W05 | Restore with seed 42 | Fresh and reset games use a recent clock seed |
| W06 | Remove leave saves | A leave writes the empty game once |

The client close check fails in both modes.
Three clients send a normal close but receive no close reply within the driver's five-second limit.
The game removes the departing player. [Beni PR #819](https://github.com/canassa/beni/pull/819) adds the platform close reply.
The current compiler pin still lacks that fix. The close check requires code `1000` for Alice and `4001` for Carol.
The failed assertion stays in the suite. The suite returns a failure result.
The review ran lint, rule, Worker, browser, and benchmark commands separately.
Lint, all 82 rule assertions, and the browser output checks passed.
The Worker command returned `1` for the close defect after both modes ran.
The suite entrypoint also continues to browser checks after a failed Worker assertion.

The coordinator assigned the platform fixture and fix to the cf-workers worker under [beni issue #724](https://github.com/canassa/beni/issues/724#issuecomment-6352841942).
The game uses no host binding or network substitute.
An explicit `web_socket_auto_reply_to_close` probe also failed to start with the pinned runtime.
The project configuration keeps its original flags.

Transcripts remain in `.scratch/workers/development.log` and `.scratch/workers/release.log`.
Rerun `scripts/test-worker.sh` after the upstream fix and a compiler pin update.

### Browser and frame measurements

`scripts/test-browser.sh` checks generated module syntax and page assets.
Chromium produces desktop `1440×1080` and mobile `390×1900` DOM dumps and screenshots.
The script removes each old PNG before the run. It requires each new PNG to exist and contain data.
At both widths, the DOM must contain the default name, connection note, preview snake class, and Enter arena button.
The script does not detect visual overlap or simulate a browser player on the live network.
A third check renders the actual live view at `390×900` with a local stress fixture.
It requires a fresh nonempty PNG, live snake markup, and `xMidYMid meet` in the SVG.
Three pure checks cover pointer coordinates through phone and desktop letterboxes.
I inspected the main mobile view and the live fixture. The fixture keeps the circles round.
The fixture opens no game socket.

Chromium puts its local singleton socket under the project's temporary directory.
A deep checkout can exceed the Unix socket path limit. The project root works.
Keep test files inside the project, as the task requires.

`scripts/benchmark.sh` renders the actual live view with 16 snakes, 2,880 body samples, and 600 food circles.
The fixture advances interpolation through animation frames. It uses no network.
The shared Linux host uses Chromium's software renderer for this check.

| Measurement | Samples | Median | p95 | Maximum |
|---|---:|---:|---:|---:|
| Frame gap | 225 | 20.443 ms | 26.443 ms | 85.140 ms |
| Callback work | 226 | 5.303 ms | 7.562 ms | 21.385 ms |

These measurements describe this local trace. They do not measure mobile hardware or production performance.
The trace and result remain in `.scratch/benchmark/trace.json` and `.scratch/benchmark/result.json`.
Each browser check stops its owned local server after the check.

### Packages

`nix build .#frontend .#worker --max-jobs 1 --cores 2` passed.
Both packages compile from the pinned beni source with Zorg.
The frontend package includes the page, local fonts, and font licenses.
The Worker package contains the generated module and its runtime imports.

The earlier preparation at `54bab5f` also started the local Wrangler server without an account.
The game listener used `127.0.0.1:4173`.
The health route, page, and stylesheet returned successful responses.
The socket route returned `426` without an upgrade request.
Wrangler stopped after the check.

The game repository has no remote. No push ran.
