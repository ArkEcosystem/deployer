#!/usr/bin/env bash

abort()
{
    error "Yikes! ${2}"
    exit "${1}"
}

abort_info()
{
    info "Huh! ${1}"
    exit 0
}

abort_success()
{
    success "Yay! ${1}"
    exit 0
}

abort_warning()
{
    warning "Argh! ${1}"
    exit 1
}

exception()
{
    abort 1 "${1}"
}

exception_missing_argument()
{
    abort 2 "Argument [${1}] is missing."
}

exception_command_not_found()
{
    abort 127 "Command [${1}] not found."
}

exception_invalid_argument()
{
    abort 128 "Argument [${1}] is invalid."
}
