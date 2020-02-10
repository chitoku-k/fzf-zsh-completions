fzf-zsh-completions
===============

[![][travis-badge]][travis-link]

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
  - log
  - merge
  - rebase
  - reset
  - revert
  - switch
- make
- npm
  - run
- systemctl
- yarn
  - run

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

[travis-link]:     https://travis-ci.com/chitoku-k/fzf-zsh-completions
[travis-badge]:    https://img.shields.io/travis/com/chitoku-k/fzf-zsh-completions/master.svg?style=flat-square
[fzf]:             https://github.com/junegunn/fzf
[fzf-completions]: https://github.com/junegunn/fzf/blob/master/README.md#fuzzy-completion-for-bash-and-zsh
[Zsh]:             https://www.zsh.org/
