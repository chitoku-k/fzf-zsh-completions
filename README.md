fzf-zsh-completions
===============

[![][workflow-badge]][workflow-link]

Fuzzy completions for [fzf][] and [Zsh][] that can be triggered by the trigger
sequence that defaults to `**`.

<img src="https://user-images.githubusercontent.com/6535425/96915303-0d674180-14e1-11eb-8a14-5b3cd3673a49.png" alt="git" width="600"><br>
<img src="https://user-images.githubusercontent.com/6535425/96915276-06403380-14e1-11eb-9697-3cd40db7cc58.png" alt="kubectl" width="600"><br>
<img src="https://user-images.githubusercontent.com/6535425/96915321-10fac880-14e1-11eb-9222-93fd5a1563b4.png" alt="systemctl" width="600">

## Prerequisites

- [fzf][]
- [Zsh][] >= 5.3
- [jq][]

## Installation

Load `fzf-zsh-completions.plugin.zsh`.

For those who prefer to install via package managers, see the instructions
below. Be sure to load the plugin after `alias` calls for aliased completions to
work.

### Antigen

```zsh
antigen bundle "chitoku-k/fzf-zsh-completions"
```

### zplug

```zsh
zplug "chitoku-k/fzf-zsh-completions"
```

## Usage

For further information, please refer to [Fuzzy completions for bash and zsh][fzf-completions].

```zsh
git rebase -i **<TAB>
```

## Supported commands

- cf
  - App instances (files, restart-app-instance, and ssh)
  - Apps (app, add-network-policy, bind-service, copy-source, create-app-manifest, delete, env, events, files, get-health-check, logs, map-route, push, remove-network-policy, rename, restage, restart, restart-app-instance, run-task, scale, set-env, set-health-check, ssh, start, stop, tasks, terminate-task, unbind-service, unmap-route, and unset-env)
  - Buildpacks (create-buildpack, delete-buildpack, push, rename-buildpack, and update-buildpack)
  - Domains (check-route, create-route, delete-domain, delete-shared-domain, push, share-private-domain, and unshare-private-domain)
  - Environment variables (set-env, and unset-env)
  - Feature flags (disable-feature-flag, enable-feature-flag, and feature-flag)
  - Files (create-buildpack, and push)
  - Isolation segments (delete-isolation-segment, disable-org-isolation, and enable-org-isolation)
  - Marketplace (create-service, disable-service-access, enable-service-access, marketplace, purge-service-offering, and service-access)
  - Marketplace plans (marketplace, and update-service)
  - Orgs (add-network-policy, create-domain, delete-org, disable-org-isolation, disable-service-access, enable-org-isolation, enable-service-access, copy-source, org, org-users, remove-network-policy, rename-org, reset-org-default-isolation-segment, service-access, set-org-role, set-quota, set-space-role, share-private-domain, share-service, space-users, unset-org-role, unset-space-role, unshare-private-domain, and unshare-service)
  - Plugins (uninstall-plugin)
  - Quotas (delete-quota, quota, set-quota, and update-quota)
  - Router groups (create-shared-domain)
  - Routes (bind-route-service, delete-route, map-route, unbind-route-service, and unmap-route)
  - Security groups (bind-running-security-group, bind-staging-security-group, delete-security-group, security-group, unbind-running-security-group, and unbind-staging-security-group)
  - Service brokers (create-service, delete-service-broker, disable-service-access, enable-service-access, purge-service-offering, rename-service-broker, service-access, and update-service-broker)
  - Service instances (bind-route-service, bind-service, create-service-key, delete-service, purge-service-instance, rename-service, service, service-keys, share-service, unbind-route-service, unbind-service, unshare-service, update-service, and update-user-provided-service)
  - Space quotas (delete-space-quota, set-space-quota, space-quota, unset-space-quota, and update-space-quota)
  - Spaces (add-network-policy, allow-space-ssh, copy-source, create-route, disallow-space-ssh, remove-network-policy, rename-space, reset-space-isolation-segment, set-space-role, space, space-ssh-allowed, space-users, and unset-space-role)
  - Stacks (delete-buildpack, push, rename-buildpack, stack, and update-buildpack)
  - Tasks (terminate-task)
  - User-provided service instance’s credentials (update-user-provided-service)
- composer
  - Scripts
- gh
  - Pull Requests
- git
  - Commit-ish
  - Commit messaees
  - Files
  - Remotes
- kubectl
  - Annotations/Labels/Field selectors
  - Containers/Ports
  - Files
  - Resources
  - Taints
- make
  - Targets
- npm
  - Scripts
- systemctl
  - Services
- yarn
  - Scripts
- docker
  - Containers/Images/Networks/Volumes
  - Files
  - Repositories

## Testing

For contributing to this project, be sure to update `tests/` and run following:

```zsh
tests/test.zsh
```

## Related Project

- [fzf-preview.zsh][]

[workflow-link]:   https://github.com/chitoku-k/fzf-zsh-completions/actions?query=branch:master
[workflow-badge]:  https://img.shields.io/github/workflow/status/chitoku-k/fzf-zsh-completions/CI%20Workflow/master.svg?style=flat-square
[fzf]:             https://github.com/junegunn/fzf
[fzf-completions]: https://github.com/junegunn/fzf/blob/master/README.md#fuzzy-completion-for-bash-and-zsh
[Zsh]:             https://www.zsh.org/
[fzf-preview.zsh]: https://github.com/yuki-ycino/fzf-preview.zsh
[jq]:              https://github.com/stedolan/jq
