#!/usr/bin/env bash

process_node_start()
{
    heading "Starting..."
    parse_node_args "$@"
    cd $BRIDGECHAIN_PATH
    forever start app.js --config "config.$CHAIN_NAME.autoforging.json" --genesis "genesisBlock.$CHAIN_NAME.json"
    success "Start OK!"

    read -p "Watch Logs? [y/N]: " choice
    if [[ "$choice" =~ ^(yes|y) ]]; then
        process_node_logs
    fi
}

process_node_stop()
{
    heading "Stopping..."
    parse_node_args "$@"
    forever stopall
    success "Stop OK!"
}

process_node_restart()
{
    heading "Restarting..."
    process_node_stop "$@"
    process_node_start "$@"
    success "Restart OK!"
}

process_node_logs()
{
    cd $BRIDGECHAIN_PATH
    tail -fn 500 logs/ark.log
}
