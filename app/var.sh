#!/usr/bin/env bash

BRIDGECHAIN_PATH="/home/$USER/ark-bridgechain"
EXPLORER_PATH="/home/$USER/ark-explorer"
CHAIN_NAME="bridgechain"
DATABASE_NAME="ark_$CHAIN_NAME"
NODE_IP="0.0.0.0"
NODE_PORT="4100"
EXPLORER_IP="127.0.0.1"
EXPLORER_PORT="4200"
TOKEN="MINE"
SYMBOL="M"
PREFIX="M"
INSTALL_DEPS="N"
SKIP_DEPS="N"

## Constants
## Fees
FEE_SEND=10000000
FEE_VOTE=100000000
FEE_SECOND_PASSPHRASE=500000000
FEE_DELEGATE=2500000000
FEE_MULTISIG=500000000

## Forging Delegates
FORGERS=51

## Vote per Wallet
MAX_VOTES=1

## Block time (seconds)
BLOCK_TIME=8

## Max Transactions per Block
TXS_PER_BLOCK=50

## Total Premined Tokens
TOTAL_PREMINE=2100000000000000

## Max Tokens per Account
MAX_TOKENS_PER_ACCOUNT=12500000000000000

## Whether to update epoch time for bridgechain
UPDATE_EPOCH="N"

## Rewards
## Start Block Height
REWARD_HEIGHT_START=75600

## ARK reward per Block
REWARD_PER_BLOCK=200000000

## Flag to indicate if args has been processed
ARGS_PROCESSED="N"

## Flag to indicate if JSON config has been processed
CONFIG_PROCESSED="N"
