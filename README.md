![ARK-DESKTOP](https://user-images.githubusercontent.com/8069294/53840292-a86c7a00-3f91-11e9-93a7-3777a786acf5.png)

## Quick setup with Vagrant
Deploy a bridgechain and explorer within its own Vagrant setup. This requires vagrant version 2 and up.

1. Install Vagrant on your local computer
2. Clone the ark-deployer from our repository
```bash
git clone https://github.com/ArkEcosystem/deployer.git ark-deployer && cd ark-deployer
```
3. Run the vagrant command
```bash
vagrant up
```

Vagrant will then reboot. Once finished, wait a further minute or so and you can access the Core and Explorer using the below URLs:

Core P2P API: `http://192.168.33.10:4102/`

Core Public API: `http://192.168.33.10:4103/`

Explorer: `http://192.168.33.10:4200/`

## Manual installation

### Prerequisites

- User running the deployer commands must has sudo access

### Setup

```bash
sudo apt-get update && sudo apt-get install -y git curl
git clone https://github.com/ArkEcosystem/deployer.git ark-deployer && cd ark-deployer
source setup.sh
```

#### Core Installation

*Note: Change <MACHINE_IP> to your Machine's IP. You can also set to "0.0.0.0" to run on all IPs (recommended)*

```bash
./bridgechain.sh install-core --name MyTest --database-name core_mytest --token MYTEST --symbol MT --core-ip <MACHINE_IP>
./bridgechain.sh start-core --network testnet
```

##### Optional Parameters

###### Database

    --database-host - Database Host [localhost]
    --database-port - Database Port [5432]
    --database-name - Database Name [core_bridgechain]

###### Bridgechain Config

    --config - Path to JSON config file for install (see below section for more information)
    --path - Path to install Bridgechain [/home/$USER/core-bridgechain]
    --name - Name of Bridgechain [bridgechain]
    --core-ip - IP for core [0.0.0.0]
    --p2p-port - Port for p2p API [4102]
    --api-port - Port for Public API [4103]
    --webhook-port - Port for webhook API [4104]
    --json-rpc-port - Port for JSON RPC API [8080]
    --mainnet-peers - Comma separated list of additional mainnet peers
    --devnet-peers - Comma separated list of additional devnet peers
    --testnet-peers - Comma separated list of additional testnet peers
    --mainnet-prefix - Mainnet Address Prefix [M]
    --devnet-prefix - Devnet Address Prefix [D]
    --testnet-prefix - Testnet Address Prefix [T]
    --token - Token Name [MINE]
    --symbol - Symbol for Token [M]
    --forgers - How many forgers for the network [51]
    --blocktime - Time per block (seconds) [8]
    --transactions-per-block - Max Transaction count per Block [150]
    --reward-height-start - Block Height when Forgers receive Rewards [75600]
    --reward-per-block - How many Rewarded Tokens per Forged Block [200000000 (2)]
    --total-premine - How many tokens initially added to genesis account [2100000000000000 (21 million)]
    --explorer-ip - IP for explorer [127.0.0.1]
    --explorer-port - Port for explorer [4200]

###### Static Fees

    --fee-static-transfer - Fee for sending Transaction [10000000 (0.1)]
    --fee-static-vote - Fee for Vote Transaction [100000000 (1)]
    --fee-static-second-signature - Fee for Second Passphrase Transaction [500000000 (5)]
    --fee-static-delegate-registration - Fee for Register Delegate Transaction [2500000000 (25)]
    --fee-static-multisig-registration - Fee for Multisignature Transaction [500000000 (5)]

###### Dynamic Fees ([more information](https://blog.ark.io/towards-flexible-marketplace-with-ark-dynamic-fees-running-on-new-core-31f1aaf1e867))

    --fee-dynamic-enabled - Enable Dynamic Fees
    --fee-dynamic-pool-min-fee - Minimum fee for transaction pool to accept [3000]
    --fee-dynamic-broadcast-min-fee - Minimum fee for transaction to be broadcast on the network [3000]
    --fee-dynamic-bytes-transfer - Adjust fee calculation for transfer transaction with additional bytes [100]
    --fee-dynamic-bytes-second-signature - Adjust fee calculation for transfers with additional bytes [250]
    --fee-dynamic-bytes-delegate-registration - Adjust fee calculation for delegate registrations with additional bytes [400000]
    --fee-dynamic-bytes-vote - Adjust fee calculation for votes with additional bytes [100]
    --fee-dynamic-bytes-multisig-registration - Adjust fee calculation for multisig registrations with additional bytes [500]
    --fee-dynamic-bytes-ipfs - Adjust fee calculation for IPFS transactions with additional bytes [250]
    --fee-dynamic-bytes-timelock-transfer - Adjust fee calculation for timelock transfers with additional bytes [500]
    --fee-dynamic-bytes-multipayment - Adjust fee calculation for multi-payments with additional bytes [500]
    --fee-dynamic-bytes-delegate-resignation - Adjust fee calculation for delegate resignations with additional bytes [400000]

###### Generic

    --git-commit - Commit changes to core on a new branch
    --git-origin - Set git origin and attempt to push changes
    --license-name - The name to appear in the License below "Ark Ecosystem"
    --license-email - The email address associated with the licensed name
    --autoinstall-deps - Automatically install dependencies without prompt
    --skip-deps - Skips check for installing dependencies
    --no-autoforger - Forces core to run in "normal" mode, without last height checks or network start mode
    --force-network-start - Force network to start in genesis-block mode (not recommended unless you know what you're doing)

#### Explorer Installation

*Note: Change <MACHINE_IP> to your Machine's IP. Set <CORE_IP> to an IP address you can access where core will be running.*

```bash
./bridgechain.sh install-explorer --name MyTest --token MYTEST --explorer-ip <MACHINE_IP> --core-ip <CORE_IP>
./bridgechain.sh start-explorer --network testnet
```

##### Optional Parameters

    --config - Path to JSON config file for install options (see below section for more information)
    --path - Path to install Explorer [/home/$USER/core-explorer]
    --name - Name of Bridgechain [bridgechain]
    --core-ip - IP for core [127.0.0.1]
    --core-port - Port for api [4103]
    --explorer-ip - IP for explorer [0.0.0.0]
    --explorer-port - Port for explorer [4200]
    --token - Token Name [MINE]
    --forgers - How many forgers for the network [51]

###### Generic

    --git-commit - Commit changes to core on a new branch
    --git-origin - Set git origin and attempt to push changes
    --license-name - The name to appear in the License below "Ark Ecosystem"
    --license-email - The email address associated with the licensed name
    --autoinstall-deps - Automatically install dependencies without prompt
    --skip-deps - Skips check for installing dependencies

### JSON Config

As mentioned in the parameters list, it's possible to pass in a JSON config file to load all properties, although they're not all required. For a full example file of all possible options, take a look [here](config.sample.json). For a small example, see below:

```json
{
    "coreIp": "0.0.0.0",
    "p2pPort": 4102,
    "apiPort": 4103,
    "explorerIp": "127.0.0.1",
    "explorerPort": 4200
}
```

To use a config file for installation, simply use the `--config` argument. For example:

```bash
./bridgechain.sh install-core --config /path/to/config.json
```

## Security

If you discover a security vulnerability within this project, please send an e-mail to security@ark.io. All security vulnerabilities will be promptly addressed.

## Credits

- [Alex Barnsley](https://github.com/alexbarnsley)
- [Brian Faust](https://github.com/faustbrian)
- [All Contributors](../../contributors)

## License

ARK Deployer is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
