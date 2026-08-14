#!/usr/bin/env bash
set -euo pipefail
source "$HYPRSERV_ROOT/tests/lib.bash"

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

make_registry "$tmp/three.conf" <<'EOF'
alpha | A | Alpha | yes
beta  | B | Beta  | yes
gamma | C | Gamma | yes
delta | D | Delta | no
EOF

status() {
    HYPRSERV_CONFIG=$tmp/three.conf HS_TEST_ACTIVE=$1 \
        bash "$HYPRSERV_ROOT/scripts/dev-status.sh"
}

# --- the three states -------------------------------------------------------
out=$(status "alpha beta gamma")
assert_contains "all tracked active -> running class" '"class": "running"' "$out"
assert_contains "all tracked active -> running alt"   '"alt": "running"'   "$out"

out=$(status "")
assert_contains "none active -> stopped class" '"class": "stopped"' "$out"

out=$(status "alpha")
assert_contains "some active -> partial class" '"class": "partial"' "$out"
assert_contains "partial tooltip counts tracked only" '1 of 3 services running' "$out"

# --- untracked units do not move the needle ---------------------------------
out=$(status "alpha beta gamma delta")
assert_contains "untracked active unit does not break running" '"class": "running"' "$out"

out=$(status "delta")
assert_contains "untracked-only active reads as stopped" '"class": "stopped"' "$out"

# --- shape ------------------------------------------------------------------
# The systemctl test double doesn't honour --quiet the way the real binary
# does, so `is-active` echoes to stdout on every call; a registry with
# tracked units would leak that noise into $out and defeat this check. An
# all-untracked registry makes zero systemctl calls, so dev-status.sh's own
# output shape can be checked in isolation. This also covers the "nothing
# tracked" case.
make_registry "$tmp/untracked.conf" <<'EOF'
alpha | A | Alpha | no
EOF
out=$(HYPRSERV_CONFIG=$tmp/untracked.conf HS_TEST_ACTIVE=alpha \
        bash "$HYPRSERV_ROOT/scripts/dev-status.sh")
assert_contains "nothing tracked -> stopped, not running" '"class": "stopped"' "$out"
assert_eq "exactly one line of output" "1" "$(printf '%s\n' "$out" | wc -l)"
if command -v jq >/dev/null; then
    assert_status "output is valid JSON" 0 bash -c "printf '%s' '$out' | jq -e ."
fi

err=$(status "alpha" 2>&1 >/dev/null)
assert_eq "nothing on stderr" "" "$err"

# --- alt and class always agree ---------------------------------------------
for active in "alpha beta gamma" "alpha" ""; do
    out=$(status "$active")
    alt=$(sed -n 's/.*"alt": "\([a-z]*\)".*/\1/p' <<<"$out")
    class=$(sed -n 's/.*"class": "\([a-z]*\)".*/\1/p' <<<"$out")
    assert_eq "alt matches class for [$active]" "$alt" "$class"
done
