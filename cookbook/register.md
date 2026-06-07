# Register a New Entry in the Catalog

## Context

Register a new skill, agent, prompt, Pi extension, or Pi theme in the librarian catalog. Catalog entries are provider-neutral when possible: they define the source item once, and providers decide where it installs. Pi extensions and Pi themes are provider-specific and install to Pi's native directories.

## Input

The user provides: name, description, source, and optionally type and dependencies.

## Steps

### 1. Sync the Librarian Repo

Pull the latest changes before modifying:

```bash
cd <LIBRARIAN_SKILL_DIR>
git pull
```

### 2. Determine the Type

Figure out the type from the user's prompt or the source path:

- If the source path contains `SKILL.md` or user says "skill" → type is `skill`
- If the source path contains `AGENT.md` or user says "agent" → type is `agent`
- If user says "prompt" → type is `prompt`
- If user says "pi extension", "pi-extension", or the source is a `.ts`/`.js` file under a `pi-extensions/` directory → type is `pi-extension`
- If user says "pi theme", "pi-theme", or the source is a `.json` file under a `pi-themes/` directory → type is `pi-theme`
- If ambiguous, ask the user

### 3. Validate the Source

- **Local path**: Verify the file exists at the given path
- **GitHub URL**: Verify the URL is well-formed (matches browser or raw URL patterns)
- Confirm the source points to a specific file, not a directory
- For Pi extensions, confirm the source is a `.ts`/`.js` file or an `index.ts`/`index.js` entry file
- For Pi themes, confirm the source is a `.json` file

Do not include target paths in the entry. Target paths come from `providers`. For Pi extensions, the entry belongs under `library.pi-extensions` and installs to `providers.pi.pi-extensions`. For Pi themes, the entry belongs under `library.pi-themes` and installs to `providers.pi.pi-themes`.

### 4. Parse Dependencies

Detect dependencies by looking through the skill/agent/prompt/extension/theme files, format them as typed references:

- `skill:name`, `agent:name`, `prompt:name`, `pi-extension:name`, `pi-theme:name`
- Verify each dependency already exists in `librarian.yaml` or warn the user
  - If they don't exist, register them in `librarian.yaml` first. If those files have dependencies, register them recursively.
  - You can detect these sometimes by looking at the frontmatter, and then in the file content look for `/<prompt|agent|skill|pi-extension|pi-theme>:name` references. If you're not sure, ask the user if they have any dependencies.

Dependencies are also provider-neutral. When installed, they use the same provider selection as the requested item.

### 5. Register the Entry in librarian.yaml

Read `librarian.yaml`, place the new entry under the correct section:

```yaml
# Under library.skills, library.agents, library.prompts, library.pi-extensions, or library.pi-themes
- name: <name>
  description: <description>
  source: <source>
  requires: [<typed:refs>] # omit if no dependencies
```

**YAML formatting rules:**

- 2-space indentation
- List items use `- ` prefix
- Properties are indented under the list item
- Keep entries alphabetically sorted by name within each section
- For skills, reference the `.../<skill-name>/SKILL.md` file
- For agents, reference the `.../<agent-name>.md` or `.../<agent-name>/AGENT.md` file
- For prompts, reference the `.../<prompt-name>.md` file
- For Pi extensions, reference either a single `.../pi-extensions/<extension-name>.ts`/`.js` file or a directory entry file like `.../pi-extensions/<extension-name>/index.ts`
- For Pi themes, reference the `.../pi-themes/<theme-name>.json` file
- Use an absolute path or a GitHub URL (HTTPS, raw, or SSH when supported)

### 6. Commit and Push

```bash
cd <LIBRARIAN_SKILL_DIR>
git add librarian.yaml
git commit -m "librarian: registered <type> <name>"
git push
```

### 7. Confirm

Tell the user the entry has been registered and is now available via `/librarian install <name>` or `/librarian install <name> for <provider>`. For Pi extensions and Pi themes, `/librarian install <name>` installs to Pi by default.
