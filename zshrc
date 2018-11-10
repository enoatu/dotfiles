# 補完
autoload -U compinit && compinit -u

bindkey "^p" history-beginning-search-backward
bindkey "^n" history-beginning-search-forward

setopt COMPLETE_IN_WORD

setopt IGNOREEOF

# 日本語を使用
export LANG=ja_JP.UTF-8

# パスを追加したい場合
export PATH="$HOME/bin:$PATH"

# 色を使用
autoload -Uz colors
colors

# vimキーバインド
bindkey -v

# 他のターミナルとヒストリーを共有
setopt share_history

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# cdコマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_cd

# 自動でpushdを実行
# `cd +<Tab>` でディレクトリの履歴が表示され、そこに移動できる
setopt auto_pushd

# pushdから重複を削除
setopt pushd_ignore_dups

# コマンドミスを修正
setopt correct

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# ビープ音を消す
setopt no_beep
# エイリアス
alias la='ls -la --color=auto'
alias ll='ls -l --color=auto'
alias so='source'
alias v='vim'
alias vi='vim'

# historyに日付を表示
alias diff='diff -U1'
alias sudovim='sudo vim -u ~/.vimrc'

# backspace,deleteキーを使えるように
stty erase '^H'
stty erase '^?'

# プロンプトを2行で:表示、時刻を表示
PROMPT="%(?.%{${fg[green]}%}.%{${fg[red]}%})%n${reset_color}@${fg[blue]}${HOST}${reset_color}(%*%) %~
 %# "

# 補完後、メニュー選択モードになり左右キーで移動が出来る
zstyle ':completion:*:default' menu select=2

# 補完候補のメニュー選択で、矢印キーの代わりにhjklで移動出来るようにする。
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# 補完で大文字にもマッチ
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# コマンドを途中まで入力後、historyから絞り込み
# 例 ls まで打ってCtrl+pでlsコマンドをさかのぼる、Ctrl+bで逆順
autoload -Uz history-search-end
