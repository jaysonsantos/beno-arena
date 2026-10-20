# Snake Arena

- Write all game code in beni.
- Do not write TypeScript or JavaScript.
- Use only the APIs that beni core and its platforms provide.
- If an API is missing, search the open issues in `canassa/beni`.
- Add the game requirement to an existing issue, or open an issue with evidence and completion criteria.
- Stop after the capability report if a required API is missing.
- Wait for the coordinator before you use a substitute or start Step 2.
- Keep project instructions in `AGENTS.md`.
- Use small commits with Conventional Commits messages.
- Do not add a remote, push commits, create a repository, or deploy the game.
- Bind each test server to `127.0.0.1`. Stop it after the test.
- Do not change the beni compiler sources.
- Keep build output and scratch files in the project. Do not use `/tmp`.
- Check `free -g` before a heavy command. Wait if available memory is below 6 GB.
- Run heavy commands under the shared lock and memory limits from the task contract.
- Never use `pkill`, `killall`, or another command that kills processes by pattern.
- Before you kill a PID, check its full command and confirm that this task owns it.
- Write chat output and durable prose in ASD-STE100 Simplified Technical English.

The task contract is `/home/jayson/.local/state/beni-dispatch/snake-arena-prompt.md`.
Read it in full before work.
