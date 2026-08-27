# Lessons learned

## Tasks skill lives in `.tasks/`

- The `tasks` skill stores task files in `.tasks/` (hidden folder), not `tasks/`. The task list and status markers remain in `AGENTS.md`.
- When creating, picking up, or finishing a task, reference `.tasks/` and keep the file's `Status:` line and the AGENTS.md list in sync.

## Installable skills live in a `skills/` container

- For the `npx skills` CLI to discover and install individual skills, each skill folder must sit under a top-level `skills/` container, one level deep: `skills/<skill-name>/SKILL.md`. This matches the cloudflare/security-audit-skill layout.
- Users install one skill at a time: `npx skills add <repo> --skill <name>`.
- Pushing to GitHub failed over SSH (unrecognized identity). Fixed by switching the remote to HTTPS (`git@github.com:...` → `https://github.com/...`) so `gh`'s credentials are used.
