# zinit package for fzf [bgn-binary+keys]
# Generated by gen-pkg.sh
# 2021-11-23T15:10:29+01:00
AUTHOR='Junegunn Choi'
DESCRIPTION='A command-line fuzzy finder'
LICENSE='MIT'
MESSAGE=''
REQUIREMENTS='cp;bgn;dl'
URL='https://github.com/junegunn/fzf'
VERSION='0.28.0'

zinit \
    id-as'fzf' \
    atclone'mkdir -p $ZPFX/{bin,man/man1}' \
    atpull'%atclone' \
    dl'https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh -> _fzf_completion;
      https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh -> key-bindings.zsh;
      https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf-tmux.1 -> $ZPFX/man/man1/fzf-tmux.1;
      https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1 -> $ZPFX/man/man1/fzf.1' \
    from'gh-r' \
    lucid \
    nocompile \
    pick'/dev/null' \
    sbin'fzf' \
    src'key-bindings.zsh' \
  for @junegunn/fzf

# vim: set ft=zsh et ts=2 sw=2 :
