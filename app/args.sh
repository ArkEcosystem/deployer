#!/usr/bin/env bash

parse_json_config()
{
    if [[ "$CONFIG_PROCESSED" == "Y" ]]; then
        return 1
    fi

    if [[ -f "$CONFIG" ]]; then
        KEYS=$(jq '. | keys[]' "$CONFIG")
        for key in $(jq '. | keys[]' "$CONFIG"); do
            case $key in
                "nodeIp")
                    NODE_IP=$(jq '.nodeIp' "$CONFIG")
                ;;
                "nodePort")
                    NODE_PORT=$(jq '.nodePort' "$CONFIG")
                ;;
                "explorerIp")
                    EXPLORER_IP=$(jq '.explorerIp' "$CONFIG")
                ;;
                "explorerPort")
                    EXPLORER_PORT=$(jq '.explorerPort' "$CONFIG")
                ;;
                "chainName")
                    CHAIN_NAME=$(jq '.chainName' "$CONFIG")
                ;;
                "token")
                    TOKEN=$(jq '.token' "$CONFIG")
                ;;
                "database")
                    DATABASE_NAME=$(jq '.database' "$CONFIG")
                ;;
                "symbol")
                    SYMBOL=$(jq '.symbol' "$CONFIG")
                ;;
                "prefix")
                    PREFIX=$(jq '.prefix' "$CONFIG")
                ;;
                "feeSend")
                    FEE_SEND=$(jq '.feeSend' "$CONFIG")
                ;;
                "feeVote")
                    FEE_VOTE=$(jq '.feeVote' "$CONFIG")
                ;;
                "feeSecondPassphrase")
                    FEE_SECOND_PASSPHRASE=$(jq '.feeSecondPassphrase' "$CONFIG")
                ;;
                "feeDelegate")
                    FEE_DELEGATE=$(jq '.feeDelegate' "$CONFIG")
                ;;
                "feeMultisig")
                    FEE_MULTISIG=$(jq '.feeMultisig' "$CONFIG")
                ;;
                "forgers")
                    FORGERS=$(jq '.forgers' "$CONFIG")
                ;;
                "maxVotes")
                    MAX_VOTES=$(jq '.maxVotes' "$CONFIG")
                ;;
                "blockTime")
                    BLOCK_TIME=$(jq '.blockTime' "$CONFIG")
                ;;
                "txsPerBlock")
                    TXS_PER_BLOCK=$(jq '.txsPerBlock' "$CONFIG")
                ;;
                "totalPremine")
                    TOTAL_PREMINE=$(jq '.totalPremine' "$CONFIG")
                ;;
                "updateEpoch")
                    local VALUE=$(jq '.updateEpoch' "$CONFIG")
                    if [[ "$VALUE" == "true" ]]; then
                        UPDATE_EPOCH="Y"
                    fi
                ;;
                "rewardHeightStart")
                    REWARD_HEIGHT_START=$(jq '.rewardHeightStart' "$CONFIG")
                ;;
                "rewardPerBlock")
                    REWARD_PER_BLOCK=$(jq '.rewardPerBlock' "$CONFIG")
                ;;
                "bridgechainPath")
                    SIDECHAIN_PATH=$(jq '.bridgechainPath' "$CONFIG")
                ;;
            esac
        done
    fi

    CONFIG_PROCESSED="Y"
}

parse_generic_args()
{
    while [[ $# -ne 0 ]] ; do
        case $1 in
            "--config")
                CONFIG="$2"
                parse_json_config
            ;;
        esac
        shift
    done

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
        esac
        shift
    done

    ARGS_PROCESSED="Y"
}

parse_explorer_args()
{
    if [[ "$ARGS_PROCESSED" == "Y" ]]; then
        return 1
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
        return 1
    fi

    parse_generic_args "$@"

    while [[ $# -ne 0 ]] ; do
        case "$1" in
            "--path")
                SIDECHAIN_PATH="$2"
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
