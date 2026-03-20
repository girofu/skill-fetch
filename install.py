#!/usr/bin/env python3
"""Skill-fetch installer — Python 3.6+, zero external dependencies."""
import argparse, sys, urllib.request, urllib.error
from pathlib import Path

BASE_URL = "https://raw.githubusercontent.com/girofu/skill-fetch/main/"
FILES = [
    "skills/skill-fetch/SKILL.md",
    "skills/skill-fetch/references/quality-signals.md",
    "skills/skill-fetch/references/interaction-patterns.md",
    "skills/skill-fetch/references/platform-adapters.md",
    "skills/skill-fetch/references/search-sources.md",
    "skills/skill-fetch/scripts/fetch-skillhub.sh",
    "skills/skill-fetch/scripts/fetch-skills-directory.sh",
]


def _a(d, label, sk=None):
    base = sk or "{}/skills/skill-fetch".format(d)
    return {
        "dir": d,
        "label": label,
        "skill": base,
    }


# fmt: off
AGENTS = {
    "claude":   _a(".claude",   "Claude Code"),
    "cursor":   _a(".cursor",   "Cursor"),
    "codex":    _a(".codex",    "Codex"),
    "gemini":   _a(".gemini",   "Gemini CLI"),
    "windsurf": _a(".windsurf", "Windsurf"),
    "amp":      _a(".amp",      "Amp"),
}
# fmt: on

# ANSI colors
GREEN, YELLOW, RED, CYAN = "\033[32m", "\033[33m", "\033[31m", "\033[36m"
BOLD, RESET = "\033[1m", "\033[0m"


def cprint(color, msg):
    sys.stdout.write("{}{}{}\n".format(color, msg, RESET))


def detect_agents():
    home = Path.home()
    return [k for k, v in AGENTS.items() if (home / v["dir"]).is_dir()]


def download(url):
    try:
        with urllib.request.urlopen(url, timeout=15) as resp:
            return resp.read()
    except urllib.error.URLError as e:
        cprint(RED, "  Download failed: {} - {}".format(url, e))
        return None


def install_for_agent(agent_key, root):
    info = AGENTS[agent_key]
    cprint(CYAN, "\nInstalling for {} ...".format(info["label"]))
    skill_dir = root / info["skill"]
    skill_dir.mkdir(parents=True, exist_ok=True)
    ok = 0
    prefix = "skills/skill-fetch/"
    for rel in FILES:
        data = download(BASE_URL + rel)
        if data is None:
            continue
        sub_path = rel[len(prefix) :]
        dest = skill_dir / sub_path
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
        cprint(GREEN, "  ✓ {}".format(dest.relative_to(root)))
        ok += 1
    status = "install complete" if ok == len(FILES) else "partial install"
    color = GREEN if ok == len(FILES) else YELLOW
    cprint(color, "  {} {} ({}/{} files)".format(info["label"], status, ok, len(FILES)))


def main():
    p = argparse.ArgumentParser(description="Install skill-fetch for AI coding agents")
    p.add_argument(
        "--agent", choices=list(AGENTS.keys()), help="Install for a specific agent"
    )
    p.add_argument(
        "--all",
        dest="install_all",
        action="store_true",
        help="Install for all detected agents",
    )
    scope = p.add_mutually_exclusive_group()
    scope.add_argument(
        "--global",
        dest="global_install",
        action="store_true",
        default=True,
        help="Install globally (default)",
    )
    scope.add_argument(
        "--local",
        dest="local_install",
        action="store_true",
        help="Install to current project",
    )
    args = p.parse_args()

    root = Path.cwd() if args.local_install else Path.home()
    cprint(BOLD, "skill-fetch installer")
    cprint(BOLD, "Install root: {}".format(root))

    if args.agent:
        targets = [args.agent]
    elif args.install_all:
        targets = detect_agents()
        if not targets:
            cprint(YELLOW, "No supported agents detected.")
            sys.exit(1)
        cprint(
            GREEN, "Detected: {}".format(", ".join(AGENTS[a]["label"] for a in targets))
        )
    else:
        detected = detect_agents()
        if not detected:
            cprint(
                YELLOW,
                "No supported agents detected. Use --agent <name> to install manually.",
            )
            sys.exit(1)
        if len(detected) == 1:
            targets = detected
        else:
            cprint(
                GREEN,
                "Detected: {}".format(", ".join(AGENTS[a]["label"] for a in detected)),
            )
            cprint(YELLOW, "Multiple agents found. Use --agent <name> or --all.")
            sys.exit(0)

    for agent_key in targets:
        install_for_agent(agent_key, root)
    cprint(BOLD + GREEN, "\nDone!")


if __name__ == "__main__":
    main()
