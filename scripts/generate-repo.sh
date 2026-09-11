#!/bin/bash
# generate-repo.sh - Regenerate repodata.txt from packages in x86_64/

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
    echo "# Format: <name>-<version>-<rev> <arch> <url> <sha256>"
    echo ""
} > "$OUTPUT"

count=0
for pkg in "$REPO_DIR"/*.mypkg.tar.xz; do
    [ -f "$pkg" ] || continue

    filename=$(basename "$pkg")
    pkg_info=$(echo "$filename" | sed 's/\.mypkg\.tar\.xz$//')

    # Detect arch
    arch=$(echo "$pkg_info" | grep -oE '(x86_64|aarch64|i686|armv7h)' | head -1)
    [ -z "$arch" ] && arch="x86_64"

    # Strip arch suffix
    name_ver_rev=$(echo "$pkg_info" | sed "s/\.${arch}$//")

    # Extract name (everything before first digit that starts a version)
    name=$(echo "$name_ver_rev" | sed 's/-[0-9][0-9.]*.*$//')
    version_part=$(echo "$name_ver_rev" | sed "s/^${name}-//")

    # Version-Rev format: 2.12.3 or 2.12.3-2
    if [[ "$version_part" == *-* ]]; then
        version="$version_part"
    else
        version="${version_part}-1"
    fi

    sha256=$(sha256sum "$pkg" | cut -d' ' -f1)
    url="$BASE_URL/$filename"

    echo "$name-$version $arch $url $sha256" >> "$OUTPUT"
    count=$((count + 1))
done

{
    echo ""
    echo "# Total: $count package(s)"
} >> "$OUTPUT"

echo "Generated $OUTPUT with $count package(s)"
