# junegunn/fzf as a Zsh package

##### Homepage link: [junegunn/fzf](https://github.com/junegunn/fzf)

| Package source | Source Tarball | Binary | Git | Node | Gem |
| :------------: | :------------: | :----: | :-: | :--: | :-: |
|     Status     |    Default     |   +    |  +  |  –   |  -  |

[Zinit](https://github.com/zdharma-continuum/Zinit) can use `package.json` to
automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
  - there can be multiple lists of ices,
  - the ice lists are stored in *profiles*; there's at least one profile,
    *default*,
  - the ices can be selectively overridden.

More documentation on Zinit Packages can be found on the
[Zinit Wiki](https://zdharma-continuum.github.io/zinit/wiki/Zinit-Packages/).

Example invocations that'll install
[junegunn/fzf](https://github.com/junegunn/fzf) either from the release archive
or from Git repository:

```zsh
# Download the package with the default ice list
zinit pack for fzf

# Download the package with the default ice list + set up the key bindings
zinit pack"default+keys" for fzf

# Download the package with the bin-gem-node annex-utilizing ice list
zinit pack"bgn" for fzf

# Download the package with the bin-gem-node annex-utilizing ice list
# + setting up the key bindings. The "+keys" variants are available
# for each profile
zinit pack"bgn+keys" for fzf

# Download with the bin-gem-node annex-utilizing ice list FROM GIT REPOSITORY
zinit pack"bgn" git for fzf

# Download the binary from the Github releases (like from'gh-r' ice)
zinit pack"binary" for fzf

# Download the binary from the Github releases and install via Bin-Gem-Node shims
zinit pack"bgn-binary" for fzf
```

## Default Profile

Provides the fuzzy finder via Makefile-installation of the `fzf` binary under
`$ZPFX/bin`.

```zsh
zinit lucid as=program pick="$ZPFX/bin/(fzf|fzf-tmux)" \
    atclone="cp shell/completion.zsh _fzf_completion; cp bin/fzf-tmux $ZPFX/bin" \
    make="PREFIX=$ZPFX install" \
    …
```

## Bin-Gem-Node Profile

Provides the fuzzy finder via *shims*, i.e., automatic forwarder scripts created
under `$ZPFX/bin` (added to the `$PATH` by default). It needs the
[bin-gem-node](https://github.com/zdharma-continuum/z-a-bin-gem-node) annex.

```zsh
zinit lucid as=null make \
    atclone="cp shell/completion.zsh _fzf_completion" \
    sbin="fzf;bin/fzf-tmux" \
    …
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
