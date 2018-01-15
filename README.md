# ARK Simple Deployment

## Installation

```bash
git clone https://github.com/faustbrian/smash.git ark-deployment && cd ark-deployment
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
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
