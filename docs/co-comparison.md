# Sunsetting dibbs-vm in favor of dibbs-ecr-viewer-playbook
- **Date:** March 2026
- **Author:** @alismx

---

## Recommendation

The Packer-built VM is difficult to maintain, build, and distribute. I propose sunsetting dibbs-vm in favor of an Ansible playbook-based deployment - [dibbs-ecr-viewer-playbook](https://github.com/alismx/dibbs-ecr-viewer-playbook)

The value is about removing friction from future builds and maintenance and reduced costs.

---

## Comparison of the VM and playbook

| Issue | VM | Playbook |
|------------|-----|----------|
| Scanning | Full VM image | Only playbook changes |
| Attack surface | entire OS, ssh, containers | ssh, and containers |
| Audit trail | git commits, images require manual tracking | git commits |
| Self Service | VM process is not easily replicated, proven difficult and error prone | Playbooks are straightforward to run, forked an modified |
| Build | 40-60+ minutes (often fails, requiring restarts) | None |
| Upload | 2-5 hours per cloud (GCP particularly slow/timing out) | None |
| Validate | 15-45 minutes per cloud | 15-45 min per cloud, per OS | 
| Package/Distribute | 30-60 minutes | None |
| Total DevOps testing/release cycle overhead | 6-14+ hours, often spanning multiple working days | 45-135 minutes |

---

## Downsides of the VM

### The Cloud Problem

The VM requires a build with Packer configs, testing cycles and image uploads that can timeout, creating hours-to-days feedback loops.

### Security & Compliance Burden

VMs require full-image scanning for every release, have a large attack surface from the bundled OS+app, and having the latest security updates require us to rebuild entire images at a regular cadence. Distribution relies on manual file sharing, emails, and password sharing, which is not scalable or secure without dedicated infrastructure.

### Self-Service Limitations

Currently, CO needs to wait for DIBBS DevOps to build and distribute images. The build process is time-consuming, manual, and prone to errors. In the future, CO will need to take ownership of this process.

## Our solution

### One Deployment Method

The playbook deploys in the same way to any supported Linux distribution:
```bash
# Install and deploy on any supported OS(Ubuntu at the moment)
curl -sSL https://...prereqs.sh | bash
# Run the playbook
ansible-playbook playbook.yaml
```

## Value

### Self-Service by Design

**Playbook Workflow:** Run prerequisites script -> Gather all the app secrets you need -> Configure via playbook wizard -> Ready to go

**Why Playbooks Enable Self-Service:**
- **No waiting for DIBBS DevOps** - Straightforward instructions, an Ubuntu Server, very few dependencies, partners can deploy on their own timeline
- **Forkable and customizable** - CO can fork and modify playbook for their needs while staying update to date with any changes we put out
- **Consistent deployments** - Nearly identical process across all clouds and on-prem environments
- **Straightforward updates** - Run a script + re-run playbook OR `git pull` + re-run playbook, this is as straightforward as it gets
- **Security updates** - Easier and quicker to resolve security issues

### Security Advantages

Ansible comes with access to a wide range of easily implemented static scans, and native testing tools to ensure compliance and quality code. OS scans only need to cover what the playbook modifies, not the entire OS.

---

## Measurable Value by adopting the playbook

### Direct Savings
- **Eliminates wasted DevOps hours running builds and managing images**
- **Eliminates the need for artifact storage and distribution**
- **Eliminates the need for VM build compute**

---

## Migration Plan

### Overview

The playbook approach enables a simple, low-risk migration path: **replace your current instance with a new vanilla Ubuntu Server and run the playbook**.

### For Existing VM Users

1. **Backup**: Export configuration from your current VM (from `~/ecr-viewer/project/docker/dibbs-ecr-viewer.env`)
2. **Provision**: Launch a new Ubuntu 24.04 LTS server instance
3. **Deploy**: 
   1. Import configuration into the new instance (`~/dibbs-ecr-viewer-playbook/docker/dibbs-ecr-viewer.env`)
   2. Run the playbook on the new instance without wizard prompts(or with if you skipped importing your configuration file)
4. **Verify**: Test all services and configurations
5. **Switch**: Update DNS/load balancer to point to the new instance

### For New Deployments

2. **Provision**: Launch a new Ubuntu 24.04 LTS server instance
3. **Deploy**: Run the playbook on the new instance with wizard prompts
4. **Verify**: Test all services and configurations
5. **Switch**: Update DNS/load balancer to point to the new instance

---

*This document was prepared as part of the dibbs project. For questions, please contact @alismx.*
