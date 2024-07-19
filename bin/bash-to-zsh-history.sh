#!/bin/sh

curl -sSL https://gist.githubusercontent.com/muendelezaji/c14722ab66b505a49861b8a74e52b274/raw/49f0fb7f661bdf794742257f58950d209dd6cb62/bash-to-zsh-hist.py -o /tmp/bash-to-zsh-hist.py
cat ~/.bash_history | python3 /tmp/bash-to-zsh-hist.py >>~/.zsh_history
