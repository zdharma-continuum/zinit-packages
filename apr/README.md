# apache/apr as a Zsh package

##### Homepage link: [apache/apr](https://github.com/apache/apr)

| **Package source:** | Source Tarball | Binary | Git | Node | Gem |
|:-------------------:|:--------------:|:------:|:---:|:----:|:---:|
| **Status:**         |    + <br> (default) |  -  | + | – |  –  |

[Zinit](https://github.com/zdharma-continuum/zinit) can use the NPM package registry
to automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
    - there can be multiple lists of ices,
    - the ice lists are stored in *profiles*; there's at least one profile, *default*,
    - the ices can be selectively overriden.

Example invocations that'll install
[apache/apr](https://github.com/apache/apr) either from the release archive
or from Git repository:

```zsh
# Download, build and install the latest Apache Portable Runtime source tarball
zinit pack for apr
```

## Default Profile

Provides the Apache Portable Runtime library by compiling and installing it to
the `$ZPFX` directory (`~/.zinit/polaris` by default). It uses the
[zinit-zsh/z-a-as-monitor](https://github.com/zinit-zsh/z-a-as-monitor) annex to
download the latest Apache Portable Runtime tarball.

The Zinit command executed will be equivalent to:

```zsh
zi as"null|monitor" dlink"https://.*/apr-%VERSION%.tar.bz2" \
    atclone'zpextract --move --auto; print -P \\n%F{75}Building Apache Portable Runtime...\\n%f; ./configure \
        --prefix="$ZPFX" >/dev/null && make >/dev/null && print -P \
        \\n%F{75}Installing Apache Portable Runtime to $ZPFX...\\n%f && make install >/dev/null && print -P \
        \\n%F{34}Installation of Apache Portable Runtime succeeded.%f || \
        print -P \\n%F{160}Installation of Apache Portable Runtime failed.%f' \
    atpull'%atclone' for \
        https://apr.apache.org/download.cgi
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
