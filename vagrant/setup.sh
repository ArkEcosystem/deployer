############################
#   ARK Deployer Vagrant   #
############################

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

## Config
CONFIG_PATH="/vagrant/vagrant/config.json"
CHAIN_NAME=$(cat "$CONFIG_PATH" | jq -r '.chainName')

## Install Node & Explorer with Dependencies
cd ~/ark-deployer
./sidechain.sh install-node --config "$CONFIG_PATH" --autoinstall-deps
./sidechain.sh install-explorer --config "$CONFIG_PATH" --skip-deps

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
