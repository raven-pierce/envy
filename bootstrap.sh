#!/usr/bin/env bash
#|---/ /+------------------+---/ /|#
#|--/ /-| ENVY Bootstrap   |--/ /-|#
#|-/ /--| Quick Installer  |-/ /--|#
#|/ /---+------------------+/ /---|#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Print ENVY banner
print_banner() {
    cat << "EOF"

     ███████╗███╗   ██╗██╗   ██╗██╗   ██╗
     ██╔════╝████╗  ██║██║   ██║╚██╗ ██╔╝
     █████╗  ██╔██╗ ██║██║   ██║ ╚████╔╝ 
     ██╔══╝  ██║╚██╗██║╚██╗ ██╔╝  ╚██╔╝  
     ███████╗██║ ╚████║ ╚████╔╝    ██║   
     ╚══════╝╚═╝  ╚═══╝  ╚═══╝     ╚═╝   
                                        
     macOS Development Environment Setup

EOF
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_color $RED "❌ ENVY is designed for macOS only"
        exit 1
    fi
    print_color $GREEN "✅ macOS detected"
}

# Check if git is available
check_git() {
    if ! command -v git &> /dev/null; then
        print_color $YELLOW "⚠️  Git not found. Installing Xcode Command Line Tools..."
        xcode-select --install
        print_color $BLUE "Please complete the Xcode installation and run this script again"
        exit 1
    fi
    print_color $GREEN "✅ Git available"
}

# Main installation function
main() {
    print_banner
    print_color $CYAN "Welcome to ENVY - Enhanced Native Virtual Yorkspace"
    echo ""
    
    # System checks
    print_color $BLUE "🔍 Performing system checks..."
    check_macos
    check_git
    echo ""
    
    # Get installation directory
    DEFAULT_DIR="$HOME/.envy"
    print_color $YELLOW "📁 Where would you like to install ENVY?"
    read -p "Directory [$DEFAULT_DIR]: " INSTALL_DIR
    INSTALL_DIR=${INSTALL_DIR:-$DEFAULT_DIR}
    
    # Clone repository
    print_color $BLUE "📥 Cloning ENVY repository..."
    if [[ -d "$INSTALL_DIR" ]]; then
        print_color $YELLOW "⚠️  Directory exists. Backing up to ${INSTALL_DIR}.backup"
        mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    git clone https://github.com/raven-pierce/envy.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Initialize submodules (for Dotbot)
    print_color $BLUE "📦 Initializing Dotbot submodule..."
    git submodule update --init --recursive
    
    # Make scripts executable
    chmod +x scripts/*.sh install
    
    # Ask for installation type
    echo ""
    print_color $PURPLE "🎯 Choose installation type:"
    echo "1) Full installation (recommended)"
    echo "2) Custom installation"
    echo "3) Dry run (test only)"
    read -p "Choice [1]: " INSTALL_TYPE
    INSTALL_TYPE=${INSTALL_TYPE:-1}
    
    case $INSTALL_TYPE in
        1)
            print_color $GREEN "🚀 Starting full ENVY installation..."
            ./scripts/install.sh
            ;;
        2)
            print_color $BLUE "🔧 Custom installation selected"
            echo "Run ./scripts/install.sh with these options:"
            echo "  -i : Install packages"
            echo "  -h : Setup shell environment"
            echo "  -r : Restore configurations"
            echo "  -s : Configure services"
            echo ""
            echo "Example: ./scripts/install.sh -ih"
            ;;
        3)
            print_color $YELLOW "🧪 Running dry run..."
            ./scripts/install.sh -n
            ;;
        *)
            print_color $RED "❌ Invalid choice"
            exit 1
            ;;
    esac
    
    echo ""
    print_color $GREEN "🎉 ENVY setup completed!"
    print_color $CYAN "📖 Check the README.md for next steps and customization options"
    print_color $BLUE "🌟 Don't forget to star the repository if you found it useful!"
}

# Run main function
main "$@" 