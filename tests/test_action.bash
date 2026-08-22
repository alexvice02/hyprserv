#!/usr/bin/env bash
set -euo pipefail
source "$HYPRSERV_ROOT/tests/lib.bash"

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# dev-action.sh loads its registry via hs_system_config_file(), which by
# design (Day 07) ignores $HYPRSERV_CONFIG so a user-writable file can never
# widen what root will act on. So these tests exercise the real bundled
# registry (config/services.conf) and real unit names instead of a fake one.

action() {
    HS_TEST_KNOWN="docker redis" HS_TEST_ACTIVE=${HS_ACTIVE:-} HS_TEST_LOG=$tmp/calls.log \
        bash "$HYPRSERV_ROOT/scripts/dev-action.sh" "$@"
}

# --- argument validation ----------------------------------------------------
assert_status "no arguments is rejected"        1 action
assert_status "two arguments are rejected"      1 action toggle:docker toggle:redis
assert_status "unknown verb is rejected"        1 action nonsense

# --- allowlist --------------------------------------------------------------
assert_status "unit outside the registry is refused" 1 action toggle:not-in-registry
err=$(action toggle:not-in-registry 2>&1 >/dev/null || true)
assert_contains "refusal names the unit" "not-in-registry" "$err"

: >"$tmp/calls.log"
action toggle:not-in-registry >/dev/null 2>&1 || true
assert_eq "refused unit never reaches systemctl" "" "$(cat "$tmp/calls.log")"

# --- toggle direction -------------------------------------------------------
: >"$tmp/calls.log"
HS_ACTIVE="docker" action toggle:docker
assert_contains "active unit is stopped" "stop -- docker" "$(cat "$tmp/calls.log")"

: >"$tmp/calls.log"
HS_ACTIVE="" action toggle:docker
assert_contains "inactive unit is started" "start -- docker" "$(cat "$tmp/calls.log")"

# --- bulk actions -----------------------------------------------------------
: >"$tmp/calls.log"
action start_all
log=$(cat "$tmp/calls.log")
assert_contains "start_all covers an early unit" "start -- postgresql" "$log"
assert_contains "start_all covers a later unit"  "start -- mariadb"    "$log"

: >"$tmp/calls.log"
action stop_all
assert_contains "stop_all stops every unit" "stop -- mariadb" "$(cat "$tmp/calls.log")"

# --- one bad unit must not abort the rest -----------------------------------
# postgresql is first in the registry, mariadb is last. Restricting
# HS_TEST_KNOWN to "mariadb" makes the stub report postgresql (and every
# other earlier unit) as "not found" while still logging the call. Without
# the Day 02 fix, set -e would abort on that first failure and
# "start -- mariadb" would never appear.
: >"$tmp/calls.log"
HS_TEST_KNOWN="mariadb" HS_TEST_LOG=$tmp/calls.log \
    bash "$HYPRSERV_ROOT/scripts/dev-action.sh" start_all >/dev/null 2>&1 || true
assert_contains "bulk start continues past a failing unit" "start -- mariadb" "$(cat "$tmp/calls.log")"

# --- restart ------------------------------------------------------------
: >"$tmp/calls.log"
HS_ACTIVE="docker" action restart:docker
assert_contains "restart calls systemctl restart" "restart -- docker" "$(cat "$tmp/calls.log")"

assert_status "restart honours the allowlist" 1 action restart:not-in-registry

: >"$tmp/calls.log"
action restart:not-in-registry >/dev/null 2>&1 || true
assert_eq "refused restart never reaches systemctl" "" "$(cat "$tmp/calls.log")"

: >"$tmp/calls.log"
HS_ACTIVE="docker" action restart_all
log=$(cat "$tmp/calls.log")
assert_contains "restart_all restarts a running unit" "restart -- docker" "$log"
assert_eq "restart_all skips a stopped unit" "" "$(grep -o 'restart -- redis' <<<"$log" || true)"
