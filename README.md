# ARK Simple Deployment

## Installation

```bash
git clone https://github.com/faustbrian/smash.git ark-deployment && cd ark-deployment
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
source ~/.profile
nvm install 8.9.1
#sudo apt-get install -y node-gyp build-essential jq
sudo apt-get install -y jq
```

### Node

```bash
./sidechain.sh install-node
./sidechain.sh start-node
```

### Explorer

```bash
./sidechain.sh install-explorer
./sidechain.sh start-explorer
```

## Credits

- [Brian Faust](https://github.com/faustbrian)
- [Alex Barnsley](https://github.com/alexbarnsley)
- [All Contributors](../../contributors)

## License

[MIT](LICENSE) © [Brian Faust](https://brianfaust.me)
