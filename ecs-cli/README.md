# aws/amazon-ecs-cli as a Zsh package

##### Homepage link: [aws/amazon-ecs-cli](https://github.com/aws/amazon-ecs-cli)

| **Package source:** | Source Tarball |      Binary      | Git | Node | Gem |
| :-----------------: | :------------: | :--------------: | :-: | :--: | :-: |
|     **Status:**     |       -        | + <br> (default) |  -  |  –   |  –  |

[Zplugin](https://github.com/zdharma-continuum/zinit) can use the NPM package registry to automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
  - there can be multiple lists of ices,
  - the ice lists are stored in *profiles*; there's at least one profile, *default*,
  - the ices can be selectively overriden.

Example invocations that'll install [aws/amazon-ecs-cli](https://github.com/aws/amazon-ecs-cli):

```zsh
# Download the binary of amazon-ecs-cli command
zinit pack for ecs-cli

# Download the ecs-cli binary with use of the bin-gem-node annex
zinit pack"bgn" for ecs-cli
```

## Default Profile

Provides the CLI command `ecs-cli` by coping it to `$ZPFX/bin`.

The Zplugin command executed will be equivalent to:

```zsh
zinit as=null id-as="ecs-cli" mv="*latest -> ecs-cli" \
    atclone='chmod +x *; cp -vf ecs-cli $ZPFX/bin' \
    atpull="%atclone" sbin="ecs-cli" is-snippet for \
        https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-${(M)OSTYPE#(linux|darwin)}-amd64-latest
```

## bin-gem-node Profile

Provides the CLI command `ecs-cli` by creating a forwarder script (a *shim*) in `$ZPFX/bin` by using the
[bin-gem-node](https://github.com/zdharma-continuum/zinit-annex-bin-gem-node) annex. It's the best method of providing
the binary to the command line.

The Zplugin command executed will be equivalent to:

```zsh
zinit as=null id-as="ecs-cli" mv="*latest -> ecs-cli" \
    atclone="chmod +x *"  atpull="%atclone" sbin="ecs-cli"
    is-snippet for \
        https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-${(M)OSTYPE#(linux|darwin)}-amd64-latest
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
