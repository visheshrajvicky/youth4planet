createCertificateFory4p2() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/y4p2.youth4planet.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/

  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.y4p2.youth4planet.com --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-y4p2-youth4planet-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-y4p2-youth4planet-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-y4p2-youth4planet-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-y4p2-youth4planet-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo

  fabric-ca-client register --caname ca.y4p2.youth4planet.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  echo
  echo "Register peer1"
  echo

  fabric-ca-client register --caname ca.y4p2.youth4planet.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  echo
  echo "Register user"
  echo

  fabric-ca-client register --caname ca.y4p2.youth4planet.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  echo
  echo "Register the org admin"
  echo

  fabric-ca-client register --caname ca.y4p2.youth4planet.com --id.name y4p2admin --id.secret y4p2adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers
  mkdir -p ../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo

  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.y4p2.youth4planet.com -M ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/msp --csr.hosts peer0.y4p2.youth4planet.com --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo

  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.y4p2.youth4planet.com -M ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls --enrollment.profile tls --csr.hosts peer0.y4p2.youth4planet.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/tlsca/tlsca.y4p2.youth4planet.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer0.y4p2.youth4planet.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/ca/ca.y4p2.youth4planet.com-cert.pem

  # --------------------------------------------------------------------------------
  #  Peer 1
  echo
  echo "## Generate the peer1 msp"
  echo

  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.y4p2.youth4planet.com -M ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/msp --csr.hosts peer1.y4p2.youth4planet.com --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo

  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.y4p2.youth4planet.com -M ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/tls --enrollment.profile tls --csr.hosts peer1.y4p2.youth4planet.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/peers/peer1.y4p2.youth4planet.com/tls/server.key
  # -----------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/y4p2.youth4planet.com/users
  mkdir -p ../crypto-config/peerOrganizations/y4p2.youth4planet.com/users/User1@y4p2.youth4planet.com

  echo
  echo "## Generate the user msp"
  echo

  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.y4p2.youth4planet.com -M ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/users/User1@y4p2.youth4planet.com/msp --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/y4p2.youth4planet.com/users/Admin@y4p2.youth4planet.com

  echo
  echo "## Generate the org admin msp"
  echo

  fabric-ca-client enroll -u https://y4p2admin:y4p2adminpw@localhost:8054 --caname ca.y4p2.youth4planet.com -M ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/users/Admin@y4p2.youth4planet.com/msp --tls.certfiles ${PWD}/fabric-ca/y4p2/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/y4p2.youth4planet.com/users/Admin@y4p2.youth4planet.com/msp/config.yaml

}

createCertificateFory4p2