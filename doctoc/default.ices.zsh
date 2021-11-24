# zinit package for doctoc [default]
# Generated by gen-pkg.sh
# 2021-11-23T15:10:23+01:00
AUTHOR='Thorsten Lorenz'
DESCRIPTION='Generates table of contents for markdown files inside local git repository. Links are compatible with anchors generated by github or other sites.'
LICENSE='MIT'
MESSAGE=''
REQUIREMENTS=''
URL='https://github.com/thlorenz/doctoc'
VERSION='1.4.1'

zinit \
    id-as'doctoc' \
    as'null' \
    atpull'%atclone' \
    git \
    lucid \
    nocompile \
    node'!doctoc' \
    sbin'n:node_modules/.bin/doctoc' \
  for @zdharma-continuum/null

# vim: set ft=zsh et ts=2 sw=2 :
