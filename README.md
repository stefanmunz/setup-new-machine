# setup-new-machine

One-command setup for a fresh Mac with a complete development environment.

## What Gets Installed

### Shell
- **zsh** - Set as default shell (uses macOS built-in `/bin/zsh`)
- **oh-my-zsh** - Framework for managing zsh configuration

### Via Homebrew
- **git** - Version control (Homebrew version, not Apple's outdated one)
- **gh** - GitHub CLI
- **ripgrep** - Fast grep replacement
- **chezmoi** - Dotfile manager
- **Visual Studio Code** - Code editor
- **1password-cli** - 1Password CLI for secrets management

### Via mise (version manager)
- **Go 1.25**
- **Node.js 22**
- **Python 3.12**
- **Ruby 3.3**
- **golangci-lint**

### VS Code Extensions (if VS Code is installed)
- Claude Code
- Go
- Python + Pylance
- Ruby LSP
- GitHub Actions
- Prettier
- EditorConfig
- Git Graph
- YAML

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
go version         # Should show go1.25.x
node --version     # Should show v22.x.x
python --version   # Should show Python 3.12.x
ruby --version     # Should show ruby 3.3.x
```

## Next Steps

### Set up dotfiles with chezmoi

```bash
chezmoi init
chezmoi add ~/.zshrc
chezmoi cd  # Opens chezmoi repo
```

### Add more tools via mise

```bash
mise use --global terraform
mise use --global kubectl
mise use --global jq
mise use --global fzf
```

See all available tools: https://mise.jdx.dev/registry.html

### Authenticate with GitHub

```bash
gh auth login
```

### Set up 1Password CLI

```bash
op signin
```
