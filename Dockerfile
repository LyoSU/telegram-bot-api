# Runtime-only image. The binary is built on the CI runner (with ccache)
# and copied in; ubuntu:24.04 matches the runner's glibc/openssl.
# Multi-arch: binaries are laid out as binaries/<arch>/telegram-bot-api by CI.
FROM ubuntu:24.04
ARG TARGETARCH
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libssl3t64 zlib1g curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /data && chown 10000:10000 /data
COPY binaries/${TARGETARCH}/telegram-bot-api /usr/local/bin/telegram-bot-api
USER 10000:10000
WORKDIR /data
EXPOSE 8081 8082
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
  CMD curl -fsS http://127.0.0.1:8082/ >/dev/null || exit 1
ENTRYPOINT ["/usr/local/bin/telegram-bot-api"]
