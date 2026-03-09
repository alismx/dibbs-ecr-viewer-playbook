#!/bin/bash

# Prerequisites installation script for dibbs-ecr-viewer-playbook
# Usage: curl -sSL https://raw.githubusercontent.com/alismx/dibbs-ecr-viewer-playbook/main/prereqs.sh | bash
#
# This script will:
# 1. Clone the repository to ~/dibbs-ecr-viewer-playbook
# 2. Install Docker and required dependencies

set -e

echo "========================================"
echo "  DIBBS eCR Viewer Prerequisites"
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
        echo ""
        echo "Please enter your password to verify sudo access:"
        if ! sudo -v; then
            echo "ERROR: Sudo authentication failed."
            exit 1
        fi
    fi

    echo "Privilege check complete."
    echo ""
}

# Configuration
REPO_URL="https://github.com/alismx/dibbs-ecr-viewer-playbook.git"
DIBBS_PLAYBOOK_DIR="${HOME}/dibbs-ecr-viewer-playbook"

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

    echo "Prerequisites check complete."
    echo ""
}

clone_repository() {
    echo "Cloning repository..."

    # Backup existing clone if present
    if [ -d "$DIBBS_PLAYBOOK_DIR" ]; then
        BACKUP_DIR="${DIBBS_PLAYBOOK_DIR}.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backing up existing installation to: $BACKUP_DIR"
        mv "$DIBBS_PLAYBOOK_DIR" "$BACKUP_DIR"
    fi

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
    echo "  Prereqs Complete!"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "Run: cd ~/dibbs-ecr-viewer-playbook && ansible-playbook -c local playbook.yaml --extra-var 'force_wizard=true'"
}

main
