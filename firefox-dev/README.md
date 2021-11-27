# Firefox Developer Edition as a Zsh package

##### Homepage link: [Mozilla Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/)

| **Package source:** | Source Tarball | Binary | Git | Node | Gem |
|:-------------------:|:--------------:|:------:|:---:|:----:|:---:|
| **Status:**         |  -             | + <br> (default) |  -  |   –  |  –  |

[Zinit](https://github.com/zdharma-continuum/zinit) can use the `package.json` file to
automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
    - there can be multiple lists of ices,
    - the ice lists are stored in *profiles*; there's at least one profile, *default*,
    - the ices can be selectively overriden.

Example invocations that'll install [Mozilla Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/)

```zsh
# Download the binary of amazon-firefox-dev command
zinit pack for firefox-dev

# Download the firefox-dev binary with use of the bin-gem-node annex
zinit pack"bgn" for firefox-dev
```

## Default Profile

Provides the CLI commands `firefox-bin` and `firefox` by extending the `$PATH`
to point to the snippet's directory.

The Zinit command executed will be equivalent to:

```zsh
zinit id-as"firefox-dev" as"command" lucid" \
    atclone'local ext="${${${(M)OSTYPE#linux*}:+tar.bz2}:-dmg}"; \
        zpextract %ID% $ext --norm ${${OSTYPE:#darwin*}:+--move}'
    pick"firefox(|-bin)" atpull"%atclone" nocompile is-snippet for \
        "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=${${${(M)OSTYPE##linux}:+linux64}:-${${(M)OSTYPE##darwin}:+osx}}&lang=en-US"
```

## bin-gem-node Profile

Provides the CLI command `firefox` by creating a forwarder script (a *shim*) to
the `firefox-bin` command, in `$ZPFX/bin` by using the
[bin-gem-node](https://github.com/zdharma-continuum/zinit-annex-bin-gem-node) annex. It's the best
method of providing the binary to the command line.

The Zinit command executed will be equivalent to:

```zsh
zinit id-as"firefox-dev" as"null" lucid \
    atclone'local ext="${${${(M)OSTYPE#linux*}:+tar.bz2}:-dmg}"; \
        zpextract %ID% $ext --norm ${${OSTYPE:#darwin*}:+--move}'
    atpull"%atclone" nocompile is-snippet for \
        "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=${${${(M)OSTYPE##linux}:+linux64}:-${${(M)OSTYPE##darwin}:+osx}}&lang=en-US"
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
