#!/usr/bin/env bash
# Runs every tests/test_*.bash file. No arguments runs all; pass names to filter.
set -euo pipefail

HYPRSERV_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export HYPRSERV_ROOT
export PATH="$HYPRSERV_ROOT/tests/stub:$PATH"

total=0
failed=0

for file in "$HYPRSERV_ROOT"/tests/test_*.bash; do
    [[ -e $file ]] || continue
    if (( $# > 0 )); then
        match=0
        for want in "$@"; do
            [[ $file == *"$want"* ]] && match=1
        done
        (( match )) || continue
    fi

    printf '%s\n' "${file##*/}"
    # each file runs in its own subshell so a failure cannot poison the next
    output=$(bash "$file" 2>&1) || true
    printf '%s\n' "$output"
    total=$(( total + $(grep -c '^  \(ok\|FAIL\) ' <<<"$output" || true) ))
    failed=$(( failed + $(grep -c '^  FAIL ' <<<"$output" || true) ))
done

printf '\n%d assertions, %d failed\n' "$total" "$failed"
(( failed == 0 ))
