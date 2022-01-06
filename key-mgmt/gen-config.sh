#!/bin/bash

checkBin() {
  if ! command -v $1 &> /dev/null
  then
      echo "Binary not found @ $1"
      print_usage
      exit
  fi
}

checkFile() {
  if test -f "$1"; then
    echo "Found $1"
  else
    echo "File not found @ $1"
    print_usage
    exit
  fi
}

checkExecution() {
  if [ $? -ne 0 ]; then
      echo "Command execution failed, please check the params"
      exit
  fi
}


outputDir=generated
configDir=generated-config
genesisFile=genesis.json
genesisNoExtraDataFile=genesis-ne.json
blankEncodeJSONFile=./config/blankEncode.json

configFile=./config/r1ibftConfigFile.json
besuBin=/home/perusworld/works/open/contrib/besu/build/docker-besu/besu/bin/besu
nodeNameType=all

print_usage() {
    echo "  Usage: ./generate-config.sh -c $configFile -b $besuBin -n $nodeNameType"
    echo "    All args are optional, default shown above will be used"
    echo "    For n use :"
    echo "      all - generate for all nodes(8)"
    echo "      validators - generate for validators nodes(4)"
    echo "      members - generate for members nodes(4)"
}

while getopts ":c:b:n:" arg; do
  case $arg in
    c) configFile=$OPTARG;;
    b) besuBin=$OPTARG;;
    n) nodeNameType=$OPTARG;;
  esac
done

baseDir=./$outputDir/$configDir
keysDir=$baseDir/keys
publicKeyFile=$baseDir/publicKeys.json
tempConfigFile=$outputDir/temp-config.json

allNodeNames=(validator1 validator2 validator3 validator4 rpcnode member1 member2 member3)
validatorNodeNames=(validator1 validator2 validator3 validator4)
memberNodeNames=(rpcnode member1 member2 member3)
kvalidatorNodeNames=(validator-0 validator-1 validator-2 validator-3)
kmemberNodeNames=(member-0 member-1 member-2)
k0validatorNodeNames=(validator-0-0 validator-1-0 validator-2-0 validator-3-0)
k0memberNodeNames=(member-0-0 member-1-0 member-2-0)


case $nodeNameType in
    validators) nodeNames=(${validatorNodeNames[*]});;
    members) nodeNames=(${memberNodeNames[*]});;
    kvalidators) nodeNames=(${kvalidatorNodeNames[*]});;
    kmembers) nodeNames=(${kmemberNodeNames[*]});;
    k0validators) nodeNames=(${k0validatorNodeNames[*]});;
    k0members) nodeNames=(${k0memberNodeNames[*]});;
    *) nodeNames=(${allNodeNames[*]});;
esac
nodeLen="${#nodeNames[@]}"
idx=0

checkBin $besuBin
checkFile $configFile

echo "Using $configFile, $besuBin, $nodeNameType to generate configs in $baseDir for $nodeLen nodes"

echo "Preping"
mkdir -p $outputDir
rm -rf $baseDir
rm -rf $tempConfigFile
touch $tempConfigFile

echo "Preping  $tempConfigFile from $configFile with node size as $nodeLen"
cat $configFile | jq ".blockchain.nodes.count=$nodeLen" | tee $tempConfigFile

echo "Executing besu generate-blockchain-config"
$besuBin operator generate-blockchain-config --config-file $tempConfigFile --to $outputDir/$configDir
checkExecution

for dr in $keysDir/*
do
  echo "Moving $dr/key.priv to $dr/key"
  mv $dr/key.priv $dr/key
  echo "Renaming $dr to ${nodeNames[idx]}"
  mv $dr $keysDir/${nodeNames[idx]}
  mkdir -p $keysDir/${nodeNames[idx]}/keys
  mv $keysDir/${nodeNames[idx]}/key $keysDir/${nodeNames[idx]}/keys
  mv $keysDir/${nodeNames[idx]}/key.pub $keysDir/${nodeNames[idx]}/keys
  ((idx=idx+1))
done

echo "Generating extraData using $blankEncodeJSONFile"
extraData=`$besuBin rlp encode --from=$blankEncodeJSONFile`
checkExecution
echo "Setting extraData of $extraData to $baseDir/$genesisNoExtraDataFile"
cat $baseDir/$genesisFile | jq ".extraData=\"$extraData\"" | tee $baseDir/$genesisNoExtraDataFile

echo "Creating $publicKeyFile"
echo '{' > $publicKeyFile
for dr in "${nodeNames[@]}"
do
  echo "Adding public key of $dr"
  pub=$(cat $keysDir/$dr/keys/key.pub)
  echo "\"$dr\": \"${pub:2}\"," >> $publicKeyFile
done
echo '}' >> $publicKeyFile

echo "Cleaning"
rm -rf $tempConfigFile
