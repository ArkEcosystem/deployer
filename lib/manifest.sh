#!/usr/bin/env bash

manifest_details()
{
    cat "${__manifest}" | jq -r '.details.'$1''
}

manifest_command_value()
{
    cat "${__manifest}" | jq -r '.commands['$1'].'$2''
}

manifest_commands_length()
{
    cat "${__manifest}" | jq -r '.commands|length'
}
