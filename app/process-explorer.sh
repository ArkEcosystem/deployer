#!/usr/bin/env bash

process_explorer_start()
{
    process_explorer_stop

    heading "Starting Explorer..."
    parse_explorer_args "$@"
    cd $EXPLORER_PATH
    ./start-explorer.sh
    success "Start OK!"
}

process_explorer_stop()
{
    heading "Stopping..."
    (uid=$(forever list | grep server.js | cut -c24-27) && forever stop $uid) || true
    success "Stop OK!"
}

process_explorer_restart()
{
    heading "Restarting..."
    process_explorer_stop "$@"
    process_explorer_start "$@"
    success "Restart OK!"
}
