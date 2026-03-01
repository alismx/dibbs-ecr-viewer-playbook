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

- **Operating System**: Fedora Server 43 (tested), other Linux distributions may work
- **Tools**:
  - Git
  - Ansible
  - Docker & Docker Compose (installed by playbook)
- **User**: A non-root user with sudo privileges to run the wizard script

## Quick Start

1. **Clone this repository**
   ```bash
   git clone <repository-url>
   cd dibbs-ecr-viewer-playbook
   ```

2. **Run the setup wizard**
   ```bash
   ./wizard.sh
   ```
   The wizard will:
   - Parse existing environment defaults
   - Guide you through selecting a configuration (AWS/Azure/GCP + PostgreSQL/SQL Server)
   - Prompt for required credentials and settings
   - Generate environment files and restart the Docker Compose stack

3. **Verify deployment**
   ```bash
   docker compose ps
   ```

## Configuration Options

The wizard supports 15 different configurations combining:

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

After running the wizard, environment files are created at `/home/ecr-viewer/project/docker/`:

- **dibbs-ecr-viewer.env** - Main application configuration (cloud credentials, database connection, auth settings)
- **dibbs-orchestration.env** - Service URL configuration for internal communication

## Usage After Deployment

### View Logs
```bash
docker compose logs -f ecr-viewer
```

### Restart Services
```bash
cd /home/ecr-viewer/project/docker && docker compose restart
```

### Stop Services
```bash
cd /home/ecr-viewer/project/docker && docker compose down
```

### Access Portainer
Open `http://<server-ip>:9000` to manage containers via the web UI.

## Manual Configuration

If you prefer not to use the wizard, manually edit the environment files:

```bash
# Edit the main configuration
vim /home/ecr-viewer/project/docker/dibbs-ecr-viewer.env

# Restart services to apply changes
docker compose -f /home/ecr-viewer/project/docker/docker-compose.yaml up -d
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
├── wizard.sh              # Interactive setup script
├── tasks/
│   ├── deps.yaml         # Install Docker dependencies
│   ├── dirs.yaml         # Create project directories
│   ├── compose.yaml      # Run docker-compose
│   └── aws/gcp.yaml      # Cloud-specific tasks (commented)
├── project/
│   └── docker/
│       ├── docker-compose.yaml
│       ├── dibbs-ecr-viewer.env
│       └── dibbs-orchestration.env
└── vars.yaml              # Variables placeholder
```

## License

MIT License - see [LICENSE](LICENSE) for details.
