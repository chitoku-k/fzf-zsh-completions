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
below.

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

- composer
  - Scripts (run-script)
- gh
  - Pull Requests (pr \*)
- git
  - Commit-ish (branch, checkout, cherry-pick, diff, log, merge, pull, rebase, reset, revert, show, and switch)
  - Commit messaees (commit)
  - Files (add, checkout, commit, diff, reset, restore, rm, and show)
  - Remotes (pull)
- kubectl
  - Annotations (annotate)
  - Containers (exec, logs, and set)
  - Files (apply)
  - Labels (annotate, cordon, delete, describe, drain, diff, get, label, logs, run, scale, set, taint, uncordon, and wait)
  - Nodes (cordon, drain, and uncordon)
  - Ports (port-forward)
  - Resources (annotate, autoscale, create, delete, describe, edit, exec, explain, expose, get, label, logs, patch, rollout, set, scale, and taint)
  - Taints (taint)
- make
  - Targets
- npm
  - Scripts (run)
- systemctl
  - Services
- yarn
  - Scripts (run, workspace, and workspace \<workspace\>)
- docker
  - Containers (attach, commit, cp, diff, exec, export, inspect, kill, logs, pause, ports, rename, restart, rm, start, stats, stop, update, unpause, and wait)
  - Files (cp)
  - Images (create, history, inspect, rmi, run, save, and tag)
  - Networks (inspect)
  - Repositories (push)
  - Volumes (inspect)

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
