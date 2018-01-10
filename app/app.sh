#!/usr/bin/env bash

app_install()
{
    while getopts u:p: option; do
        case "$option" in
            u)
                local user=$OPTARG
            ;;
            p)
                local password=$OPTARG
            ;;
        esac
    done

    info "User is [$user]..."
    info "Password is [$password]..."
}

app_uninstall()
{
    heading "Uninstalling..."
    app_kill
    rm -rf "${__dir}"
    success "Uninstall OK!"
}

app_update()
{
    cd "${__dir}"

    local current_version="$(git rev-parse origin/master)"
    local install_version="$(git rev-parse HEAD)"

    if [[ "$current_version" == "$install_version" ]]; then
        info 'You are already using the latest version.'
    else
        read -p 'An update is available, do you want to install it? [y/N] :' choice

        if [[ "$choice" =~ ^(yes|y) ]]; then
            heading "Updating..."
            git reset --hard
            git pull
            success 'Update OK!'
        fi
    fi
}

app_alias()
{
    heading "Installing alias..."
    echo "alias ${__base}='bash ${__file}'" | tee -a "${HOME}/.bashrc"
    success "Run [source ${HOME}/.bashrc] to complete the installation."
}

app_version()
{
    local version="$(git rev-parse HEAD)"

    info "You are using version: ${version}"
}
