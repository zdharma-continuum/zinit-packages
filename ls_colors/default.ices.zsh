# zinit package for ls_colors [default]
# Generated by zinit-pkg-gen.sh
# 2021-11-27T11:44:07+01:00
AUTHOR='Magnus Woldrich'
DESCRIPTION='A collection of LS_COLORS definitions; needs your contribution!'
LICENSE='Artistic License'
MESSAGE=''
NAME='zsh-ls_colors'
PARAM_DEFAULT=''
REQUIREMENTS=''
URL='https://github.com/trapd00r/LS_COLORS'
VERSION='1.0.4'

zinit \
    atclone'[[ -z ${commands[dircolors]} ]] &&
      local P=${${(M)OSTYPE##darwin}:+g};
      ${P}sed -i '\''/DIR/c\DIR 38;5;63;1'\'' LS_COLORS;
      ${P}dircolors -b LS_COLORS >! clrs.zsh' \
    atload'zstyle '\'':completion:*:default'\'' list-colors "${(s.:.)LS_COLORS}";' \
    atpull'%atclone' \
    git \
    id-as'trapd00r/LS_COLORS' \
    lucid \
    nocompile'!' \
    pick'clrs.zsh' \
    reset \
  for @trapd00r/LS_COLORS

# vim: set ft=zsh et ts=2 sw=2 :
