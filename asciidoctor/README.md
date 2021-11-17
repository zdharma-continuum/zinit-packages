# asciidoctor/asciidoctor as a Zsh package

##### Homepage link: [asciidoctor/asciidoctor](https://github.com/asciidoctor/asciidoctor)

| **Package source:** | Tarball | Git | Node | Gem |
|:-------------------:|:-------:|:---:|:----:|:---:|
| **Status:**         |    -    |  -  |   -  |  + <br> (default)  |

[Zplugin](https://github.com/zdharma-continuum/zinit) can use the NPM package registry
to automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
    - there can be multiple lists of ices,
    - the ice lists are stored in *profiles*; there's at least one profile, *default*,
    - the ices can be selectively overriden.

Example invocations that'll install
[asciidoctor/asciidoctor](https://github.com/asciidoctor/asciidoctor) by using the
[bin-gem-node](https://github.com/zplugin/z-a-bin-gem-node) annex:

```zsh
# Download the Gem of asciidoctor locally into the plugin directory
# Using the `@' prefix because of collision with the as'' ice
zplugin pack for @asciidoctor
```

## Default Profile

Provides the CLI command `asciidoctor`.

The Gem is installed locally into a null-plugin directory (feature of the
bin-gem-node annex) and provided to the command line through *shims*, i.e.:
automatic forwarder scripts created under `$ZPFX/bin` (which is added to the
`$PATH` by default; shims are also a bin-gem-node annex feature).

The Zplugin command executed will be equivalent to:

```zsh
zplugin lucid as=null node="!asciidoctor" sbin="g:bin/asciidoctor" for \
    zdharma/null
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
