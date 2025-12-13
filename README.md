# setup-new-machine

One-command setup for fresh machines with a complete development environment.

## macOS (Full Setup)

### What Gets Installed

**Shell:** zsh, oh-my-zsh

**Via Homebrew:** git, gh, ripgrep, chezmoi, VS Code, 1password-cli

**Via mise:** Go 1.25, Node.js 22, Python 3.12, Ruby 3.3, golangci-lint

**VS Code Extensions:** Claude Code, Go, Python, Ruby LSP, GitHub Actions, Prettier, etc.

**Dotfiles:** .zshrc, .gitconfig, .ssh/config via chezmoi + unique SSH key per machine

### Setup (1Password SSH agent required)

1) Install Xcode CLT:
```bash
xcode-select --install
```
Wait for the installer to finish.

2) Enable 1Password SSH Agent (in the 1Password app): Settings → Developer → “Use the SSH Agent”. Keep 1Password unlocked.

3) Generate a GitHub SSH key with `gh` (this writes to `~/.ssh` temporarily):
```bash
gh auth login --ssh --git-protocol ssh
# Choose “Generate new SSH key”, accept the default path.
```

4) Move the key into 1Password and remove local copies:
```bash
op item create --category=ssh-key --title "GitHub – <machine name>" \
  "public key[file]=$HOME/.ssh/id_ed25519.pub" \
  "private key[file]=$HOME/.ssh/id_ed25519"
rm $HOME/.ssh/id_ed25519 $HOME/.ssh/id_ed25519.pub
```

5) Point SSH to the 1Password agent until chezmoi applies your dotfiles:
```bash
mkdir -p ~/.ssh
cat <<'EOF' > ~/.ssh/config
Host github.com
  HostName github.com
  IdentityAgent ~/.1password/agent.sock
EOF
chmod 600 ~/.ssh/config
```

6) Verify GitHub SSH works (approve in 1Password):
```bash
ssh -T git@github.com
```

7) Run the bootstrap (installs Homebrew, mise, tools, etc.):
```bash
sudo -v
curl -fsSL https://raw.githubusercontent.com/stefanmunz/setup-new-machine/main/bootstrap.sh | bash
```

8) chezmoi (invoked by the bootstrap) will initialize dotfiles over SSH:
```bash
chezmoi init --apply git@github.com:stefanmunz/dotfiles.git
```
If you rerun it manually, ensure 1Password is unlocked first. After your dotfiles are applied, you can drop the temporary `~/.ssh/config` if your chezmoi-managed config replaces it.

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
