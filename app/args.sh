#!/usr/bin/env bash

parse_json_config()
{
    if [[ "$CONFIG_PROCESSED" == "Y" ]]; then
        return 1
    fi

    if [[ -f "$CONFIG" ]]; then
        KEYS=$(jq -r '. | keys[]' "$CONFIG")
        for KEY in $(jq -r '. | keys[]' "$CONFIG"); do
            case $KEY in
                "nodeIp")
                    NODE_IP=$(jq -r '.nodeIp' "$CONFIG")
                ;;
                "nodePort")
                    NODE_PORT=$(jq -r '.nodePort' "$CONFIG")
                ;;
                "explorerIp")
                    EXPLORER_IP=$(jq -r '.explorerIp' "$CONFIG")
                ;;
                "explorerPort")
                    EXPLORER_PORT=$(jq -r '.explorerPort' "$CONFIG")
                ;;
                "chainName")
                    CHAIN_NAME=$(jq -r '.chainName' "$CONFIG")
                ;;
                "token")
                    TOKEN=$(jq -r '.token' "$CONFIG")
                ;;
                "database")
                    DATABASE_NAME=$(jq -r '.database' "$CONFIG")
                ;;
                "symbol")
                    SYMBOL=$(jq -r '.symbol' "$CONFIG")
                ;;
                "prefix")
                    PREFIX=$(jq -r '.prefix' "$CONFIG")
                ;;
                "feeSend")
                    FEE_SEND=$(jq -r '.feeSend' "$CONFIG")
                ;;
                "feeVote")
                    FEE_VOTE=$(jq -r '.feeVote' "$CONFIG")
                ;;
                "feeSecondPassphrase")
                    FEE_SECOND_PASSPHRASE=$(jq -r '.feeSecondPassphrase' "$CONFIG")
                ;;
                "feeDelegate")
                    FEE_DELEGATE=$(jq -r '.feeDelegate' "$CONFIG")
                ;;
                "feeMultisig")
                    FEE_MULTISIG=$(jq -r '.feeMultisig' "$CONFIG")
                ;;
                "forgers")
                    FORGERS=$(jq -r '.forgers' "$CONFIG")
                ;;
                "maxVotes")
                    MAX_VOTES=$(jq -r '.maxVotes' "$CONFIG")
                ;;
                "blockTime")
                    BLOCK_TIME=$(jq -r '.blockTime' "$CONFIG")
                ;;
                "txsPerBlock")
                    TXS_PER_BLOCK=$(jq -r '.txsPerBlock' "$CONFIG")
                ;;
                "totalPremine")
                    TOTAL_PREMINE=$(jq -r '.totalPremine' "$CONFIG")
                ;;
                "updateEpoch")
                    local VALUE=$(jq -r '.updateEpoch' "$CONFIG")
                    if [[ "$VALUE" == "true" ]]; then
                        UPDATE_EPOCH="Y"
                    fi
                ;;
                "rewardHeightStart")
                    REWARD_HEIGHT_START=$(jq -r '.rewardHeightStart' "$CONFIG")
                ;;
                "rewardPerBlock")
                    REWARD_PER_BLOCK=$(jq -r '.rewardPerBlock' "$CONFIG")
                ;;
                "bridgechainPath")
                    BRIDGECHAIN_PATH=$(jq -r '.bridgechainPath' "$CONFIG")
                ;;
                "explorerPath")
                    EXPLORER_PATH=$(jq -r '.explorerPath' "$CONFIG")
                ;;
            esac
        done
    fi

    CONFIG_PROCESSED="Y"
}

parse_generic_args()
{
    ARGS="$@"
    while [[ $# -ne 0 ]] ; do
        case $1 in
            "--config")
                CONFIG="$2"
                parse_json_config
            ;;
        esac
        shift
    done

    set -- $ARGS
    while [[ $# -ne 0 ]] ; do
        case $1 in
            "--name")
                CHAIN_NAME="$2"
            ;;
            "--node-ip")
                NODE_IP="$2"
            ;;
            "--node-port")
                NODE_PORT="$2"
            ;;
            "--explorer-ip")
                EXPLORER_IP="$2"
            ;;
            "--explorer-port")
                EXPLORER_PORT="$2"
            ;;
            "--token")
                TOKEN="$2"
            ;;
            "--forgers")
                FORGERS="$2"
            ;;
            "--autoinstall-deps")
                INSTALL_DEPS="Y"
            ;;
            "--skip-deps")
                SKIP_DEPS="Y"
            ;;
            "--non-interactive")
                INTERACTIVE="N"
            ;;
        esac
        shift
    done

    ARGS_PROCESSED="Y"
}

parse_explorer_args()
{
    if [[ "$ARGS_PROCESSED" == "Y" ]]; then
        return 0
    fi

    parse_generic_args "$@"

    while [[ $# -ne 0 ]] ; do
        case $1 in
            "--path")
                EXPLORER_PATH="$2"
            ;;
        esac
        shift
    done
}

parse_node_args()
{
    if [[ "$ARGS_PROCESSED" == "Y" ]]; then
        return 0
    fi

    parse_generic_args "$@"

    while [[ $# -ne 0 ]] ; do
        case "$1" in
            "--path")
                BRIDGECHAIN_PATH="$2"
            ;;
            "--database")
                DATABASE_NAME="$2"
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
            "--total-premine")
                TOTAL_PREMINE="$2"
            ;;
            "--max-tokens-per-account")
                MAX_TOKENS_PER_ACCOUNT="$2"
            ;;
            "--no-autoforger")
                AUTO_FORGER="N"
            ;;
            "--update-epoch")
                UPDATE_EPOCH="Y"
            ;;
        esac
        shift
    done

    if [[ "$TOTAL_PREMINE" > "$MAX_TOKENS_PER_ACCOUNT" ]]; then
        MAX_TOKENS_PER_ACCOUNT="$TOTAL_PREMINE"
    fi
}
