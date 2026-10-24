# Beni capability check

Source revision: `84c0d23976f7cdbe22f3addf1eeb3f8442c32847`.
The pin includes the tested peer-close fix from [beni PR #819](https://github.com/canassa/beni/pull/819).
It also includes the `Dom` full-screen API from [beni PR #906](https://github.com/canassa/beni/pull/906).
The earlier report recorded gaps in sockets, pointer coordinates, and the Cloudflare platform.
This revision supplies those APIs.

## APIs that the game uses

| Need | API and evidence in the pinned beni source |
|---|---|
| Worker routing and static assets | `Worker.forward` and `Worker.callService` in `platforms/cloudflare/Worker.beni` |
| One object per arena | `Worker.objects` and `Worker.byName` in `platforms/cloudflare/Worker.beni` |
| Object state and fixed tick | `Worker.Object.define` and `Handlers.tick` in `platforms/cloudflare/Worker/Object.beni` |
| Object WebSocket acceptance | `Worker.Object.accept` in `platforms/cloudflare/Worker/Object.beni` |
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
- Cesar answered `cf-workers-q9`: `tick` stays in the handler record.
- The compiler will reject a tick that waits through `sync_boundary`.
- The game selector already stays pure and never waits.
- The pinned platform answers normal client closes. The game keeps its close-code assertions.
- The upstream hibernation probe, RPC, and client-disconnect probes do not block local play.
- A Cloudflare account answer remains necessary for a future deployment.
- No account operation or remote development command belongs to this task.

See the [deployment notes](deployment.md) for the local configuration and the production prerequisites.
See the [check results](checks.md) and the [upstream close fix](https://github.com/canassa/beni/pull/819).
