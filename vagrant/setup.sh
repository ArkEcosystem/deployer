############################
#   ARK Deployer Vagrant   #
############################

## Config
CHAIN_NAME="MyTest"
DATABASE_NAME="ark_mytest"
TOKEN_NAME="MYTEST"
SYMBOL="MT"
NODE_IP="192.168.33.10"
NODE_PORT="4100"
EXPLORER_IP="192.168.33.10"
EXPLORER_PORT="4200"
TOKEN_PREFIX="T"
FEE_SEND=10000000
FEE_VOTE=100000000
FEE_SECOND_PASSPHRASE=500000000
FEE_DELEGATE=2500000000
FEE_MULTISIG=500000000
FORGERS=5
MAX_VOTES=1
BLOCK_TIME=16
TXS_PER_BLOCK=500
REWARD_HEIGHT_START=0
REWARD_PER_BLOCK=200000000
TOTAL_PREMINE=2100000000000000

## Update and Install Initial Packages
sudo apt-get update && sudo apt-get install -y jq git curl

## Install NodeJS & NPM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 8.9.1

## Link Codebase
if [[ ! -d ~/ark-deployer/ ]]; then
    ln -s /vagrant ~/ark-deployer
fi

## Install Node & Explorer with Dependencies
cd ~/ark-deployer
./sidechain.sh install-node --name "$CHAIN_NAME" \
                            --database "$DATABASE_NAME" \
                            --token "$TOKEN_NAME" \
                            --symbol "$SYMBOL" \
                            --prefix "$TOKEN_PREFIX" \
                            --fee-send "$FEE_SEND" \
                            --fee-vote "$FEE_VOTE" \
                            --fee-second-passphrase "$FEE_SECOND_PASSPHRASE" \
                            --fee-delegate "$FEE_DELEGATE" \
                            --fee-multisig "$FEE_MULTISIG" \
                            --forgers "$FORGERS" \
                            --max-votes "$MAX_VOTES" \
                            --blocktime "$BLOCK_TIME" \
                            --transactions-per-block "$TXS_PER_BLOCK" \
                            --reward-height-start "$REWARD_HEIGHT_START" \
                            --reward-per-block "$REWARD_PER_BLOCK" \
                            --total-premine "$TOTAL_PREMINE" \
                            --node-ip "$NODE_IP" \
                            --node-port "$NODE_PORT" \
                            --autoinstall-deps
./sidechain.sh install-explorer --name "$CHAIN_NAME" \
                                --token "$TOKEN_NAME" \
                                --node-ip "$NODE_IP" \
                                --node-port "$NODE_PORT" \
                                --explorer-ip "$EXPLORER_IP" \
                                --explorer-port "$EXPLORER_PORT" \
                                --forgers "$FORGERS" \
                                --skip-deps

## Setup scripts to run at startup
cat > ~/startup.sh <<- EOS
#!/bin/bash -l
export PATH=/home/vagrant/bin:/home/vagrant/.local/bin:/home/vagrant/.nvm/versions/node/v8.9.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
~/ark-deployer/sidechain.sh start-node --name "$CHAIN_NAME" &>> ~/node.log &
~/ark-deployer/sidechain.sh start-explorer &>> ~/explorer.log &
EOS
chmod u+x ~/startup.sh

echo '@reboot sleep 10; sudo mount -t vboxsf -o ro vagrant /vagrant &>> ~/mount.log' > ~/cron.sh
echo '@reboot sleep 15; env USER=$LOGNAME ~/startup.sh' >> ~/cron.sh
crontab ~/cron.sh
rm ~/cron.sh
echo 'Rebooting Vagrant Machine - check back in a few minutes on the below:'
echo "  Node API: http://127.0.0.1:14100/api/"
echo "  Explorer: http://127.0.0.1:14200/"
sudo reboot
