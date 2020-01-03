fzf-zsh-completions
===============

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
    - Shows the files
  - branch
    - Shows the commits/branches
  - checkout
    - Shows the commits/branches
  - cherry-pick
    - Shows the commits/branches
  - commit
    - Shows the commit messages, or the commits/branches if preceded by `--fixup`
  - log
    - Shows the commits/branches
  - merge
    - Shows the commits/branches
  - rebase
    - Shows the commits/branches
  - reset
    - Shows the commits/branches
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

[fzf]:             https://github.com/junegunn/fzf
[fzf-completions]: https://github.com/junegunn/fzf/blob/master/README.md#fuzzy-completion-for-bash-and-zsh
[Zsh]:             https://www.zsh.org/
