#!/bin/sh
set -x

SERVERS="prd-app3 prd-app4 prd-app5 prd-app6 prd-app7 prd-app8 prd-cache prd-lvs prd-mail prd-image"
for SERVER in $SERVERS
do
echo "== $SERVER ==";
sudo ssh $SERVER 'mkdir /home/enotiru/.ssh'
sudo scp .ssh/authorized_keys $SERVER:/home/enotiru/.ssh/
sudo ssh $SERVER 'chown -R enotiru:moove /home/enotiru/.ssh'
done
