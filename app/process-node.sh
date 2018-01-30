#!/usr/bin/env bash

process_node_args()
{
    while [[ $# -ne 0 ]] ; do
        case "$1" in
            "--path")
                SIDECHAIN_PATH="$2"
            ;;
            "--database")
                DATABASE_NAME="$2"
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
            "--symbol")
                SYMBOL="$2"
            ;;
            "--prefix")
                PREFIX="$2"
            ;;
            "--fee-send")
                FEE_SEND="$2"
            ;;
            "--fee-vote")
                FEE_VOTE="$2"
            ;;
            "--fee-second-passphrase")
                FEE_SECOND_PASSPHRASE="$2"
            ;;
            "--fee-delegate")
                FEE_DELEGATE="$2"
            ;;
            "--fee-multisig")
                FEE_MULTISIG="$2"
            ;;
            "--forgers")
                FORGERS="$2"
            ;;
            "--max-votes")
                MAX_VOTES="$2"
            ;;
            "--blocktime")
                BLOCK_TIME="$2"
            ;;
            "--transactions-per-block")
                TXS_PER_BLOCK="$2"
            ;;
            "--reward-height-start")
                REWARD_HEIGHT_START="$2"
            ;;
            "--reward-per-block")
                REWARD_PER_BLOCK="$2"
            ;;
            "--update-epoch")
                UPDATE_EPOCH="Y"
            ;;
            "--skip-deps")
                SKIP_DEPS="Y"
            ;;
        esac
        shift
    done
}

process_node_start()
{
    heading "Starting..."
    process_node_args "$@"
    cd $SIDECHAIN_PATH
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
    process_node_args "$@"
    cd $SIDECHAIN_PATH
    forever stop app.js
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
    cd $SIDECHAIN_PATH
    tail -fn 500 logs/ark.log
}
