# `any-node` Zsh package

| **Package source:** | Source Tarball | Binary | Git | Node | Gem
| |:-------------------:|:--------------:|:------:|:---:|:----:|:---:|
| **Status:**         |        -       |  -     |  -  |  + <br> (default)
|  –  |

## Introduction

[Zinit](https://github.com/zdharma-continuum/zinit) can use the NPM package registry
to automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
    - there can be multiple lists of ices,
    - the ice lists are stored in *profiles*; there's at least one profile, *default*,
    - the ices can be selectively overriden.

## The `any-node` Package

This package is special – it is designed for easy installing of any Node modules
inside the plugin directory, exposing their binaries via *shims* (i.e.: forwarder
scripts)  created automatically by
[Bin-Gem-Node](https://github.com/zdharma-continuum/z-a-bin-gem-node) annex.

The Node module(s) to install are specified by the `param'MOD → {module1}; MOD2
→ {module2}; …'` ice. The name of the plugin will be `{module1}`, unless
`id-as''` ice will be provided, or the `IDAS` param will be set (i.e.:
`param'IDAS → my-plugin; MOD → …'`).

A few example invocations:

```zsh
# Install `coffee-script' module and call the plugin with the same name
zplugin pack param='MOD → coffee-script' for any-node

# Install `remark' Markdown processor and call the plugin: remark
zplugin id-as=remark pack param='MOD → remark-man; MOD2 → remark-cli' for any-node

# Install `pen' Markdown previewer and call the plugin: my-pen
zplugin pack param='IDAS → my-pen; MOD → pen' for any-node
```

## Default Profile

The only profile that does all the magic. It relies on the `%PARAM%` keywords,
which are substituted with the `value` from the ice `param'PARAM → value; …'`.

The Zplugin command executed will be equivalent to:

```zsh
zplugin lucid id-as="${${:-%IDAS%}:-%MOD%}" as=null \
    node="%MOD%;%MOD2%;%MOD3%;%MOD4%;%MOD5%;%MOD6%;%MOD7%;%OTHER%" \
    sbin="n:node_modules/.bin/*" for \
        zdharma/null
```

The package is thus a simplifier of Zplugin commands.

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
