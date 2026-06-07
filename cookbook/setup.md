# Set Up The Librarian

## Context

First-time setup of The Librarian on a new device. The user either has the template repo cloned directly, or has already forked it to their own private repo.

## Steps

### 1. Check Prerequisites

- Verify `git` is installed: `git --version`
- Verify the Pi global skills directory exists or can be created: `~/.pi/agent/skills/`
- If using additional providers, verify their global directories exist or can be created, e.g. `~/.pi/agent/skills/`, `~/.pi/agent/extensions/`, and `~/.pi/agent/themes/`

### 2. Determine Fork Status

Ask the user: **"Is this the template repo or your own fork?"**

**If template repo (hasn't forked yet):**

- Instruct the user to create a private fork on GitHub
- Once forked, update the remote URL:
  ```bash
  cd <LIBRARIAN_SKILL_DIR>
  git remote set-url origin <fork_url>
  ```
- Verify with: `git remote -v`

**If already forked:**

- Skip this step — the remote is already pointing to their fork

### 3. Clone to Global Skills Directory

If the repo isn't already cloned locally:

```bash
mkdir -p <LIBRARIAN_SKILL_DIR>
cd <LIBRARIAN_SKILL_DIR>
git clone <fork_url> .
```

If already cloned (e.g., user cloned the template first), just update the remote per step 2.

### 4. Update Variables and Providers

- Open `SKILL.md` in the librarian directory
- Take note of your current working directory
- Update the `## Variables` section:
  - **LIBRARIAN_REPO_URL**: Set to the user's fork URL
  - **LIBRARIAN_YAML_PATH**: Confirm path (default: `~/.pi/agent/skills/librarian/librarian.yaml`)
  - **LIBRARIAN_SKILL_DIR**: Confirm path (default: `~/.pi/agent/skills/librarian/`)
- Open `librarian.yaml`
- Confirm `default_provider` is set to the provider the user wants by default, usually `pi`
- Confirm `providers` contains any provider install directories the user wants
- Only include the types a provider actually supports, for example:

```yaml
default_provider: pi
providers:
  claude:
    skills:
      default: .claude/skills/
      global: ~/.claude/skills/
    agents:
      default: .claude/agents/
      global: ~/.claude/agents/
    prompts:
      default: .claude/commands/
      global: ~/.claude/commands/
  pi:
    skills:
      default: .pi/skills/
      global: ~/.pi/agent/skills/
    prompts:
      default: .pi/prompts/
      global: ~/.pi/agent/prompts/
    pi-extensions:
      default: .pi/extensions/
      global: ~/.pi/agent/extensions/
    pi-themes:
      default: .pi/themes/
      global: ~/.pi/agent/themes/
```

### 5. Verify Installation

- Confirm `SKILL.md` exists at `<LIBRARIAN_SKILL_DIR>/SKILL.md`
- Confirm `librarian.yaml` exists at `<LIBRARIAN_SKILL_DIR>/librarian.yaml`
- Confirm the librarian command is available in the default provider environment (`/skill:librarian` in Pi)
- Optionally run `/skill:librarian catalog` to verify the catalog and provider statuses load

### 6. Done

Tell the user:

- The Librarian is now globally available
- The default provider is configured
- `/skill:librarian catalog` in Pi will show the catalog and install status by provider
- `/skill:librarian install <name> for <provider>` installs into a specific provider
- `/skill:librarian register` starts adding skills, agents, prompts, Pi extensions, and Pi themes
- The `justfile` in the librarian directory has shorthand commands
