#!/bin/bash
# SkillHub API search script for skill-fetch
# Reads SKILLHUB_API_KEY from ~/.claude/skills/.fetch-config.json
# Usage: bash fetch-skillhub.sh "search query"

CONFIG="$HOME/.claude/skills/.fetch-config.json"
if [ ! -f "$CONFIG" ]; then
  echo '{"error":"config not found","hint":"Create ~/.claude/skills/.fetch-config.json with SKILLHUB_API_KEY"}'
  exit 1
fi

KEY=$(node -e "const c=require('$CONFIG');console.log(c.SKILLHUB_API_KEY||'')")
if [ -z "$KEY" ]; then
  echo '{"error":"no SKILLHUB_API_KEY in config"}'
  exit 1
fi

QUERY=$(printf '%s' "$1" | sed 's/[\\"]/\\&/g')
curl -s -X POST "https://www.skillhub.club/api/v1/skills/search" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$QUERY\", \"limit\": 5, \"method\": \"hybrid\"}"
