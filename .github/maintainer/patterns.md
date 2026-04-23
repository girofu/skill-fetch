# Observed Patterns

Patterns the maintainer agent has learned while operating the repo. Use these to pattern-match new issues faster and to preempt recurring mistakes.

## Recurring Issues

### Partial skill downloads (install the directory, not the file)
- **First observed:** 2026-04-23 (internal review → [PR:1])
- **Cause:** Install logic hardcoded `SKILL.md` + `references/*.md` + `scripts/*.sh`. Skills that ship `.py` scripts, `assets/`, `templates/`, etc. were installed with missing files.
- **Resolution:** Full git-tree enumeration via `scripts/fetch-skill-bundle.sh` (PR:1).
- **Prevention:** Never hardcode subdir names or extensions in install/scan logic. Walk the tree.

## Codebase Patterns

- SKILL.md is the public contract; references/ files are progressive disclosure. Keep SKILL.md lean; push detail down into reference files.
- Every shell script must pass ShellCheck `--severity=warning`. CI enforces this.
- API keys live in `~/.claude/skills/.fetch-config.json` and are loaded by bundled scripts — never on command lines.

## Contributor Patterns

_(none yet — file grows as PRs/issues come in)_
