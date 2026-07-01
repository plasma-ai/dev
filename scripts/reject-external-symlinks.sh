#!/usr/bin/env bash
set -euo pipefail

# Reject staged symlinks whose target resolves outside the repository,
# so links into sibling repos (e.g. private skill directories) are never
# committed. Intra-repo symlinks are allowed. The target is resolved lexically
# (no disk access), so the check holds even before the target exists on disk.

root="$(git rev-parse --show-toplevel)"
status=0
for link in "$@"; do
    target="$(readlink "$link")"
    if resolved="$(cd "$(dirname "$link")" && python3 -c 'import os, sys; print(os.path.abspath(sys.argv[1]))' "$target")"; then
        case "$resolved/" in
            "$root"/*) continue ;;
        esac
    fi
    echo "error: symlink points outside the repo: $link -> $target" >&2
    status=1
done
exit "$status"
