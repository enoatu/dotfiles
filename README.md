# dotfiles

自分が使うどのサーバーでも、同じシェルとエディタの設定で作業するための設定ファイル集です。

## 考え方

- 公開してよいものだけを置く
  - token、パスワード、鍵などの秘密の情報は、コード、コメント、コミットメッセージのどこにも書かない
  - 公開できないものは、別の非公開リポジトリ private-dotfiles に置く
  - コミットのときに hook (git/hooks/) が gitleaks で token や鍵が入っていないかを調べる
- OSS として、だれが clone してもそのまま使えるシンプルなものにする
  - private-dotfiles には依存せず、dotfiles だけで動くようにする
  - private-dotfiles は、あるときだけ install.sh が取得して設定を加える
  - private-dotfiles を使ってよいのは次のところだけにする
    - ほかで使いたくなったら、次のどれかを入り口にして private-dotfiles 側に書く
    - どれも private-dotfiles がないときは何もしない
    - install.sh
      - 取得と、private-dotfiles の mise の設定へのリンク
    - git/gitconfig
      - private-dotfiles/git/gitconfig の include
    - zsh/zshrc
      - private-dotfiles/zsh/zshrc_private の source
    - git/hooks/
      - private-dotfiles/git/hooks/dotfiles/ にある同じ名前の hook の実行
    - .claude/CLAUDE.md
      - private-dotfiles/README.md の @ での参照
    - .gitignore と .dockerignore
      - 対象から外す
- マシンごとに違う設定は git に入れない
  - ~/.zshrc.local と neovim/lua/env.lua に書く
  - env.lua はないときだけ neovim/lua/env.lua.sample からコピーされる
- macOS と Linux の両方で使う
  - 違いは tmux/tmux.conf.tmpl のように mise の template で分ける
- ツールとリンクは mise でそろえる
  - ツールは mise/tools.toml、リンクは mise/dotfiles.toml に書く
- 入れる量を2つから選べる
  - full はすべて入れる
  - light はシェルと neovim だけを入れる

## 入れ方

```
git clone https://github.com/enoatu/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

light で入れるときは次のようにします。

```
INSTALL_TYPE=light ~/dotfiles/install.sh
```
