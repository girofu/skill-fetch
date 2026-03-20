#!/bin/bash
# Skills Directory API search script for skill-fetch
# Reads SKILLS_DIRECTORY_API_KEY from ~/.claude/skills/.fetch-config.json
# Usage: bash fetch-skills-directory.sh "search+query"

CONFIG="$HOME/.claude/skills/.fetch-config.json"
if [ ! -f "$CONFIG" ]; then
  echo '{"data":[],"error":"config not found","hint":"Create ~/.claude/skills/.fetch-config.json with SKILLS_DIRECTORY_API_KEY"}'
  exit 1
fi

KEY=$(node -e "const c=require('$CONFIG');console.log(c.SKILLS_DIRECTORY_API_KEY||'')")
if [ -z "$KEY" ]; then
  echo '{"data":[],"error":"no SKILLS_DIRECTORY_API_KEY in config"}'
  exit 1
fi

QUERY=$(printf '%s' "$1" | python3 -c "import sys,urllib.parse;print(urllib.parse.quote(sys.stdin.read().strip()))")
curl -s "https://www.skillsdirectory.com/api/v1/skills?q=$QUERY&limit=5&securityGrade=A" \
  -H "x-api-key: $KEY"
