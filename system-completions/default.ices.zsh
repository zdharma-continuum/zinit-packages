# Generated by gen-pkg-json.sh
# 2021-11-22T18:35:51+01:00
AUTHOR="zdharma-continuum"
DESCRIPTION=""
LICENSE="MIT"
REQUIREMENTS=""
URL="https://github.com/zdharma-continuum/system-completions/"
VERSION="1.0.0"

zinit \
    as'completion' \
    atclone'print Installing system completions...;
      mkdir -p $ZPFX/funs;
      command cp -f $ZPFX/share/zsh/$ZSH_VERSION/functions/^_* $ZPFX/funs;
      zinit creinstall -q $ZPFX/share/zsh/$ZSH_VERSION/functions;
     ' \
    atload'fpath=( ${(u)fpath[@]:#$ZPFX/share/zsh/*} );
      fpath+=( $ZPFX/funs );
     ' \
    atpull'%atclone' \
    git \
    lucid \
    nocompile \
    run-atpull \
  for @zdharma-continuum/null

# vim: set ft=zsh et ts=2 sw=2 :