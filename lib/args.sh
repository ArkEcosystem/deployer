#!/usr/bin/env bash

parse_args()
{
    local method="$(cat ${__manifest} | jq -r --arg COMMAND "$1" '.commands[] | select(.command == $COMMAND) | .method')"

    if [[ -z "$method" ]]; then
        method="$(cat ${__manifest} | jq -r --arg COMMAND "$1" '.commands[] | select(.abbreviation == $COMMAND) | .method')"
    fi

    if [[ -z "$method" ]]; then
        read_the_fucking_manual
    fi

    $method "${@:2}"
}
