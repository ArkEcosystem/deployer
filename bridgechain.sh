#!/usr/bin/env bash

[[ "${DEBUG}" == 'true' ]] && set -o xtrace
set -o errexit
set -o pipefail
set -o noclobber

shopt -s extglob

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __base="$(basename ${__file} .sh)"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)"
readonly __manifest="${__dir}/manifest.json"

readonly -a DEPENDENCIES_PROGRAMS=('postgresql postgresql-contrib build-essential libcairo2-dev pkg-config libtool autoconf automake python git curl jq libpq-dev redis-server ntp')
readonly -a DEPENDENCIES_NODEJS=('pm2 grunt-cli node-sass lerna')

source "${__dir}/bootstrap/lib.sh"
source "${__dir}/bootstrap/app.sh"

main()
{
    parse_args "$@"

    trap cleanup SIGINT SIGTERM SIGKILL
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
