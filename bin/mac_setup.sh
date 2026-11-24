#!/bin/sh
set -eu

# トラックパッドの速度を限界突破させる(再起動必要)
defaults write -g com.apple.trackpad.scaling 5
# 確認方法
defaults read -g com.apple.trackpad.scaling

# キーリピート速度を限界突破させる(再起動必要)
defaults write -g KeyRepeat -int 1
# 確認方法
defaults read -g KeyRepeat

# リピート入力認識を限界突破させる(再起動必要)
defaults write -g InitialKeyRepeat -int 12
# 確認方法
defaults read -g InitialKeyRepeat
