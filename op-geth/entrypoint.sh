#!/bin/sh

DATA_DIR=/data
PRELOADED_DATA_FILE=/mainnet-bedrock.tar.zst

# Configuration defined in https://community.optimism.io/docs/developers/bedrock/node-operator-guide/#configuring-op-geth

# Tx pool gossip is disabled as it is not supported yet

# TODO: Should we add --http.api and --ws.api flags?

echo "[INFO - entrypoint] Starting Geth"
exec geth --datadir $DATA_DIR \
  --rollup.sequencerhttp $SEQUENCER_HTTP_URL \
  --rollup.disabletxpoolgossip \
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
  --syncmode=snap \
  --port ${P2P_PORT} \
  --networkid=10 \
  --op-network=op-mainnet \
  ${EXTRA_FLAGS}
