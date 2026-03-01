#!/bin/bash

# Install script for dibbs-ecr-viewer-playbook
# Usage: curl -sSL https://github.com/alismx/dibbs-ecr-viewer-playbook/install.sh | bash
#
# This script will:
# 1. Clone the repository to /tmp/dibbs-ecr-viewer-playbook
# 2. Run the wizard.sh setup script interactively
# 3. Execute the Ansible playbook

set -e

echo "========================================"
echo "  DIBBS eCR Viewer Installation Script"
echo "========================================"
echo ""

# Configuration
REPO_URL="https://github.com/alismx/dibbs-ecr-viewer-playbook"
INSTALL_DIR="/tmp/dibbs-ecr-viewer-playbook"
PROJECT_DIR="/home/ecr-viewer/project"

# Prerequisites check
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "ERROR: curl is required but not installed."
        exit 1
    fi
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        echo "ERROR: git is required but not installed."
        exit 1
    fi
    
    # Check if ansible is available
    if ! command -v ansible-playbook &> /dev/null; then
        echo "WARNING: ansible-playbook is not installed. Installing..."

        # Detect OS and use appropriate package manager
        if command -v dnf &> /dev/null; then
            # Fedora 31+
            dnf install -y ansible || {
                echo "ERROR: Failed to install ansible."
                exit 1
            }
        elif command -v yum &> /dev/null; then
            # RHEL/CentOS/Fedora < 31
            yum install -y ansible || {
                echo "ERROR: Failed to install ansible."
                exit 1
            }
        elif command -v apt-get &> /dev/null; then
            # Debian/Ubuntu
            apt-get update -qq && apt-get install -y -qq ansible || {
                echo "ERROR: Failed to install ansible."
                exit 1
            }
        else
            echo "ERROR: No package manager found (dnf, yum, or apt-get required)."
            exit 1
        fi
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
    rm -rf "$INSTALL_DIR"
    
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
    
    echo "Repository cloned to: $INSTALL_DIR"
    echo ""
}

run_wizard() {
    echo "Running setup wizard..."
    echo "The wizard will prompt you for configuration details."
    echo ""

    if [ -f "$PROJECT_DIR/docker/dibbs-ecr-viewer.env" ]; then
        echo "WARNING: Existing environment file found at $PROJECT_DIR/docker/dibbs-ecr-viewer.env"
        read -p "Do you want to overwrite it? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "Aborting installation."
            exit 0
        fi
    fi

    # Run the wizard script from its own directory
    bash "$INSTALL_DIR/wizard.sh"

    echo ""
}

run_playbook() {
    echo "Running Ansible playbook..."
    echo ""
    
    cd "$INSTALL_DIR"
    
    ansible-playbook -c local playbook.yaml
    
    echo ""
    echo "========================================"
    echo "  Installation Complete!"
    echo "========================================"
    echo ""
    echo "Your eCR Viewer is now installed at: $PROJECT_DIR/docker/"
    echo "Check the .env file for your configuration."
}

cleanup() {
    echo ""
    read -p "Clean up temporary installation files? (Y/n): " cleanup_confirm
    if [ "$cleanup_confirm" != "n" ] && [ "$cleanup_confirm" != "N" ]; then
        rm -rf "$INSTALL_DIR"
        echo "Cleanup complete."
    fi
}

# Main execution
main() {
    check_prerequisites
    clone_repository
    run_wizard
    run_playbook
    cleanup
    
    echo ""
    echo "Installation finished successfully!"
    echo "Next steps:"
    echo "  1. Check $PROJECT_DIR/docker/dibbs-ecr-viewer.env for your configuration"
    echo "  2. Access your eCR Viewer at http://localhost:3000/ecr-viewer"
}

main
