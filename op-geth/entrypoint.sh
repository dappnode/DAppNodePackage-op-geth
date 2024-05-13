#!/bin/sh

SNAP_DATA_DIR=/data/snap
ARCHIVAL_DATA_DIR=/data/archive

HISTORICAL_RPC_URL=http://op-l2geth.dappnode:8545
PRELOADED_DATA_FILE=/mainnet-bedrock.tar.zst

# Configuration defined in https://community.optimism.io/docs/developers/bedrock/node-operator-guide/#configuring-op-geth

# Tx pool gossip is disabled as it is not supported yet

# TODO: Should we add --http.api and --ws.api flags?

if [ "$_DAPPNODE_GLOBAL_OP_ENABLE_HISTORICAL_RPC" = "true" ]; then

  if [ -z "$HISTORICAL_RPC_URL" ]; then
    echo "[ERROR - entrypoint] ENABLE_HISTORICAL_RPC is set to true but HISTORICAL_RPC_URL is not defined"
    sleep 60
    exit 1
  fi

  echo "[INFO - entrypoint] Enabling historical RPC"
  rm -rf $SNAP_DATA_DIR

  # Before starting the download, check if a partial file exists.
  if [ -f "$PRELOADED_DATA_FILE" ]; then
    echo "[WARNING - entrypoint] Found a partial preloaded data file. Removing it..."
    rm -f $PRELOADED_DATA_FILE
  fi

  # Start the download.
  wget -O $PRELOADED_DATA_FILE https://datadirs.optimism.io$PRELOADED_DATA_FILE
  if [ $? -ne 0 ]; then
    echo "[ERROR - entrypoint] Failed to download preloaded data."
    exit 1
  fi

  echo "[INFO - entrypoint] Decompressing preloaded data. This can take a while..."
  zstd -d --stdout $PRELOADED_DATA_FILE | tar xvf - -C $ARCHIVAL_DATA_DIR
  if [ $? -ne 0 ]; then
    echo "[ERROR - entrypoint] Failed to decompress preloaded data."
    rm -f $PRELOADED_DATA_FILE # Remove the faulty file
    exit 1
  fi

  echo "[INFO - entrypoint] Removing preloaded data file. Not needed anymore."
  rm -rf $PRELOADED_DATA_FILE
  EXTRA_FLAGS="--rollup.historicalrpc $HISTORICAL_RPC_URL --gcmode archive --syncmode full --datadir $ARCHIVAL_DATA_DIR"
  # EXTRA_FLAGS="--datadir.ancient $ARCHIVAL_DATA_DIR/geth/chaindata/ancient"

else
  echo "[INFO - entrypoint] Historical RPC is disabled"
  EXTRA_FLAGS="--gcmode full --syncmode snap --datadir $SNAP_DATA_DIR"
  rm -rf $ARCHIVAL_DATA_DIR
fi

echo "[INFO - entrypoint] Starting Geth"
exec geth --rollup.sequencerhttp $SEQUENCER_HTTP_URL \
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
  --port ${P2P_PORT} \
  --networkid 10 \
  --op-network op-mainnet \
  ${EXTRA_FLAGS}
