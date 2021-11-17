# trapd00r/LS_COLORS: Zsh & NPM package

**LS_COLORS source code**:
[trapd00r/LS_COLORS](https://github.com/trapd00r/LS_COLORS)

| Package | Tarball |   Git   | Node | Gem |
| :-----: | :-----: | :-----: | :--: | :-: |
| Status  |   N/A   | Default | N/A  | N/A |

[Zinit](https://github.com/zdharma-continuum/zinit) can use a `package.json`
(similar in construct to the one used in `npm` packages) to automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
  - there can be multiple lists of ices,
  - the ice lists are stored in *profiles*; there's at least one profile,
    *default*,
  - the ices can be selectively overridden.

Example invocations that'll install
[trapd00r/LS_COLORS](https://github.com/trapd00r/LS_COLORS) from Git repository
in the most optimized way as described on the
[Zinit Wiki](https://zdharma-continuum.github.io/zinit/wiki/LS_COLORS-explanation/):

```zsh
# Download the default profile
zinit pack for ls_colors

# Download the no-zsh-completion profile
zinit pack"no-zsh-completion" for ls_colors

# Download the no-dir-color-swap profile
zinit pack"no-dir-color-swap" for ls_colors
```

## Default Profile

Provides the LS_COLORS definitions for GNU `ls` and `ogham/exa` and sets up the
zsh-completion system to use the definitions. It also edits the color for the
directory (see the details in the `no-dir-color-swap` profile section).

The Zinit command executed will be equivalent to:

```zsh
zinit lucid reset \
 atclone"[[ -z ${commands[dircolors]} ]] && local P=g
    \${P}sed -i '/DIR/c\DIR 38;5;63;1' LS_COLORS; \
    \${P}dircolors -b LS_COLORS > clrs.zsh" \
 atpull'%atclone' pick"clrs.zsh" nocompile'!' \
 atload'zstyle ":completion:*:default" list-colors "${(s.:.)LS_COLORS}";' for \
    trapd00r/LS_COLORS
```

## `no-zsh-completion` Profile

Provides the LS_COLORS definitions for GNU `ls`, `ogham/exa` but doesn't set up
the zsh-completion system to use them.

The Zinit command executed will be equivalent to:

```zsh
zinit lucid reset \
 atclone"[[ -z ${commands[dircolors]} ]] && local P=g
    \${P}sed -i '/DIR/c\DIR 38;5;63;1' LS_COLORS; \
    \${P}dircolors -b LS_COLORS > clrs.zsh" \
 atpull'%atclone' pick"clrs.zsh" nocompile'!' for \
    trapd00r/LS_COLORS
```

## `no-dir-color-swap` Profile

Provides the LS_COLORS definitions like the `default` profile; however, it
doesn't edit the definitions file or changes the directory's color. The color is
being edited in the default profile because the author found it to be too dark.

The Zinit command executed will be equivalent to:

```zsh
zinit lucid \
 atclone"[[ -z ${commands[dircolors]} ]] && local P=g
     ${P}dircolors -b LS_COLORS > clrs.zsh" \
 atpull'%atclone' pick"clrs.zsh" nocompile'!' \
 atload'zstyle ":completion:*:default" list-colors "${(s.:.)LS_COLORS}";' for \
    trapd00r/LS_COLORS
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
