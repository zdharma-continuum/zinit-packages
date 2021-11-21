# zinit-packages

🌻 Welcome to [zinit](https://github.com/zdharma-continuum/zinit)'s package
repository.

To learn more about zinit packages and how to install them please refer to:

https://zdharma-continuum.github.io/zinit/wiki/Zinit-Packages/

# Developers!

## Creating new packages

To create a new package named `foo`:

```zsh
./gen-pkg-json.sh create foo
```

This will create a directory named `foo` which contains:

- `default.ices.zsh`: Your source file where you can define your zinit
ices and will later be used for genereting `package.json`
- `package.json`: this is what `zinit pack` actually consumes

To add another profile (as in `zinit pack"PROFILE" for PACKAGE`), for example
`bar`:

```zsh
./gen-pkg-json.sh create foo bar
```

This will create a new file in your package directory: `bar.ices.zsh`.

## The package format

As mentionned above you should start by editing your `.ices.zsh` file.

📓 Exactly one zinit call is required in there, multiple `zinit` calls are not
supported.

📝 You can also define metadata in your `.ices.zsh` files:

| Variable     | Description                           | Example Value                               |
|--------------|---------------------------------------|---------------------------------------------|
| AUTHOR       | Author of the package                 | zdharma-continuum                           |
| DESCRIPTION  | Description of the package            | My amazing blockchain project               |
| LICENSE      | License of the packaged software      | `GPL-3`                                     |
| REQUIREMENTS | List of requirements for this package | `bgn;tar`                                   |
| URL          | Link to the upstream project          | `https://github.com/zdharma-continuum/null` |
| VERSION      | Version of the package                | `0.0.1`                                     |

Also please refer to the [`null` package](./null/) for an up-to-date example

## Updating `package.json` files

To generate a `package.json` file for your package run:

```zsh
# Replace these
pkg=null
profile=default

./gen-pkg-json.sh ${pkg} ${profile}
```

<!-- vim: set ft=markdown et ts=2 sw=2 tw=80 --!>
