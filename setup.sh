#!/bin/bash

curl -sL https://deb.nodesource.com/setup_11.x | sudo bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install -y nodejs yarn jq

if [[ -f ~/.profile ]]; then
    echo "export PATH=\"\$PATH:\$(yarn global bin)\"" >> ~/.profile
    source ~/.profile
elif [ -f ~/.bash_profile ]; then
    echo "export PATH=\"\$PATH:\$(yarn global bin)\"" >> ~/.bash_profile
    source ~/.bash_profile
fi
