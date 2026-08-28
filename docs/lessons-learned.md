# Lessons learned

## Tasks skill lives in `.tasks/`

- The `tasks` skill stores task files in `.tasks/` (hidden folder), not `tasks/`. The task list and status markers remain in `AGENTS.md`.
- When creating, picking up, or finishing a task, reference `.tasks/` and keep the file's `Status:` line and the AGENTS.md list in sync.

## Installable skills live in a `skills/` container

- For the `npx skills` CLI to discover and install individual skills, each skill folder must sit under a top-level `skills/` container, one level deep: `skills/<skill-name>/SKILL.md`. This matches the cloudflare/security-audit-skill layout.
- Users install one skill at a time: `npx skills add <repo> --skill <name>`.
- Pushing to GitHub failed over SSH (unrecognized identity). Fixed by switching the remote to HTTPS (`git@github.com:...` → `https://github.com/...`) so `gh`'s credentials are used.

## Skills can bundle executable scripts

- The `security-audit-runner` skill carries a shell script under `skills/security-audit-runner/scripts/`. The `npx skills` layout tolerates extra files next to `SKILL.md`; the script must be `chmod +x` and referenced with paths relative to the skill root (`$SCRIPT_DIR`).
- When a script that once lived in a standalone repo is converted into a skill, the script's default "project root" must change. `$SCRIPT_DIR/..` no longer points at the target project once the script sits in `skills/<name>/scripts/`; default to `$PWD` instead and keep an explicit `TARGET` override.
