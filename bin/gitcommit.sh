#!/bin/bash

set -eu

ICON=$1
MSG=$2
main() {
    git commit -m ":$ICON: $MSG"
}

main

exit 0
