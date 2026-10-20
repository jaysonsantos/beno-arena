# Snake Arena

A planned multiplayer snake game in beni.
Beni compiles the game to JavaScript for the browser and server.
The project contains no game implementation yet.

The capability check found missing platform APIs.
The task contract requires a stop until the coordinator gives new instructions.

- [Capability check](docs/capabilities.md): source evidence and upstream issues.
- [Deployment preparation](docs/deployment.md): Cloudflare Workers, Durable Objects, and the celld assessment.

The repository retains `.editorconfig`, `.gitignore`, and a Nix development shell.
The shell supplies Node 24 for compiled beni output.
The shell does not supply the beni compiler yet.

Next: resolve the platform blockers, then build the game and run its tests.
