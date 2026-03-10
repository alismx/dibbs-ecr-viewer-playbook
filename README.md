# DIBBS eCR Viewer Playbook

An Ansible-based setup project for deploying the CDC's **eCR (Electronic Case Reporting) Viewer** application stack using Docker Compose.

## Overview

This playbook automates the deployment of the following services:

| Service | Port | Description |
|---------|------|-------------|
| `ecr-viewer` | 3000 | Main web application |
| `ingestion` | 8080 | Ingestion API service |
| `fhir-converter` | 8082 | FHIR data converter |
| `message-parser` | 8083 | Message parser service |
| `trigger-code-reference` | 8084 | Trigger code reference |
| `orchestration` | 8085 | Orchestration service |
| `portainer` | 9000 | Container management UI |

## Prerequisites

- **Operating Systems**:
  - Fedora Server 43
  - Ubuntu 24.04 LTS (Noble Numbat)
  - Debian 12 (Bookworm)
- **Tools**:
  - Git
  - Ansible
- **User**: A non-root user with sudo privileges to install packages and run the playbook

## Installation

```bash
# Download and run prerequisites installation (non-interactive)
curl -sSL https://raw.githubusercontent.com/alismx/dibbs-ecr-viewer-playbook/main/prereqs.sh | bash

# Navigate to the installed directory
cd ~/dibbs-ecr-viewer-playbook

# Run the Ansible playbook to deploy
ansible-playbook -c local playbook.yaml
```

The playbook will:
1. Install Docker and required dependencies
2. Prompt for configuration interactively (first run only)
3. Start the Docker Compose stack

**Note**: The installation script requires sudo access to install system packages (Docker, Ansible) and will prompt for your password when needed.

### Updating

To update your installation, re-run the prerequisites script which pulls the latest changes and re-applies the playbook:

```bash
curl -sSL https://raw.githubusercontent.com/alismx/dibbs-ecr-viewer-playbook/main/prereqs.sh | bash
```

**Note**: The prereqs script creates a backup of your existing installation before updating, allowing you to restore if needed.

If you prefer to update manually:

```bash
cd ~/dibbs-ecr-viewer-playbook
git pull
ansible-playbook -c local playbook.yaml
```

## Configuration Options

The playbook prompts for 15 different configurations combining:

- **Cloud Providers**: AWS, Azure, GCP
- **Databases**: PostgreSQL, SQL Server
- **Integration Modes**: Non-integrated, Dual, or Integrated (with NBS)

### Selected Configurations

| Config | Description |
|--------|-------------|
| `AWS_PG_NON_INTEGRATED` | AWS S3 + PostgreSQL, manual configuration |
| `AWS_INTEGRATED` | AWS S3 + NBS integration |
| `AZURE_SQLSERVER_DUAL` | Azure Storage + SQL Server with NBS dual write |
| `GCP_INTEGRATED` | GCP Cloud Storage + NBS integration |

## Environment Files

After running the playbook, environment files are created at `~/ecr-viewer/project/docker/`:

- **dibbs-ecr-viewer.env** - Main application configuration (cloud credentials, database connection, auth settings)
- **dibbs-orchestration.env** - Service URL configuration for internal communication

## Usage After Deployment

### View Logs
```bash
docker compose logs -f ecr-viewer
```

### Restart Services
```bash
cd ~/ecr-viewer/project/docker && docker compose restart
```

### Stop Services
```bash
cd ~/ecr-viewer/project/docker && docker compose down
```

### Access Portainer
Open `http://<server-ip>:9000` to manage containers via the web UI.

## Manual Configuration

If you prefer not to use the playbook's interactive prompts, manually edit the environment files:

```bash
# Edit the main configuration
vim ~/ecr-viewer/project/docker/dibbs-ecr-viewer.env

# Restart services to apply changes
docker compose -f ~/ecr-viewer/project/docker/docker-compose.yaml up -d
```

## Required Environment Variables

### All Configurations
- `CONFIG_NAME` - Configuration profile (see above)
- `DATABASE_URL` or SQL Server credentials
- `AUTH_PROVIDER` - Authentication method (`ad` or `keycloak`)
- `AUTH_CLIENT_ID`, `AUTH_CLIENT_SECRET`, `AUTH_ISSUER`
- `NEXTAUTH_SECRET` - Generate with: `openssl rand -base64 32`

### Cloud-Specific
| Provider | Variables |
|----------|-----------|
| AWS | `AWS_REGION`, `ECR_BUCKET_NAME` |
| Azure | `AZURE_STORAGE_CONNECTION_STRING`, `AZURE_CONTAINER_NAME` |
| GCP | `GCP_PROJECT_ID`, `ECR_BUCKET_NAME` |

## Project Structure

```
dibbs-ecr-viewer-playbook/
├── playbook.yaml          # Main Ansible playbook
├── install.sh             # Automated installation script
├── roles/                 # Ansible role directory
│   └── dibbs_ecr_viewer/
│       ├── tasks/         # Task files (main.yaml, prereqs.yaml, wizard.yaml, etc.)
│       ├── handlers/main.yaml  # Handlers for services
│       ├── defaults/      # Default variables
│       ├── vars/          # Role-specific variables
│       └── meta/          # Role metadata
├── project/
│   └── docker/
│       ├── docker-compose.yaml
│       ├── dibbs-ecr-viewer.env
│       └── dibbs-orchestration.env
└── vars.yaml              # Variables placeholder
```

## License

MIT License - see [LICENSE](LICENSE) for details.
