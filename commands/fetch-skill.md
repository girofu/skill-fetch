---
name: fetch-skill
description: Search and install AI agent skills from multiple registries
arguments:
  - name: query
    description: Search keywords or a GitHub URL to install from
    required: false
user-invocable: true
---

# Fetch Skill

Delegate to the `skill-fetch` skill with the provided arguments.

## Procedure

1. Invoke `Skill("skill-fetch")` with `$ARGUMENTS` passed through
2. The skill handles search, scoring, display, and installation
3. If no arguments provided, the skill will extract keywords from the current task context

## Examples

```
/fetch-skill react native animation
/fetch-skill https://github.com/owner/skill-repo
/fetch-skill testing
```
