#!/bin/bash
#
# bootstrap-server.sh
# Minimal setup for Ubuntu servers
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/stefanmunz/setup-new-machine/main/bootstrap-server.sh | bash
#
# Exit codes:
#   0 - Success
#   1 - General error
#   2 - Not running on Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Check we're on Linux
check_linux() {
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        error_exit "This script is for Linux servers. Use bootstrap.sh for macOS." 2
    fi
    log_info "Running on Linux: $(uname -a)"
}

# Install packages via apt
install_apt_packages() {
    log_info "Updating apt and installing packages..."

    sudo apt-get update

    local packages=(
        "git"
        "curl"
        "build-essential"
        "ripgrep"
        "xclip"          # For clipboard in SSH script
    )

    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" &>/dev/null; then
            log_info "  $pkg already installed"
        else
            log_info "  Installing $pkg..."
            sudo apt-get install -y "$pkg" || log_warn "Failed to install $pkg"
        fi
    done

    log_info "apt packages installed"
}

# Install GitHub CLI
install_gh() {
    if command -v gh &>/dev/null; then
        log_info "GitHub CLI already installed: $(gh --version | head -1)"
        return 0
    fi

    log_info "Installing GitHub CLI..."

    # Add GitHub CLI repo
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh

    log_info "GitHub CLI installed"
}

# Install chezmoi
install_chezmoi() {
    if command -v chezmoi &>/dev/null; then
        log_info "chezmoi already installed: $(chezmoi --version)"
        return 0
    fi

    log_info "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"

    # Add to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    log_info "chezmoi installed"
}

# Install mise
install_mise() {
    if [[ -x "$HOME/.local/bin/mise" ]]; then
        log_info "mise already installed: $($HOME/.local/bin/mise --version)"
        return 0
    fi

    if command -v mise &>/dev/null; then
        log_info "mise already installed: $(mise --version)"
        return 0
    fi

    log_info "Installing mise..."
    curl -fsSL https://mise.run | sh

    log_info "mise installed: $($HOME/.local/bin/mise --version)"
}

# Install dev tools via mise
install_mise_tools() {
    local mise_cmd="$HOME/.local/bin/mise"

    if ! [[ -x "$mise_cmd" ]]; then
        if command -v mise &>/dev/null; then
            mise_cmd="mise"
        else
            error_exit "mise not found" 1
        fi
    fi

    log_info "Installing development tools via mise..."

    # Go
    log_info "  Installing Go 1.25..."
    $mise_cmd use --global go@1.25 || log_warn "Failed to install Go"

    # Node.js (LTS)
    log_info "  Installing Node.js (LTS)..."
    $mise_cmd use --global node@lts || log_warn "Failed to install Node.js"

    # Python
    log_info "  Installing Python 3.12..."
    $mise_cmd use --global python@3.12 || log_warn "Failed to install Python"

    log_info "mise tools installed"
}

# Configure shell
configure_shell() {
    local bashrc="$HOME/.bashrc"

    # Add mise shims and activation if not present
    if ! grep -q 'mise' "$bashrc" 2>/dev/null; then
        log_info "Adding mise to .bashrc..."
        echo "" >> "$bashrc"
        echo "# mise - polyglot version manager" >> "$bashrc"
        echo "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"" >> "$bashrc"
        echo "eval \"\$(\$HOME/.local/bin/mise activate bash)\"" >> "$bashrc"
    fi

    # Add chezmoi to PATH if not present
    if ! grep -q '.local/bin' "$bashrc" 2>/dev/null; then
        log_info "Adding ~/.local/bin to PATH..."
        echo "" >> "$bashrc"
        echo "# Local binaries" >> "$bashrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$bashrc"
    fi

    log_info "Shell configuration updated"
}

# Setup dotfiles via chezmoi
setup_dotfiles() {
    log_info "Setting up dotfiles via chezmoi..."

    # Ensure chezmoi is in PATH
    export PATH="$HOME/.local/bin:$PATH"

    if [[ -d "$HOME/.local/share/chezmoi" ]] && [[ -d "$HOME/.local/share/chezmoi/.git" ]]; then
        log_info "chezmoi already initialized, updating..."
        chezmoi update || log_warn "Could not update chezmoi"
    else
        log_info "Initializing chezmoi with dotfiles (via HTTPS)..."
        chezmoi init --apply https://github.com/stefanmunz/dotfiles.git || log_warn "Could not initialize chezmoi"
    fi
}

# Main
main() {
    echo ""
    echo "========================================"
    echo "  Setup Server (Ubuntu)"
    echo "  Minimal dev environment"
    echo "========================================"
    echo ""

    check_linux
    install_apt_packages
    install_gh
    install_chezmoi
    install_mise
    install_mise_tools
    configure_shell
    setup_dotfiles

    echo ""
    log_info "========================================="
    log_info "Setup completed successfully!"
    log_info "========================================="
    echo ""
    log_info "Installed:"
    log_info "  Via apt:"
    log_info "    - git, ripgrep, gh"
    echo ""
    log_info "  Via mise:"
    log_info "    - Go 1.25"
    log_info "    - Node.js (LTS)"
    log_info "    - Python 3.12"
    echo ""
    log_info "  Dotfiles:"
    log_info "    - Via chezmoi"
    log_info "    - SSH key generated for this machine"
    echo ""
    log_warn "IMPORTANT: Run 'source ~/.bashrc' or open a new terminal."
    echo ""
    log_info "Verify your setup:"
    echo "    git --version"
    echo "    go version"
    echo "    node --version"
    echo "    python --version"
    echo ""
}

main
