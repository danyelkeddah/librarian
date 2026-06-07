# Find Catalog Entries

## Context

Find entries in the catalog by keyword when the user doesn't remember the exact name.

## Input

The user provides a keyword or description.

## Steps

### 1. Sync the Librarian Repo

Pull the latest catalog before reading:

```bash
cd <LIBRARIAN_SKILL_DIR>
git pull
```

### 2. Read the Catalog

- Read `librarian.yaml`
- Parse all entries from `library.skills`, `library.agents`, `library.prompts`, `library.pi-extensions`, and `library.pi-themes`

### 3. Search

- Match the keyword (case-insensitive) against:
  - Entry `name`
  - Entry `description`
- A match is any entry where the keyword appears as a substring in either field
- Collect all matches across all types

### 4. Display Results

If matches found, format as:

```
## Search Results for "<keyword>"

| Type | Name | Description | Source |
|------|------|-------------|--------|
| skill | matching-skill | description... | source... |
| agent | matching-agent | description... | source... |
| pi-extension | matching-extension | description... | source... |
| pi-theme | matching-theme | description... | source... |
```

If no matches:

```
No results found for "<keyword>".
Tip: Try broader keywords or run `/librarian catalog` to see the full catalog.
```

### 5. Suggest Next Step

If matches were found, suggest: `Run /librarian install <name> to install to the default provider, or /librarian install <name> for <provider> to pick a provider.` For Pi extensions and Pi themes, `/librarian install <name>` installs to Pi by default.
