#!/usr/bin/env bash

case "$(uname -s)" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

install_dependencies()
{
    if [[ "$SKIP_DEPS" != "Y" ]]; then
        heading "Checking Dependencies..."
        check_program_dependencies
        check_nodejs_dependencies

        export PATH="/home/vagrant/bin:/home/vagrant/.local/bin:/home/vagrant/.yarn/bin:$PATH"
    fi
}

apt_package_installed()
{
    local package="$1"
    local install_status

    install_status=$(dpkg --list "$package" 2>&1 | tail -n 1 | head -c 3) || true
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
    local -a DEPENDENCIES="${DEPENDENCIES_PROGRAMS[@]}"

    TO_INSTALL=""
    for DEPENDENCY in ${DEPENDENCIES[@]}; do
        if ! apt_package_installed "$DEPENDENCY" ; then
            TO_INSTALL="$TO_INSTALL$DEPENDENCY "
        fi
    done

    if [[ ! -z "$TO_INSTALL" ]]; then
        if [[ "$INSTALL_DEPS" != "Y" ]]; then
            read -p "Dependencies [ ${TO_INSTALL}] are not installed. Do you want to install them? [y/N]: " choice
        fi

        if [[ "$choice" =~ ^(yes|y|Y) || "$INSTALL_DEPS" == "Y" ]]; then
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
    local -a DEPENDENCIES="${DEPENDENCIES_NODEJS[@]}"

    TO_INSTALL=""
    YARN_LIST=$(yarn global list)
    for DEPENDENCY in ${DEPENDENCIES[@]}; do
        INSTALLED_1=$(echo "$YARN_LIST" | egrep "^\s+-\s($DEPENDENCY)$" | awk '{print $2}') || true
        INSTALLED_2=$(echo "$YARN_LIST" | egrep "$DEPENDENCY.+has binaries:$" | awk '{print $2}' | egrep -o "\"$DEPENDENCY@") || true
        if [[ "$INSTALLED_1" != "$DEPENDENCY" && "$INSTALLED_2" != "\"$DEPENDENCY@" ]]; then
            TO_INSTALL="$TO_INSTALL$DEPENDENCY "
        fi
    done

    if [[ ! -z "$TO_INSTALL" ]]; then
        if [[ "$INSTALL_DEPS" != "Y" ]]; then
            read -p "[ ${TO_INSTALL}] are not installed. Do you want to install them? [y/N]: " choice
        fi

        if [[ "$choice" =~ ^(yes|y|Y) || "$INSTALL_DEPS" == "Y" ]]; then
            success "Installing NodeJS Dependencies..."
            sh -c "yarn global add ${TO_INSTALL}"
            success 'NodeJS Dependencies Installed!'
        else
            abort 1 "Please ensure that [ ${TO_INSTALL}] dependencies are installed and try again."
        fi
    fi
}

check_file_dependencies()
{
    local -a DEPENDENCIES="${1}"

    for DEPENDENCY in ${DEPENDENCIES[@]}; do
        if [[ ! -f "${DEPENDENCY}" ]]; then
            abort 1 "Please ensure that [${DEPENDENCY}] exists and try again."
        fi
    done
}

check_process_dependencies()
{
    local -a DEPENDENCIES="${1}"

    for DEPENDENCY in ${DEPENDENCIES[@]}; do
        if [[ ! $(pgrep -x "${DEPENDENCY}") ]]; then
            read -p "[${DEPENDENCY}] is not running. Do you want to start it? [y/N] :" choice

            if [[ "$choice" =~ ^(yes|y|Y) ]]; then
                success "Starting ${DEPENDENCY}..."
                sudo service "${DEPENDENCY}" start
                success 'Start OK!'
            else
                abort 1 "Please ensure that [${DEPENDENCY}] is running and try again."
            fi
        fi
    done
}
