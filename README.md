# Dot_files
Common addition to dot files to make Quality Of Life Changes.
These are not Dot file Replacements these are intended to be added to Dot files.

Put this in yout .bashrc file
```bash
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi
if [ -f ~/.pentesting_aliases ]; then
    source ~/.pentesting_aliases
fi
```

```bash

git clone https://github.com/TheTrueZeroTwo/DotFiles /home/$USER/ && chmod +x dotfile-install.sh && /home/$USER/dotfile-install.sh

```
