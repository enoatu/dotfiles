autoload -U compinit
compinit

setopt COMPLETE_IN_WORD

setopt IGNOREEOF

# 日本語を使用
export LANG=ja_JP.UTF-8

# パスを追加したい場合
export PATH="$HOME/bin:$PATH"

# 色を使用
autoload -Uz colors
colors

# 補完
autoload -Uz compinit
compinit

# emacsキーバインド
bindkey -e


# 他のターミナルとヒストリーを共有
setopt share_history

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# cdコマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_cd

# 自動でpushdを実行
setopt auto_pushd

# pushdから重複を削除
setopt pushd_ignore_dups

# コマンドミスを修正
setopt correct


# グローバルエイリアス
alias -g L='| less'
alias -g H='| head'
alias -g G='| grep'
alias -g GI='| grep -ri'

# エイリアス
alias lst='ls -ltr --color=auto'
alias l='ls -ltr --color=auto'
alias la='ls -la --color=auto'
alias ll='ls -l --color=auto'
alias so='source'
alias v='vim'
alias vi='vim'
alias vz='vim ~/.zshrc'
alias c='cdr'
# historyに日付を表示
alias h='fc -lt '%F %T' 1'
alias cp='cp -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias ..='c ../'
alias back='pushd'
alias diff='diff -U1'
alias sudovim='sudo vim -u ~/.vimrc'
# backspace,deleteキーを使えるように
stty erase '^H'
stty erase '^?'
##ctrl+sのロック, Ctrl+qのロック解除を無効にする
setopt no_flow_control

# プロンプトを2行で:表示、時刻を表示
PROMPT="%(?.%{${fg[green]}%}.%{${fg[red]}%})%n${reset_color}@${fg[blue]}$HOST${reset_color}(%*%) %~
%# "

 # 補完後、メニュー選択モードになり左右キーで移動が出来る
 zstyle ':completion:*:default' menu select=2

 # 補完で大文字にもマッチ
 zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

 # Ctrl+rでヒストリーのインクリメンタルサーチ、Ctrl+sで逆順
 #bindkey '^r' history-incremental-pattern-search-backward
 #bindkey '^s' history-incremental-pattern-search-forward

 # コマンドを途中まで入力後、historyから絞り込み
 # 例 ls まで打ってCtrl+pでlsコマンドをさかのぼる、Ctrl+bで逆順
 autoload -Uz history-search-end
 #zle -N history-beginning-search-backward-end history-search-end
 #zle -N history-beginning-search-forward-end history-search-end
 #bindkey "^p" history-beginning-search-backward-end
 #bindkey "^b" history-beginning-search-forward-end

 # cdrコマンドを有効 ログアウトしても有効なディレクトリ履歴
 # cdr タブでリストを表示
 autoload -Uz add-zsh-hook
 autoload -Uz chpwd_recent_dirs cdr
 add-zsh-hook chpwd chpwd_recent_dirs
 # cdrコマンドで履歴にないディレクトリにも移動可能に
 zstyle ":chpwd:*" recent-dirs-default true


 # 複数ファイルのmv 例　zmv *.txt *.txt.bk
 autoload -Uz zmv
 alias zmv='noglob zmv -W'
 export PERL5LIB=$HOME/work/Moove/lib:$HOME/work/moove/lib:$PERL5LIB

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
