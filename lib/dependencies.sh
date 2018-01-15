#!/usr/bin/env bash

case "$(uname -s)" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

check_program_dependencies()
{
    local -a dependencies="${1}"

    for dependency in ${dependencies[@]}; do
        INSTALLED=$(dpkg -l "$dependency" | fgrep "$dependency" | egrep "^[a-zA-Z]" | awk '{print $2}') || true
        if [[ "$INSTALLED" != "$dependency" ]]; then
            read -p "[${dependency}] is not installed. Do you want to install it? [y/N] :" choice

            if [[ "$choice" =~ ^(yes|y) ]]; then
                success "Installing ${dependency}..."
                if [[ "$machine" == "Linux" ]]; then
                    sudo apt-get install "${dependency}" -y
                elif [[ "$machine" == "Mac" ]]; then
                    brew install "${dependency}" -y
                else
                    abort 1 'Unsupported platform.'
                fi
                success 'Installation OK!'
            else
                abort 1 "Please ensure that [${dependency}] is installed and try again."
            fi
        fi
    done
}

check_nodejs_dependencies()
{
    local -a dependencies="${1}"

    for dependency in ${dependencies[@]}; do
        INSTALLED=$(npm list -g "$dependency" | fgrep "$dependency" | awk '{print $2}' | awk -F'@' '{print $1}')
        if [[ "$INSTALLED" != "$dependency" ]]; then
            read -p "[${dependency}] is not installed. Do you want to install it? [y/N] :" choice

            if [[ "$choice" =~ ^(yes|y) ]]; then
                success "Installing ${dependency}..."
                sudo npm install -g "${dependency}"
                success 'Installation OK!'
            else
                abort 1 "Please ensure that [${dependency}] is installed and try again."
            fi
        fi
    done
}

check_file_dependencies()
{
    local -a dependencies="${1}"

    for dependency in ${dependencies[@]}; do
        if [[ ! -f "${dependency}" ]]; then
            abort 1 "Please ensure that [${dependency}] exists and try again."
        fi
    done
}

check_process_dependencies()
{
    local -a dependencies="${1}"

    for dependency in ${dependencies[@]}; do
        if [[ ! $(pgrep -x "${dependency}") ]]; then
            read -p "[${dependency}] is not running. Do you want to start it? [y/N] :" choice

            if [[ "$choice" =~ ^(yes|y) ]]; then
                success "Starting ${dependency}..."
                sudo service "${dependency}" start
                success 'Start OK!'
            else
                abort 1 "Please ensure that [${dependency}] is running and try again."
            fi
        fi
    done
}
