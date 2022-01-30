#!/bin/bash

shell=0

if [$(echo $0) = '/bin/bash';
  then
    set -o shell 1
    echo -e 'if [ -f /home/$USER/.bash_aliases ]; then\n  source ~/.bash_aliases\nfi\n' >> /home/$USER/.bashrc
elif [$(echo $0) = '/bin/zsh';
  then
    set -o shell 2
    echo -e 'if [ -f /home/$USER/.bash_aliases ]; then\n  source ~/.bash_aliases\nfi\n' >> /home/$USER/.zshrc
fi

if [shell=1];then
  cat /home/$USER/.bashrc | grep ".bash_aliases" >/dev/null && echo "susess!" || && echo "this script has failed"
elif [shell=2];then
  cat /home/$USER/.zshrc | grep ".bash_aliases" >/dev/null && echo "susess!" || && echo "this script has failed"
fi
