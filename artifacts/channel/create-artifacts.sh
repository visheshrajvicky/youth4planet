
chmod -R 0755 ./crypto-config
# Delete existing artifacts
rm -rf ./crypto-config
rm genesis.block mychannel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
# cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/



# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="y4pchannel"

echo $CHANNEL_NAME

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./y4pchannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./y4p1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg y4p1MSP

echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./y4p2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg y4p2MSP

# echo "#######    Generating anchor peer update for Org3MSP  ##########"
# configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP