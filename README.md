# Besu Scripts

## Generate Keys

## Sample Cert Tree
![Cer Tree](cert-tree.png)

## Note
Make sure to run with JDK 11 in path, anything higher will result in keystore load related errors like "Algorithm HmacPBESHA256 not available" 

### Might have to install to generate the pkcs11 keystore
```bash
sudo apt install libnss3-tools
```

## Besu Genesis Blockchain Config and Node Keys File Generation 
### [gen-config.sh](gen-config.sh)
This script is used to generate Besu blockchain genesis and node keys files used in [quorum-dev-quickstart - addon_features_tls](https://github.com/perusworld/quorum-dev-quickstart/tree/addon_features_tls). Copy the contents of the above mentioned export folder to ./files/besu/config/besu/p2p-tls folder in quorum-dev-quickstart.

If you run the script without any arguments it should print the usage formats. all of them are optional but tend to look for presence of the besu binary and the config to use to generate the keys. The configuration is generated in the **./generated/generated-config** folder.

The **genesis.json** file has the nodes encoded in the extra data, The **genesis-ne.json** file has the **nothing** encoded in the extra data.

A reccomended option is to run the command twice, first
```bash
./generate-config.sh  -n validators
```
Then copy the generated config and keys. And then run again
```bash
./generate-config.sh  -n members
```
THis time just copy the member node keys and use the config from the first run. This was the validators are only encoded in the extra data.
## Key/Cert Gen Scripts
There are a couple of key gen scripts in here. They generate the keys in **./generated/keys** and the corresponding exported version of the keys in **./generated/export**. As of now 3 types of keystore are exported using a combination of openssl, keytool and certutil
* jks
* pkcs11
* pkcs12

Most of the common functions are in [common.sh](common.sh), One can include that in their own scripts to customise the key generation.

### [gen-keys.sh](gen-keys.sh)
This script is used to generate the keys used in [quorum-dev-quickstart - addon_features_tls](https://github.com/perusworld/quorum-dev-quickstart/tree/addon_features_tls). Copy the contents of the aove mentioned export folder to ./files/besu/config/besu/p2p-tls folder in quorum-dev-quickstart.

### [gen-test-keys.sh](gen-test-keys.sh)
This script is used to generate the keys used in the [Besu - PKI Module Test Cases](https://github.com/hyperledger/besu/tree/master/pki). Copy the contents of the aove mentioned export folder to ./pki/src/test/resources/keystore/ folder in besu.

### [gen-at-keys.sh](gen-at-keys.sh)
This script is used to generate the keys used in the [Besu - Acceptance Test Cases](https://github.com/perusworld/besu/tree/master/acceptance-tests). Copy the contents of the aove mentioned export folder to ./tests/src/test/resources/p2p-tls/ folder in besu.

