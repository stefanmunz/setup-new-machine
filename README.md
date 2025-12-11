# setup-new-machine

One-command setup for fresh machines with a complete development environment.

## macOS (Full Setup)

### What Gets Installed

**Shell:** zsh, oh-my-zsh

**Via Homebrew:** git, gh, ripgrep, chezmoi, VS Code, 1password-cli

**Via mise:** Go 1.25, Node.js 22, Python 3.12, Ruby 3.3, golangci-lint

**VS Code Extensions:** Claude Code, Go, Python, Ruby LSP, GitHub Actions, Prettier, etc.

**Dotfiles:** .zshrc, .gitconfig, .ssh/config via chezmoi + unique SSH key per machine

### Setup

```bash
xcode-select --install
# Wait for installation to complete...

sudo -v
curl -fsSL https://raw.githubusercontent.com/stefanmunz/setup-new-machine/main/bootstrap.sh | bash
```

**Open a new terminal** for all changes to take effect.

### Verify

```bash
zsh --version      # zsh 5.9+
git --version      # git 2.x.x (no "Apple Git")
go version         # go1.25.x
node --version     # v22.x.x
python --version   # Python 3.12.x
ruby --version     # ruby 3.3.x
```

---

## Ubuntu Server (Minimal Setup)

### What Gets Installed

**Via apt:** git, gh, ripgrep

**Via mise:** Go 1.25, Node.js 22, Python 3.12

**Dotfiles:** via chezmoi + unique SSH key per machine

### Setup

```bash
curl -fsSL https://raw.githubusercontent.com/stefanmunz/setup-new-machine/main/bootstrap-server.sh | bash
```

Run `source ~/.bashrc` or open a new terminal.

### Verify

```bash
git --version      # git 2.x.x
go version         # go1.25.x
node --version     # v22.x.x
python --version   # Python 3.12.x
```

---

## Adding More Tools

```bash
mise use --global terraform
mise use --global kubectl
mise use --global jq
mise use --global fzf
```

See all available tools: https://mise.jdx.dev/registry.html

## Authenticate with GitHub

```bash
gh auth login
```
