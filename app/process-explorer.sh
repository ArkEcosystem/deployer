#!/usr/bin/env bash

process_explorer_args()
{
    while [[ $# -ne 0 ]] ; do
        case $1 in
            "--path")
                EXPLORER_PATH="$2"
            ;;
            "--name")
                CHAIN_NAME="$2"
            ;;
            "--ip")
                NODE_IP="$2"
            ;;
            "--token")
                TOKEN="$2"
            ;;
            "--forgers")
                FORGERS="$2"
            ;;
            "--skip-deps")
                SKIP_DEPS="Y"
            ;;
        esac
        shift
    done
}

process_explorer_start()
{
    process_explorer_stop

    heading "Starting Explorer..."
    process_explorer_args "$@"
    cd $EXPLORER_PATH
    npm start
    success "Start OK!"
}

process_explorer_stop()
{
    heading "Stopping..."
    killall npm || true
    success "Stop OK!"
}

process_explorer_restart()
{
    heading "Restarting..."
    process_explorer_stop "$@"
    process_explorer_start "$@"
    success "Restart OK!"
}
