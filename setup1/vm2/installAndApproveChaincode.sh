export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../vm1/crypto-config/ordererOrganizations/youth4planet.com/orderers/orderer.youth4planet.com/msp/tlscacerts/tlsca.youth4planet.com-cert.pem
export PEER0_Y4P2_CA=${PWD}/crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../../artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForPeer0y4p2() {
    export CORE_PEER_LOCALMSPID="y4p2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Y4P2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/y4p2.youth4planet.com/users/Admin@y4p2.youth4planet.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer1y4p2() {
    export CORE_PEER_LOCALMSPID="y4p2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Y4P2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/y4p2.youth4planet.com/users/Admin@y4p2.youth4planet.com/msp
    export CORE_PEER_ADDRESS=localhost:10051

}

# presetup() {
#     echo Vendoring Go dependencies ...
#     pushd ./../../artifacts/src/github.com/fabcar/go
#     GO111MODULE=on go mod vendor
#     popd
#     echo Finished vendoring Go dependencies
# }
# presetup

CHANNEL_NAME="y4pchannel"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
# CC_SRC_PATH="./../../artifacts/src/github.com/fabcar/go"
CC_SRC_PATH="./../../artifacts/src/chaincode-javascript"
CC_NAME="basic"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0y4p2
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.y4p2 ===================== "
}
 packageChaincode

installChaincode() {
    setGlobalsForPeer0y4p2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.y4p2 ===================== "

}

 installChaincode

queryInstalled() {
    setGlobalsForPeer0y4p2
    peer lifecycle chaincode queryinstalled >&log.txt

    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.y4p2 on channel ===================== "
}

 queryInstalled

approveForMyy4p2() {
    setGlobalsForPeer0y4p2

    # Replace localhost with your orderer's vm IP address
    peer lifecycle chaincode approveformyorg -o 35.224.142.40:7050 \
        --ordererTLSHostnameOverride orderer.youth4planet.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}
queryInstalled
approveForMyy4p2

checkCommitReadyness() {

    setGlobalsForPeer0y4p2
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_Y4P2_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

checkCommitReadyness
