# skills

Skills, skills, skills for harnessing these things.

## Available Skills

| Skill | Description |
| --- | --- |
| [tasks](skills/tasks/SKILL.md) | How tasks work in this repo — the .tasks/ folder, the task list in .tasks/TASKS.md, and the status markers agents must keep updated. |
| [git-commit-workflow](skills/git-commit-workflow/SKILL.md) | Rules for committing, bumping versions, and pushing to git. |
| [borum-writer](skills/borum-writer/SKILL.md) | Write blog posts, updates, logs, or essays in the Gonzo Coder / Borum voice. |
| [security-audit-runner](skills/security-audit-runner/SKILL.md) | Automated security audits powered by the Cloudflare security-audit skill via headless opencode, with Telegram notifications. |
| [youtube-search](skills/youtube-search/SKILL.md) | Find and verify exact-whisky YouTube review/tasting videos across languages using multiple search sources. |

## Install

Install a single skill with the [Skills CLI](https://skills.sh):

```bash
npx skills add https://github.com/borumbombum/skills --skill tasks
npx skills add https://github.com/borumbombum/skills --skill git-commit-workflow
npx skills add https://github.com/borumbombum/skills --skill borum-writer
npx skills add https://github.com/borumbombum/skills --skill security-audit-runner
npx skills add https://github.com/borumbombum/skills --skill youtube-search
```

Add `--global` for a user-level installation.