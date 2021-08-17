export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../vm1/crypto-config/ordererOrganizations/youth4planet.com/orderers/orderer.youth4planet.com/msp/tlscacerts/tlsca.youth4planet.com-cert.pem
export PEER0_Y4P2_CA=${PWD}/crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../../artifacts/channel/config/

export CHANNEL_NAME=y4pchannel

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

fetchChannelBlock() {
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0y4p2
    # Replace localhost with your orderer's vm IP address
    peer channel fetch 0 ./channel-artifacts/$CHANNEL_NAME.block -o 35.224.142.40:7050 \
        --ordererTLSHostnameOverride orderer.youth4planet.com \
        -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
}

#fetchChannelBlock

joinChannel() {
    setGlobalsForPeer0y4p2
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer1y4p2
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

}

#joinChannel

updateAnchorPeers() {
    setGlobalsForPeer0y4p2
    # Replace localhost with your orderer's vm IP address
    peer channel update -o 35.224.142.40:7050 --ordererTLSHostnameOverride orderer.youth4planet.com \
        -c $CHANNEL_NAME -f ./../../artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

}

#updateAnchorPeers

fetchChannelBlock
joinChannel
updateAnchorPeers
