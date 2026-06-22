#!/usr/bin/env bash
# tmux ウィンドウ名: 通常は basename(cwd)、ssh中は ssh-<host>
PANE_PID=$1
CWD=$2
CMD=$3

if [ "$CMD" = "ssh" ]; then
    # pane の子プロセスから ssh の引数を取る。exec ssh の場合は pane 自体
    ARGS=$(pgrep -P "$PANE_PID" -a 2>/dev/null | awk '$2 == "ssh" {for (n=2; n<=NF; n++) printf "%s ", $n; exit}')
    [ -z "$ARGS" ] && ARGS=$(ps -o args= -p "$PANE_PID" 2>/dev/null)

    HOST=$(echo "$ARGS" | awk '{
        for (n=1; n<=NF; n++) {
            if ($n == "ssh") continue
            if ($n ~ /^-[bcDEeFIiJLlmOopQRSWw]$/) { n++; continue }
            if ($n ~ /^-/) continue
            m = split($n, parts, "@")
            print parts[m]
            exit
        }
    }')

    [ -n "$HOST" ] && echo "ssh-$HOST" || echo "ssh"
else
    # git リポジトリ内なら origin URL から取ったリポジトリ名 (submodule は自身の URL)、無ければ cwd の basename
    URL=$(git -C "$CWD" config --get remote.origin.url 2>/dev/null)
    if [ -n "$URL" ]; then
        NAME=${URL##*/}
        NAME=${NAME##*:}
        echo "${NAME%.git}"
    else
        TOP=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)
        [ -n "$TOP" ] && basename "$TOP" || basename "$CWD"
    fi
fi
