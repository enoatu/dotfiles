#!/bin/bash

arch -arm64 brew install squid
#/opt/homebrew/etc/squid.confに以下を追記

# # キャッシュディレクトリの指定とサイズ（100 MBのキャッシュを設定例）
# cache_dir ufs /opt/homebrew/var/cache/squid 100 16 256
#
# # メモリキャッシュサイズ
# cache_mem 500 MB
#
# # 最大キャッシュサイズ（必要に応じて増やす）
# maximum_object_size 100 MB
#
# # リクエストのキャッシュ期間の設定（例：7日）
# refresh_pattern . 1440 20% 10080
#
# # 全てのネットワークのアクセス許可（必要に応じて変更）
# http_access allow all

# # Squidポート設定
# http_port 3128 ssl-bump cert=/opt/homebrew/etc/squid/ssl_cert/squid.crt.pem key=/opt/homebrew/etc/squid/ssl_cert/squid.key.pem
# # SSLインターセプト設定
# acl step1 at_step SslBump1
# ssl_bump peek step1
# ssl_bump bump all

mkdir -p /opt/homebrew/var/lib
mkdir -p /opt/homebrew/etc/squid/ssl_cert
# 秘密鍵の生成
openssl genpkey -algorithm RSA -out /opt/homebrew/etc/squid/ssl_cert/squid.key.pem -pkeyopt rsa_keygen_bits:2048
# CSR（証明書署名要求）の作成
openssl req -new -key /opt/homebrew/etc/squid/ssl_cert/squid.key.pem -out /opt/homebrew/etc/squid/ssl_cert/squid.csr.pem -subj "/C=JP/ST=Tokyo/L=Tokyo/O=MyOrg/OU=MyDept/CN=localhost"
# 自己署名証明書の作成
openssl x509 -req -days 365 -in /opt/homebrew/etc/squid/ssl_cert/squid.csr.pem -signkey /opt/homebrew/etc/squid/ssl_cert/squid.key.pem -out /opt/homebrew/etc/squid/ssl_cert/squid.crt.pem

# ssl_crtdキャッシュの初期化
/opt/homebrew/opt/squid/libexec/security_file_certgen -c -s /opt/homebrew/var/lib/ssl_db -M 4MB

# キャッシュを保存するディレクトリを初期化
/opt/homebrew/opt/squid/sbin/squid -z
# squidの起動、デーモン化
brew services restart squid

# キャッシュのクリア
squid -k shutdown
rm -rf /usr/local/var/cache/squid
squid -z
squid

# Squidの再起動
brew services restart squid

brew services stop squid
brew services remove squid
