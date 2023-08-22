ARG UPSTREAM_VERSION

# TODO: DockerHub looks out of date for Optimism. We might need to build from source 
FROM https://us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:${UPSTREAM_VERSION}

RUN mkdir /config

COPY /security/jwtsecret.hex /config/jwtsecret.hex
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk update && apk add curl &&\ 
    chmod +x /usr/local/bin/entrypoint.sh

# Get Genesis file for Optimism
RUN curl -o /config/genesis.json -sL <URL to genesis JSON> # TODO: What is the genesis file?

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]