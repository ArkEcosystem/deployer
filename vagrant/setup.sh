## Update and Install Initial Packages
sudo apt-get update && sudo apt-get install -y jq git curl

## Install NodeJS & NPM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 8.9.1

## Link Codebase
ln -s /vagrant ~/ark-deployer

## Install Node & Explorer with Dependencies
cd ~/ark-deployer
echo -e 'yes\nyes\n' | ./sidechain.sh install-node --name MyTest --database ark_mytest --token MYTEST --symbol MT --ip 192.168.33.10
./sidechain.sh install-explorer --name MyTest --token MYTEST --ip 192.168.33.10 --skip-deps

## Setup scripts to run at startup
cat > ~/startup.sh <<- EOS
#!/bin/bash -l
export PATH=/home/vagrant/bin:/home/vagrant/.local/bin:/home/vagrant/.nvm/versions/node/v8.9.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
~/ark-deployer/sidechain.sh start-node --name MyTest &>> ~/node.log &
~/ark-deployer/sidechain.sh start-explorer &>> ~/explorer.log &
EOS
chmod u+x ~/startup.sh

echo '@reboot sleep 10; sudo mount -t vboxsf -o ro vagrant /vagrant &>> ~/mount.log' > ~/cron.sh
echo '@reboot sleep 15; env USER=$LOGNAME ~/startup.sh' >> ~/cron.sh
crontab ~/cron.sh
rm ~/cron.sh
sudo reboot
