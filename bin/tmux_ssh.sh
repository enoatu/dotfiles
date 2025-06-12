#!/bin/bash

# SSH接続時にtmuxウィンドウ名を自動的に変更するラッパー関数
ssh() {
    if [[ -n "$TMUX" ]]; then
        # 接続先のホスト名を取得
        # 最後の引数がホスト名の可能性が高い（オプションを除く）
        local host=""
        for arg in "$@"; do
            # オプションでない最初の引数をホスト名とみなす
            if [[ ! "$arg" =~ ^- ]]; then
                host="$arg"
                # user@host形式の場合はホスト部分のみ取得
                host="${host#*@}"
                # ポート番号が含まれる場合は除去
                host="${host%:*}"
                break
            fi
        done
        
        if [[ -n "$host" ]]; then
            # 現在のウィンドウ名を保存
            local old_name=$(tmux display-message -p '#W')
            
            # ウィンドウ名を変更
            tmux rename-window "SSH: $host"
            
            # SSH実行
            command ssh "$@"
            local ssh_exit_code=$?
            
            # ウィンドウ名を元に戻す
            tmux rename-window "$old_name"
            
            return $ssh_exit_code
        else
            # ホスト名が見つからない場合は通常のSSHを実行
            command ssh "$@"
        fi
    else
        # tmux外では通常のSSHを実行
        command ssh "$@"
    fi
}