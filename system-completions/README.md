# `system-completions` Zinit package

| **Package source:** | Tarball | Binary | Git | Node | Gem |
|:-------------------:|:-------:|:------:|:---:|:----:|:---:|
| **Status:**         |    -    |    -   |  -  |   –  |  –  |

## Introduction

[Zinit](https://github.com/zdharma-continuum/zinit) can use a `package.json`
(similar in construct to the one used in `npm` packages) to automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
    - there can be multiple lists of ices,
    - the ice lists are stored in *profiles*; there's at least one profile, *default*,
    - the ices can be selectively overriden.

## The `system-completions` Package

Moves the stock Zsh completions under the control of Zinit. You can then
selectively enable and disable the completions with `cenable` and `cdisable`.

Example Zinit invocations:

```zsh
zinit pack for system-completions

# Utilize Turbo
zinit wait pack for system-completions

# Utilize Turbo and initialize the completion system
zinit wait pack atload=+"zicompinit; zicdreplay" for system-completions
```

## Default Profile

The Zinit command executed will be equivalent to:

```zsh
zinit id-as=system-completions wait as=completion lucid \
    atclone='print Installing system completions...; \
      mkdir -p $ZPFX/funs; \
      command cp -f $ZPFX/share/zsh/$ZSH_VERSION/functions/^_* $ZPFX/funs; \
      zinit creinstall -q $ZPFX/share/zsh/$ZSH_VERSION/functions' \
    atload='fpath=( ${(u)fpath[@]:#$ZPFX/share/zsh/*} ); \
      fpath+=( $ZPFX/funs )' \
    atpull="%atclone" run-atpull for \
         zdharma/null
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
