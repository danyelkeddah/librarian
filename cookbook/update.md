# Update All Installed Items

## Context

Refresh every locally installed skill, agent, prompt, Pi extension, and Pi theme by re-pulling from its source. Update only changes items that are already installed in a provider directory.

## Input

The user may optionally specify a provider:

- `/librarian update` → update installed items across all configured providers
- `/librarian update for claude` → update Claude installs only
- `/librarian update for pi` → update Pi installs only

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

### 4. Find All Installed Items

For each entry in the catalog and each selected provider:

- Determine the type (`skills`, `agents`, `prompts`, `pi-extensions`, or `pi-themes`)
- If the provider does not define that type, skip it
- Check if a directory or file matching the entry name exists in the provider's `default` directory
- Check if a directory or file matching the entry name exists in the provider's `global` directory
- Search recursively for name matches
- Collect each installed copy with its provider and scope (`default` or `global`)
- If nothing is installed, tell the user and exit

### 5. Resolve Dependencies

For each installed entry that has a `requires` field:

- Check if each dependency is also installed in the same provider/scope
- If a dependency is not installed, pull it using the `install` workflow for that same provider/scope
- Process dependencies before the items that require them

### 6. Re-pull Each Installed Copy

Fetch the source once per entry, then copy it into each installed provider target.

**If source is a local path** (starts with `/` or `~`):

- Resolve `~` to the home directory
- Use the referenced file as the source file

**If source is a GitHub URL**:

- Parse the URL to extract: `org`, `repo`, `branch`, `file_path`
  - Browser URL pattern: `https://github.com/<org>/<repo>/blob/<branch>/<path>`
  - Raw URL pattern: `https://raw.githubusercontent.com/<org>/<repo>/<branch>/<path>`
- Determine the clone URL: `https://github.com/<org>/<repo>.git`
- Clone into a temporary directory:
  ```bash
  tmp_dir=$(mktemp -d)
  git clone --depth 1 --branch <branch> https://github.com/<org>/<repo>.git "$tmp_dir"
  ```
- If clone fails for a private repo, try SSH:
  ```bash
  git clone --depth 1 --branch <branch> git@github.com:<org>/<repo>.git "$tmp_dir"
  ```
- Use `$tmp_dir/<file_path>` as the source file
- Clean up the temp directory after copying

**Copy rules per installed provider target:**

- For skills: copy the entire parent directory of the source file to the existing target:
  ```bash
  cp -R <source_parent_directory>/ <target_root>/<name>/
  ```
- For agents: copy the agent file to the existing target:
  ```bash
  cp <source_file> <target_root>/<agent_name>.md
  ```
- For prompts: copy the prompt file to the existing target:
  ```bash
  cp <source_file> <target_root>/<prompt_name>.md
  ```
- For Pi extensions:
  - If the source file is `index.ts` or `index.js`, copy the entire parent directory:
    ```bash
    cp -R <source_parent_directory>/ <target_root>/<name>/
    ```
  - Otherwise, copy the extension file using the same extension:
    ```bash
    cp <source_file> <target_root>/<name>.<ts-or-js>
    ```
- For Pi themes: copy the theme JSON file to the existing target:
  ```bash
  cp <source_file> <target_root>/<theme_name>.json
  ```
- If an agent or prompt is nested in a subdirectory under `agents/`, `commands/`, or `prompts/`, preserve that subdirectory when the target provider supports nested files.

### 7. Report Results

Display a summary table:

```md
## Update Complete

| Provider | Scope | Type | Name | Status |
|----------|-------|------|------|--------|
| claude | global | skill | skill-name | refreshed |
| pi | default | pi-theme | midnight | refreshed |
| claude | default | skill | other-skill | failed: <reason> |
```

Then show:

- Updated: X installed copies
- Failed: Y installed copies

If any items failed (e.g., network error, missing source), list them with the reason so the user can fix individually.
