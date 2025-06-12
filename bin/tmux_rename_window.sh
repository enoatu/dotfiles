#!/bin/bash

# tmuxのウィンドウ名を動的に設定するための関数
tmux_rename_window() {
    # tmux内でのみ実行
    if [[ -n "$TMUX" ]]; then
        # SSH判定を改善: SSH_CONNECTION, SSH_CLIENT, SSH_TTYのいずれかが設定されているか確認
        # また、親プロセスがsshdかどうかも確認
        if [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] || [[ "$(ps -o comm= -p $PPID 2>/dev/null)" =~ sshd ]]; then
            # SSH接続中の場合
            tmux rename-window "SSH: $(hostname -s)"
        else
            # ローカルの場合
            tmux rename-window "$(basename "$PWD")"
        fi
    fi
}

# ZSHのprecmd関数に登録（ディレクトリ変更時に自動実行）
if [[ -n "$ZSH_VERSION" ]]; then
    precmd_functions+=(tmux_rename_window)
fi

# Bashの場合はPROMPT_COMMANDに追加
if [[ -n "$BASH_VERSION" ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}tmux_rename_window"
fi