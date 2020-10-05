fzf-zsh-completions
===============

[![][workflow-badge]][workflow-link]

Fuzzy completions for [fzf][] and [Zsh][] that can be triggered by the trigger
sequence that defaults to `**`.

## Prerequisites

- [fzf][]
- [Zsh][] >= 5.3

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
- git
  - add
  - branch
  - checkout
  - cherry-pick
  - commit
  - diff
  - log
  - merge
  - pull
  - push
  - rebase
  - reset
  - restore
  - revert
  - rm
  - switch
- kubectl
  - describe (pods)
  - exec
  - get (pods)
  - logs
- make
- npm
  - run
- systemctl
- yarn
  - run
- docker
  - attach
  - commit
  - cp
  - create
  - diff
  - exec
  - export
  - history
  - kill
  - logs
  - pause
  - port
  - rename
  - restart
  - rm
  - rmi
  - run
  - save
  - start
  - stats
  - stop
  - tag
  - top
  - unpause
  - update
  - wait

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
