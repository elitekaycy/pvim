#!/usr/bin/env bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Minimum versions
MIN_NVIM_VERSION="0.11.0"
MIN_NODE_VERSION="18"
MIN_JAVA_VERSION="17"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &>/dev/null; then
            echo "debian"
        elif command -v dnf &>/dev/null; then
            echo "fedora"
        elif command -v pacman &>/dev/null; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Version comparison
version_gte() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# Detect version managers
detect_version_manager() {
    if command -v mise &>/dev/null; then
        echo "mise"
    elif command -v asdf &>/dev/null; then
        echo "asdf"
    elif command -v sdkman &>/dev/null || [[ -d "$HOME/.sdkman" ]]; then
        echo "sdkman"
    elif command -v nvm &>/dev/null || [[ -d "$HOME/.nvm" ]]; then
        echo "nvm"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "system"
    fi
}

# Install Neovim
install_neovim() {
    local current_version=""
    local vm=$(detect_version_manager)

    if command -v nvim &>/dev/null; then
        current_version=$(nvim --version | head -1 | grep -oP '[\d.]+' | head -1)
        if version_gte "$current_version" "$MIN_NVIM_VERSION"; then
            log_success "Neovim $current_version already installed"
            return 0
        fi
        log_warn "Neovim $current_version found, need $MIN_NVIM_VERSION+"
    fi

    log_info "Installing Neovim $MIN_NVIM_VERSION+..."

    local install_success=false

    case "$vm" in
        mise)
            if mise use -g neovim@latest 2>/dev/null; then
                install_success=true
            fi
            ;;
        asdf)
            asdf plugin add neovim 2>/dev/null || true
            if asdf install neovim latest 2>/dev/null && asdf global neovim latest 2>/dev/null; then
                install_success=true
            fi
            ;;
        brew)
            if brew install neovim 2>/dev/null; then
                install_success=true
            fi
            ;;
    esac

    # Fallback to AppImage if version manager failed
    if [[ "$install_success" == "false" ]]; then
        log_warn "Version manager install failed, using AppImage..."
        install_neovim_appimage
    else
        log_success "Neovim installed via $vm"
    fi
}

# Install Neovim via AppImage (fallback)
install_neovim_appimage() {
    local appimage_url="https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.appimage"
    local macos_url="https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-macos-arm64.tar.gz"

    mkdir -p "$HOME/.local/bin"

    local os=$(detect_os)
    if [[ "$os" == "macos" ]]; then
        log_info "Downloading Neovim for macOS..."
        curl -Lo /tmp/nvim.tar.gz "$macos_url"
        tar -xzf /tmp/nvim.tar.gz -C /tmp
        cp -r /tmp/nvim-macos-arm64/* "$HOME/.local/"
        rm -rf /tmp/nvim.tar.gz /tmp/nvim-macos-arm64
    else
        log_info "Downloading Neovim AppImage..."
        curl -Lo "$HOME/.local/bin/nvim" "$appimage_url"
        chmod +x "$HOME/.local/bin/nvim"
    fi

    # Verify installation
    if "$HOME/.local/bin/nvim" --version &>/dev/null; then
        log_success "Neovim installed via AppImage"
    else
        log_error "Neovim installation failed"
        exit 1
    fi
}

# Install Node.js
install_node() {
    local current_version=""
    local vm=$(detect_version_manager)

    if command -v node &>/dev/null; then
        current_version=$(node --version | grep -oP '[\d]+' | head -1)
        if [[ "$current_version" -ge "$MIN_NODE_VERSION" ]]; then
            log_success "Node.js v$(node --version) already installed"
            return 0
        fi
        log_warn "Node.js v$current_version found, need v$MIN_NODE_VERSION+"
    fi

    log_info "Installing Node.js..."

    case "$vm" in
        mise)
            mise use -g node@lts
            ;;
        asdf)
            asdf plugin add nodejs 2>/dev/null || true
            asdf install nodejs latest
            asdf global nodejs latest
            ;;
        nvm)
            source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
            nvm install --lts
            nvm use --lts
            ;;
        brew)
            brew install node
            ;;
        *)
            local os=$(detect_os)
            case "$os" in
                debian)
                    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                    ;;
                fedora)
                    sudo dnf install -y nodejs
                    ;;
                arch)
                    sudo pacman -S --noconfirm nodejs npm
                    ;;
            esac
            ;;
    esac

    log_success "Node.js installed"
}

# Install Java (for JDTLS)
install_java() {
    local current_version=""
    local vm=$(detect_version_manager)

    if command -v java &>/dev/null; then
        current_version=$(java -version 2>&1 | head -1 | grep -oP '[\d]+' | head -1)
        if [[ "$current_version" -ge "$MIN_JAVA_VERSION" ]]; then
            log_success "Java $current_version already installed"
            return 0
        fi
        log_warn "Java $current_version found, need $MIN_JAVA_VERSION+"
    fi

    log_info "Installing Java $MIN_JAVA_VERSION+..."

    case "$vm" in
        mise)
            mise use -g java@21
            ;;
        asdf)
            asdf plugin add java 2>/dev/null || true
            asdf install java temurin-21.0.2+13.0.LTS
            asdf global java temurin-21.0.2+13.0.LTS
            ;;
        sdkman)
            source "$HOME/.sdkman/bin/sdkman-init.sh" 2>/dev/null || true
            sdk install java 21-tem
            ;;
        brew)
            brew install openjdk@21
            ;;
        *)
            local os=$(detect_os)
            case "$os" in
                debian)
                    sudo apt-get install -y openjdk-21-jdk
                    ;;
                fedora)
                    sudo dnf install -y java-21-openjdk-devel
                    ;;
                arch)
                    sudo pacman -S --noconfirm jdk-openjdk
                    ;;
            esac
            ;;
    esac

    log_success "Java installed"
}

# Install essential CLI tools
install_cli_tools() {
    local os=$(detect_os)
    local tools=()

    # Check what's missing
    command -v git &>/dev/null || tools+=("git")
    command -v curl &>/dev/null || tools+=("curl")
    command -v wget &>/dev/null || tools+=("wget")
    command -v unzip &>/dev/null || tools+=("unzip")
    command -v rg &>/dev/null || tools+=("ripgrep")
    command -v fd &>/dev/null || tools+=("fd-find")
    command -v fzf &>/dev/null || tools+=("fzf")
    command -v lazygit &>/dev/null || tools+=("lazygit")
    command -v tree-sitter &>/dev/null || tools+=("tree-sitter-cli")

    if [[ ${#tools[@]} -eq 0 ]]; then
        log_success "All CLI tools already installed"
        return 0
    fi

    log_info "Installing CLI tools: ${tools[*]}..."

    case "$os" in
        debian)
            sudo apt-get update
            for tool in "${tools[@]}"; do
                case "$tool" in
                    ripgrep) sudo apt-get install -y ripgrep ;;
                    fd-find) sudo apt-get install -y fd-find ;;
                    lazygit)
                        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                        tar xf lazygit.tar.gz lazygit
                        sudo install lazygit /usr/local/bin
                        rm lazygit lazygit.tar.gz
                        ;;
                    tree-sitter-cli)
                        npm install -g tree-sitter-cli 2>/dev/null || true
                        ;;
                    *) sudo apt-get install -y "$tool" ;;
                esac
            done
            ;;
        fedora)
            for tool in "${tools[@]}"; do
                case "$tool" in
                    fd-find) sudo dnf install -y fd-find ;;
                    lazygit) sudo dnf copr enable atim/lazygit -y && sudo dnf install -y lazygit ;;
                    tree-sitter-cli) npm install -g tree-sitter-cli 2>/dev/null || true ;;
                    *) sudo dnf install -y "$tool" ;;
                esac
            done
            ;;
        arch)
            for tool in "${tools[@]}"; do
                case "$tool" in
                    fd-find) sudo pacman -S --noconfirm fd ;;
                    tree-sitter-cli) npm install -g tree-sitter-cli 2>/dev/null || true ;;
                    *) sudo pacman -S --noconfirm "$tool" ;;
                esac
            done
            ;;
        macos)
            for tool in "${tools[@]}"; do
                case "$tool" in
                    fd-find) brew install fd ;;
                    tree-sitter-cli) npm install -g tree-sitter-cli 2>/dev/null || true ;;
                    *) brew install "$tool" ;;
                esac
            done
            ;;
    esac

    log_success "CLI tools installed"
}

# Install Python tools (for some LSPs)
install_python_tools() {
    if ! command -v python3 &>/dev/null; then
        log_info "Installing Python3..."
        local os=$(detect_os)
        case "$os" in
            debian) sudo apt-get install -y python3 python3-pip python3-venv ;;
            fedora) sudo dnf install -y python3 python3-pip ;;
            arch) sudo pacman -S --noconfirm python python-pip ;;
            macos) brew install python ;;
        esac
    fi

    # Install pynvim for python plugins
    pip3 install --user pynvim 2>/dev/null || python3 -m pip install --user pynvim 2>/dev/null || true

    log_success "Python tools ready"
}

# Setup shell config (zsh/bash)
setup_shell_config() {
    local shell_rc=""
    local shell_name=""

    # Detect shell
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
        shell_name="zsh"
    else
        shell_rc="$HOME/.bashrc"
        shell_name="bash"
    fi

    log_info "Configuring $shell_name..."

    # Backup if needed
    if [[ -f "$shell_rc" ]]; then
        cp "$shell_rc" "$shell_rc.pvim.bak" 2>/dev/null || true
    fi

    # Check if pvim config already exists
    if grep -q "# PVIM Configuration" "$shell_rc" 2>/dev/null; then
        log_info "Shell config already contains PVIM setup, updating..."
        # Remove old pvim config
        sed -i '/# PVIM Configuration/,/# END PVIM/d' "$shell_rc"
    fi

    # Add pvim configuration
    cat >> "$shell_rc" << 'EOF'

# PVIM Configuration
export PATH="$HOME/.local/bin:$PATH"
alias pvim='NVIM_APPNAME=pvim nvim'
alias pvi='NVIM_APPNAME=pvim nvim'

# Optional: make pvim the default editor
# export EDITOR='pvim'
# export VISUAL='pvim'
# END PVIM
EOF

    log_success "Shell config updated: $shell_rc"
}

# Setup pvim config
setup_pvim() {
    local pvim_config="$HOME/.config/pvim"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ "$script_dir" != "$pvim_config" ]]; then
        log_info "Linking pvim config..."
        mkdir -p "$(dirname "$pvim_config")"

        if [[ -d "$pvim_config" ]] && [[ ! -L "$pvim_config" ]]; then
            log_warn "Backing up existing config to $pvim_config.bak"
            mv "$pvim_config" "$pvim_config.bak"
        fi

        ln -sf "$script_dir" "$pvim_config"
    fi

    # Create pvim wrapper script (fallback for scripts)
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/pvim" << 'EOF'
#!/usr/bin/env bash
NVIM_APPNAME=pvim exec nvim "$@"
EOF
    chmod +x "$HOME/.local/bin/pvim"

    # Setup shell config
    setup_shell_config

    log_success "pvim setup complete"
}

# Run Mason to install LSP servers
setup_mason() {
    log_info "Installing LSP servers via Mason..."

    NVIM_APPNAME=pvim nvim --headless "+MasonInstall lua-language-server typescript-language-server tailwindcss-language-server css-lsp html-lsp jdtls clangd prettier stylua" +qa 2>/dev/null || true

    log_success "Mason setup complete"
}

# Main
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         PVIM Installation Script       ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""

    local os=$(detect_os)
    local vm=$(detect_version_manager)

    log_info "Detected OS: $os"
    log_info "Version manager: $vm"
    echo ""

    # Install dependencies
    install_neovim
    install_node
    install_java
    install_cli_tools
    install_python_tools

    echo ""

    # Setup pvim
    setup_pvim

    echo ""
    log_info "Running initial plugin sync..."
    NVIM_APPNAME=pvim nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

    echo ""
    log_info "Installing LSP servers (this may take a moment)..."
    setup_mason

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Installation Complete!           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Run ${YELLOW}pvim${NC} to start your IDE"
    echo ""

    # Remind about PATH if needed
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        log_warn "Add this to your shell config:"
        echo -e "  ${YELLOW}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
}

# Run
main "$@"
