# zdharma-continuum/zsh-github-issues as a Zsh package

##### Homepage link: [zdharma-continuum/zsh-github-issues](https://github.com/zdharma-continuum/zsh-github-issues)

| **Package source:** | Tarball | Git | Node | Gem |
|:-------------------:|:-------:|:---:|:----:|:---:|
| **Status:**         |    -    |  + <br> (default) |  –  |  –  |

[Zplugin](https://github.com/zdharma-continuum/zinit) can use the NPM package registry
to automatically:

- get the plugin's Git repository OR release-package URL,
- get the list of the recommended ices for the plugin,
    - there can be multiple lists of ices,
    - the ice lists are stored in *profiles*; there's at least one profile, *default*,
    - the ices can be selectively overriden.

Example Zplugin invocations that'll install
[zdharma-continuum/zsh-github-issues](https://github.com/zdharma-continuum/zsh-github-issues):

```zsh
# Download the default profile. Need the `@' prefix because of the `git' ice.
zinit pack for @github-issues

# Download the `compact-message' profile
zinit pack"compact-message" for @github-issues
```

## Default Profile

The Zplugin command executed will be equivalent to:

```zsh
zinit lucid id-as"GitHub-notify" \
 on-update-of'~/.cache/zsh-github-issues/new_titles.log' \
 notify'New issue: $NOTIFY_MESSAGE' for \
    zdharma-continuum/zsh-github-issues
```

## `compact-message` Profile

Will emit the notification message without `New issue: ` prefix.

The Zplugin command executed will be equivalent to:

```zsh
zinit lucid id-as"GitHub-notify" \
 on-update-of'~/.cache/zsh-github-issues/new_titles.log' \
 notify'$NOTIFY_MESSAGE' for \
    zdharma-continuum/zsh-github-issues
```

<!-- vim:set ft=markdown tw=80 fo+=an1 autoindent: -->
