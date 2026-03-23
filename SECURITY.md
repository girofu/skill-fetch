# Security Policy

## Supported Versions

Only the **latest released version** of skill-fetch receives security fixes. Please ensure you are running the most recent version before reporting a vulnerability.

| Version | Supported |
|---------|-----------|
| Latest  | Yes       |
| Older   | No        |

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub Issues.**

Please report security vulnerabilities using **GitHub Security Advisories**:

1. Go to https://github.com/girofu/skill-fetch
2. Navigate to **Settings** → **Security** → **Advisories**
3. Click **New draft security advisory**
4. Fill in the details: affected versions, description, reproduction steps, and impact
5. Submit the draft — only you and the maintainer can see it

### Response Timeline

- **48 hours**: Acknowledgment of the report
- **7 days**: Assessment and initial fix plan provided
- **Coordinated disclosure**: We will work with you on a disclosure timeline before publishing the advisory publicly

If you do not receive a response within 48 hours, please follow up by opening a non-sensitive GitHub Issue noting that you have submitted a security advisory and are awaiting a response.

## Security Design

skill-fetch is designed with the following security properties:

### Local-Only Credential Storage

API keys and tokens are stored exclusively in the local file `~/.claude/skills/.fetch-config.json` on the user's machine. This file is never read, transmitted, or uploaded by skill-fetch itself. Users are responsible for protecting this file with appropriate filesystem permissions (recommended: `chmod 600`).

### SHA-256 Integrity Verification

When a skill is installed, skill-fetch records the SHA-256 hash of the installed files at installation time. This hash can be used to verify that the installed skill has not been tampered with after installation.

### 6-Category Security Scan

Before and after installation, skill-fetch performs a security scan across 6 categories (labeled A through F):

- **A**: Credential and secret exposure (API keys, tokens, passwords in code)
- **B**: Dangerous shell operations (eval, arbitrary code execution, unsafe redirects)
- **C**: Network exfiltration (unexpected outbound connections, data exfiltration patterns)
- **D**: Filesystem access (writes outside expected skill directories, path traversal)
- **E**: Supply chain risks (unpinned dependencies, obfuscated code)
- **F**: Privilege escalation (sudo usage, setuid, capability manipulation)

Scan results are displayed to the user before installation is finalized, allowing an informed decision.

### Fail-Safe Shell Scripts

All shell scripts in skill-fetch use `set -euo pipefail` at the top of every script. This ensures:

- `-e`: Exit immediately on any command failure
- `-u`: Treat unset variables as errors (prevents silent use of empty strings)
- `-o pipefail`: Propagate errors through pipes rather than silently swallowing them

### JSON Injection Prevention

All API scripts use `node`'s built-in `JSON.stringify()` and `JSON.parse()` for constructing and parsing JSON data. User-supplied query strings are never concatenated directly into JSON payloads or shell commands, preventing injection attacks.

## Scope

This security policy covers vulnerabilities in **skill-fetch itself** — the plugin code, search logic, installation scripts, and security scanning infrastructure.

It does **not** cover:

- Security issues within skills that are discovered and installed by skill-fetch (those should be reported to the respective skill authors)
- Vulnerabilities in external registries or APIs that skill-fetch queries
- Issues arising from user misconfiguration of API keys or file permissions
