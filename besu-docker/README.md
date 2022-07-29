# Besu Docker Dev Quickstart - with support for more configurations!

This derives most of the scripts from [quorum-dev-quickstart](https://github.com/ConsenSys/quorum-dev-quickstart) with added support for specifying a config file as an optional argument to refine the kind of network that is created. This is primarily geared towards Besu customisations will look at porting the same to GoQuorum later. Look at the (example: [default.json](./config/default.json)) for config options.

## NOTE ##

Make sure to run this on the local besu checkout to use it.
```bash
./gradlew clean spotlessApply build -x test -x acceptanceTest distDocker
```

## Example: Nodes with P2P-SSL and Tessera private transaction manager
```bash
npm run build && npm start -- --configFile=./config/small-p2p-tls-tessera.json
```
## Example: Nodes with P2P-SSL and Orion private transaction manager
```bash
npm run build && npm start -- --configFile=./config/small-p2p-tls-orion.json
```
## Example: Nodes with P2P-SSL and Tessera private transaction manager and using secp256r1 algorithm based node keys
```bash
npm run build && npm start -- --configFile=./config/small-p2p-tls-tessera-r1.json
```

## Example: Nodes with PKI-based Block Creation
```bash
npm run build && npm start -- --configFile=./config/pki-4-block-validation.json
```

Complex configurations can be saved to a config json file and invoked via commandline using the the following command. A few config files are available [here](/config)

```
npm run build && npm start -- --configFile=./config/small-p2p-tls-tessera.json

npm run build && npm start -- --configFile=./config/small-p2p-tls-orion.json

npm run build && npm start -- --configFile=./config/small-p2p-tls-tessera-splunk-snap.json

npm run build && npm start -- --configFile=./config/four-r1-tls.json

npm run build && npm start -- --configFile=./config/small-p2p-tls-tessera-r1.json

npm run build && npm start -- --configFile=./config/small-p2p-tls-tessera-r1-t.json

npm run build && npm start -- --configFile=./config/one.json
```

**To start services and the network:**

Follow the README.md file of select artifact:
* [Hyperledger Besu](./files/besu/README.md)
