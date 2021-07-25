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
  - Apps/App instances/Tasks/...
  - Domains/Routes/...
  - Files
  - Marketplace/Service brokers/Service instances/...
  - Orgs/Spaces/...
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
