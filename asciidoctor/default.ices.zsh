# zinit package for asciidoctor [default]
# Generated by zinit-pkg-gen.sh
# 2021-11-27T11:43:33+01:00
AUTHOR='Dan Allen, Sarah White, Ryan Waldron'
DESCRIPTION='A fast, open source text processor and publishing toolchain, written in Ruby, for converting AsciiDoc content to HTML 5, DocBook 5, and other formats.'
LICENSE='MIT'
MESSAGE=''
NAME='zsh-asciidoctor'
PARAM_DEFAULT=''
REQUIREMENTS=''
URL='https://github.com/asciidoctor/asciidoctor'
VERSION='2.0.11'

zinit \
    as'null' \
    atpull'%atclone' \
    gem'!asciidoctor' \
    git \
    id-as'zsh-asciidoctor' \
    lucid \
    nocompile \
    sbin'g:bin/asciidoctor' \
  for @zdharma-continuum/null

# vim: set ft=zsh et ts=2 sw=2 :
