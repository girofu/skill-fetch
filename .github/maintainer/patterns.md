# Observed Patterns

Patterns the maintainer agent has learned while operating the repo. Use these to pattern-match new issues faster and to preempt recurring mistakes.

## Recurring Issues

### Partial skill downloads (install the directory, not the file)
- **First observed:** 2026-04-23 (internal review → [PR:1])
- **Cause:** Install logic hardcoded `SKILL.md` + `references/*.md` + `scripts/*.sh`. Skills that ship `.py` scripts, `assets/`, `templates/`, etc. were installed with missing files.
- **Resolution:** Full git-tree enumeration via `scripts/fetch-skill-bundle.sh` (PR:1).
- **Prevention:** Never hardcode subdir names or extensions in install/scan logic. Walk the tree.

### Project-scope `.mcp.json` in a public repo shadowing user-scope MCP registrations
- **First observed:** 2026-04-23 (internal review → [PR:5], affected v1.4.1)
- **Cause:** `db8deba` committed a repo-root `.mcp.json` that registered `skillsmp` without an API key, intending "auto-provision". Claude Code's MCP resolution gives project-scope precedence over user-scope, so the keyless server overrode the user-scope version where the key lives. Compounded by `marketplace.json` having `source: "./"` — the whole repo is the plugin payload, so the file shipped to every plugin user.
- **Resolution:** Delete `.mcp.json`; point users at `claude mcp add --scope user ...` / `/fetch-skill-config` (PR:5).
- **Prevention:**
  - Any MCP server requiring an API key or other secret MUST be registered at **user scope** via `claude mcp add --scope user` or via an interactive setup helper. Never commit `.mcp.json` to a public repo for such a server.
  - Project-scope `.mcp.json` is only appropriate for MCP servers that (a) need no secrets, or (b) read secrets from the user's environment / `~/.claude/skills/.fetch-config.json` at runtime — and even then, the plugin payload implications (`source: "./"`) must be considered.
  - Check `marketplace.json`'s `source` when reasoning about what ships to users. If `./`, treat every repo-root config file as user-visible.

## Codebase Patterns

- SKILL.md is the public contract; references/ files are progressive disclosure. Keep SKILL.md lean; push detail down into reference files.
- Every shell script must pass ShellCheck `--severity=warning`. CI enforces this.
- API keys live in `~/.claude/skills/.fetch-config.json` and are loaded by bundled scripts — never on command lines.

## Contributor Patterns

_(none yet — file grows as PRs/issues come in)_
