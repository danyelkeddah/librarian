# The Librarian

A meta-skill for private-first distribution of skills, agents, prompts, Pi extensions, and Pi themes across your agents, devices, teams, and providers. It maintains a single catalog (`librarian.yaml`) that points to where everything lives — local file paths or GitHub URLs — and installs items on demand. The Librarian handles fetching, updating, dependency resolution, and publishing changes back to the source.

Librarian keeps entries provider-neutral where possible. The default provider is Pi, and items can still install to a named provider, for example `/librarian install spec-plan for claude`, `/librarian install spec-plan for pi`, or `/librarian install spec-plan everywhere`. In Pi, invoke the skill as `/skill:librarian ...` or use the `justfile`. Pi extensions and Pi themes live in their own `pi-extensions` and `pi-themes` sections and install to Pi by default.

## Acknowledgments

Inspired by [The Library](https://github.com/disler/the-library) by [@disler](https://github.com/disler) (IndyDevDan). The original concept of a meta-skill for private-first distribution of agentics laid the foundation for this project.
