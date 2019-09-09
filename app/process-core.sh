#!/usr/bin/env bash

process_core_start()
{
    process_core_stop "$@"

    heading "Starting..."
    parse_core_args "$@"

    if [ ! -d "$BRIDGECHAIN_PATH/packages/core" ]; then
        error "Bridgechain path could not be found. Use '--path' to specify the location it was installed."

        return
    fi

    app_install_core_configuration

    cd "$BRIDGECHAIN_PATH/packages/core"
    local NETWORK=$(echo "$NETWORK" | awk '{print tolower($0)}')

    if [ -z "$NETWORK" ]; then
        abort 1 "Network must be specified"
    elif [ ! -d "$XDG_CONFIG_HOME/${CORE_ALIAS}-core/$NETWORK" ]; then
        echo "$XDG_CONFIG_HOME/${CORE_ALIAS}-core/$NETWORK"
        abort 1 "Network '$NETWORK' does not exist"
    fi

    if [[ "$AUTO_FORGER" == "Y" ]]; then
        local LAST_HEIGHT=$(__core_check_last_height "$CONFIG_PATH")
        if [[ "$LAST_HEIGHT" > "0" ]]; then
            __core_start
        else
            ./bin/run relay:start --network="$NETWORK" --networkStart --ignoreMinimumNetworkReach --env=test
            if [ $(sh -c "jq '.secrets | length' $XDG_CONFIG_HOME/${CORE_ALIAS}-core/$NETWORK/delegates.json") <> "0" ]; then
                ./bin/run forger:start --network="$NETWORK" --env=test
            else
                warning "No forging delegates found in 'delegates.json' config"
            fi
        fi
    else
        __core_start
    fi
    success "Start OK!"

    local WATCH_LOGS="N"
    if [[ "$INTERACTIVE" == "Y" ]]; then
        read -p "Watch Logs? [y/N]: " WATCH_LOGS
    fi
    if [[ "$WATCH_LOGS" =~ ^(yes|y|Y) ]]; then
        process_core_logs
    fi
}

__core_start() {
    if [[ "$FORCE_NETWORK_START" == "Y" ]]; then
        ./bin/run relay:start --network="$NETWORK" --networkStart --ignoreMinimumNetworkReach
    else
        ./bin/run relay:start --network="$NETWORK" --ignoreMinimumNetworkReach
    fi

    if [ $(sh -c "jq '.secrets | length' $XDG_CONFIG_HOME/${CORE_ALIAS}-core/$NETWORK/delegates.json") <> "0" ]; then
        ./bin/run forger:start --network="$NETWORK"
    else
        warning "No forging delegates found in 'delegates.json' config"
    fi
}

__core_check_last_height() {
    local CONFIG_PATH="$1"
    local DATABASE_NAME=$(cat "$XDG_CONFIG_HOME/${CORE_ALIAS}-core/$NETWORK/.env" | fgrep 'CORE_DB_DATABASE=' | awk -F'=' '{print $2}')
    psql -qtAX -d "$DATABASE_NAME" -c "SELECT height FROM blocks ORDER BY height DESC LIMIT 1" 2>/dev/null || echo 0
}

process_core_stop()
{
    heading "Stopping..."
    parse_core_args "$@"

    local NETWORK=$(echo "$NETWORK" | awk '{print tolower($0)}')
    if [[ -d "$BRIDGECHAIN_PATH/packages/core" && ! -z "$NETWORK" ]]; then
        cd "$BRIDGECHAIN_PATH/packages/core"

        if [ ! -d "$XDG_CONFIG_HOME/${CORE_ALIAS}-core/$NETWORK" ]; then
            error "Network '$NETWORK' does not exist"

            return
        fi

        ./bin/run relay:stop --network="$NETWORK" &>/dev/null || true
        ./bin/run forger:stop --network="$NETWORK" &>/dev/null || true
    else
        for PROCESS in $(pm2 list | fgrep "online" | egrep -v "explorer|────|^│ App nam" | awk '{print $2}'); do
            pm2 stop "$PROCESS" &>/dev/null || true
        done
    fi

    success "Stop OK!"
}

process_core_restart()
{
    heading "Restarting..."
    process_core_stop "$@"
    process_core_start "$@"
    success "Restart OK!"
}

process_core_logs()
{
    pm2 logs
}
