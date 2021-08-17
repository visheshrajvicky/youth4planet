export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../vm1/crypto-config/ordererOrganizations/youth4planet.com/orderers/orderer.youth4planet.com/msp/tlscacerts/tlsca.youth4planet.com-cert.pem
export PEER0_Y4P1_CA=${PWD}/crypto-config/peerOrganizations/y4p1.youth4planet.com/peers/peer0.y4p1.youth4planet.com/tls/ca.crt
export PEER0_Y4P2_CA=${PWD}/../vm2/crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/ca.crt
# export PEER0_Y4P3_CA=${PWD}/../vm3/crypto-config/peerOrganizations/org3.youth4planet.com/peers/peer0.org3.youth4planet.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../../artifacts/channel/config/


export CHANNEL_NAME=y4pchannel

setGlobalsForPeer0y4p1() {
    export CORE_PEER_LOCALMSPID="y4p1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Y4P1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/y4p1.youth4planet.com/users/Admin@y4p1.youth4planet.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1y4p1() {
    export CORE_PEER_LOCALMSPID="y4p1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Y4P1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/y4p1.youth4planet.com/users/Admin@y4p1.youth4planet.com/msp
    export CORE_PEER_ADDRESS=localhost:8051

}

# setGlobalsForPeer0y4p2() {
#     export CORE_PEER_LOCALMSPID="y4p2MSP"
#     export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Y4P2_CA
#     export CORE_PEER_MSPCONFIGPATH=${PWD}/../../artifacts/channel/crypto-config/peerOrganizations/y4p2.youth4planet.com/users/Admin@y4p2.youth4planet.com/msp
#     export CORE_PEER_ADDRESS=localhost:9051

# }

# setGlobalsForPeer1y4p2() {
#     export CORE_PEER_LOCALMSPID="y4p2MSP"
#     export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Y4P2_CA
#     export CORE_PEER_MSPCONFIGPATH=${PWD}/../../artifacts/channel/crypto-config/peerOrganizations/y4p2.youth4planet.com/users/Admin@y4p2.youth4planet.com/msp
#     export CORE_PEER_ADDRESS=localhost:10051

# }

# presetup() {
#     echo Vendoring Go dependencies ...
#     pushd ./../../artifacts/src/github.com/fabcar/go
#     GO111MODULE=on go mod vendor
#     popd
#     echo Finished vendoring Go dependencies
# }
# # presetup

CHANNEL_NAME="y4pchannel"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
# CC_SRC_PATH="./../../artifacts/src/github.com/fabcar/go"
CC_SRC_PATH="./../../artifacts/src/chaincode-javascript"
CC_NAME="basic"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0y4p1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.y4p1 ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0y4p1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.y4p1 ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0y4p1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.y4p1 on channel ===================== "
}

# queryInstalled

approveForMyy4p1() {
    setGlobalsForPeer0y4p1
    # set -x
    # Replace localhost with your orderer's vm IP address
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.youth4planet.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from y4p 1 ===================== "

}

# queryInstalled
# approveForMyy4p1

checkCommitReadyness() {
    setGlobalsForPeer0y4p1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from y4p 1 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0y4p1
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.youth4planet.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_Y4P1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_Y4P2_CA \
        # --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_Y4P3_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required
}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0y4p1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0y4p1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.youth4planet.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_Y4P2_CA \
        #  --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_Y4P3_CA \
        --isInit -c '{"Args":[]}'

}

 # --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_Y4P1_CA \

# chaincodeInvokeInit

chaincodeInvoke() {
    setGlobalsForPeer0y4p1

    ## Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.youth4planet.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_Y4P1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_Y4P2_CA   \
        # --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_Y4P3_CA \
        -c '{"function": "createCar","Args":["Car-ABCDEEE", "Audi", "R8", "Red", "Sandip"]}'

    ## Init ledger
    # peer chaincode invoke -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.youth4planet.com \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME} \
    #     --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_Y4P1_CA \
    #     --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_Y4P2_CA \
    #     -c '{"function": "initLedger","Args":[]}'

}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0y4p1

    # Query Car by Id
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryCar","Args":["CAR0"]}'
 
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
# presetup

# packageChaincode
# installChaincode
# queryInstalled
# approveForMyy4p1
# checkCommitReadyness
# approveForMyy4p2
# checkCommitReadyness
# commitChaincodeDefination
# queryCommitted
# chaincodeInvokeInit
# sleep 5
# chaincodeInvoke
# sleep 3
# chaincodeQuery
