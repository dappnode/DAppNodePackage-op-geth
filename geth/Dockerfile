ARG UPSTREAM_VERSION

FROM ethereum/client-go:${UPSTREAM_VERSION}

COPY /security /security
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk update && apk add curl && apk add wget &&\ 
    chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir /config

# Get Lukso genesis for Geth
RUN wget https://raw.githubusercontent.com/lukso-network/network-configs/main/mainnet/shared/genesis_42.json -O /config/genesis.json

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]