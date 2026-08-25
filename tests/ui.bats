setup() {
    cd "${BATS_TEST_DIRNAME}/.."
    source scripts/global_fn.sh
}

@test "ui_rich is false in --yes mode" {
    use_default="--yes" run ui_rich
    [ "$status" -ne 0 ]
}

@test "prompt_yes_no honors --yes with default_yes" {
    use_default="--yes" run prompt_yes_no "proceed?" default_yes
    [ "$status" -eq 0 ]
}

@test "prompt_yes_no honors --yes with default_no" {
    use_default="--yes" run prompt_yes_no "proceed?" default_no
    [ "$status" -ne 0 ]
}

@test "prompt_input echoes the default when non-interactive" {
    use_default="--yes" run prompt_input "Name" "fallback"
    [ "$status" -eq 0 ]
    [ "$output" = "fallback" ]
}

@test "with_retry succeeds when the command succeeds" {
    run with_retry 3 true
    [ "$status" -eq 0 ]
}

@test "with_retry gives up after max attempts" {
    run with_retry 2 false
    [ "$status" -ne 0 ]
}

@test "with_retry retries until the command succeeds" {
    marker="${BATS_TEST_TMPDIR}/attempts"
    : >"${marker}"
    flaky() {
        printf 'x' >>"${marker}"
        [ "$(wc -c <"${marker}")" -ge 2 ]
    }
    export -f flaky
    run with_retry 5 flaky
    [ "$status" -eq 0 ]
}
