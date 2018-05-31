#!/usr/bin/env bash

case "$(uname -s)" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

apt_package_installed()
{
    local package="$1"
    local install_status

    install_status=$(dpkg --list "$package" | tail -n 1 | head -c 3) || true
    # interpretation of the 3 characters of install status
    # https://linuxprograms.wordpress.com/2010/05/11/status-dpkg-list/
    if [[ "$install_status" == "ii " ]]; then
        return 0
    else
        return 1
    fi
}

check_program_dependencies()
{
    local -a dependencies="${1}"

    TO_INSTALL=""
    for dependency in ${dependencies[@]}; do
        if ! apt_package_installed "$dependency" ; then
            TO_INSTALL="$TO_INSTALL$dependency "
        fi
    done

    if [[ ! -z "$TO_INSTALL" ]]; then
        if [[ "$INSTALL_DEPS" != "Y" ]]; then
            read -p "Dependencies [ ${TO_INSTALL}] are not installed. Do you want to install them? [y/N]: " choice
        fi

        if [[ "$choice" =~ ^(yes|y) || "$INSTALL_DEPS" == "Y" ]]; then
            success "Installing Program Dependencies..."
            if [[ "$machine" == "Linux" ]]; then
                sudo sh -c "sudo apt-get install ${TO_INSTALL} -y"
            elif [[ "$machine" == "Mac" ]]; then
                sh -c "brew install ${TO_INSTALL} -y"
            else
                abort 1 'Unsupported platform.'
            fi
            success 'Program Dependencies Installed!'
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
        if [[ "$INSTALL_DEPS" != "Y" ]]; then
            read -p "[ ${TO_INSTALL}] are not installed. Do you want to install them? [y/N]: " choice
        fi

        if [[ "$choice" =~ ^(yes|y) || "$INSTALL_DEPS" == "Y" ]]; then
            success "Installing NodeJS Dependencies..."
            sh -c "npm install -g ${TO_INSTALL}"
            success 'NodeJS Dependencies Installed!'
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
