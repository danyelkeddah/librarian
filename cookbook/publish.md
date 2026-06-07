# Publish an Item to the Source

## Context

The user has improved an installed skill, agent, prompt, Pi extension, or Pi theme and wants to publish changes back to the catalog source.

## Input

The user provides a skill, agent, prompt, Pi extension, or Pi theme name/description. They may optionally specify the provider to publish from:

- `from claude` / `for claude`
- `from pi` / `for pi`
- no provider → search all configured providers and ask if more than one local copy is found

## Steps

### 1. Find the Entry

- Read `librarian.yaml`
- Search across all sections for the matching entry
- Determine the type (skill, agent, prompt, Pi extension, or Pi theme)
- If no match, tell the user the item wasn't found in the catalog

### 2. Locate the Local Copy

- Read `default_provider` and `providers` from `librarian.yaml`
- If the catalog only has legacy `default_dirs`, treat it as one `claude` provider
- If the user named a provider, search that provider's `default` and `global` directories for the item type
- Otherwise, if the entry is a Pi extension or Pi theme, search the `pi` provider's `default` and `global` directories
- Otherwise, search all configured providers' `default` and `global` directories for the item type
- If a provider does not define that type, skip it
- For skills, look for `<target_root>/<name>/`
- For agents/prompts, look for `<target_root>/<name>.md` and recursive name matches
- For Pi extensions, look for `<target_root>/<name>.ts`, `<target_root>/<name>.js`, `<target_root>/<name>/index.ts`, `<target_root>/<name>/index.js`, and recursive name matches
- For Pi themes, look for `<target_root>/<name>.json`
- If found in multiple places, ask which one to publish
- If not found locally, tell the user there's nothing to publish

### 3. Check for Conflicts

**If source is a local path:**

- Compare the selected local installed copy with the source
- If the source has been modified since last pull, warn the user:
  "The source has changes that aren't in your local copy. Pushing will overwrite them. Continue?"

**If source is a GitHub URL:**

- Clone the repo to a temp directory (shallow):
  ```bash
  tmp_dir=$(mktemp -d)
  git clone --depth 1 --branch <branch> <clone_url> "$tmp_dir"
  ```
- Compare the item in the clone with the selected local copy
- If they differ AND the remote has changes not in the local copy, warn about conflict
- Ask the user to resolve before continuing

### 4. Publish to Source

**If source is a local path:**

- For skills, copy the entire selected local directory to the source parent directory, overwriting:
  ```bash
  cp -R <local_directory>/ <source_parent_directory>/
  ```
- For agents/prompts, copy the selected local file to the source file path, overwriting:
  ```bash
  cp <local_file> <source_file>
  ```
- For Pi extensions:
  - If the source file is `index.ts` or `index.js`, copy the selected local directory to the source parent directory
  - Otherwise, copy the selected local file to the source file path
- For Pi themes, copy the selected local JSON file to the source file path
- Confirm the overwrite

**If source is a GitHub URL:**

- Determine `<item_path_in_repo>`:
  - For skills, use the parent directory of the referenced `SKILL.md`
  - For agents/prompts, use the referenced file path
  - For Pi extensions, use the parent directory when the referenced file is `index.ts`/`index.js`; otherwise use the referenced file path
  - For Pi themes, use the referenced file path
- If we don't already have a tmp clone from step 3, clone now:
  ```bash
  tmp_dir=$(mktemp -d)
  git clone --depth 1 --branch <branch> <clone_url> "$tmp_dir"
  ```
- Remove the old source item in the clone:
  ```bash
  rm -rf "$tmp_dir/<item_path_in_repo>"
  ```
- Copy the selected local version into the clone:
  ```bash
  cp -R <local_path> "$tmp_dir/<item_path_in_repo>"
  ```
- Stage ONLY the relevant changes:
  ```bash
  cd "$tmp_dir"
  git add <item_path_in_repo>
  ```
- Commit with the standard format:
  ```bash
  git commit -m "librarian: updated <name> <brief description of what changed>"
  ```
- Push to the remote repository:
  ```bash
  git push
  ```
- Clean up:
  ```bash
  rm -rf "$tmp_dir"
  ```

### 5. Confirm

Tell the user:

- What was published and where
- Which provider/scope local copy was used
- The commit message used
- If it was a local path publish, confirm the overwrite
