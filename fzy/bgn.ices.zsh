# zinit package for fzy [bgn]
# Generated by zinit-pkg-gen.sh
# 2021-11-27T11:44:00+01:00
AUTHOR='John Hawthorn'
DESCRIPTION='A better fuzzy finder'
LICENSE='MIT'
MESSAGE=''
NAME='zsh-fzy'
PARAM_DEFAULT=''
REQUIREMENTS='cc;make;bgn'
URL='https://github.com/jhawthorn/fzy'
VERSION='1.0.6'

zinit \
    as'null' \
    atclone'cp -vf fzy.1 $ZPFX/man/man1' \
    atpull'%atclone' \
    id-as'jhawthorn/fzy' \
    lucid \
    make \
    nocompile \
    sbin'fzy;contrib/fzy-*' \
  for @jhawthorn/fzy

# vim: set ft=zsh et ts=2 sw=2 :
