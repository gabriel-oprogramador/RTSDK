#!/usr/bin/env bash
set -e

main(){
    ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/RaylibTemplate"
    mkdir -p "$ROOT"
    echo "Ready: $ROOT"
    make ship
    cp -rf ./SDK/* ${ROOT}
    rm -rf ./SDK
}

main