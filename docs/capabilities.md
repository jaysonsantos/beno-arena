# Beni capability check

Source revision: `ab70761e3546db04a5daeffdc82a554e38d30f19`.
The assigned compiler worktree matched `origin/master` after `git pull --ff-only`.
The earlier report recorded gaps in sockets, pointer coordinates, and the Cloudflare platform.
This revision supplies those APIs.

## APIs that the game uses

| Need | API and evidence in the pinned beni source |
|---|---|
| Worker routing and static assets | `Worker.forward` at `platforms/cloudflare/Worker.beni:740`; `Worker.callService` at line 802 |
| One object per arena | `Worker.objects` at `platforms/cloudflare/Worker.beni:628`, then `Worker.byName` |
| Object state and fixed tick | `Worker.Object.define` at `platforms/cloudflare/Worker/Object.beni:98`; `Handlers.tick` at line 59 |
| Object WebSocket acceptance | `Worker.Object.accept` at `platforms/cloudflare/Worker/Object.beni:752` |
| Stable socket identities and text output | `WebSocket.id`, `write`, and `close` in `platforms/cloudflare/WebSocket.beni` |
| Durable checkpoints | `Worker.Storage.get` and `put` in `platforms/cloudflare/Worker/Storage.beni` |
| Browser WebSocket | `WebSocket.listen` and `send` in `platforms/browser/WebSocket.beni` |
| Pointer and touch coordinates | `Html.Pointer`, `localX`, and `localY` in `platforms/html/Html.beni` |
| Keyboard and animation frames | `Browser.Events.onKeyDown` and `onAnimationFrameDelta` |
| Responsive coordinates | `Dom.box` in `platforms/browser/Dom.beni` |
| SVG rendering | The official `html` vocabulary |
| Deterministic food | `Random.Pcg.initialSeed`, `step`, and `float` in `core/Random/Pcg.beni` |
| Input, snapshots, and checkpoints | Compiled schema declarations and `core/Schema` |
| Local integration checks | The unchanged `tests/workers/driver.mjs`, from the same pinned source |

All application code uses these public APIs.
No application module imports `Js` or declares `foreign`.
No compiler source changes exist from this task.

## Platform fixtures

- `ObjectSocket` supplies the acceptance, stable ID, message, and close pattern.
- `ObjectCounter` supplies the checkpoint, pure tick selector, and deterministic tick-hook pattern.
- `ObjectAsk` supplies the typed inter-object message pattern. The game needs no ask or RPC.
- `boundary.md` section 9.12 (a)–(l) supplies the platform and lifecycle contract.
- `api-cloudflare.md` supplies the public signatures. `websocket.md` distinguishes object events from browser subscriptions.

## Remaining limits and owner questions

- The current platform does not measure a socket's outbound queue.
- The game bounds sockets, food, body length, input size, and snapshots per tick.
- `cf-workers-q9` still concerns the compiler's sync check for `tick`.
- The game selector stays pure and never waits.
- The upstream hibernation probe, RPC, and client-disconnect probes do not block local play.
- A Cloudflare account answer remains necessary for a future deployment.
- No account operation or remote development command belongs to this task.

See the [deployment notes](deployment.md) for the local configuration and the production prerequisites.
