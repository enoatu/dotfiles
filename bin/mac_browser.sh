#!/bin/zsh
set -u

SERVER_HOST=${MAC_BROWSER_HOST:-enotiru.moove.bz}
PROFILE_NAME=${1:-default}
CHROME_PORT=$(plutil -extract "$PROFILE_NAME" raw -o - "$HOME/mac-chrome/profiles.json" 2>/dev/null) \
  || { echo "~/mac-chrome/profiles.json に ${PROFILE_NAME} がない"; exit 1 }
CHROME_PROFILE=$HOME/.chrome-debug
[[ $PROFILE_NAME != default ]] && CHROME_PROFILE=$HOME/.chrome-debug-$PROFILE_NAME
CANDIDATE_PORTS=({${CHROME_PORT}..$((CHROME_PORT + 4))})

chrome_is_ready() {
  curl -s --max-time 3 "localhost:${CHROME_PORT}/json/version" | grep -q '"Browser"'
}

start_chrome() {
  echo "Chrome を起動する (プロファイル ${CHROME_PROFILE})"
  # 普段使いのプロファイルとは別インスタンスにして CDP のポートを開ける
  open -na "Google Chrome" --args \
    --remote-debugging-port=${CHROME_PORT} \
    --user-data-dir="${CHROME_PROFILE}" \
    --profile-directory=Default \
    --no-first-run \
    --no-default-browser-check \
    --hide-crash-restore-bubble \
    --lang=ja

  for _ in {1..20}; do
    chrome_is_ready && return 0
    sleep 1
  done
  return 1
}

master_is_ready() {
  ssh -O check "$SERVER_HOST" > /dev/null 2>&1
}

start_master() {
  echo "ControlMaster を張る"
  ssh -f -N -o BatchMode=yes -o ConnectTimeout=10 \
    -o ServerAliveInterval=30 -o ServerAliveCountMax=3 \
    "$SERVER_HOST" 2>/dev/null

  for _ in {1..10}; do
    master_is_ready && return 0
    sleep 1
  done
  return 1
}

remote_is_ready() {
  local remote_port=$1
  ssh -o BatchMode=yes -o ConnectTimeout=10 "$SERVER_HOST" \
    "curl -s --max-time 3 localhost:${remote_port}/json/version" 2>/dev/null | grep -q '"Browser"'
}

port_is_listening() {
  local remote_port=$1
  ssh -o BatchMode=yes -o ConnectTimeout=10 "$SERVER_HOST" \
    "ss -lnt | grep -q '127.0.0.1:${remote_port} '" 2>/dev/null
}

free_port() {
  local remote_port=$1
  ssh -O cancel -R ${remote_port}:localhost:${CHROME_PORT} "$SERVER_HOST" > /dev/null 2>&1
  pkill -f "R ${remote_port}:localhost:${CHROME_PORT}" 2>/dev/null
  sleep 1
  port_is_listening ${remote_port} || return 0

  echo "ポート ${remote_port} を掴んだままの sshd を止める"
  ssh -o BatchMode=yes "$SERVER_HOST" \
    'ps -u $USER -o pid=,cmd= | grep -E "sshd: $USER\$" | while read pid rest; do kill $pid; done' \
    > /dev/null 2>&1
  sleep 2
  port_is_listening ${remote_port} && return 1
  return 0
}

add_forward() {
  local remote_port=$1
  ssh -O cancel -R ${remote_port}:localhost:${CHROME_PORT} "$SERVER_HOST" > /dev/null 2>&1
  ssh -O forward -R ${remote_port}:localhost:${CHROME_PORT} "$SERVER_HOST" > /dev/null 2>&1

  for _ in {1..8}; do
    remote_is_ready ${remote_port} && return 0
    sleep 1
  done
  ssh -O cancel -R ${remote_port}:localhost:${CHROME_PORT} "$SERVER_HOST" > /dev/null 2>&1
  return 1
}

report_success() {
  local remote_port=$1
  echo "${SERVER_HOST} から Chrome へ到達できる (ポート ${remote_port})"
  if [[ ${remote_port} -ne ${CHROME_PORT} ]]; then
    echo "${CHROME_PORT} を空けられなかったので別ポートを使う。${SERVER_HOST} 側で次を実行する"
    echo "  export CDP_URL=http://127.0.0.1:${remote_port}"
    return 0
  fi
  [[ $PROFILE_NAME == default ]] && return 0
  echo "${SERVER_HOST} 側で次を実行する"
  echo "  export MAC_BROWSER_PROFILE=${PROFILE_NAME}"
}

if chrome_is_ready; then
  echo "Chrome の CDP は起動済み"
else
  start_chrome || { echo "Chrome の CDP が起動しない。Chrome を全て終了してから再実行する"; exit 1 }
  echo "Chrome の CDP が起動した"
fi

master_is_ready || start_master || { echo "ControlMaster を張れない。ssh ${SERVER_HOST} の認証を確認する"; exit 1 }

for remote_port in ${CANDIDATE_PORTS}; do
  if remote_is_ready ${remote_port}; then
    report_success ${remote_port}
    exit 0
  fi
done

for remote_port in ${CANDIDATE_PORTS}; do
  echo "ポート ${remote_port} でリバースフォワードを張り直す"
  port_is_listening ${remote_port} && ! free_port ${remote_port} && continue
  master_is_ready || start_master || { echo "ControlMaster を張り直せない"; exit 1 }
  if add_forward ${remote_port}; then
    report_success ${remote_port}
    exit 0
  fi
done

echo "どのポートでもフォワードを張れない。以下を確認する"
echo "  ssh -O check ${SERVER_HOST} の結果"
echo "  ${SERVER_HOST} 側で ss -lnt | grep 92 の結果"
exit 1
