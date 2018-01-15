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

    TO_INSTALL=""
    for dependency in ${dependencies[@]}; do
        INSTALLED=$(dpkg -l "$dependency" 2>/dev/null | fgrep "$dependency" | egrep "^[a-zA-Z]" | awk '{print $2}') || true
        if [[ "$INSTALLED" != "$dependency" ]]; then
            TO_INSTALL="$TO_INSTALL$dependency "
        fi
    done

    if [[ ! -z "$TO_INSTALL" ]]; then
        read -p "Dependencies [ ${TO_INSTALL}] are not installed. Do you want to install them? [y/N]: " choice

        if [[ "$choice" =~ ^(yes|y) ]]; then
            success "Installing dependencies..."
            if [[ "$machine" == "Linux" ]]; then
                sudo apt-get install "${TO_INSTALL}" -y
            elif [[ "$machine" == "Mac" ]]; then
                brew install "${TO_INSTALL}" -y
            else
                abort 1 'Unsupported platform.'
            fi
            success 'Installation OK!'
        else
            abort 1 "Please ensure that [ ${TO_INSTALL}] dependencies are installed and try again."
        fi
    fi
}

check_nodejs_dependencies()
{
    local -a dependencies="${1}"

    TO_INSTALL=""
    for dependency in ${dependencies[@]}; do
        INSTALLED=$(npm list -g "$dependency" | fgrep "$dependency" | awk '{print $2}' | awk -F'@' '{print $1}') || true
        if [[ "$INSTALLED" != "$dependency" ]]; then
            TO_INSTALL="$TO_INSTALL$dependency "
        fi
    done

    if [[ ! -z "$TO_INSTALL" ]]; then
        read -p "[ ${TO_INSTALL}] are not installed. Do you want to install them? [y/N]: " choice

        if [[ "$choice" =~ ^(yes|y) ]]; then
            success "Installing dependencies..."
            npm install -g "${TO_INSTALL}"
            success 'Installation OK!'
        else
            abort 1 "Please ensure that [ ${TO_INSTALL}] dependencies are installed and try again."
        fi
    fi
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
