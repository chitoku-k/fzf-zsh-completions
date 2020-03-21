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

### zplug

```zsh
zplug "chitoku-k/fzf-zsh-completions"
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
  - rebase
  - reset
  - restore
  - revert
  - rm
  - switch
- make
- npm
  - run
- systemctl
- yarn
  - run
- docker
  - attach
  - commit
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

## Usage

For further information, please refer to [Fuzzy completions for bash and zsh][fzf-completions].

```zsh
git rebase -i **<TAB>
```

## Testing

For contributing to this project, be sure to update `tests/` and run following:

```zsh
tests/test.zsh
```

[workflow-link]:   https://travis-ci.com/chitoku-k/fzf-zsh-completions
[workflow-badge]:  https://img.shields.io/github/workflow/status/chitoku-k/fzf-zsh-completions/ci/master.svg?style=flat-square
[fzf]:             https://github.com/junegunn/fzf
[fzf-completions]: https://github.com/junegunn/fzf/blob/master/README.md#fuzzy-completion-for-bash-and-zsh
[Zsh]:             https://www.zsh.org/
