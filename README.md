# ARK Simple Deployment

## Vagrant

Deploy a sidechain and explorer within it's own Vagrant setup.

```bash
git clone https://github.com/alexbarnsley/ark-deployment.git && cd ark-deployment
vagrant up
```

Vagrant will then reboot. Once finished, wait a further minute or so and you can access the Node and Explorer using the below URLs:

Node API: `http://192.168.33.10:4100/api/`
Explorer: `http://192.168.33.10:4200/`

## Installation

```bash
git clone https://github.com/alexbarnsley/ark-deployment.git && cd ark-deployment
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
source ~/.profile
nvm install 8.9.1
sudo apt-get install -y jq
```

### Node

```bash
./sidechain.sh install-node --name AlexTest --database ark_alex --token ALEX --symbol AL --ip 192.168.0.22
./sidechain.sh start-node --name AlexTest
```

#### Optional Parameters

	- --path - Path to install Side Chain [/home/$USER/ark-sidechain]
	- --name - Name of Side Chain [sidechain]
	- --database - Database Name [ark_sidechain]
	- --ip - IP for node [localhost] *Only useful for Explorer*
	- --token - Token Name [MINE]
	- --symbol - Symbol for Token [M]
	- --skip-deps - Skips check for installing dependencies

### Explorer

```bash
./sidechain.sh install-explorer --name AlexTest --token ALEX --ip 192.168.0.22
./sidechain.sh start-explorer --ip 192.168.0.22
```

#### Optional Parameters

	- --path - Path to install Explorer [/home/$USER/ark-explorer]
	- --name - Name of Side Chain [sidechain]
	- --ip - IP for Explorer to run on [localhost]
	- --token - Token Name [MINE]
	- --skip-deps - Skips check for installing dependencies

## Credits

- [Brian Faust](https://github.com/faustbrian)
- [Alex Barnsley](https://github.com/alexbarnsley)
- [All Contributors](../../contributors)

## License

[MIT](LICENSE) © [Brian Faust](https://brianfaust.me)
