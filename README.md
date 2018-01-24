![ARK-DESKTOP](https://user-images.githubusercontent.com/8069294/35097070-78c0dc40-fc46-11e7-9bb0-ad36f7182f39.png)

## Installation

```bash
git clone https://github.com/ArkEcosystem/ark-deployer.git && cd ark-deployer
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
source ~/.profile
nvm install 8.9.1
sudo apt-get install -y jq
```

### Node

*Note: Change <MACHINE_IP> to your Machine's IP*

```bash
./sidechain.sh install-node --name MyTest --database ark_mytest --token MYTEST --symbol MT --ip <MACHINE_IP>
./sidechain.sh start-node --name MyTest
```

#### Optional Parameters

	- --path - Path to install Side Chain [/home/$USER/ark-sidechain]
	- --name - Name of Side Chain [sidechain]
	- --database - Database Name [ark_sidechain]
	- --ip - IP for node [localhost] *Only useful for Explorer*
	- --token - Token Name [MINE]
    - --symbol - Symbol for Token [M]
    - --prefix - Address Prefix [M]
    - --fee-send - Fee for sending Transaction [0.10000000 (1)]
    - --fee-vote - Fee for Vote Transaction [100000000 (1)]
    - --fee-second-passphrase - Fee for Second Passphrase Transaction [500000000 (5)]
    - --fee-delegate - Fee for Register Delegate Transaction [2500000000 (25)]
    - --fee-multisig - Fee for Multisignature Transaction [500000000 (5)]
    - --forgers - How many forgers for the network [51]
    - --max-votes - Max Votes per Wallet [1]
    - --blocktime - Time per block (seconds) [8]
    - --transactions-per-block - Max Transaciton count per Block [50]
    - --reward-height-start - Block Height when Forgers receive Rewards [75600]
    - --reward-per-block - How many Rewarded Tokens per Forged Block [200000000 (2)]
	- --skip-deps - Skips check for installing dependencies

### Explorer

*Note: Change <MACHINE_IP> to your Machine's IP*

```bash
./sidechain.sh install-explorer --name MyTest --token MYTEST --ip <MACHINE_IP>
./sidechain.sh start-explorer
```

#### Optional Parameters

	- --path - Path to install Explorer [/home/$USER/ark-explorer]
	- --name - Name of Side Chain [sidechain]
	- --ip - IP for Explorer to run on [localhost]
	- --token - Token Name [MINE]
    - --forgers - How many forgers for the network [51]
	- --skip-deps - Skips check for installing dependencies

## Vagrant

Deploy a sidechain and explorer within its own Vagrant setup.

```bash
git clone https://github.com/ArkEcosystem/ark-deployer.git && cd ark-deployer
vagrant up
```

Vagrant will then reboot. Once finished, wait a further minute or so and you can access the Node and Explorer using the below URLs:

Node API: `http://192.168.33.10:4100/api/`
Explorer: `http://192.168.33.10:4200/`

## Credits

- [Alex Barnsley](https://github.com/alexbarnsley)
- [Brian Faust](https://github.com/faustbrian)
- [All Contributors](../../contributors)

## License

ARK Deployer is licensed under the MIT License - see the [LICENSE](./LICENSE.md) file for details.
