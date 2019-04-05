#!/usr/bin/env bash

ROOT_PATH=$(cd "$(dirname $(dirname "${BASH_SOURCE[0]}"))" >/dev/null 2>&1 && pwd)
BRIDGECHAIN_PATH="/home/$USER/core-bridgechain"
EXPLORER_PATH="/home/$USER/core-explorer"
CHAIN_NAME="bridgechain"
DATABASE_HOST="localhost"
DATABASE_PORT="5432"
DATABASE_NAME="core_$CHAIN_NAME"
CORE_IP="0.0.0.0"
P2P_PORT="4102"
API_PORT="4103"
WEBHOOK_PORT="4104"
JSON_RPC_PORT="8080"
EXPLORER_IP="127.0.0.1"
EXPLORER_PORT="4200"
TOKEN="MINE"
SYMBOL="M"
MAINNET_PEERS=""
DEVNET_PEERS=""
MAINNET_PREFIX="M"
DEVNET_PREFIX="D"
TESTNET_PREFIX="T"
INSTALL_DEPS="N"
SKIP_DEPS="N"
INTERACTIVE="Y"
PEER_INSTALL="N"
if [[ $METHOD == "install-explorer" ]]; then
    CORE_IP="127.0.0.1"
    EXPLORER_IP="0.0.0.0"
fi

## Constants
## Fees - Static
FEE_STATIC_TRANSFER=10000000
FEE_STATIC_VOTE=100000000
FEE_STATIC_SECOND_SIGNATURE=500000000
FEE_STATIC_DELEGATE_REGISTRATION=2500000000
FEE_STATIC_MULTISIG_REGISTRATION=500000000

## Fees - Dynamic
FEE_DYNAMIC_ENABLED="N"
FEE_DYNAMIC_POOL_MIN_FEE=3000
FEE_DYNAMIC_BROADCAST_MIN_FEE=3000
FEE_DYNAMIC_BYTES_TRANSFER=100
FEE_DYNAMIC_BYTES_SECOND_SIGNATURE=250
FEE_DYNAMIC_BYTES_DELEGATE_REGISTRATION=400000
FEE_DYNAMIC_BYTES_VOTE=100
FEE_DYNAMIC_BYTES_MULTISIG_REGISTRATION=500
FEE_DYNAMIC_BYTES_IPFS=250
FEE_DYNAMIC_BYTES_TIMELOCK_TRANSFER=500
FEE_DYNAMIC_BYTES_MULTIPAYMENT=500
FEE_DYNAMIC_BYTES_DELEGATE_RESIGNATION=400000

## Forging Delegates
FORGERS=51

## Block time (seconds)
BLOCK_TIME=8

## Max Transactions per Block
TXS_PER_BLOCK=150

## Total Premined Tokens
TOTAL_PREMINE=2100000000000000

## Rewards
## Start Block Height
REWARD_HEIGHT_START=75600

## ARK reward per Block
REWARD_PER_BLOCK=200000000

## Flag to indicate if args has been processed
ARGS_PROCESSED="N"

## Flag to indicate if JSON config has been processed
CONFIG_PROCESSED="N"

## Start core options
AUTO_FORGER="Y"
FORCE_NETWORK_START="N"
NETWORK=""

## Git
GIT_CORE_COMMIT="N"
GIT_CORE_ORIGIN=""
GIT_EXPLORER_COMMIT="N"
GIT_EXPLORER_ORIGIN=""

## License
LICENSE_NAME=""
LICENSE_EMAIL=""
