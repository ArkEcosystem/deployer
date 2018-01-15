#!/usr/bin/env bash

SIDECHAIN_PATH="/home/$USER/ark-sidechain"
CHAIN_NAME="sidechain"

process_args()
{
    while getopts p:n: option; do
        case "$option" in
            p)
                SIDECHAIN_PATH=$OPTARG
            ;;
            n)
                CHAIN_NAME=$OPTARG
            ;;
        esac
    done
}

process_start()
{
    heading "Starting..."
    process_args
    cd $SIDECHAIN_PATH
    forever start app.js --config "config.$CHAIN_NAME.autoforging.json" --genesis "genesisBlock.$CHAIN_NAME.json"
    success "Start OK!"

    read -p "Watch Logs? [y/N] :" choice
    if [[ "$choice" =~ ^(yes|y) ]]; then
        process_logs
    fi
}

process_stop()
{
    heading "Stopping..."
    process_args
    cd $SIDECHAIN_PATH
    forever stop app.js
    success "Stop OK!"
}

process_restart()
{
    heading "Restarting..."
    process_stop
    process_start
    success "Restart OK!"
}

process_logs()
{
    cd $SIDECHAIN_PATH
    tail -fn 500 logs/ark.log
}
