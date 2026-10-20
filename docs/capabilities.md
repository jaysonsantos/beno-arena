# Beni capability check

State: blocked at Step 1. No game code or runtime tests.

Source revision: `4586e4fb0f329b6bd1cf5884288b694754afd6aa`.
Source root: `/home/jayson/src/beni.worktrees/snake-arena`.
The assigned worktree matched `origin/master` after `git pull --ff-only`.

## Required capabilities

| Need | Result | Evidence relative to the source root |
|---|---|---|
| Node server WebSocket | **Missing.** HTTP handlers expose no upgrade or socket API. | `docs/design/boundary.md:5335`; `platforms/node/Http/Server.beni:64`, `:79`, `:101`. |
| Browser WebSocket | **Missing.** The design still lists `Ws` as owed. | `docs/design/boundary.md:2903`; `platforms/browser-tea/beni.json:5`; no WebSocket module in `platforms/browser/`. |
| Node server tick | **Has it.** A fiber can read the clock, sleep, and repeat. The game must implement fixed-step timing. | `platforms/node/Io.beni:44`, `:104`; `core/Task.beni:963`, `:1850`; `core/Clock.beni:39`. |
| Browser time and animation frames | **Has it.** Time subscriptions and frame deltas exist. | `platforms/browser/Time.beni:54`, `:72`; `platforms/browser/Browser/Events.beni:169`. |
| Arena graphics | **Has it.** SVG supports circles, paths, and coordinates. No public canvas context API exists. | `platforms/html/Html.beni:466`, `:472`, `:484`, `:994`; `examples/bike-wars/src/Game.beni:183`. |
| Hundreds of moving circles | **Performance unknown.** SVG can express the scene. No frame-time measurement exists for this game. | SVG API evidence above; no game benchmark yet. |
| Mouse coordinates | **Missing.** `onMouseMove` exists, but the public event API exposes no coordinates. | `platforms/html/Html.beni:34`, `:48`, `:66`, `:1385`. |
| Touch control | **Missing.** The vocabulary exposes neither touch nor pointer events. | `platforms/html/Html.beni:1337`; no `onTouch`, `onPointer`, or touch-coordinate API in the platform tree. |
| Keys | **Has it.** Key events and typed readers exist. | `platforms/html/Html.beni:66`, `:72`; `platforms/browser/Browser/Events.beni:131`. |
| Server random values | **Has it.** Node supplies entropy and core supplies seeded PCG generators. | `platforms/node/Random.beni:37`, `:80`; `core/Random/Pcg.beni:50`, `:58`, `:79`, `:109`. |
| Static page files | **Has it on Node.** The todo example serves compiled modules and other text assets. | `platforms/node/Io.beni:138`; `examples/todo/server/src/Files.beni:21`, `:74`, `:92`. |
| JSON and message checks | **Has it.** Typed JSON and schemas expose parse errors and value constraints. | `core/Json.beni:27`, `:39`; `core/Schema.beni:759`, `:3112`, `:3146`; `examples/todo/shared/Todos.beni:16`. |
| Lists, maps, shared state | **Has it.** Core supplies `List`, `Dict`, and `Ref`. | `core/List.beni:259`, `:287`, `:1706`; `core/Dict.beni:74`, `:145`; `examples/todo/server/src/Main.beni:28`. |
| Cloudflare Workers and Durable Objects | **Missing.** No installed platform exposes their entrypoints, bindings, or object lifecycle. | `docs/design/boundary.md:758`; `platforms/node/beni.json:4`; `platforms/node/runtime.js:14`; no Cloudflare platform in `platforms/`. |

The source check found no WebSocket API in either target.
It also found no public input-coordinate reader in `core/` or `platforms/`.
`core/Js.beni:5` restricts host access to core and platform packages.
The game cannot supply these missing bindings through an ordinary beni module.

## Issues

- Commented on [#340: Node WebSockets](https://github.com/canassa/beni/issues/340#issuecomment-6298637878).
- Opened [#524: browser WebSockets](https://github.com/canassa/beni/issues/524).
- Opened [#525: pointer coordinates and touch input](https://github.com/canassa/beni/issues/525).
- Opened [#526: Workers and Durable Objects](https://github.com/canassa/beni/issues/526).

The Node issue concerns the original local server target.
The Cloudflare production target requires #526.
Both deployment choices require the browser fixes.

## What the examples establish

- `examples/todo/` separates a Node server, a browser page, and shared schemas.
- `examples/bike-wars/` uses SVG, key events, and animation frames.
- `examples/sternhalma/` uses typed drag events and browser model updates.
- `Tea.element` supplies commands and subscriptions through `platforms/browser-tea/Tea.beni:58`.

These findings come from source inspection.
I did not rebuild beni or run these examples.
The contract requires a stop when a required capability is missing.

## Next

Resolve #524, #525, and #526 before the Cloudflare game implementation.
Keep #340 if the coordinator retains the local Node server requirement.
Then check SVG frame time, fixed-tick rules, multi-client messages, and reconnect behavior.
