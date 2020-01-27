#!/usr/bin/env bash

parse_json_config()
{
    if [[ "$CONFIG_PROCESSED" == "Y" ]]; then
        return
    fi

    if [[ -f "$CONFIG" ]]; then
        KEYS=$(jq -r '. | keys[]' "$CONFIG")
        for KEY in $(jq -r '. | keys[]' "$CONFIG"); do
            case $KEY in
                "coreIp") ## Used when accessing Explorer
                    CORE_IP=$(jq -r '.coreIp' "$CONFIG")
                    if [ "$CORE_IP" == "127.0.0.1" ]; then
                        CORE_IP=$(get_ip)
                    fi
                ;;
                "p2pPort")
                    P2P_PORT=$(jq -r '.p2pPort' "$CONFIG")
                ;;
                "apiPort")
                    API_PORT=$(jq -r '.apiPort' "$CONFIG")
                ;;
                "webhookPort")
                    WEBHOOK_PORT=$(jq -r '.webhookPort' "$CONFIG")
                ;;
                "jsonRpcPort")
                    JSON_RPC_PORT=$(jq -r '.jsonRpcPort' "$CONFIG")
                ;;
                "explorerIp")
                    EXPLORER_IP=$(jq -r '.explorerIp // empty' "$CONFIG")
                ;;
                "explorerPort")
                    EXPLORER_PORT=$(jq -r '.explorerPort // empty' "$CONFIG")
                ;;
                "chainName")
                    local CHANGE_DATABASE="N"
                    if [[ "$DATABASE_NAME" == "core_$CHAIN_NAME" ]]; then
                        CHANGE_DATABASE="Y"
                    fi
                    CHAIN_NAME=$(jq -r '.chainName' "$CONFIG" | tr -cs '[:alnum:]\r\n' '-')
                    if [ "$CHANGE_DATABASE" == "Y" ]; then
                        DATABASE_NAME="core_$CHAIN_NAME"
                    fi
                ;;
                "token")
                    TOKEN=$(jq -r '.token' "$CONFIG")
                ;;
                "cliAlias")
                    CLI_ALIAS=$(jq -r '.cliAlias' "$CONFIG")
                ;;
                "databaseHost")
                    DATABASE_HOST=$(jq -r '.databaseHost' "$CONFIG")
                ;;
                "databasePort")
                    DATABASE_PORT=$(jq -r '.databasePort' "$CONFIG")
                ;;
                "databaseName")
                    DATABASE_NAME=$(jq -r '.databaseName' "$CONFIG")
                ;;
                "symbol")
                    SYMBOL=$(jq -r '.symbol' "$CONFIG")
                ;;
                "mainnetPeers")
                    local MAINNET_PEERS_RAW=$(jq -r '.mainnetPeers // empty' "$CONFIG")
                    if [ ! -z "$MAINNET_PEERS_RAW" ]; then
                        MAINNET_PEERS=$(jq -r '.mainnetPeers // empty | join(",")' "$CONFIG")
                    fi
                ;;
                "devnetPeers")
                    local DEVNET_PEERS_RAW=$(jq -r '.devnetPeers // empty' "$CONFIG")
                    if [ ! -z "$DEVNET_PEERS_RAW" ]; then
                        DEVNET_PEERS=$(jq -r '.devnetPeers // empty | join(",")' "$CONFIG")
                    fi
                ;;
                "mainnetPrefix")
                    MAINNET_PREFIX=$(jq -r '.mainnetPrefix' "$CONFIG")
                ;;
                "devnetPrefix")
                    DEVNET_PREFIX=$(jq -r '.devnetPrefix' "$CONFIG")
                ;;
                "testnetPrefix")
                    TESTNET_PREFIX=$(jq -r '.testnetPrefix' "$CONFIG")
                ;;
                "fees")
                    local STATIC_FEES=$(jq -r '.fees.static // empty' "$CONFIG")
                    if [ ! -z "$STATIC_FEES" ]; then
                        local STATIC_TRANSFER=$(jq -r '.fees.static.transfer // empty' "$CONFIG")
                        if [ ! -z "$STATIC_TRANSFER" ]; then
                            FEE_STATIC_TRANSFER="$STATIC_TRANSFER"
                        fi
                        local STATIC_VOTE=$(jq -r '.fees.static.vote // empty' "$CONFIG")
                        if [ ! -z "$STATIC_VOTE" ]; then
                            FEE_STATIC_VOTE="$STATIC_VOTE"
                        fi
                        local STATIC_SECOND_SIGNATURE=$(jq -r '.fees.static.secondSignature // empty' "$CONFIG")
                        if [ ! -z "$STATIC_SECOND_SIGNATURE" ]; then
                            FEE_STATIC_SECOND_SIGNATURE="$STATIC_SECOND_SIGNATURE"
                        fi
                        local STATIC_DELEGATE_REGISTRATION=$(jq -r '.fees.static.delegateRegistration // empty' "$CONFIG")
                        if [ ! -z "$STATIC_DELEGATE_REGISTRATION" ]; then
                            FEE_STATIC_DELEGATE_REGISTRATION="$STATIC_DELEGATE_REGISTRATION"
                        fi
                        local STATIC_MULTISIG_REGISTRATION=$(jq -r '.fees.static.multiSignature // empty' "$CONFIG")
                        if [ ! -z "$STATIC_MULTISIG_REGISTRATION" ]; then
                            FEE_STATIC_MULTISIG_REGISTRATION="$STATIC_MULTISIG_REGISTRATION"
                        fi
                    fi

                    local DYNAMIC_FEES=$(jq -r '.fees.dynamic // empty' "$CONFIG")
                    if [ ! -z "$DYNAMIC_FEES" ]; then
                        local IS_ENABLED=$(jq -r '.fees.dynamic.enabled' "$CONFIG")
                        if [[ "$IS_ENABLED" == "true" ]]; then
                            FEE_DYNAMIC_ENABLED="Y"
                        fi
                        local POOL_MIN_FEE=$(jq -r '.fees.dynamic.minFeePool // empty' "$CONFIG")
                        if [ ! -z "$POOL_MIN_FEE" ]; then
                            FEE_DYNAMIC_POOL_MIN_FEE="$POOL_MIN_FEE"
                        fi
                        local BROADCAST_MIN_FEE=$(jq -r '.fees.dynamic.minFeeBroadcast // empty' "$CONFIG")
                        if [ ! -z "$BROADCAST_MIN_FEE" ]; then
                            FEE_DYNAMIC_BROADCAST_MIN_FEE="$BROADCAST_MIN_FEE"
                        fi
                        local BYTES_TRANSFER=$(jq -r '.fees.dynamic.addonBytes.transfer // empty' "$CONFIG")
                        if [ ! -z "$BYTES_TRANSFER" ]; then
                            FEE_DYNAMIC_BYTES_TRANSFER="$BYTES_TRANSFER"
                        fi
                        local BYTES_SECOND_SIGNATURE=$(jq -r '.fees.dynamic.addonBytes.secondSignature // empty' "$CONFIG")
                        if [ ! -z "$BYTES_SECOND_SIGNATURE" ]; then
                            FEE_DYNAMIC_BYTES_SECOND_SIGNATURE="$BYTES_SECOND_SIGNATURE"
                        fi
                        local BYTES_DELEGATE_REGISTRATION=$(jq -r '.fees.dynamic.addonBytes.delegateRegistration // empty' "$CONFIG")
                        if [ ! -z "$BYTES_DELEGATE_REGISTRATION" ]; then
                            FEE_DYNAMIC_BYTES_DELEGATE_REGISTRATION="$BYTES_DELEGATE_REGISTRATION"
                        fi
                        local BYTES_VOTE=$(jq -r '.fees.dynamic.addonBytes.vote // empty' "$CONFIG")
                        if [ ! -z "$BYTES_VOTE" ]; then
                            FEE_DYNAMIC_BYTES_VOTE="$BYTES_VOTE"
                        fi
                        local BYTES_MULTISIG_REGISTRATION=$(jq -r '.fees.dynamic.addonBytes.multiSignature // empty' "$CONFIG")
                        if [ ! -z "$BYTES_MULTISIG_REGISTRATION" ]; then
                            FEE_DYNAMIC_BYTES_MULTISIG_REGISTRATION="$BYTES_MULTISIG_REGISTRATION"
                        fi
                        local BYTES_IPFS=$(jq -r '.fees.dynamic.addonBytes.ipfs // empty' "$CONFIG")
                        if [ ! -z "$BYTES_IPFS" ]; then
                            FEE_DYNAMIC_BYTES_IPFS="$BYTES_IPFS"
                        fi
                        local BYTES_HTLC_LOCK=$(jq -r '.fees.dynamic.addonBytes.htlcLock // empty' "$CONFIG")
                        if [ ! -z "$BYTES_HTLC_LOCK" ]; then
                            FEE_DYNAMIC_BYTES_HTLC_LOCK="$BYTES_HTLC_LOCK"
                        fi
                        local BYTES_HTLC_CLAIM=$(jq -r '.fees.dynamic.addonBytes.htlcClaim // empty' "$CONFIG")
                        if [ ! -z "$BYTES_HTLC_CLAIM" ]; then
                            FEE_DYNAMIC_BYTES_HTLC_CLAIM="$BYTES_HTLC_CLAIM"
                        fi
                        local BYTES_MULTIPAYMENT=$(jq -r '.fees.dynamic.addonBytes.multiPayment // empty' "$CONFIG")
                        if [ ! -z "$BYTES_MULTIPAYMENT" ]; then
                            FEE_DYNAMIC_BYTES_MULTIPAYMENT="$BYTES_MULTIPAYMENT"
                        fi
                        local BYTES_DELEGATE_RESIGNATION=$(jq -r '.fees.dynamic.addonBytes.delegateResignation // empty' "$CONFIG")
                        if [ ! -z "$BYTES_DELEGATE_RESIGNATION" ]; then
                            FEE_DYNAMIC_BYTES_DELEGATE_RESIGNATION="$BYTES_DELEGATE_RESIGNATION"
                        fi
                    fi
                ;;
                "forgers")
                    FORGERS=$(jq -r '.forgers' "$CONFIG")
                ;;
                "blocktime")
                    BLOCK_TIME=$(jq -r '.blocktime' "$CONFIG")
                ;;
                "transactionsPerBlock")
                    TXS_PER_BLOCK=$(jq -r '.transactionsPerBlock' "$CONFIG")
                ;;
                "totalPremine")
                    TOTAL_PREMINE=$(jq -r '.totalPremine' "$CONFIG")
                ;;
                "rewardHeightStart")
                    REWARD_HEIGHT_START=$(jq -r '.rewardHeightStart' "$CONFIG")
                ;;
                "rewardPerBlock")
                    REWARD_PER_BLOCK=$(jq -r '.rewardPerBlock' "$CONFIG")
                ;;
                "vendorFieldLength")
                    VENDORFIELD_LENGTH=$(jq -r '.vendorFieldLength' "$CONFIG")
                ;;
                "bridgechainPath")
                    BRIDGECHAIN_PATH_RAW=$(jq -r '.bridgechainPath' "$CONFIG")
                    BRIDGECHAIN_PATH=$(eval echo "$BRIDGECHAIN_PATH_RAW")
                ;;
                "explorerPath")
                    EXPLORER_PATH_RAW=$(jq -r '.explorerPath' "$CONFIG")
                    EXPLORER_PATH=$(eval echo "$EXPLORER_PATH_RAW")
                ;;
                "gitCoreCommit")
                    local VALUE=$(jq -r '.gitCoreCommit' "$CONFIG")
                    if [[ "$VALUE" == "true" ]]; then
                        GIT_CORE_COMMIT="Y"
                    fi
                ;;
                "gitCoreOrigin")
                    GIT_CORE_ORIGIN=$(jq -r '.gitCoreOrigin // empty' "$CONFIG")
                ;;
                "gitExplorerCommit")
                    local VALUE=$(jq -r '.gitExplorerCommit' "$CONFIG")
                    if [[ "$VALUE" == "true" ]]; then
                        GIT_EXPLORER_COMMIT="Y"
                    fi
                ;;
                "gitExplorerOrigin")
                    GIT_EXPLORER_ORIGIN=$(jq -r '.gitExplorerOrigin // empty' "$CONFIG")
                ;;
                "gitUseSsh")
                    local USE_SSH=$(jq -r '.gitUseSsh' "$CONFIG")
                    if [[ "$USE_SSH" == "true" ]]; then
                        GIT_USE_SSH="Y"
                    fi
                ;;
                "licenseName")
                    LICENSE_NAME=$(jq -r '.licenseName // empty' "$CONFIG")
                ;;
                "licenseEmail")
                    LICENSE_EMAIL=$(jq -r '.licenseEmail // empty' "$CONFIG")
                ;;
            esac
        done
    fi

    post_args_process

    CONFIG_PROCESSED="Y"
}

post_args_process()
{
    if [ "$CLI_ALIAS" == "TOKEN" ]; then
        CORE_ALIAS="$TOKEN"
    else
        CORE_ALIAS="$CHAIN_NAME"
    fi

    CORE_ALIAS=$(echo $CORE_ALIAS | tr -cs '[:alnum:]\r\n' '-' | tr '[:upper:]' '[:lower:]')

    LOCAL_EXPLORER_IP="$EXPLORER_IP"
    LOCAL_EXPLORER_PORT=$(echo "$EXPLORER_PORT" | sed 's/[^0-9]//g')
    if [ -z "$LOCAL_EXPLORER_IP" ]; then
        LOCAL_EXPLORER_IP="0.0.0.0"
    fi
    if [ -z "$LOCAL_EXPLORER_PORT" ]; then
        LOCAL_EXPLORER_PORT="4200"
    fi
    EXPLORER_URL="http://$LOCAL_EXPLORER_IP:$LOCAL_EXPLORER_PORT"
}

parse_generic_args()
{
    ARGS="$@"
    HAS_JSON_CONFIG="N"

    while [[ $# -ne 0 ]] ; do
        case $1 in
            "--config")
                CONFIG="$2"
                HAS_JSON_CONFIG="Y"
            ;;
        esac
        shift
    done

    if [ "$HAS_JSON_CONFIG" == "Y" ]; then
        parse_json_config
    elif [[ -d "$XDG_CONFIG_HOME/deployer" && -f "$XDG_CONFIG_HOME/deployer/.env" ]]; then
        export $(grep -v '^#' "$XDG_CONFIG_HOME/deployer/.env" | xargs)
    fi

    set -- $ARGS
    while [[ $# -ne 0 ]] ; do
        case $1 in
            "--name")
                local CHANGE_DATABASE="N"
                if [[ "$DATABASE_NAME" == "core_$CHAIN_NAME" ]]; then
                    CHANGE_DATABASE="Y"
                fi
                CHAIN_NAME=$(echo $2 | tr -cs '[:alnum:]\r\n' '-')
                if [ "$CHANGE_DATABASE" == "Y" ]; then
                    DATABASE_NAME="core_$CHAIN_NAME"
                fi
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
            "--cli-alias")
                CLI_ALIAS="$2"
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
            "--git-commit")
                if [[ $METHOD == "install-core" ]]; then
                    GIT_CORE_COMMIT="Y"
                elif [[ $METHOD == "install-explorer" ]]; then
                    GIT_EXPLORER_COMMIT="Y"
                fi
            ;;
            "--git-origin")
                if [[ $METHOD == "install-core" ]]; then
                    GIT_CORE_ORIGIN="$2"
                elif [[ $METHOD == "install-explorer" ]]; then
                    GIT_EXPLORER_ORIGIN="$2"
                fi
            ;;
            "--git-use-ssh")
                GIT_USE_SSH="Y"
            ;;
            "--license-name")
                LICENSE_NAME="$2"
            ;;
            "--license-email")
                LICENSE_EMAIL="$2"
            ;;
            ## Starting options
            "--network")
                NETWORK="$2"
            ;;
        esac
        shift
    done

    post_args_process

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
                EXPLORER_PATH_RAW="$2"
                EXPLORER_PATH=$(eval echo "$EXPLORER_PATH_RAW")
            ;;
            "--core-ip")
                CORE_IP="$2"
                if [ "$CORE_IP" == "127.0.0.1" ]; then
                    CORE_IP=$(get_ip)
                fi
            ;;
            "--core-port")
                API_PORT="$2"
            ;;
        esac
        shift
    done

    write_args_env
}

parse_core_args()
{
    if [[ "$ARGS_PROCESSED" == "Y" ]]; then
        return 0
    fi

    parse_generic_args "$@"

    while [[ $# -ne 0 ]] ; do
        case "$1" in
            "--path")
                BRIDGECHAIN_PATH_RAW="$2"
                BRIDGECHAIN_PATH=$(eval echo "$BRIDGECHAIN_PATH_RAW")
            ;;
            "--database")
                DATABASE_NAME="$2"
            ;;
            "--p2p-port")
                P2P_PORT="$2"
            ;;
            "--api-port")
                API_PORT="$2"
            ;;
            "--webhook-port")
                WEBHOOK_PORT="$2"
            ;;
            "--json-rpc-port")
                JSON_RPC_PORT="$2"
            ;;
            "--symbol")
                SYMBOL="$2"
            ;;
            "--mainnet-peers")
                MAINNET_PEERS="$2"
            ;;
            "--devnet-peers")
                DEVNET_PEERS="$2"
            ;;
            "--mainnet-prefix")
                MAINNET_PREFIX="$2"
            ;;
            "--devnet-prefix")
                DEVNET_PREFIX="$2"
            ;;
            "--testnet-prefix")
                TESTNET_PREFIX="$2"
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
            "--vendorfield-length")
                VENDORFIELD_LENGTH="$2"
            ;;
            "--total-premine")
                TOTAL_PREMINE="$2"
            ;;
            "--force-network-start")
                FORCE_NETWORK_START="Y"
            ;;
            "--no-autoforger")
                AUTO_FORGER="N"
            ;;
            ## Static Fees
            "--fee-static-transfer")
                FEE_STATIC_TRANSFER="$2"
            ;;
            "--fee-static-vote")
                FEE_STATIC_VOTE="$2"
            ;;
            "--fee-static-second-signature")
                FEE_STATIC_SECOND_SIGNATURE="$2"
            ;;
            "--fee-static-delegate-registration")
                FEE_STATIC_DELEGATE_REGISTRATION="$2"
            ;;
            "--fee-static-multisig-registration")
                FEE_STATIC_MULTISIG_REGISTRATION="$2"
            ;;
            ## Dynamic Fees
            "--fee-dynamic-enabled")
                FEE_DYNAMIC_ENABLED="Y"
            ;;
            "--fee-dynamic-pool-min-fee")
                FEE_DYNAMIC_POOL_MIN_FEE="$2"
            ;;
            "--fee-dynamic-broadcast-min-fee")
                FEE_DYNAMIC_BROADCAST_MIN_FEE="$2"
            ;;
            "--fee-dynamic-bytes-transfer")
                FEE_DYNAMIC_BYTES_TRANSFER="$2"
            ;;
            "--fee-dynamic-bytes-second-signature")
                FEE_DYNAMIC_BYTES_SECOND_SIGNATURE="$2"
            ;;
            "--fee-dynamic-bytes-delegate-registration")
                FEE_DYNAMIC_BYTES_DELEGATE_REGISTRATION="$2"
            ;;
            "--fee-dynamic-bytes-vote")
                FEE_DYNAMIC_BYTES_VOTE="$2"
            ;;
            "--fee-dynamic-bytes-multisig-registration")
                FEE_DYNAMIC_BYTES_MULTISIG_REGISTRATION="$2"
            ;;
            "--fee-dynamic-bytes-ipfs")
                FEE_DYNAMIC_BYTES_IPFS="$2"
            ;;
            "--fee-dynamic-bytes-htlc-lock")
                FEE_DYNAMIC_BYTES_HTLC_LOCK="$2"
            ;;
            "--fee-dynamic-bytes-htlc-claim")
                FEE_DYNAMIC_BYTES_HTLC_CLAIM="$2"
            ;;
            "--fee-dynamic-bytes-multipayment")
                FEE_DYNAMIC_BYTES_MULTIPAYMENT="$2"
            ;;
            "--fee-dynamic-bytes-delegate-resignation")
                FEE_DYNAMIC_BYTES_DELEGATE_RESIGNATION="$2"
            ;;
        esac
        shift
    done

    write_args_env
}

write_args_env()
{
    if [ ! -d "$XDG_CONFIG_HOME/deployer" ]; then
        mkdir -p "$XDG_CONFIG_HOME/deployer"
    fi

    rm -f "$XDG_CONFIG_HOME/deployer/.env"
    cat > "$XDG_CONFIG_HOME/deployer/.env" <<- EOF
BRIDGECHAIN_PATH="$BRIDGECHAIN_PATH"
EXPLORER_PATH="$EXPLORER_PATH"
CHAIN_NAME="$CHAIN_NAME"
TOKEN="$TOKEN"
CORE_ALIAS="$CORE_ALIAS"
CLI_ALIAS="$CLI_ALIAS"
DATABASE_HOST="$DATABASE_HOST"
DATABASE_PORT="$DATABASE_PORT"
DATABASE_NAME="$DATABASE_NAME"
CORE_IP="$CORE_IP"
P2P_PORT="$P2P_PORT"
API_PORT="$API_PORT"
WEBHOOK_PORT="$WEBHOOK_PORT"
JSON_RPC_PORT="$JSON_RPC_PORT"
EXPLORER_IP="$EXPLORER_IP"
EXPLORER_PORT="$EXPLORER_PORT"
EXPLORER_URL="$EXPLORER_URL"
SYMBOL="$SYMBOL"
MAINNET_PEERS="$MAINNET_PEERS"
DEVNET_PEERS="$DEVNET_PEERS"
MAINNET_PREFIX="$MAINNET_PREFIX"
DEVNET_PREFIX="$DEVNET_PREFIX"
TESTNET_PREFIX="$TESTNET_PREFIX"
INSTALL_DEPS="$INSTALL_DEPS"
SKIP_DEPS="$SKIP_DEPS"
INTERACTIVE="$INTERACTIVE"
FEE_STATIC_TRANSFER="$FEE_STATIC_TRANSFER"
FEE_STATIC_VOTE="$FEE_STATIC_VOTE"
FEE_STATIC_SECOND_SIGNATURE="$FEE_STATIC_SECOND_SIGNATURE"
FEE_STATIC_DELEGATE_REGISTRATION="$FEE_STATIC_DELEGATE_REGISTRATION"
FEE_STATIC_MULTISIG_REGISTRATION="$FEE_STATIC_MULTISIG_REGISTRATION"
FEE_DYNAMIC_ENABLED="$FEE_DYNAMIC_ENABLED"
FEE_DYNAMIC_POOL_MIN_FEE="$FEE_DYNAMIC_POOL_MIN_FEE"
FEE_DYNAMIC_BROADCAST_MIN_FEE="$FEE_DYNAMIC_BROADCAST_MIN_FEE"
FEE_DYNAMIC_BYTES_TRANSFER="$FEE_DYNAMIC_BYTES_TRANSFER"
FEE_DYNAMIC_BYTES_SECOND_SIGNATURE="$FEE_DYNAMIC_BYTES_SECOND_SIGNATURE"
FEE_DYNAMIC_BYTES_DELEGATE_REGISTRATION="$FEE_DYNAMIC_BYTES_DELEGATE_REGISTRATION"
FEE_DYNAMIC_BYTES_VOTE="$FEE_DYNAMIC_BYTES_VOTE"
FEE_DYNAMIC_BYTES_MULTISIG_REGISTRATION="$FEE_DYNAMIC_BYTES_MULTISIG_REGISTRATION"
FEE_DYNAMIC_BYTES_IPFS="$FEE_DYNAMIC_BYTES_IPFS"
FEE_DYNAMIC_BYTES_HTLC_LOCK="$FEE_DYNAMIC_BYTES_HTLC_LOCK"
FEE_DYNAMIC_BYTES_HTLC_CLAIM="$FEE_DYNAMIC_BYTES_HTLC_CLAIM"
FEE_DYNAMIC_BYTES_MULTIPAYMENT="$FEE_DYNAMIC_BYTES_MULTIPAYMENT"
FEE_DYNAMIC_BYTES_DELEGATE_RESIGNATION="$FEE_DYNAMIC_BYTES_DELEGATE_RESIGNATION"
FORGERS="$FORGERS"
BLOCK_TIME="$BLOCK_TIME"
TXS_PER_BLOCK="$TXS_PER_BLOCK"
TOTAL_PREMINE="$TOTAL_PREMINE"
REWARD_HEIGHT_START="$REWARD_HEIGHT_START"
REWARD_PER_BLOCK="$REWARD_PER_BLOCK"
VENDORFIELD_LENGTH="$VENDORFIELD_LENGTH"
ARGS_PROCESSED="$ARGS_PROCESSED"
CONFIG_PROCESSED="$CONFIG_PROCESSED"
AUTO_FORGER="$AUTO_FORGER"
FORCE_NETWORK_START="$FORCE_NETWORK_START"
NETWORK="$NETWORK"
GIT_CORE_COMMIT="$GIT_CORE_COMMIT"
GIT_CORE_ORIGIN="$GIT_CORE_ORIGIN"
GIT_EXPLORER_COMMIT="$GIT_EXPLORER_COMMIT"
GIT_EXPLORER_ORIGIN="$GIT_EXPLORER_ORIGIN"
GIT_USE_SSH="$GIT_USE_SSH"
LICENSE_NAME="$LICENSE_NAME"
LICENSE_EMAIL="$LICENSE_EMAIL"
EOF
}
