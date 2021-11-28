# zinit-packages

🌻 Welcome to [zinit](https://github.com/zdharma-continuum/zinit)'s package
repository.

To learn more about zinit packages and how to install them please refer to:

https://zdharma-continuum.github.io/zinit/wiki/Zinit-Packages/

# Developers!

## 🆕 Creating new packages

To create a new package named `foo`:

```zsh
./zinit-gen-pkg.sh create foo
```

This will create a directory named `foo` which contains:

- `default.ices.zsh`: Your source file where you can define your zinit
ices and will later be used for generating `package.json`
- `package.json`: The file that `zinit pack` actually consumes

To add another profile (as in `zinit pack"PROFILE" for PACKAGE`), for example
`bar`:

```zsh
./zinit-gen-pkg.sh create foo bar
```

This will create a new file in your package directory: `bar.ices.zsh`.

## 📄 The package format

As mentionned above you should start by editing your `.ices.zsh` file.

📓 Exactly one zinit call is required in there, multiple `zinit` calls are not
supported.

📝 You can also define metadata in your `.ices.zsh` files:

| Variable        | Description                                       | Example Value                               |
|-----------------|---------------------------------------------------|---------------------------------------------|
| `AUTHOR`        | Author of the package                             | `zdharma-continuum`                         |
| `DESCRIPTION`   | Description of the package                        | `My amazing blockchain project`             |
| `LICENSE`       | License of the packaged software                  | `GPL-3`                                     |
| `MESSAGE`       | Message to be display when installing             | `Thanks for using zinit pack!`              |
| `NAME`          | Package name (defaults to plugin name if not set) | `stuxnet-monero-miner`                      |
| `REQUIREMENTS`  | List of requirements for this package             | `bgn;tar`                                   |
| `PARAM_DEFAULT` | *Optional* Default `param` ice value              | `MOD -> speed-test`                         |
| `URL`           | Link to the upstream project                      | `https://github.com/zdharma-continuum/null` |
| `VERSION`       | Version of the package                            | `0.0.1`                                     |

Also please refer to the [`null` package](./null/) for an up-to-date example

## 👏 Updating `package.json` files

To generate a `package.json` file for your package run:

```zsh
# Replace these
pkg=null
profile=default

./zinit-gen-pkg.sh gen ${pkg} ${profile}
```

## 🐳 How do I run these?

There's a shorthand subcommand for running a `.ices.zsh` file locally, inside a
container:

```zsh
./zinit-gen-pkg.sh run PACKAGE PROFILE
```

Great, but I want to test my `package.json` directly!

Here you go:

```zsh
./zinit-gen-pkg.sh run --pack PACKAGE PROFILE
```

<!-- vim: set ft=markdown et ts=2 sw=2 tw=80 --!>
