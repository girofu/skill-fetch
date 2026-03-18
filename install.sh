#!/usr/bin/env bash
set -euo pipefail

# --- Colors ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

info()    { printf "${BLUE}ℹ${NC}  %s\n" "$1"; }
success() { printf "${GREEN}✓${NC}  %s\n" "$1"; }
warn()    { printf "${YELLOW}⚠${NC}  %s\n" "$1"; }
error()   { printf "${RED}✗${NC}  %s\n" "$1" >&2; }
die()     { error "$1"; exit 1; }

# --- Constants ---
REPO_BASE="https://raw.githubusercontent.com/girofu/skill-fetch/main"
FILES=("skills/skill-fetch/SKILL.md" "references/quality-signals.md" "references/interaction-patterns.md" "references/platform-adapters.md")
AGENTS=("claude" "cursor" "codex" "gemini" "windsurf" "amp")
SCOPE="global"
TARGET_AGENT=""
INSTALL_ALL=false

agent_dir() {
  case "$1" in
    claude)   echo ".claude" ;;
    cursor)   echo ".cursor" ;;
    codex)    echo ".codex" ;;
    gemini)   echo ".gemini" ;;
    windsurf) echo ".windsurf" ;;
    amp)      echo ".amp" ;;
    *)        die "Unknown agent: $1" ;;
  esac
}

usage() {
  cat <<HELP
${BOLD}skill-fetch installer${NC}

Usage: install.sh [OPTIONS]

Options:
  --agent <name>   Install for a specific agent (claude, cursor, codex, gemini, windsurf, amp)
  --all            Install for all detected agents (skip prompt)
  --global         Install globally to ~/.<agent>/ (default)
  --local          Install to current project directory
  --help           Show this help message

Examples:
  install.sh                     # Auto-detect agents, prompt if multiple
  install.sh --agent claude      # Install for Claude Code only
  install.sh --all               # Install for all detected agents
  install.sh --local --agent cursor  # Install to .cursor/ in current project
HELP
  exit 0
}

# --- Parse flags ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)  [[ -z "${2:-}" ]] && die "--agent requires a name"; TARGET_AGENT="$2"; shift 2 ;;
    --global) SCOPE="global"; shift ;;
    --local)  SCOPE="local"; shift ;;
    --all)    INSTALL_ALL=true; shift ;;
    --help)   usage ;;
    *)        die "Unknown option: $1. Use --help for usage." ;;
  esac
done

# --- Preflight checks ---
command -v curl >/dev/null 2>&1 || die "curl is required but not installed."

# --- Detect installed agents ---
detect_agents() {
  local found=()
  for a in "${AGENTS[@]}"; do
    local dir; dir="$(agent_dir "$a")"
    if [[ -d "${HOME}/${dir}" ]]; then
      found+=("$a")
    fi
  done
  echo "${found[@]}"
}

# --- Download a single file ---
download_file() {
  local url="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if ! curl -fsSL --retry 2 --connect-timeout 10 -o "$dest" "$url"; then
    error "Failed to download: $url"
    return 1
  fi
}

# --- Install for one agent ---
install_for_agent() {
  local agent="$1"
  local dir; dir="$(agent_dir "$agent")"
  local base

  if [[ "$SCOPE" == "global" ]]; then
    base="${HOME}/${dir}/skills/skill-fetch"
  else
    base="./${dir}/skills/skill-fetch"
  fi

  info "Installing skill-fetch for ${BOLD}${agent}${NC} → ${base}"

  local fail=0
  for file in "${FILES[@]}"; do
    local url="${REPO_BASE}/${file}"
    local dest
    case "$file" in
      skills/skill-fetch/*)
        dest="${base}/${file#skills/skill-fetch/}" ;;
      references/*)
        dest="${base}/${file}" ;;
    esac
    if ! download_file "$url" "$dest"; then
      fail=1
    fi
  done

  if [[ $fail -eq 0 ]]; then
    success "Installed for ${agent} at ${base}"
  else
    warn "Some files failed to download for ${agent}"
  fi
}

# --- Resolve target agents ---
if [[ -n "$TARGET_AGENT" ]]; then
  # Validate agent name
  valid=false
  for a in "${AGENTS[@]}"; do
    [[ "$a" == "$TARGET_AGENT" ]] && valid=true
  done
  $valid || die "Unknown agent '${TARGET_AGENT}'. Valid: ${AGENTS[*]}"
  targets=("$TARGET_AGENT")
else
  read -ra detected <<< "$(detect_agents)"
  if [[ ${#detected[@]} -eq 0 ]]; then
    die "No supported AI coding agents detected. Use --agent <name> to install manually."
  elif [[ ${#detected[@]} -eq 1 ]]; then
    targets=("${detected[0]}")
    info "Detected agent: ${BOLD}${detected[0]}${NC}"
  elif $INSTALL_ALL; then
    targets=("${detected[@]}")
    info "Installing for all detected agents: ${detected[*]}"
  else
    echo ""
    info "Multiple agents detected:"
    for i in "${!detected[@]}"; do
      printf "  ${BOLD}%d)${NC} %s\n" $((i + 1)) "${detected[$i]}"
    done
    printf "  ${BOLD}a)${NC} All of the above\n"
    echo ""
    printf "Choose an option [1-%d/a]: " "${#detected[@]}"
    read -r choice
    if [[ "$choice" == "a" || "$choice" == "A" ]]; then
      targets=("${detected[@]}")
    elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#detected[@]} )); then
      targets=("${detected[$((choice - 1))]}")
    else
      die "Invalid choice: $choice"
    fi
  fi
fi

# --- Install ---
echo ""
for t in "${targets[@]}"; do
  install_for_agent "$t"
done

# --- Done ---
echo ""
success "${BOLD}Installation complete!${NC}"
echo ""
info "Usage: Ask your AI agent to use the ${BOLD}skill-fetch${NC} skill, or reference it with:"
echo "     ${BOLD}/skill-fetch${NC} (if supported by your agent)"
echo ""
