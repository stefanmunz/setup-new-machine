#!/bin/bash
#
# bootstrap.sh
# Complete setup for a fresh Mac: zsh, oh-my-zsh, Homebrew, mise, Go
#
# Prerequisites:
#   Xcode Command Line Tools must be installed first:
#   xcode-select --install
#
# Usage:
#   sudo -v
#   curl -fsSL https://raw.githubusercontent.com/stefanmunz/setup-new-machine/main/bootstrap.sh | bash
#
# Exit codes:
#   0 - Success
#   1 - General error
#   2 - Homebrew installation failed
#   3 - Git installation failed
#   4 - Oh-my-zsh installation failed
#   5 - Xcode CLT not installed
#   6 - mise installation failed
#   7 - Go installation failed

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

# Check for Xcode Command Line Tools
check_xcode_clt() {
    if ! xcode-select -p &> /dev/null; then
        echo ""
        log_error "Xcode Command Line Tools are not installed."
        echo ""
        log_info "Please install them first by running:"
        echo ""
        echo "    xcode-select --install"
        echo ""
        log_info "Wait for the installation to complete, then run this script again."
        echo ""
        exit 5
    fi
    log_info "Xcode Command Line Tools found: $(xcode-select -p)"
}

# Determine Homebrew prefix
get_brew_prefix() {
    if [[ -d /opt/homebrew ]]; then
        echo "/opt/homebrew"
    else
        echo "/usr/local"
    fi
}

# Install Homebrew
install_homebrew() {
    if command -v brew &> /dev/null; then
        log_info "Homebrew already installed: $(brew --version | head -1)"
        return 0
    fi

    log_info "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_info "Homebrew installed successfully"

        # Add Homebrew to PATH for this session
        local brew_prefix=$(get_brew_prefix)
        eval "$($brew_prefix/bin/brew shellenv)"

        if ! command -v brew &> /dev/null; then
            error_exit "Homebrew installed but not found in PATH. Please restart your terminal and run this script again." 2
        fi
    else
        error_exit "Failed to install Homebrew" 2
    fi
}

# Install git via Homebrew
install_git() {
    local brew_prefix=$(get_brew_prefix)

    # Check if Homebrew git is already installed
    if [[ -x "$brew_prefix/bin/git" ]]; then
        log_info "Homebrew git already installed: $($brew_prefix/bin/git --version)"
        return 0
    fi

    log_info "Installing git via Homebrew..."
    if brew install git; then
        log_info "Git installed successfully: $($brew_prefix/bin/git --version)"
    else
        error_exit "Failed to install git" 3
    fi
}

# Switch to zsh
setup_zsh() {
    local current_shell=$(basename "$SHELL")

    if [[ "$current_shell" == "zsh" ]]; then
        log_info "Already using zsh"
        return 0
    fi

    if [[ ! -x /bin/zsh ]]; then
        error_exit "zsh not found at /bin/zsh" 1
    fi

    log_info "Switching default shell to zsh..."
    if chsh -s /bin/zsh; then
        log_info "Default shell changed to zsh (will take effect in new terminal)"
    else
        log_warn "Could not change shell automatically. Run manually: chsh -s /bin/zsh"
    fi
}

# Install oh-my-zsh
install_ohmyzsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Oh-my-zsh already installed"
        return 0
    fi

    log_info "Installing oh-my-zsh..."
    # Use unattended install (no shell switch, we handle that separately)
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        log_info "Oh-my-zsh installed successfully"
    else
        error_exit "Failed to install oh-my-zsh" 4
    fi
}

# Install mise
install_mise() {
    if [[ -x "$HOME/.local/bin/mise" ]]; then
        log_info "mise already installed: $($HOME/.local/bin/mise --version)"
        return 0
    fi

    if command -v mise &> /dev/null; then
        log_info "mise already installed: $(mise --version)"
        return 0
    fi

    log_info "Installing mise..."
    if curl -fsSL https://mise.run | sh; then
        log_info "mise installed successfully: $($HOME/.local/bin/mise --version)"
    else
        error_exit "Failed to install mise" 6
    fi
}

# Install Go via mise
install_go() {
    local mise_cmd="$HOME/.local/bin/mise"

    if ! [[ -x "$mise_cmd" ]]; then
        if command -v mise &> /dev/null; then
            mise_cmd="mise"
        else
            error_exit "mise not found" 7
        fi
    fi

    log_info "Installing Go 1.25 globally via mise..."
    if $mise_cmd use --global go@1.25; then
        log_info "Go installed successfully"
    else
        error_exit "Failed to install Go" 7
    fi
}

# Configure shell
configure_shell() {
    local brew_prefix=$(get_brew_prefix)
    local zshrc="$HOME/.zshrc"

    # Ensure .zshrc exists (oh-my-zsh should have created it)
    if [[ ! -f "$zshrc" ]]; then
        touch "$zshrc"
    fi

    # Add Homebrew to PATH if not present
    if ! grep -q 'brew shellenv' "$zshrc" 2>/dev/null; then
        log_info "Adding Homebrew to .zshrc..."
        echo "" >> "$zshrc"
        echo "# Homebrew" >> "$zshrc"
        echo "eval \"\$($brew_prefix/bin/brew shellenv)\"" >> "$zshrc"
    fi

    # Add mise shims and activation if not present
    if ! grep -q 'mise' "$zshrc" 2>/dev/null; then
        log_info "Adding mise to .zshrc..."
        echo "" >> "$zshrc"
        echo "# mise - polyglot version manager" >> "$zshrc"
        echo "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"" >> "$zshrc"
        echo "eval \"\$(\$HOME/.local/bin/mise activate zsh)\"" >> "$zshrc"
    fi

    log_info "Shell configuration updated"
}

# Main
main() {
    echo ""
    echo "========================================"
    echo "  Setup New Machine"
    echo "  zsh + oh-my-zsh + mise + Go"
    echo "========================================"
    echo ""

    check_xcode_clt
    install_homebrew
    install_git
    setup_zsh
    install_ohmyzsh
    install_mise
    install_go
    configure_shell

    echo ""
    log_info "========================================="
    log_info "Setup completed successfully!"
    log_info "========================================="
    echo ""
    log_info "Installed:"
    log_info "  - Homebrew (package manager)"
    log_info "  - Git (via Homebrew)"
    log_info "  - zsh (set as default shell)"
    log_info "  - oh-my-zsh (zsh framework)"
    log_info "  - mise (version manager)"
    log_info "  - Go 1.25 (via mise)"
    echo ""
    log_warn "IMPORTANT: Open a new terminal for all changes to take effect."
    echo ""
    log_info "Verify your setup in a new terminal:"
    echo "    zsh --version"
    echo "    git --version"
    echo "    mise --version"
    echo "    go version"
    echo ""
}

main
