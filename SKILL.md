---
name: librarian
disable-model-invocation: true
user-invocable: true
description: Private distribution system for skills, agents, prompts, Pi extensions, and Pi themes across providers. Use when the user wants to set up Librarian or register, install, update, publish, remove, catalog, or find skills, agents, prompts, Pi extensions, or Pi themes from their private catalog. Triggers on /librarian or /skill:librarian commands, skill distribution, provider installs, Pi extensions, Pi themes, or agentic management.
argument-hint: "[command] [name or details] [for provider|everywhere]"
---

# The Librarian

A meta-skill for private-first distribution of skills, agents, prompts, Pi extensions, and Pi themes across your agents, devices, teams, and providers.

## Variables

- **LIBRARIAN_REPO_URL**: `https://github.com/danyelkeddah/librarian.git`
- **LIBRARIAN_YAML_PATH**: `~/.pi/agent/skills/librarian/librarian.yaml`
- **LIBRARIAN_SKILL_DIR**: `~/.pi/agent/skills/librarian/`

## How It Works

The Librarian is a catalog of references to your skills, agents, prompts, Pi extensions, and Pi themes. The `librarian.yaml` file points to where they live (local filesystem or GitHub repos) and which provider directories they can install into. Nothing is fetched until you ask for it.

**The `librarian.yaml` is a catalog, not a manifest.** Entries define what's _available_ — not what gets installed. You install specific items on demand with `/librarian install <name>`. If no provider is named, Librarian uses `default_provider`.

**Security:** Pi extensions run with full system permissions. Review extension source before installing from untrusted sources.

## Commands

| Command                                         | Purpose                                         |
| ----------------------------------------------- | ----------------------------------------------- |
| `/librarian setup`                              | First-time Librarian setup: fork, clone, config |
| `/librarian register <details>`                 | Register a new catalog entry                    |
| `/librarian install <name>`                     | Install or refresh an item to default provider  |
| `/librarian install <name> for <provider>`      | Install to a specific provider, e.g. `for pi`   |
| `/librarian install <name> everywhere`          | Install to all configured providers             |
| `/librarian publish <name>`                     | Publish local changes back to source            |
| `/librarian remove <name>`                      | Remove from catalog and optionally local copies |
| `/librarian catalog`                            | Show catalog with provider install status       |
| `/librarian update`                             | Refresh installed items from source             |
| `/librarian find <keyword>`                     | Find entries by keyword                         |

**Pi invocation:** Pi exposes skills as `/skill:<name>`. When running from Pi, use `/skill:librarian <command>` or the `justfile` recipes.

## Cookbook

Each command has a detailed step-by-step guide. **Read the relevant cookbook file before executing a command.**

| Command  | Cookbook                                       | Use When                                                        |
| -------- | ---------------------------------------------- | --------------------------------------------------------------- |
| setup    | [cookbook/setup.md](cookbook/setup.md)         | User wants first-time setup on a new device                     |
| register | [cookbook/register.md](cookbook/register.md)   | User wants to register a new skill/agent/prompt/pi item         |
| install  | [cookbook/install.md](cookbook/install.md)     | User wants to install or refresh an item for one or more providers |
| publish  | [cookbook/publish.md](cookbook/publish.md)     | User improved an installed item and wants to publish to source  |
| remove   | [cookbook/remove.md](cookbook/remove.md)       | User wants to remove an entry from the catalog                  |
| catalog  | [cookbook/catalog.md](cookbook/catalog.md)     | User wants to see what's available and what's installed         |
| update   | [cookbook/update.md](cookbook/update.md)       | User wants to refresh all installed items at once               |
| find     | [cookbook/find.md](cookbook/find.md)           | User is looking for an item but doesn't know the exact name     |

**When a user invokes a `/librarian` or `/skill:librarian` command, read the matching cookbook file first, then execute the steps.**

## Source Format

The `source` field in `librarian.yaml` supports these formats (auto-detected):

- `/absolute/path/to/SKILL.md` — local filesystem
- `https://github.com/org/repo/blob/main/path/to/SKILL.md` — GitHub browser URL
- `https://raw.githubusercontent.com/org/repo/main/path/to/SKILL.md` — GitHub raw URL
- `https://github.com/org/repo/blob/main/pi-extensions/my-extension.ts` — Pi extension file
- `https://github.com/org/repo/blob/main/pi-themes/my-theme.json` — Pi theme file

Both GitHub URL formats are supported. Parse org, repo, branch, and file path from the URL structure. For private repos, use SSH or `GITHUB_TOKEN` for auth automatically.

**Important:** The source points to a specific file (SKILL.md, AGENT.md, prompt file, Pi extension entry file, or Pi theme JSON file). Skills install as the source file's parent directory. Agents and prompts install as files. Pi extensions install as a `.ts`/`.js` file, or as a directory when the source points to `index.ts`/`index.js`. Pi themes install as `.json` files.

## Source Parsing Rules

**Local paths** start with `/` or `~`:

- Use the path directly. Apply the copy rule for the item type: skill directory, agent file, prompt file, Pi extension file/directory, or Pi theme file.

**GitHub browser URLs** match `https://github.com/<org>/<repo>/blob/<branch>/<path>`:

- Parse: `org`, `repo`, `branch`, `file_path`
- Clone URL: `https://github.com/<org>/<repo>.git`
- File location within repo: `<path>`

**GitHub raw URLs** match `https://raw.githubusercontent.com/<org>/<repo>/<branch>/<path>`:

- Parse: `org`, `repo`, `branch`, `file_path`
- Clone URL: `https://github.com/<org>/<repo>.git`
- File location within repo: `<path>`

## GitHub Workflow

When working with GitHub sources, prefer `gh api` for accessing single files (e.g., reading a SKILL.md to check metadata). For installing items, clone into a temp dir per the steps below.

**Fetching (install):**

1. Clone the repo with `git clone --depth 1 <clone_url>` into a temporary directory
2. Locate the referenced file inside the clone
3. Copy according to type: skill parent directory, agent file, prompt file, Pi extension file/directory, or Pi theme file
4. Repeat the copy for each selected provider target
5. The temporary directory is cleaned up automatically

**Publishing (publish):**

1. Clone the repo with `git clone --depth 1 <clone_url>` into a temporary directory
2. Overwrite the source item in the clone with the selected local version
3. Stage only the relevant changes: `git add <item_path>`
4. Commit with message: `librarian: updated <name> <what changed>`
5. Push to remote
6. The temporary directory is cleaned up automatically

## Typed Dependencies

The `requires` field uses typed references to avoid ambiguity:

- `skill:name` — references a skill in the catalog
- `agent:name` — references an agent in the catalog
- `prompt:name` — references a prompt in the catalog
- `pi-extension:name` — references a Pi extension in `library.pi-extensions`
- `pi-theme:name` — references a Pi theme in `library.pi-themes`

When resolving dependencies: look up each reference in `librarian.yaml`, fetch all dependencies first (recursively), then fetch the requested item. Dependencies use the same provider selection and scope as the requested item.

## Provider Target Directories

Entries are provider-neutral where possible. Providers define install destinations. Provider-specific item types, like `pi-extensions` and `pi-themes`, still live in the catalog and install to their matching provider by default.

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

The catalog types are named `pi-extensions` (not generic `extensions`) and `pi-themes` to keep provider-specific items explicit. Install paths still use Pi's native `.pi/extensions/` and `.pi/themes/` directories so Pi can auto-discover them.

Providers use their own native settings and may omit unsupported types. For example, Pi has skills, prompt templates, extensions, and themes, but no built-in agent directory.

Provider selection rules:

- If the user says `for <provider>`, use that provider from `providers`.
- If the user says `everywhere` or `all providers`, install to every configured provider.
- If no provider is mentioned, use `default_provider`.
- For `pi-extensions` and `pi-themes`, use the `pi` provider by default because these item types are provider-specific.
- If the user says "global" or "globally", use the provider's `global` directory.
- If the user specifies a custom path, use that path for the selected provider request.
- Otherwise, use the provider's `default` directory.

For backward compatibility, if an older catalog has `default_dirs` but no `providers`, treat it as a single `claude` provider.

## Librarian Repo Sync

The librarian skill itself lives in `<LIBRARIAN_SKILL_DIR>` as a cloned git repo. When running `register` (which modifies `librarian.yaml`), always:

1. `git pull` in the librarian directory first to get latest
2. Make the changes
3. `git add librarian.yaml && git commit && git push`

This keeps the catalog in sync across devices.

## Repo Naming Convention

The librarian manages content stored in library repos. The naming convention:

- `librarian` — this meta-skill (the distribution engine)
- `library` — your core collection of skills, agents, prompts, Pi extensions, and Pi themes
- `library-engineering` — engineering-specific
- `library-marketing` — marketing-specific
- `library-design` — design-specific

## Example Filled Librarian File

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

library:
  skills:
    - name: firecrawl
      description: Scrape, crawl, and search websites using Firecrawl CLI
      source: /Users/me/projects/tools/skills/firecrawl/SKILL.md

    - name: meta-skill
      description: Creates new Agent Skills following best practices
      source: /Users/me/projects/tools/skills/meta-skill/SKILL.md

    - name: diagram-kroki
      description: Generate diagrams via Kroki HTTP API supporting 28+ languages
      source: https://github.com/myorg/library/blob/main/skills/diagram-kroki/SKILL.md
      requires: [skill:firecrawl]

    - name: green-screen-captions
      description: Generate and burn AI-powered captions onto green screen videos
      source: https://github.com/myorg/library/blob/main/skills/green-screen-captions/SKILL.md
      requires: [agent:video-processor, prompt:caption-style]

  agents:
    - name: video-processor
      description: Processes video files with ffmpeg and whisper transcription
      source: /Users/me/projects/tools/agents/video-processor/AGENT.md

    - name: code-reviewer
      description: Reviews code for quality, security, and performance
      source: https://github.com/myorg/library/blob/main/agents/code-reviewer/AGENT.md

  prompts:
    - name: caption-style
      description: Style guide for generating video captions
      source: /Users/me/projects/content/prompts/caption-style.md

    - name: commit-message
      description: Standardized commit message format for all projects
      source: https://github.com/myorg/library/blob/main/prompts/commit-message.md

  pi-extensions:
    - name: permission-gate
      description: Prompts before dangerous bash commands in Pi
      source: https://github.com/myorg/library/blob/main/pi-extensions/permission-gate.ts

  pi-themes:
    - name: midnight
      description: Dark Pi TUI theme with blue accents
      source: https://github.com/myorg/library/blob/main/pi-themes/midnight.json
```
