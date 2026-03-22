---
name: fetch-skill-config
description: Interactive API key setup for skill-fetch registries
user-invocable: true
---

# Fetch Skill Config

Interactive setup for skill-fetch API keys. Configures `~/.claude/skills/.fetch-config.json` and optionally installs the SkillsMP MCP server.

## Procedure

### Step 1: Read existing config

Read the file `~/.claude/skills/.fetch-config.json`. If it exists, parse the JSON. If it doesn't exist, treat all keys as empty.

### Step 2: Display current status

Show the user a status table:

```
## API Key Status

| Key | Status | Registry |
|-----|--------|----------|
| SKILLSMP_API_KEY | [SET/NOT SET] | SkillsMP (Sources 1-2) - Recommended |
| SKILLHUB_API_KEY | [SET/NOT SET] | SkillHub (Source 8) - Optional |
| SKILLS_DIRECTORY_API_KEY | [SET/NOT SET] | Skills Directory (Source 9) - Optional |

Sources 3-7 (GitHub, Anthropic Skills, ClawSkillHub, skills.sh, PolySkill) work without API keys.
```

### Step 3: Ask which keys to configure

Use AskUserQuestion to ask: "Which API keys would you like to configure? (enter numbers, e.g. `1,2` or `all`)"

Options:
1. `SKILLSMP_API_KEY` — Get from [skillsmp.com](https://skillsmp.com) (free, recommended)
2. `SKILLHUB_API_KEY` — Optional, for SkillHub API
3. `SKILLS_DIRECTORY_API_KEY` — Optional, for Skills Directory API

If the user says "none" or "skip", end here.

### Step 4: Collect keys one by one

For each selected key, use AskUserQuestion to ask:
- **SKILLSMP_API_KEY**: "Enter your SkillsMP API key (get one free at https://skillsmp.com):"
- **SKILLHUB_API_KEY**: "Enter your SkillHub API key:"
- **SKILLS_DIRECTORY_API_KEY**: "Enter your Skills Directory API key:"

If user enters empty or "skip" for a key, skip it (keep existing value if any).

### Step 5: Write config file

Merge new values with existing config (preserve keys the user didn't change). Write the result to `~/.claude/skills/.fetch-config.json`:

```json
{
  "SKILLSMP_API_KEY": "...",
  "SKILLHUB_API_KEY": "...",
  "SKILLS_DIRECTORY_API_KEY": "..."
}
```

Only include keys that have non-empty values.

### Step 6: SkillsMP MCP server setup

If `SKILLSMP_API_KEY` was set (new or existing), check if the SkillsMP MCP server is already available by checking if `skillsmp_search` MCP tools exist in the current session.

If not installed, run:
```bash
claude mcp add --scope user skillsmp -- npx -y skillsmp-mcp-server --env SKILLSMP_API_KEY={the_key}
```

If already installed but the key changed, run:
```bash
claude mcp remove skillsmp
claude mcp add --scope user skillsmp -- npx -y skillsmp-mcp-server --env SKILLSMP_API_KEY={the_key}
```

### Step 7: Done

Display a summary of what was configured and remind the user:

> Restart Claude Code to activate MCP server changes. After restart, use `/fetch-skill <query>` to search skills.
