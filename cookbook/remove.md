# Remove an Entry from the Catalog

## Context

The user wants to remove a skill, agent, or prompt from the librarian catalog and optionally delete the local copy.

## Input

The user provides a skill name or description.

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
- Determine the type (skill, agent, or prompt)
- If no match, tell the user the item wasn't found in the catalog

### 3. Confirm with User

Show the entry details and ask:

- "Remove **<n>** from the librarian catalog?"
- If installed locally, also ask: "Also delete the local copy at `<path>`?"

### 4. Remove from librarian.yaml

- Remove the entry from the appropriate section (`library.skills`, `library.agents`, or `library.prompts`)
- If other entries depend on this one (via `requires`), warn the user before proceeding

### 5. Delete Local Copy (if requested)

If the user confirmed local deletion:

- Check the default directory for the type (from `default_dirs`)
- Check the global directory
- Remove the directory or file:
  ```bash
  rm -rf <target_directory>/<n>
  ```

### 6. Commit and Push

```bash
cd <LIBRARIAN_SKILL_DIR>
git add librarian.yaml
git commit -m "librarian: removed <type> <n>"
git push
```

### 7. Confirm

Tell the user:

- The entry has been removed from the catalog
- Whether the local copy was also deleted
- If other entries depended on it, remind them to update those entries
