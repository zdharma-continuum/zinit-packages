# zinit package for pyenv [bgn]
# Generated by zinit-pkg-gen.sh
# 2021-11-28T22:45:32+01:00
AUTHOR='Yuu Yamashita, Sam Stephenson, Mislav Marohnić, Josh Friend'
DESCRIPTION='Simple Python version management'
LICENSE='MIT'
MESSAGE=''
NAME='zsh-pyenv'
PARAM_DEFAULT=''
REQUIREMENTS='bgn'
URL='https://github.com/pyenv/pyenv'
VERSION='2.2.2'

zinit \
    id-as'pyenv/pyenv' \
    as'null' \
    atclone'PYENV_ROOT="$PWD" ./libexec/pyenv init - > zpyenv.zsh' \
    atinit'export PYENV_ROOT="$PWD"' \
    atpull'%atclone' \
    lucid \
    nocompile'!' \
    sbin'bin/pyenv' \
    src'zpyenv.zsh' \
  for @pyenv/pyenv

# vim: set ft=zsh et ts=2 sw=2 :
