#!/bin/bash
set -e

REPO_DIR="x86_64"
OUTPUT="repodata.txt"
GITHUB_USER="GliTcHZzZ67"
REPO_NAME="myelin-package-manager"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/${REPO_DIR}"

{
    echo "# NoExZOS Repository"
    echo "# Generated: $(date)"
    echo "# Format: <name>-<version>-<rev> <arch> <url> <sha256> <deps>"
    echo ""
} > "$OUTPUT"

count=0
for pkg in "$REPO_DIR"/*.mypkg.tar.*; do
    [ -f "$pkg" ] || continue
    filename=$(basename "$pkg")

    case "$filename" in
        *.mypkg.tar.zst) base="${filename%.mypkg.tar.zst}" ;;
        *.mypkg.tar.xz)  base="${filename%.mypkg.tar.xz}" ;;
        *.mypkg.tar.gz)  base="${filename%.mypkg.tar.gz}" ;;
        *) continue ;;
    esac

    arch=""
    for a in x86_64 aarch64 i686 armv7h; do
        case "$base" in
            *"-$a") arch="$a"; base="${base%-$a}"; break ;;
        esac
    done
    [ -z "$arch" ] && arch="x86_64"

    name=$(echo "$base" | sed -E 's/-[0-9][0-9.]*.*$//')
    version_part=$(echo "$base" | sed "s/^${name}-//")

    if echo "$version_part" | grep -q -- '-'; then
        version="$version_part"
    else
        version="${version_part}-1"
    fi

    # Extract deps from .PKGINFO inside tarball
    deps=$(tar -xOf "$pkg" .PKGINFO 2>/dev/null | grep "^deps=" | cut -d= -f2 | tr ' ' ',' | sed 's/^,//;s/,$//')
    [ -z "$deps" ] && deps=""

    sha256=$(sha256sum "$pkg" | cut -d' ' -f1)
    url="$BASE_URL/$filename"

    echo "$name-$version $arch $url $sha256 $deps" >> "$OUTPUT"
    count=$((count + 1))
done

{
    echo ""
    echo "# Total: $count package(s)"
} >> "$OUTPUT"

echo "Generated $OUTPUT with $count package(s)"
