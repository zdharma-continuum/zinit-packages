# Generated by gen-pkg-json.sh
# 2021-11-22T18:35:48+01:00
AUTHOR="trapd00r"
DESCRIPTION=""
LICENSE="Artistic License"
REQUIREMENTS=""
URL="https://github.com/trapd00r/LS_COLORS"
VERSION="1.0.3"

zinit \
    atclone'[[ -z ${commands[dircolors]} ]] &&
      local P=g;
      ${P}dircolors -b LS_COLORS >! clrs.zsh' \
    atload'zstyle :completion:*:default list-colors "${(s.:.)LS_COLORS}";
     ' \
    atpull'%atclone' \
    git \
    lucid \
    nocompile'!' \
    pick'clrs.zsh' \
  for @trapd00r/LS_COLORS

# vim: set ft=zsh et ts=2 sw=2 :