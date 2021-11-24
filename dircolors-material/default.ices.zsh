# zinit package for dircolors-material [default]
# Generated by gen-pkg.sh
# 2021-11-23T15:10:20+01:00
AUTHOR='Grigorii Horos'
DESCRIPTION='Dircolors material theme'
LICENSE='MIT'
MESSAGE=''
REQUIREMENTS=''
URL='https://github.com/zpm-zsh/material-colors'
VERSION='1.0.0'

zinit \
    id-as'dircolors-material' \
    atclone'(( !${+commands[dircolors]} )) &&
      local P=g;
      ${P}sed -i '\''/DIR/c\DIR 38;
     5;
     63;
     1'\'' material.dircolors;
      TERM=ansi ${P}dircolors -b material.dircolors >! colors.zsh' \
    atload'zstyle '\'':completion:*:default'\'' list-colors "${(s.:.)LS_COLORS}";
     ' \
    atpull'%atclone' \
    git \
    lucid \
    nocompile'!' \
    pick'colors.zsh' \
    reset \
  for @zpm-zsh/material-colors

# vim: set ft=zsh et ts=2 sw=2 :
