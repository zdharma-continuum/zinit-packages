# zinit package for [romkatv/zsh-bin](https://github.com/romkatv/zsh-bin)

Very much WIP.

## Usage

```zsh
zinit pack for zsh-static
```

## Profiles

### Default profile

Requires root or sudo. Installs static zsh to /usr/local and tries to register it as a login shell.

```zsh
zinit lucid as"null" \
  depth"1" \
  atclone"./install -e yes -d /usr/local" \
  atpull"%atclone" \
  nocompile \
  nocompletions \
  for @romkatv/zsh-bin
```

### rootless profile

Does not require root. Installs static zsh to ~/.local.

```zsh
zinit lucid as"null" \
  depth"1" \
  atclone"./install -e no -d ~/.local" \
  atpull"%atclone" \
  nocompile \
  nocompletions \
  for @romkatv/zsh-bin
```

### bgn profile

**🚧 DO NOT USE. WIP.**

The Zinit command that'll be run will be equivalent to:

```zsh
zinit lucid as"null" \
  from"gh-r" \
  sbin"bin/zsh*" \
  bpick"*.tar.gz" \
  nocompile \
  for @romkatv/zsh-bin
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
