set dotenv-load := true

# These recipes invoke the local librarian skill with Pi.
# Pi exposes skills as /skill:<name>, so recipes call /skill:librarian.
# Model: openai-codex/gpt-5.5 with low thinking/reasoning.
# Provider words in the arguments control the install target, e.g. `for pi`.

# List available recipes
default:
    @just --list

# First-time Librarian setup
setup:
    pi --skill . --model openai-codex/gpt-5.5 --thinking low "/skill:librarian setup"

# Register a new skill, agent, prompt, Pi extension, or Pi theme in the catalog
register +prompt:
    pi --skill . --model openai-codex/gpt-5.5 --thinking low "/skill:librarian register {{prompt}}"

# Install an item from the catalog. Example: just install spec-plan for pi
install +query:
    pi --skill . --model openai-codex/gpt-5.5 --thinking low "/skill:librarian install {{query}}"

# Publish local changes back to the source. Example: just publish spec-plan from pi
publish +query:
    pi --skill . --model openai-codex/gpt-5.5 --thinking low "/skill:librarian publish {{query}}"

# Remove an item from the catalog and optionally installed copies
remove +query:
    pi --skill . --model openai-codex/gpt-5.5 --thinking low "/skill:librarian remove {{query}}"

# Update installed items. Optional provider: just update for pi
update *args:
    pi --skill . --model openai-codex/gpt-5.5 --thinking low "/skill:librarian update {{args}}"

# Show the catalog with provider install status. Optional provider: just catalog for pi
catalog *args:
    pi --skill . --model openai-codex/gpt-5.5 --thinking low "/skill:librarian catalog {{args}}"

# Find catalog entries by keyword
find +keyword:
    pi --skill . --model openai-codex/gpt-5.5 --thinking low "/skill:librarian find {{keyword}}"
