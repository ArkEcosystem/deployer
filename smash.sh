#!/usr/bin/env bash

[[ "${DEBUG}" == 'true' ]] && set -o xtrace
set -o errexit
# set -o nounset
set -o pipefail
set -o noclobber

shopt -s extglob

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __base="$(basename ${__file} .sh)"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)"
readonly __manifest="${__dir}/manifest.json"
readonly __daemon="${__dir}/daemon.json"

readonly -a DEPENDENCIES_PROGRAMS=('jq postgresql postgresql-contrib libpq-dev build-essential python git curl jq libtool autoconf locales automake locate zip unzip htop nmon iftop')
readonly -a DEPENDENCIES_NODEJS=('pm2 forever grunt-cli')
# readonly -a DEPENDENCIES_FILES=()
# readonly -a DEPENDENCIES_PROCESSES=()

source "${__dir}/bootstrap/lib.sh"
source "${__dir}/bootstrap/app.sh"

main()
{
    #check_program_dependencies "${DEPENDENCIES_PROGRAMS[@]}"
    #check_nodejs_dependencies "${DEPENDENCIES_NODEJS[@]}"

    parse_args "$@"

    trap cleanup SIGINT SIGTERM SIGKILL
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
