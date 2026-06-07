# Remove an Entry from the Catalog

## Context

The user wants to remove a skill, agent, prompt, Pi extension, or Pi theme from the librarian catalog and optionally delete installed copies from provider directories.

## Input

The user provides a skill, agent, prompt, Pi extension, or Pi theme name/description. They may also specify a provider for local deletion:

- `for claude` / `for pi` → only consider that provider's installed copy
- `everywhere` / `all providers` → consider installed copies in every provider
- no provider → use `default_provider` when deleting local copies, except Pi extensions and Pi themes use `pi`

## Steps

### 1. Sync the Librarian Repo

Pull the latest catalog before modifying:

```bash
cd <LIBRARIAN_SKILL_DIR>
git pull
```

### 2. Find the Entry

- Read `librarian.yaml`
- Search across all sections for the matching entry
- Determine the type (skill, agent, prompt, Pi extension, or Pi theme)
- If no match, tell the user the item wasn't found in the catalog

### 3. Determine Provider Target(s) for Local Deletion

- Read `default_provider` and `providers` from `librarian.yaml`
- If the catalog only has legacy `default_dirs`, treat it as one `claude` provider
- If user said `everywhere` or `all providers` → check every configured provider
- If user said `for <provider>` → check that provider
- Otherwise, if the entry is a Pi extension or Pi theme → check `pi`
- Otherwise → check `default_provider`
- For each selected provider, check both `default` and `global` directories for the entry type
- If a selected provider does not define that type, warn and skip local deletion for that provider

### 4. Confirm with User

Show the entry details and installed copies found, then ask:

- "Remove **<name>** from the librarian catalog?"
- If installed locally, also ask which local copies to delete:
  - a specific provider/scope path
  - all found copies
  - none/local catalog removal only

### 5. Remove from librarian.yaml

- Remove the entry from the appropriate section (`library.skills`, `library.agents`, `library.prompts`, `library.pi-extensions`, or `library.pi-themes`)
- If other entries depend on this one (via `requires`), warn the user before proceeding

### 6. Delete Local Copy/Copies (if requested)

If the user confirmed local deletion:

- Remove each selected installed path:
  ```bash
  rm -rf <installed_path>
  ```
- For skills, the installed path is usually `<target_root>/<name>/`
- For agents/prompts, the installed path is usually `<target_root>/<name>.md` or a preserved nested path
- For Pi extensions, the installed path is usually `<target_root>/<name>.ts`, `<target_root>/<name>.js`, or `<target_root>/<name>/`
- For Pi themes, the installed path is usually `<target_root>/<name>.json`

### 7. Commit and Push

```bash
cd <LIBRARIAN_SKILL_DIR>
git add librarian.yaml
git commit -m "librarian: removed <type> <name>"
git push
```

### 8. Confirm

Tell the user:

- The entry has been removed from the catalog
- Whether local copies were deleted
- Which provider/scope paths were deleted
- If other entries depended on it, remind them to update those entries
