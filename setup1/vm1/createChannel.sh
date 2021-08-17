export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../vm4/crypto-config/ordererOrganizations/youth4planet.com/orderers/orderer.youth4planet.com/msp/tlscacerts/tlsca.youth4planet.com-cert.pem
export PEER0_Y4P1_CA=${PWD}/crypto-config/peerOrganizations/y4p1.youth4planet.com/peers/peer0.y4p1.youth4planet.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../../artifacts/channel/config/

export CHANNEL_NAME=y4pchannel

setGlobalsForPeer0y4p1(){
    export CORE_PEER_LOCALMSPID="y4p1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Y4P1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/y4p1.youth4planet.com/users/Admin@y4p1.youth4planet.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1y4p1(){
    export CORE_PEER_LOCALMSPID="y4p1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Y4P1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/y4p1.youth4planet.com/users/Admin@y4p1.youth4planet.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0y4p1
    
    # Replace localhost with your orderer's vm IP address
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.youth4planet.com \
    -f ./../../artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# createChannel

joinChannel(){
    setGlobalsForPeer0y4p1
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1y4p1
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

# joinChannel

updateAnchorPeers(){
    setGlobalsForPeer0y4p1
    # Replace localhost with your orderer's vm IP address
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.youth4planet.com -c $CHANNEL_NAME -f ./../../artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

# updateAnchorPeers

# removeOldCrypto

createChannel
joinChannel
updateAnchorPeers