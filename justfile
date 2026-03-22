set dotenv-load := true

# List available commands
default:
    @just --list

# Install the librarian (first-time setup)
install:
    claude --dangerously-skip-permissions --model opus "/librarian install"

# Add a new skill, agent, or prompt to the catalog
add prompt:
    claude --dangerously-skip-permissions --model opus "/librarian add {{prompt}}"

# Pull a skill from the catalog (install or refresh)
use name:
    claude --dangerously-skip-permissions --model opus "/librarian use {{name}}"

# Push local changes back to the source
push name:
    claude --dangerously-skip-permissions --model opus "/librarian push {{name}}"

# Remove a locally installed skill
remove name:
    claude --dangerously-skip-permissions --model opus "/librarian remove {{name}}"

# Sync all installed items (re-pull from source)
sync:
    claude --dangerously-skip-permissions --model opus "/librarian sync"

# List all entries in the catalog with install status
list:
    claude --dangerously-skip-permissions --model opus "/librarian list"

# Search the catalog by keyword
search keyword:
    claude --dangerously-skip-permissions --model opus "/librarian search {{keyword}}"
