# zinit package for apr [default]
# Generated by zinit-pkg-gen.sh
# 2021-11-27T11:43:31+01:00
AUTHOR='Yuu Yamashita, Sam Stephenson, Mislav Marohnić, Josh Friend'
DESCRIPTION='Simple Python version management'
LICENSE='MIT'
MESSAGE=''
NAME='zsh-apr'
PARAM_DEFAULT=''
REQUIREMENTS=''
URL='https://github.com/apr/apr'
VERSION='1.6.1'

zinit \
    as'null|readurl' \
    atclone'zpextract --move --auto;
      print -P \\
%F{75}Building Apache Portable Runtime...\\
%f;
      ./configure --prefix='\''$ZPFX'\'' >/dev/null &&
      make >/dev/null &&
      print -P \\
%F{75}Installing Apache Portable Runtime to $ZPFX...\\
%f &&
      make install >/dev/null &&
      print -P \\
%F{34}Installation of Apache Portable Runtime succeeded.%f || print -P \\
%F{160}Installation of Apache Portable Runtime failed.%f' \
    atpull'%atclone' \
    dl'https://.*/apr-%VERSION%.tar.bz2' \
    id-as'zsh-apr' \
    lucid \
    nocompile'!' \
  for 'https://dlcdn.apache.org/apr/'

# vim: set ft=zsh et ts=2 sw=2 :
