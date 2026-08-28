# Tools

Tools created in this repo, beyond the skills themselves.

## run-security-audit.sh

`skills/security-audit-runner/scripts/run-security-audit.sh` — runs an automated security (plus reliability, performance, code quality) audit of a target codebase.

- Invokes the Cloudflare `security-audit` skill through `opencode run` in headless mode (`--dir <target> --thinking --auto`).
- Writes artifacts to `<target>/.audit-results/` (`architecture.md`, `REPORT.md`, `FINDINGS-DETAIL.md`, `findings.json`, `raw-output-<date>.md`).
- Parses `findings.json` with `jq` into CRITICAL / HIGH / MEDIUM counts for confirmed findings.
- Optionally notifies a Telegram chat via `.env` (`TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`) placed next to the script.
- Exit code 1 means the run was incomplete or errored — never treat that as "no issues".
- Usage: `./scripts/run-security-audit.sh` (audits `$PWD`) or `TARGET=/path/to/project ./scripts/run-security-audit.sh`.
- Prerequisites: `opencode` CLI authenticated, `jq`, and the `security-audit` skill installed in the target project (`npx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit`) at `<target>/.agents/skills/security-audit/`.