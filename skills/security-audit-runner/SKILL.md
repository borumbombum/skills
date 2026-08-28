---
name: security-audit-runner
description: Automated security audits of a codebase using the Cloudflare security-audit skill via opencode in headless mode. Use whenever asked to run a security audit, reliability/performance/code-quality review, or a periodic automated audit of a project.
---

# AI Auditing

Run a full security audit (plus reliability, performance, and code quality review) of a target project and produce structured artifacts in `<project-root>/.audit-results/`.

## How it works

`scripts/run-security-audit.sh` triggers the Cloudflare `security-audit` skill through `opencode run` in headless (`--auto`) mode. The skill runs a 6-phase pipeline: recon, hunting, validation, reporting, structured output, and independent verification. The audit is run as a nested headless opencode session so it works non-interactively and can be scheduled via cron.

## Prerequisites

- `opencode` CLI installed and authenticated (non-interactive).
- `jq` installed (parses `findings.json`).
- The `security-audit` skill installed **locally** in the target project, not globally:

  ```bash
  cd <target-project>
  npx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit
  ```

  It must be at `<target-project>/.agents/skills/security-audit/SKILL.md` so the nested session has pre-approved permissions for headless runs.
- Optional Telegram notifications via `.env` next to the script (`TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`). Copy `.env.example` if present.

## Running an audit

Run the script via the bash tool from this skill's directory:

```bash
./scripts/run-security-audit.sh                # audits $PWD
TARGET=/path/to/project ./scripts/run-security-audit.sh
```

Default target is the current working directory (`$PWD`). Any path set in `TARGET` overrides it.

The script exits non-zero if the audit was incomplete (opencode error, or a rejected/errored tool call mid-run). A non-zero exit does **not** mean "no issues" — treat it as inconclusive.

## Agent steps after running

1. Run the script; capture its output and exit code.
2. If the script fails the pre-check (missing `security-audit` skill), install it in the target project as shown above and re-run.
3. Report the finding counts from the script output (CRITICAL / HIGH / MEDIUM).
4. Point to `REPORT.md` (and `FINDINGS-DETAIL.md` for MEDIUM+ traces) under `<target>/.audit-results/`.
5. If the run was incomplete, say so explicitly — never present an incomplete run as "all good".

## Output artifacts

Written to `<target>/.audit-results/`:

- `architecture.md` — recon output
- `REPORT.md` — human-readable report
- `FINDINGS-DETAIL.md` — detailed traces for MEDIUM+ findings
- `findings.json` — machine-readable structured output
- `raw-output-<date>.md` — full terminal log

## Scheduling (cron)

```cron
0 3 * * 1 cd /path/to/site && /path/to/skills/security-audit-runner/scripts/run-security-audit.sh >> /tmp/audit-cron.log 2>&1
```