# Show the Catalog

## Context

Show the full librarian catalog with install status for the configured provider directories.

## Input

The user may optionally specify a provider:

- `/librarian catalog` → show status for all configured providers
- `/librarian catalog for claude` → show status for Claude only
- `/librarian catalog for pi` → show status for Pi only

## Steps

### 1. Sync the Librarian Repo

Pull the latest catalog before reading:

```bash
cd <LIBRARIAN_SKILL_DIR>
git pull
```

### 2. Read the Catalog

- Read `librarian.yaml`
- Parse `default_provider`, `providers`, and all entries from `library.skills`, `library.agents`, `library.prompts`, `library.pi-extensions`, and `library.pi-themes`
- If the catalog only has legacy `default_dirs`, treat it as one `claude` provider

### 3. Select Provider(s)

- If the user named a provider, check only that provider
- Otherwise, check all configured providers
- For each provider, read the `default` and `global` directories for each supported type

### 4. Check Install Status

For each entry and selected provider:

- Determine the type (`skills`, `agents`, `prompts`, `pi-extensions`, or `pi-themes`)
- If the provider does not define that type, mark `<provider>: unsupported`
- Check if a matching directory or file exists in the provider's `default` directory
- Check if a matching directory or file exists in the provider's `global` directory
- Search recursively for name matches
- Mark as:
  - `<provider>: installed (default)`
  - `<provider>: installed (global)`
  - `<provider>: installed (default + global)`
  - `<provider>: not installed`
  - `<provider>: unsupported`

### 5. Display Results

Format the output as a table grouped by type:

```md
## Skills
| Name | Description | Source | Status |
|------|-------------|--------|--------|
| skill-name | skill-description | /local/path/... | claude: installed (global); pi: not installed |
| other-skill | other-description | github.com/... | claude: not installed; pi: installed (default) |

## Agents
| Name | Description | Source | Status |
|------|-------------|--------|--------|
| agent-name | agent-description | /local/path/... | claude: installed (global) |

## Prompts
| Name | Description | Source | Status |
|------|-------------|--------|--------|
| prompt-name | prompt-description | github.com/... | pi: not installed |

## Pi Extensions
| Name | Description | Source | Status |
|------|-------------|--------|--------|
| permission-gate | prompts before dangerous commands | github.com/... | pi: installed (global) |

## Pi Themes
| Name | Description | Source | Status |
|------|-------------|--------|--------|
| midnight | dark blue-accent theme | github.com/... | pi: installed (default) |
```

If a section is empty, show: `No <type> in catalog.`

### 6. Summary

At the bottom, show:

- Total entries in catalog
- Providers checked
- Total installed copies found
- Total entries with no installed copy in the checked provider(s)
