#!/bin/sh

DATA_DIR=/data
PRELOADED_DATA_FILE=/mainnet-bedrock.tar.zst

# Configuration defined in https://community.optimism.io/docs/developers/bedrock/node-operator-guide/#configuring-op-geth

# Tx pool gossip is disabled as it is not supported yet
# Max peers set to 0 to disable peer discovery (will be enabled in the future for snap sync)
# TODO: Should we add --http.api and --ws.api flags?

if [ "$_DAPPNODE_GLOBAL_OP_ENABLE_HISTORICAL_RPC" = "true" ]; then

  if [ -z "$HISTORICAL_RPC_URL" ]; then
    echo "[ERROR - entrypoint] ENABLE_HISTORICAL_RPC is set to true but HISTORICAL_RPC_URL is not defined"
    sleep 60
    exit 1
  fi

  echo "[INFO - entrypoint] Enabling historical RPC"
  EXTRA_FLAGS="--rollup.historicalrpc $HISTORICAL_RPC_URL --gcmode archive"
else
  echo "[INFO - entrypoint] Historical RPC is disabled"
  EXTRA_FLAGS="--gcmode full"
fi

# If $DATA_DIR is not empty, then geth is already initialized
if [ "$(ls -A $DATA_DIR)" ]; then
  echo "[INFO - entrypoint] Database already exists, skipping initialization"
else
  echo "[INFO - entrypoint] $DATA_DIR is empty, initializing geth from preloaded data"
  echo "[INFO - entrypoint] Downloading preloaded data from $PRELOADED_DATA_URL. This can take hours..."
  mkdir -p $DATA_DIR

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
  zstd -d --stdout $PRELOADED_DATA_FILE | tar xvf - -C $DATA_DIR
  if [ $? -ne 0 ]; then
    echo "[ERROR - entrypoint] Failed to decompress preloaded data."
    rm -f $PRELOADED_DATA_FILE # Remove the faulty file
    exit 1
  fi

  echo "[INFO - entrypoint] Removing preloaded data file. Not needed anymore."
  rm -rf $PRELOADED_DATA_FILE
  EXTRA_FLAGS="--datadir.ancient $DATA_DIR/geth/chaindata/ancient"
fi

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
  --nodiscover \
  --maxpeers 0 \
  --syncmode full \
  --networkid=10 \
  ${EXTRA_FLAGS}
