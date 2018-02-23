![ARK-DESKTOP](https://user-images.githubusercontent.com/8069294/35097070-78c0dc40-fc46-11e7-9bb0-ad36f7182f39.png)

## Installation

```bash
git clone https://github.com/ArkEcosystem/ark-deployer.git && cd ark-deployer
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
source ~/.profile
nvm install 8.9.1
sudo apt-get install -y jq
```

## Guide

Follow this [full guide](https://blog.ark.io/ark-deployer-setup-guide-c10825ebb0e4) to get the best out of your Bridgechain.

### Node

*Note: Change <MACHINE_IP> to your Machine's IP*

```bash
./sidechain.sh install-node --name MyTest --database ark_mytest --token MYTEST --symbol MT --node-ip <NODE_IP>
./sidechain.sh start-node --name MyTest
```

#### Optional Parameters

    --path - Path to install Side Chain [/home/$USER/ark-sidechain]
    --name - Name of Side Chain [sidechain]
    --database - Database Name [ark_sidechain]
    --node-ip - IP for node [0.0.0.0]
    --node-port - Port for node [4100]
    --explorer-ip - IP for explorer [127.0.0.1]
    --explorer-port - Port for explorer [4200]
    --token - Token Name [MINE]
    --symbol - Symbol for Token [M]
    --prefix - Address Prefix [M]
    --forgers - How many forgers for the network [51]
    --max-votes - Max Votes per Wallet [1]
    --blocktime - Time per block (seconds) [8]
    --transactions-per-block - Max Transaciton count per Block [50]
    --reward-height-start - Block Height when Forgers receive Rewards [75600]
    --reward-per-block - How many Rewarded Tokens per Forged Block [200000000 (2)]
    --total-premine - How many tokens initially added to genesis account [2100000000000000 (21 million)]
    --max-tokens-per-account - Max amount of tokens per account [12500000000000000 (125 million)]
    --config - Path to JSON config file for install options (see below section for more information)
    --autoinstall-deps - Automatically instal dependencies without prompt
    --skip-deps - Skips check for installing dependencies

*Note: Below Parameters do not work with standard wallets (with hardcoded values)*

    --fee-send - Fee for sending Transaction [10000000 (0.1)]
    --fee-vote - Fee for Vote Transaction [100000000 (1)]
    --fee-second-passphrase - Fee for Second Passphrase Transaction [500000000 (5)]
    --fee-delegate - Fee for Register Delegate Transaction [2500000000 (25)]
    --fee-multisig - Fee for Multisignature Transaction [500000000 (5)]
    --update-epoch - Set Epoch based on time the chain was created

### Explorer

*Note: Change <MACHINE_IP> to your Machine's IP*

```bash
./sidechain.sh install-explorer --name MyTest --token MYTEST --explorer-ip <EXPLORER_IP> --node-ip <NODE_IP>
./sidechain.sh start-explorer
```

#### Optional Parameters

    --path - Path to install Explorer [/home/$USER/ark-explorer]
    --name - Name of Side Chain [sidechain]
    --node-ip - IP for node [0.0.0.0]
    --node-port - Port for node [4100]
    --explorer-ip - IP for explorer [127.0.0.1]
    --explorer-port - Port for explorer [4200]
    --token - Token Name [MINE]
    --forgers - How many forgers for the network [51]
    --config - Path to JSON config file for install options (see below section for more information)
    --autoinstall-deps - Automatically instal dependencies without prompt
    --skip-deps - Skips check for installing dependencies

## JSON Config

As mentioned in the parameters list, it's possible to pass in a JSON config file to load all properties, although they're not all required. For a full sample file, take a look [here](config.sample.json). For a small sample, see below:

```json
{
    "nodeIp": "localhost",
    "nodePort": 4100,
    "explorerIp": "1.2.3.4",
    "explorerPort": 4200
}
```

## Vagrant

Deploy a sidechain and explorer within its own Vagrant setup. This requires vagrant version 2 and up.

```bash
git clone https://github.com/ArkEcosystem/ark-deployer.git && cd ark-deployer
vagrant up
```

Vagrant will then reboot. Once finished, wait a further minute or so and you can access the Node and Explorer using the below URLs:

Node API (port forwarded): `http://127.0.0.1:14100/api/`
Explorer (port forwarded): `http://127.0.0.1:14200/`

## Credits

- [Alex Barnsley](https://github.com/alexbarnsley)
- [Brian Faust](https://github.com/faustbrian)
- [All Contributors](../../contributors)

## License

ARK Deployer is licensed under the MIT License - see the [LICENSE](./LICENSE.md) file for details.
