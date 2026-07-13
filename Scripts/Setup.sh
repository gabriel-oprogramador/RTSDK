#!/usr/bin/env bash
set -e

main(){
    echo
    echo "============================================="
    echo "          RaylibTemplate Setup Tool"
    echo "============================================="
    echo

    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    ZIG_VERSION="0.15.2"
    ZIG_DIR="${ROOT}/Toolchain/zig/${ZIG_VERSION}"
    ZIG_URL="https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz"

    EMSCRIPTEN_VERSION="6.0.0"
    EMSDK_DST="${ROOT}/Toolchain/emsdk"
    EMSDK_URL="https://github.com/emscripten-core/emsdk/archive/refs/heads/main.zip"

    download_and_extract "Zig" "$ZIG_VERSION" "$ZIG_URL" "$ZIG_DIR"
    install_emscripten "Emscripten" "$EMSCRIPTEN_VERSION" "$EMSDK_URL" "$EMSDK_DST"

    echo
    echo "============================================="
    echo "         Setup completed successfully"
    echo "============================================="
    echo

#read -n 1 -s -r -p "Press any key to close..."
}

download_and_extract() {
    NAME="$1"
    VERSION="$2"
    URL="$3"
    DEST="$4"
    VERSION_FILE="$DEST/.version"
    FILE="/tmp/${NAME// /_}.tar.gz"
    if [ -f "$VERSION_FILE" ]; then
        INSTALLED="$(tr -d '[:space:]' < "$VERSION_FILE")"
        if [ "$INSTALLED" = "$VERSION" ]; then
            echo "[OK] $NAME $VERSION already installed."
            return
        fi
    fi
    echo "[INFO] Downloading $NAME $VERSION..."
    curl -L --progress-bar "$URL" -o "$FILE"
    rm -rf "$DEST"
    mkdir -p "$DEST"
    echo "[INFO] Extracting $NAME..."
    tar -xf "$FILE" -C "$DEST" --strip-components=1
    echo "$VERSION" > "$DEST/.version"
    rm -f "$FILE"
    echo "[OK] $NAME installed."
}

strip_unzip() {
    local zip="$1"
    local dest="$2"
    local tmp="$dest/_tmp"
    rm -rf "$tmp"
    mkdir -p "$tmp"
    unzip -q "$zip" -d "$tmp"
    local root
    root=$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    shopt -s dotglob
    mv "$root"/* "$dest/"
    shopt -u dotglob
    rm -rf "$tmp"
}

install_emscripten() {
    NAME="$1"
    VERSION="$2"
    URL="$3"
    DEST="$4"
    ZIP_FILE="/tmp/${NAME// /_}.archive"
    VERSION_FILE="$DEST/.version"
    if [ -f "$VERSION_FILE" ]; then
        INSTALLED="$(tr -d '[:space:]' < "$VERSION_FILE")"
        if [ "$INSTALLED" = "$VERSION" ]; then
            echo "[OK] $NAME $VERSION already installed."
            return
        fi
    fi
    #read -p "Install Web Support (Emscripten)? [Y/N]: " INSTALL_WEB
    case "$INSTALL_WEB" in
        [Nn]) return ;;
    esac
    echo "[INFO] Downloading $NAME $VERSION..."
    curl -L --progress-bar "$URL" -o "$ZIP_FILE"
    rm -rf "$DEST"
    mkdir -p "$DEST"
    echo "[INFO] Extracting $NAME..."
    strip_unzip "$ZIP_FILE" "$DEST"
    echo "$VERSION" > "$DEST/.version"
    rm -f "$ZIP_FILE"
    echo "[OK] $NAME installed."
    pushd "$ROOT/Toolchain/emsdk" >/dev/null
    ./emsdk install "$VERSION"
    ./emsdk activate "$VERSION"
    popd >/dev/null
}

main