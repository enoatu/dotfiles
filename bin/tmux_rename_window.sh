#!/bin/bash

# tmuxのウィンドウ名を動的に設定するための関数
tmux_rename_window() {
    # tmux内でのみ実行
    if [[ -n "$TMUX" ]]; then
        # ローカルの場合
        tmux rename-window "$(basename "$PWD")"
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
