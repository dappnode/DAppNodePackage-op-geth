#!/bin/sh

case "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_LUKSO" in
"prysm-lukso.dnp.dappnode.eth")
  echo "Using prysm-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/prysm/jwtsecret.hex"
  ;;
"lighthouse-lukso.dnp.dappnode.eth")
  echo "Using lighthouse-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/lighthouse/jwtsecret.hex"
  ;;
"lodestar-lukso.dnp.dappnode.eth")
  echo "Using lodestar-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/lodestar/jwtsecret.hex"
  ;;
"teku-lukso.dnp.dappnode.eth")
  echo "Using teku-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/teku/jwtsecret.hex"
  ;;
"nimbus-lukso.dnp.dappnode.eth")
  echo "Using nimbus-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/nimbus/jwtsecret.hex"
  ;;
*)
  echo "Using default JWT"
  JWT_PATH="/security/default/jwtsecret.hex"
  ;;
esac

echo "[INFO - entrypoint] Posting JWT to dappmanager: ${JWT_PATH}"
JWT=$(cat $JWT_PATH)
curl -X POST "http://my.dappnode/data-send?key=jwt&data=${JWT}"

echo "[INFO - entrypoint] Initializing Geth from genesis"
geth --datadir=/lukso init /config/genesis.json

echo "[INFO - entrypoint] Starting Geth"
exec geth --datadir /lukso \
  --networkid 42 \
  --miner.gasprice 4200000000 \
  --miner.gaslimit 42000000 \
  --bootnodes enode://c2bb19ce658cfdf1fecb45da599ee6c7bf36e5292efb3fb61303a0b2cd07f96c20ac9b376a464d687ac456675a2e4a44aec39a0509bcb4b6d8221eedec25aca2@34.147.73.193:30303", "enode://276f14e4049840a0f5aa5e568b772ab6639251149a52ba244647277175b83f47b135f3b3d8d846cf81a8e681684e37e9fc10ec205a9841d3ae219aa08aa9717b@34.32.192.211:30303 \
  --maxpeers 50 \
  --port ${P2P_PORT} \
  --http \
  --http.api eth,engine,net,web3,txpool \
  --http.addr 0.0.0.0 \
  --http.corsdomain "*" \
  --http.vhosts "*" \
  --ws \
  --ws.api eth,engine,net,web3,txpool \
  --ws.addr 0.0.0.0 \
  --ws.port 8546 \
  --ws.origins "*" \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.vhosts "*" \
  --authrpc.jwtsecret ${JWT_PATH} \
  --syncmode ${SYNC_MODE:-snap} \
  --metrics \
  --metrics.addr 0.0.0.0 \
  ${EXTRA_FLAGS}
