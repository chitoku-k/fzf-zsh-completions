fzf-zsh-completions
===============

[![][travis-badge]][travis-link]

Fuzzy completions for [fzf][] and [Zsh][] that can be triggered by the trigger
sequence that defaults to `**`.

## Prerequisites

- [fzf][]
- [Zsh][]

## Installation

Just load all the `*.zsh` files under the root directory.

For those who prefer to install via package managers, see the instructions
below.

### zplug

```zsh
zplug "chitoku-k/fzf-zsh-completions"
```

## Supported commands

- git
  - add
    - Shows the unstaged files
  - branch
    - Shows the commits/branches/tags
  - checkout
    - Shows the commits/branches/tags
  - cherry-pick
    - Shows the commits/branches/tags
  - commit
    - Shows the commit messages, or the commits/branches/tags if preceded by `--fixup`
  - log
    - Shows the commits/branches/tags
  - merge
    - Shows the commits/branches/tags
  - rebase
    - Shows the commits/branches/tags
  - reset
    - Shows the commits/branches/tags
- npm
  - run
    - Shows the scripts
- yarn
  - run
    - Shows the scripts

## Usage

For further information, please refer to [Fuzzy completions for bash and zsh][fzf-completions].

```zsh
git rebase -i **<TAB>
```

[travis-link]:     https://travis-ci.com/chitoku-k/fzf-zsh-completions
[travis-badge]:    https://img.shields.io/travis/com/chitoku-k/fzf-zsh-completions/master.svg?style=flat-square
[fzf]:             https://github.com/junegunn/fzf
[fzf-completions]: https://github.com/junegunn/fzf/blob/master/README.md#fuzzy-completion-for-bash-and-zsh
[Zsh]:             https://www.zsh.org/
