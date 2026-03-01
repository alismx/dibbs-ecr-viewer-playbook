#!/bin/bash

# Update script for dibbs-ecr-viewer-playbook
# Usage: ./update.sh
#
# This script will:
# 1. Pull the latest changes from the repository
# 2. Re-run the Ansible playbook to apply any configuration updates
# 3. Restart Docker Compose services if needed

set -e

echo "========================================"
echo "  DIBBS eCR Viewer Update Script"
echo "========================================"
echo ""

# Configuration
REPO_DIR="${REPO_DIR:-$(dirname "$0")}"
PROJECT_DIR="/home/ecr-viewer/project/docker"

# Verify we're in the correct directory
if [ ! -f "$REPO_DIR/playbook.yaml" ]; then
    echo "ERROR: playbook.yaml not found. Please run this script from the repository root."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker compose &> /dev/null; then
    echo "ERROR: Docker Compose is required but not installed."
    exit 1
fi

# Pull latest changes
echo "Pulling latest changes..."
cd "$REPO_DIR"
git pull
echo ""

# Check if environment file exists
if [ ! -f "$PROJECT_DIR/dibbs-ecr-viewer.env" ]; then
    echo "WARNING: Environment file not found at $PROJECT_DIR/dibbs-ecr-viewer.env"
    echo "The playbook will create this file during installation."
    read -p "Continue with playbook run? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Aborting update."
        exit 0
    fi
fi

# Run Ansible playbook
echo ""
echo "Running Ansible playbook to apply configuration updates..."
cd "$REPO_DIR"
ansible-playbook -c local playbook.yaml

echo ""

# Restart Docker Compose services
echo "Restarting Docker Compose services..."
cd "$PROJECT_DIR"
docker compose down
docker compose up -d

echo ""
echo "========================================"
echo "  Update Complete!"
echo "========================================"
echo ""
echo "Your eCR Viewer has been updated."
echo "Check the logs with: docker compose logs -f"
