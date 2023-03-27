#!/bin/bash

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s checkwinsize
umask 0000

export PATH=${PATH}:/tmp/home/composer/vendor/bin
export PHP_IDE_CONFIG=serverName=local

for f in $HOME/*.sh; do
    if [ -e "$f" ]; then
      . "$f"
    fi
done