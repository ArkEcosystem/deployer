#!/usr/bin/env bash

process_node_start()
{
    process_node_stop

    heading "Starting..."
    parse_node_args "$@"
    cd $BRIDGECHAIN_PATH
    if [[ "$AUTO_FORGER" == "Y" ]]; then
        forever start -s app.js --config "config.$CHAIN_NAME.autoforging.json" --genesis "genesisBlock.$CHAIN_NAME.json"
    else
        forever start -s app.js --config "config.$CHAIN_NAME.json" --genesis "genesisBlock.$CHAIN_NAME.json"
    fi
    success "Start OK!"

    WATCH_LOGS="N"
    if [[ "$INTERACTIVE" == "Y" ]]; then
        read -p "Watch Logs? [y/N]: " WATCH_LOGS
    fi
    if [[ "$WATCH_LOGS" =~ ^(yes|y) ]]; then
        process_node_logs
    fi
}

process_node_stop()
{
    heading "Stopping..."
    parse_node_args "$@"
    for uid in $(forever list | grep app.js | egrep -v "STOPPED" | cut -c24-27); do
        forever stop $uid || true;
    done
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
