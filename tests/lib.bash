# shellcheck shell=bash
# Minimal assertion helpers. Sourced by test files.

HS_TESTS_RUN=0
HS_TESTS_FAILED=0

hs_t_ok() {
    HS_TESTS_RUN=$(( HS_TESTS_RUN + 1 ))
    printf '  ok   %s\n' "$1"
}

hs_t_fail() {
    HS_TESTS_RUN=$(( HS_TESTS_RUN + 1 ))
    HS_TESTS_FAILED=$(( HS_TESTS_FAILED + 1 ))
    printf '  FAIL %s\n' "$1"
    [[ -n ${2:-} ]] && printf '       expected: %s\n' "$2"
    [[ -n ${3:-} ]] && printf '       actual:   %s\n' "$3"
    return 0
}

assert_eq() {
    local desc=$1 expected=$2 actual=$3
    if [[ $expected == "$actual" ]]; then
        hs_t_ok "$desc"
    else
        hs_t_fail "$desc" "$expected" "$actual"
    fi
}

assert_contains() {
    local desc=$1 needle=$2 haystack=$3
    if [[ $haystack == *"$needle"* ]]; then
        hs_t_ok "$desc"
    else
        hs_t_fail "$desc" "contains: $needle" "$haystack"
    fi
}

assert_status() {
    local desc=$1 expected=$2; shift 2
    local actual=0
    "$@" >/dev/null 2>&1 || actual=$?
    assert_eq "$desc" "$expected" "$actual"
}

# Write a registry to $1 from "unit|icon|label|tracked" lines on stdin.
make_registry() {
    cat >"$1"
}
