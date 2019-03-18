#!/usr/bin/env bash

parse_args()
{
    METHOD="$(cat ${__manifest} | jq -r --arg COMMAND "$1" '.commands[] | select(.command == $COMMAND) | .method')"

    if [[ -z "$METHOD" ]]; then
        METHOD="$(cat ${__manifest} | jq -r --arg COMMAND "$1" '.commands[] | select(.abbreviation == $COMMAND) | .method')"
    fi

    if [[ -z "$METHOD" ]]; then
        help_me
    fi

    $METHOD "${@:2}"
}
