############################
#   ARK Deployer Vagrant   #
############################

## Remount /vagrant as Read/Write
sudo mount -o remount,rw /vagrant/vagrant /vagrant

## Update and Install Initial Packages
sudo apt-get update && sudo apt-get install -y jq git curl software-properties-common

## Install NodeJS & NPM
curl -sL https://deb.nodesource.com/setup_11.x | sudo bash -
sudo apt-get update && sudo apt-get install nodejs

## Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install -y yarn

## Link Codebase
if [[ ! -d ~/ark-deployer/ ]]; then
    ln -s /vagrant ~/ark-deployer
fi

## Config
CONFIG_PATH="/vagrant/vagrant/config.json"
CHAIN_NAME=$(jq -r '.chainName' "$CONFIG_PATH")

## Install Core & Explorer with Dependencies
cd ~/ark-deployer
./bridgechain.sh install-core --config "$CONFIG_PATH" --autoinstall-deps --non-interactive
./bridgechain.sh install-explorer --config "$CONFIG_PATH" --skip-deps --non-interactive

## Setup startup and login scripts
cat >> ~/.profile <<- EOS
export PATH="/home/vagrant/bin:/home/vagrant/.local/bin:/home/vagrant/.yarn/bin:\$PATH"
EOS

cat > ~/startup.sh <<- EOS
#!/bin/bash -l
#export PATH="/home/vagrant/bin:/home/vagrant/.local/bin:/home/vagrant/.yarn/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
~/ark-deployer/bridgechain.sh start-core --network "testnet" &>> ~/core.log &
~/ark-deployer/bridgechain.sh start-explorer --network "testnet" &>> ~/explorer.log &
EOS
chmod u+x ~/startup.sh

echo '@reboot sleep 10; sudo mount -t vboxsf -o ro vagrant /vagrant &>> ~/mount.log' > ~/cron.sh
echo '@reboot sleep 15; env USER=$LOGNAME ~/startup.sh' >> ~/cron.sh
crontab ~/cron.sh
rm ~/cron.sh

API_PORT=$(jq -r '.apiPort' "$CONFIG_PATH")
P2P_PORT=$(jq -r '.p2pPort' "$CONFIG_PATH")
EXPLORER_PORT=$(jq -r '.explorerPort' "$CONFIG_PATH")

echo 'Rebooting Vagrant Machine - check back in a few minutes on the below:'
echo "  Core P2P API: http://192.168.33.10:$P2P_PORT/"
echo "  Core Public API: http://192.168.33.10:$API_PORT/"
echo "  Explorer: http://192.168.33.10:$EXPLORER_PORT/"
sudo reboot
