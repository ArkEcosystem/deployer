#!/usr/bin/env bash

help_me()
{
    printf "%s# ---------------------------------------------------------------------------"
    printf "%s\n#"
    printf "%s\n#  $(manifest_details title)"
    printf "%s\n#    Version: $(manifest_details version)"
    printf "%s\n#"
    printf "%s\n#  Usage:"
    printf "%s\n#    $(manifest_details syntax)"
    printf "%s\n#"
    printf "%s\n"

    local MAX_COL=0
    local COUNT_ARGS=$(manifest_commands_length)

    for (( i = 0; i < COUNT_ARGS; i++ )) do
        ARG_LEN=$(manifest_command_value $i abbreviation)+$(manifest_command_value $i command)

        ((${#ARG_LEN} > MAX_COL)) && MAX_COL=${#ARG_LEN}

        (($i == COUNT_ARGS-1 )) && ((MAX_COL+=6))
    done

    for (( i = 0; i < COUNT_ARGS; i++ )) do
        local abbreviation="$(manifest_command_value $i abbreviation)"

        if [[ "$abbreviation" == "null" ]]; then
            printf "%-${MAX_COL}s %s\n" "#  $(manifest_command_value $i command)" "$(manifest_command_value $i description)"
        else
            printf "%-${MAX_COL}s %s\n" "#  ${abbreviation}, $(manifest_command_value $i command)" "$(manifest_command_value $i description)"
        fi
    done

    printf "%s#\n"
    printf "%s# ---------------------------------------------------------------------------\n"
}
