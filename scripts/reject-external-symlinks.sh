#!/usr/bin/env bash
set -euo pipefail

# Reject staged symlinks that resolve outside the repository
# ----------------------------------------------------------
#
# Usage: reject-external-symlinks.sh <symlink>...
#
# Links into sibling repos (e.g. private skill directories) must never be
# committed. Intra-repo symlinks are allowed. The target is resolved lexically
# (no disk access), so the check holds even before the target exists on disk.

# pre-commit invokes hooks from the repository root, so the
# cwd-dependent git call is the hook's contract
ROOT="$(git rev-parse --show-toplevel)"
STATUS=0
for link in "$@"; do
    TARGET="$(readlink "$link")"
    if RESOLVED="$(cd "$(dirname "$link")" && python3 -c 'import os, sys; print(os.path.abspath(sys.argv[1]))' "$TARGET")"; then
        case "$RESOLVED/" in
            "$ROOT"/*) continue ;;
        esac
    fi
    echo "Error: symlink points outside the repo: $link -> $TARGET" >&2
    STATUS=1
done
exit "$STATUS"
