# dibbs-ecr-viewer-playbook

Ansible playbook to set up a DIBBS ecr-viewer environment on Fedora Server.

## Features

- Install Docker and dependencies on Fedora (dnf)
- Configure fail2ban for SSH protection (Fedora 39+)
- Create project directories and user account
- Setup docker-compose based ecr-viewer deployment

### Fail2ban Support

The playbook includes fail2ban configuration for Fedora systems:
- Installs fail2ban via dnf on Fedora 39+
- Configures jails for sshd with DDoS protection
- Default settings: 5-minute findtime, 10-minute ban time
- Customizable via templates/jails.local.j2

## Compatibility

Tested with:
- Fedora Server 43

## Requirements

- Git
- Ansible (tested with 2.15+)

## Usage

```bash
git clone https://github.com/alismx/dibbs-ecr-viewer-playbook.git
cd dibbs-ecr-viewer-playbook
ansible-playbook playbook.yaml
```

