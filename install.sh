#!/bin/bash

# Install script for dibbs-ecr-viewer-playbook
# Usage: curl -sSL https://github.com/alismx/dibbs-ecr-viewer-playbook/install.sh | bash
#
# This script will:
# 1. Clone the repository to ~/dibbs-ecr-viewer-playbook
# 2. Run the wizard.sh setup script interactively
# 3. Execute the Ansible playbook

set -e

echo "========================================"
echo "  DIBBS eCR Viewer Installation Script"
echo "========================================"
echo ""

# User privilege check
check_privileges() {
    echo "Checking user privileges..."

    # Check if running as root (not allowed)
    if [ "$EUID" -eq 0 ] || [ "$(whoami)" = "root" ]; then
        echo "ERROR: This script should not be run as root."
        echo "Please run as a regular user with sudo privileges."
        exit 1
    fi

    # Verify sudo access for system-level operations during playbook execution
    if ! sudo -n echo "Sudo access verified" &> /dev/null; then
        echo "WARNING: Sudo access is required for Ansible playbook execution."
        echo "The playbook will prompt for your password when needed."
    fi

    echo "Privilege check complete."
    echo ""
}

# Configuration
REPO_URL="https://github.com/alismx/dibbs-ecr-viewer-playbook"
DIBBS_PLAYBOOK_DIR="${HOME}/dibbs-ecr-viewer-playbook"
DIBBS_ECR_VIEWER_DIR="${HOME}/ecr-viewer/project"

# Detect and store package manager
detect_package_manager() {
    if command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
    elif command -v apt-get &> /dev/null; then
        PKG_MGR="apt"
    else
        echo "ERROR: No package manager found (dnf, yum, or apt-get required)."
        exit 1
    fi
}

# Install a package using the detected package manager
install_package() {
    local pkg=$1
    case "$PKG_MGR" in
        dnf)
            dnf install -y "$pkg" || { echo "ERROR: Failed to install $pkg."; exit 1; }
            ;;
        yum)
            yum install -y "$pkg" || { echo "ERROR: Failed to install $pkg."; exit 1; }
            ;;
        apt)
            apt-get update -qq && apt-get install -y -qq "$pkg" || { echo "ERROR: Failed to install $pkg."; exit 1; }
            ;;
    esac
}

# Prerequisites check
check_prerequisites() {
    echo "Checking prerequisites..."

    # Detect package manager once at start
    detect_package_manager

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "ERROR: curl is required but not installed."
        exit 1
    fi

    # Install git if missing
    if ! command -v git &> /dev/null; then
        echo "WARNING: git is not installed. Installing..."
        install_package git
    fi

    # Install ansible if missing
    if ! command -v ansible-playbook &> /dev/null; then
        echo "WARNING: ansible-playbook is not installed. Installing..."
        install_package ansible
    fi

    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null; then
        echo "WARNING: Docker or Docker Compose not found. Installation will continue but playbook may fail."
    fi

    echo "Prerequisites check complete."
    echo ""
}

clone_repository() {
    echo "Cloning repository..."

    # Remove existing clone if present
    rm -rf "$DIBBS_PLAYBOOK_DIR"

    git clone --depth 1 "$REPO_URL" "$DIBBS_PLAYBOOK_DIR"

    echo "Repository cloned to: $DIBBS_PLAYBOOK_DIR"
    echo ""
}

# Main execution
main() {
    check_privileges
    check_prerequisites
    clone_repository

    echo ""
    echo "========================================"
    echo "  Installation Complete!"
    echo "========================================"
    echo ""
    echo "Repository installed at: $DIBBS_ECR_VIEWER_DIR/docker/"
    echo ""
    echo "Next steps:"
    echo "1. Run the setup wizard: cd ~/dibbs-ecr-viewer-playbook && ./wizard.sh"
    echo "2. After configuring, run: ansible-playbook -c local playbook.yaml"
}

main
