#!/bin/bash
# generate-repo.sh - Regenerate repodata.txt from x86_64/ packages

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
    # Remove .mypkg.tar.xz suffix
    base="${filename%.mypkg.tar.xz}"

    # Detect arch suffix: x86_64, aarch64, i686
    arch=""
    for a in x86_64 aarch64 i686 armv7h; do
        case "$base" in
            *"-$a") arch="$a"; base="${base%-$a}"; break ;;
        esac
    done
    [ -z "$arch" ] && arch="x86_64"

    # base now: name-version (e.g., "hello-2.12.3")
    # Extract name (before first digit-dot pattern)
    name=$(echo "$base" | sed -E 's/-[0-9][0-9.]*.*$//')
    version_part=$(echo "$base" | sed "s/^${name}-//")

    # Add -1 revision if not present
    if echo "$version_part" | grep -q -- '-'; then
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
