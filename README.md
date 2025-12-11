# setup-new-machine

One-command setup for a fresh Mac with a modern development environment.

## What Gets Installed

- **zsh** - Set as default shell (uses macOS built-in `/bin/zsh`)
- **oh-my-zsh** - Framework for managing zsh configuration
- **Homebrew** - Package manager for macOS
- **Git** - Version control (via Homebrew, not Apple's outdated version)
- **mise** - Polyglot version manager for dev tools
- **Go 1.25** - Latest Go version (via mise)

## Setup

First, install Xcode Command Line Tools (~1-2GB download):

```bash
xcode-select --install
```

Wait for the installation to fully complete, then run:

```bash
sudo -v
curl -fsSL https://raw.githubusercontent.com/stefanmunz/setup-new-machine/main/bootstrap.sh | bash
```

**Open a new terminal** for all changes to take effect.

## Verify

In a new terminal:

```bash
zsh --version      # Should show zsh 5.9 or similar
git --version      # Should show git 2.x.x (no "Apple Git")
mise --version     # Should show mise version
go version         # Should show go1.25.x
```

## Adding More Tools

Use mise to install additional development tools:

```bash
# Node.js
mise use --global node@22

# Python
mise use --global python@3.12

# Other tools
mise use --global ripgrep
mise use --global jq
mise use --global fzf
```

See all available tools: https://mise.jdx.dev/registry.html
