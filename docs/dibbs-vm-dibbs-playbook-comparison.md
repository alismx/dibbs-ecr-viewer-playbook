# Sunsetting dibbs-vm in Favor of dibbs-ecr-viewer-playbook
- **Date:** March 2026
- **Author:** @alismx

---

## Executive Summary

The Packer-built VM approach has become increasingly difficult to maintain, build, and distribute. I propose sunsetting dibbs-vm in favor of an Ansible playbook-based deployment - [dibbs-ecr-viewer-playbook](https://github.com/alismx/dibbs-ecr-viewer-playbook)

| Issue | VM | Playbook |
|------------|-----|----------|
| Multi-cloud support | GCP and AWS with different processes | AWS, Azure, GCP + other + on-prem with the same playbook |
| Scanning | Full VM image | Only playbook changes |
| Attack surface | entire OS + Containers | ssh, and containers |
| Audit trail | git commits, images require manual tracking | git commits |
| Self Service | VM process is not easily replicated, proven diffcult and error prone | Playbooks are straightforward to run, forked an modified |
| Build | 40-60+ minutes (often fails, requiring restarts) | None |
| Upload | 2-5 hours per cloud (GCP particularly slow/timing out) | None |
| Validate | 15-45 minutes per cloud | 15-45 min per cloud, per OS | 
| Package/Distribute | 30-60 minutes | None |
| Total DevOps testing/release cycle overhead | 6-14+ hours, often spanning multiple working days | 45-135 minutes |

---

## Recommendation

**Sunset the dibbs-vm approach and migrate all development to the playbook.**

This isn't just about cutting costs - it's about removing friction from deployment so we can focus on:
- **Shipping value quickly to more jurisdictions**
- **Creating a product that can actually be self-service**
- **Adding features**

---

## Why the VM Appliance Approach Is Failing Us

### The Multi-Cloud Problem

The VM requires separate builds for each cloud (GCP only has 1 partner; AWS has interest but no deployments; Azure isn't implemented). Each cloud needs unique Packer configs and testing, creating hours-to-days feedback loops. Combined with slow image uploads that can timeout, this makes multi-cloud support impractical.

### Security & Compliance Burden

VMs require full-image scanning for every release (not yet fully implemented), have a large attack surface from the bundled OS+app, and having the latest security updates require us to rebuild entire images at a regular cadence. Distribution currently rely on manual file sharing, emails, and password sharing, which is not scalable or secure without dedicated infrastructure.

### Self-Service Limitations

Moving the VM approach towards self-service model will present our partners with the same challenges I'm outlining in this document, and would take significant development to improve. At the moment, partners typically wait for DIBBS DevOps to build and distribute images because the build process is time-consuming, manual, and prone to errors.

This creates friction that prevents jurisdictions from deploying on their own timeline.

## How the Playbook Approach Solves This

### One Deployment Method for All Clouds

The playbook deploys in the same way to any supported Linux distribution:
```bash
# Install and deploy on any supported OS(Ubuntu at the moment)
curl -sSL https://...prereqs.sh | bash
# Run the playbook
ansible-playbook playbook.yaml
```

### Self-Service by Design

**Playbook Workflow:** Run prerequisites script -> Gather all the app secrets you need -> Configure via playbook wizard -> Ready to go

**Why Playbooks Enable Self-Service:**
- **No waiting for DIBBS DevOps** - Straightforward instructions, a vanilla Ubuntu Server OS, and very few dependencies, partners can deploy on their own timeline
- **Forkable and customizable** - Jurisdictions can fork and modify playbook for their needs while staying update to date with any changes we put out
- **Consistent deployments** - Nearly identical process across all clouds and on-prem environments
- **Straightforward updates** - Run a script we provide + re-run playbook OR `git pull` + re-run playbook, this is as straightforward as it gets

### Security Advantages

Ansible comes with access to a wide range of easily implemented static scans, and native testing tools to ensure compliance and quality code. OS scans only need to cover what the playbook modifies, not the entire OS.

---

## Measurable Value by adopting the playbook

### Direct Savings for us and for our partners $$$
- **Eliminates the need for artifact storage and distribution**
- **Eliminates the need for VM build compute**
- **Eliminates wasted DevOps hours running builds and managing images**

### Strategic Benefits
| Initiative | VM | Playbook |
|------------|-----|----------|
| Add Azure support | Implementation may time weeks/Not Planned | Implementation may take days, Azure is likely already supported, but this requires a dev/test cycle to confirm |
| Jurisdiction support | Issues may take a week or more to resolve | Could be solved same day |
| DIBBS products | Would need separate builds per product, per cloud | Could be a template, modified for other DIBBS products |

---

## OKR Alignment - 2025 Objectives

| OKR | VM Approach | Playbook Impact |
|-----|-------------|-----------------|
| eCR Viewer used by case investigators, EPIs, eCR teams | Slow feature delivery | Weekly iterations |
| Jurisdictions have support/resources to adopt | Complex distribution barriers | Self-service deployment |
| New features make workflow delightful | Monthly releases | Frequent improvements |
| 8 jurisdictions in production | Build capacity limits | Parallel deployments |

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

### What Happens to Existing VM Images

- AWS AMIs: Mark as deprecated, do not launch new instances
- GCP images: Remove from public availability, keep for CO until they migrate
- Azure: Not currently supported, no work

---

*This document was prepared as part of the dibbs project. For questions, please contact @alismx.*
