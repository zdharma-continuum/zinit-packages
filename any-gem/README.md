# `any-gem` Zsh package

| **Package source:** | Source Tarball | Binary | Git | Node | Gem |
|:-------------------:|:--------------:|:------:|:---:|:----:|:---:|
| **Status:**         |        -       |  -     |  -  |  –   |  + <br> (default)  |

## Introduction

[Zplugin](https://github.com/zdharma-continuum/zinit) can use a `package.json`
(similar in construct to the one used in `npm` packages) to automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
    - there can be multiple lists of ices,
    - the ice lists are stored in *profiles*; there's at least one profile, *default*,
    - the ices can be selectively overriden.

## The `any-gem` Package

This package is special – it is designed for easy installing of any Ruby Gems
locally inside the plugin directory, exposing their binaries via *shims* (i.e.:
forwarder scripts) created automatically by
[Bin-Gem-Node](https://github.com/zplugin/z-a-bin-gem-gem) annex.

The Ruby Gem(s) to install are specified by the `param'GEM → {gem1}; GEM2 →
{gem2}; …'` ice. The name of the plugin will be `{gem1}`, unless `id-as''` ice
will be provided, or the `IDAS` param will be set (i.e.: `param'IDAS →
my-plugin; GEM → …'`).

A few example invocations:

```zsh
# Install `chef' Gem and call the plugin with the same name
zinit pack param='GEM → chef' for any-gem

# Install `rails' Gem and call the plugin: ruby-on-rails
zinit id-as=ruby-on-rails pack param='GEM → rails' for any-gem

# Install `jekyll' Gem and call the plugin: jkl
zinit pack param='IDAS → jkl; GEM → jekyll' for any-gem
```

## Default Profile

The only profile that does all the magic. It relies on the `%PARAM%` keywords,
which are substituted with the `value` from the ice `param'PARAM → value; …'`.

The Zplugin command executed will be equivalent to:

```zsh
zinit lucid id-as="${${:-%IDAS%}:-%GEM%}" as=null \
    gem="%GEM%;%GEM2%;%GEM3%;%GEM4%;%GEM5%;%GEM6%;%GEM7%;%OTHER%" \
    sbin="n:bin/*" for \
        zdharma-continuum/null
```

The package is thus a simplifier of Zplugin commands.

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
