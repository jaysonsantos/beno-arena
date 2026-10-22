# Deployment preparation

State: design prepared; deployment blocked by beni platform support.
The repository now prepares a static frontend package.
The Worker and live game remain blocked.

Beni-generated JavaScript is valid deployment output.
The missing part is a supported beni interface to the host APIs and required exports.
The game will contain no TypeScript or hand-written JavaScript.

## Recommended target: Cloudflare

Use one Worker and one Durable Object per arena.
The Worker routes `/arena/<id>/ws` to the object for that arena.
The object owns the players, food, random seed, tick, and scores.
Clients send input. The object checks each message and sends visible state.

Cloudflare supports WebSockets in Durable Objects and recommends its hibernation API.
The Worker forwards the request to the object, which accepts the connection.
See [Cloudflare WebSockets](https://developers.cloudflare.com/durable-objects/best-practices/websockets/).

Compile the browser page with beni.
Serve its output through Workers static assets.
Route `/arena/*` to the Worker before asset lookup.
See [asset configuration](https://developers.cloudflare.com/workers/static-assets/binding/).

## Planned configuration

These values define the intended configuration. They are not a runnable Wrangler file.

| Setting | Planned value |
|---|---|
| Worker name | `snake-arena` |
| Durable Object binding | `ARENAS` |
| Durable Object class export | `Arena` |
| Object identity | One stable object name per arena ID |
| Assets binding | `ASSETS` |
| Worker-first routes | `/arena/*` |
| Worker entrypoint | The output from the future beni Cloudflare platform; path unresolved |
| Assets directory | `build/page/`, or the frontend Nix package output |
| Compatibility date | Select and pin it with the first tested build |
| Storage | SQLite for state that must survive restarts |

The platform must emit the Worker entrypoint and the `Arena` class export.
Wrangler must bind `ARENAS` to that export.
Check the class registration syntax against the pinned Wrangler version.
The current guide uses the `exports` field for new classes.
See [Durable Objects setup](https://developers.cloudflare.com/durable-objects/get-started/).

Do not add a manifest with a nonexistent entrypoint.
Create the runnable configuration after #526 defines the output contract.

## Tick and lifecycle

- Run a fixed simulation tick while players need an active arena.
- Bound catch-up work after a delayed tick.
- Stop timers when the arena becomes idle.
- Store connection identity in WebSocket attachments.
- Restore durable state and connection identity after hibernation.
- Handle object restarts through reconnect and a fresh state snapshot.

Scheduled timers prevent hibernation.
Hibernation removes in-memory state, and runtime shutdown can close WebSockets.
These rules require explicit restoration and reconnect behavior.
See [Durable Object lifecycle](https://developers.cloudflare.com/durable-objects/concepts/durable-object-lifecycle/).

The initial game can reset an interrupted match if the coordinator accepts that behavior.
Persistent matches need a defined checkpoint policy before implementation.

## Alternative: celld

Celld runs JavaScript and Cloudflare-style Workers and Durable Objects on machines that you operate.
Its cells support WebSockets and private SQLite state.
This makes it a plausible host for a future compatible beni build.
See [celld documentation](https://celld.dev/docs/).

Celld does not remove the beni API blocker.
The same application still needs Worker exports, Durable Object bindings, and browser WebSocket support.
Compatibility remains untested until the beni platform exists.

Celld also needs nodes, object storage, and TLS ingress that you operate.
Its documentation identifies the current release as beta.
See [celld limitations](https://celld.dev/docs/limitations/).

Recommendation: use Cloudflare first.
Keep celld as an alternative if control of the server infrastructure becomes a requirement.
The user asked about celld but did not select it.

## Required checks before deployment

1. Resolve [#524](https://github.com/canassa/beni/issues/524), [#525](https://github.com/canassa/beni/issues/525), and [#526](https://github.com/canassa/beni/issues/526).
2. Compile the browser and Worker from beni source.
3. Check the generated exports against the Wrangler configuration.
4. Run local tests with listeners on `127.0.0.1`.
5. Check two clients in one arena and clients in separate arenas.
6. Check malformed input, message size limits, growth, collisions, death, and rejoin.
7. Check frame time, tick delays, reconnect, idle timers, and object restart.
8. Check the deployment bundle without publication.
9. Record the target Cloudflare account and hostname before publication.

The current task permits preparation only.
No account resources, deployment, or public listener exist from this work.
