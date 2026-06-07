# Install an Item from the Catalog

## Context

Pull a skill, agent, prompt, Pi extension, or Pi theme from the catalog into the selected provider. If already installed there, overwrite with the latest from the source (refresh).

## Input

The user provides a skill, agent, prompt, Pi extension, or Pi theme name/description. They may also specify a provider and scope:

- `for claude` / `for pi` → install to that provider
- `everywhere` / `all providers` → install to every configured provider
- `global` / `globally` → use the provider's global directory
- no provider → use `default_provider`; Pi extensions and Pi themes use `pi` by default

## Steps

### 1. Sync the Librarian Repo

Pull the latest catalog before reading:

```bash
cd <LIBRARIAN_SKILL_DIR>
git pull
```

### 2. Find the Entry

- Read `librarian.yaml`
- Search across `library.skills`, `library.agents`, `library.prompts`, `library.pi-extensions`, and `library.pi-themes`
- Match by name (exact) or description (fuzzy/keyword match)
- If multiple matches, show them and ask the user to pick one
- If no match, tell the user and suggest `/librarian find`

### 3. Determine Provider Target(s)

- Read `default_provider` and `providers` from `librarian.yaml`
- If the catalog only has legacy `default_dirs`, treat it as one `claude` provider
- If user said `everywhere` or `all providers` → select every configured provider
- If user said `for <provider>` → select that provider
- Otherwise, if the entry is a Pi extension or Pi theme → select `pi`
- Otherwise → select `default_provider`
- If user specified a custom target path, use that as the target root for this install
- Otherwise, if user said `global` or `globally` → use `global`; else use `default`
- Select the correct type section (`skills`, `agents`, `prompts`, `pi-extensions`, or `pi-themes`)
- Target root format: `providers.<provider>.<type>.<scope>`

If a selected provider is missing the needed type or scope, warn the user and skip that provider.

### 4. Resolve Dependencies

If the entry has a `requires` field:

- For each typed reference (`skill:name`, `agent:name`, `prompt:name`, `pi-extension:name`, `pi-theme:name`):
  - Look it up in `librarian.yaml`
  - If found, recursively run the `install` workflow for that dependency first
  - Use the same selected provider(s) and scope as the requested item
  - If not found, warn the user: "Dependency <ref> not found in the catalog"
- Process all dependencies before the requested item

### 5. Fetch from Source

Fetch the source once, then copy it into each selected provider target.

For Pi extensions, remember that extensions run with full system permissions. If the source is not trusted, review the extension file before installing.

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

**Copy rules per selected provider target:**

- For skills: copy the entire parent directory of the source file to the target:
  ```bash
  cp -R <source_parent_directory>/ <target_root>/<name>/
  ```
- For agents: copy the agent file to the target:
  ```bash
  cp <source_file> <target_root>/<agent_name>.md
  ```
- For prompts: copy the prompt file to the target:
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
- For Pi themes: copy the theme JSON file to the target:
  ```bash
  cp <source_file> <target_root>/<theme_name>.json
  ```
- If an agent or prompt is nested in a subdirectory under `agents/`, `commands/`, or `prompts/`, preserve that subdirectory when the target provider supports nested files.

### 6. Verify Installation

For each selected provider target:

- Confirm the target directory/file exists
- Confirm the main file (`SKILL.md`, `AGENT.md`, prompt file, Pi extension entry file, or Pi theme JSON file) exists
- Report success with the installed path

### 7. Confirm

Tell the user:

- What was installed
- Which provider(s) it was installed to
- Where it was installed
- Any dependencies that were also installed
- If this was a refresh (overwrite), mention that
