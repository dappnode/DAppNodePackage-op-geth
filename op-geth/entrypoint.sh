#!/bin/sh

# Configuration defined in https://community.optimism.io/docs/developers/bedrock/node-operator-guide/#configuring-op-geth

echo "[INFO - entrypoint] Initializing Geth from genesis"
geth --datadir=/data init /config/genesis.json

# Tx pool gossip is disabled as it is not supported yet
# Max peers set to 0 to disable peer discovery (will be enabled in the future for snap sync)
# TODO: Should we add --http.api and --ws.api flags?

echo "[INFO - entrypoint] Starting Geth"
exec geth --datadir /data \
  --rollup.historicalrpc http://l2geth.dappnode:8545 \
  --rollup.sequencerhttp https://bedrock-beta-1-sequencer.optimism.io \
  --rollup.disabletxpoolgossip true \
  --ws \
  --ws.port 8546 \
  --ws.addr 0.0.0.0 \
  --ws.origins "*" \
  --http \
  --http.port 8545 \
  --http.addr 0.0.0.0 \
  --http.vhosts "*" \
  --http.corsdomain "*" \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.vhosts "*" \
  --authrpc.jwtsecret /config/jwtsecret.hex \
  --verbosity 3 \
  --nodiscover \
  --maxpeers 0 \
  --syncmode full \
  ${EXTRA_FLAGS}
