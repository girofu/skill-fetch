# Standing Rules

Automation policies the maintainer agent applies by default. Human approval is still required for any public-facing action; these rules describe the agent's *recommendations*, not auto-executes.

## Stale Policy

| Condition | Days | Recommended Action |
|-----------|------|--------------------|
| Issue waiting on reporter | 30 | Comment asking for update |
| Issue waiting on reporter | 60 | Close as stale |
| PR waiting on author | 30 | Close as stale |

## Auto-Label Suggestions

| Condition | Label |
|-----------|-------|
| PR or issue touches `skills/skill-fetch/SKILL.md` | `area:skill-core` |
| PR or issue touches `skills/skill-fetch/scripts/` | `area:scripts` |
| PR or issue touches `install.sh` / `install.py` | `area:installer` |
| PR or issue touches `.claude-plugin/` | `area:plugin` |
| Issue mentions install failure, 404, missing file | `type:install-bug` |
| Issue mentions security, prompt injection, RCE | `priority:security` |
| First-time contributor | `first-contribution` |

## External PR Handling

- **Never merge external PRs.** Extract intent via `references/intent-extraction.md`, implement the fix in a maintainer-authored PR, and close the original with a crediting comment.
- When the original PR has useful test cases or reproductions, reuse them (with attribution) in the maintainer PR.

## Security-First Defaults

- Any new source/script that touches user API keys must read from `~/.claude/skills/.fetch-config.json`, never from argv.
- Any install-path change must preserve the directory layout of the source skill; adding implicit filtering is forbidden.
- Any change to the 6-category security scan must include a positive test case (a fixture that should trip the new rule).
