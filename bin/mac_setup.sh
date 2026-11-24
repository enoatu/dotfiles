#!/bin/sh
set -eu

# マウスの速度を限界突破させる
defaults write -g com.apple.mouse.scaling 5
# トラックパッドの速度を限界突破させる(再起動必要)
defaults write -g com.apple.trackpad.scaling 5
# キーリピート速度を限界突破させる(再起動必要)
defaults write -g KeyRepeat -int 1
# リピート入力認識を限界突破させる(再起動必要)
defaults write -g InitialKeyRepeat -int 12

# Dockのアイコンサイズを1〜128の範囲で指定
defaults write com.apple.dock tilesize -int 64
# ウィンドウをしまう時のアニメーションをシンプルに
defaults write com.apple.dock mineffect -string scale
# 起動中のアプリのアニメーション無効化
defaults write com.apple.dock launchanim -bool false
# Dockの自動表示/非表示機能を有効化
defaults write com.apple.dock autohide -bool true
# Dock表示速度 最速化
defaults write com.apple.dock autohide-delay -int 0
# Dock表示アニメーション速度 最速化
defaults write com.apple.dock autohide-time-modifier -int 0

# 拡張子まで表示する設定
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# 隠しファイルを表示する設定
defaults write com.apple.Finder AppleShowAllFiles -bool true
# Finderウィンドウ下部のパスバーを表示する設定
defaults write com.apple.finder ShowPathbar -bool true
# ゴミ箱を空にする際の確認警告を無効化する設定
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# 保存フォルダ変更
defaults write com.apple.screencapture location ~/Downloads/
# デフォルトファイル形式変更
defaults write com.apple.screencapture type png
# スクリーンショット撮影時のサムネイル表示を無効化する設定
defaults write com.apple.screencapture show-thumbnail -bool false
# ウィンドウキャプチャ時の影（ドロップシャドウ）を無効化する設定
defaults write com.apple.screencapture disable-shadow -bool true

killall Dock Finder SystemUIServer
