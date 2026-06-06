# Runtime-only image. The binary is built on the CI runner (with ccache)
# and copied in; ubuntu:24.04 matches the runner's glibc/openssl.
# Multi-arch: binaries are laid out as binaries/<arch>/telegram-bot-api by CI.
FROM ubuntu:24.04
ARG TARGETARCH
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libssl3t64 zlib1g curl libjemalloc2 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /data && chown 10000:10000 /data \
    # Arch-agnostic symlink so LD_PRELOAD works for both amd64 and arm64 builds.
    && ln -s "/usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2" /usr/local/lib/libjemalloc.so.2
# jemalloc cuts telegram-bot-api RSS substantially (glibc malloc fragments badly
# under TDLib's small-allocation churn) and speeds up allocation at high RPS.
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2
# Return freed pages to the OS within ~30s instead of hoarding them.
ENV MALLOC_CONF=background_thread:true,dirty_decay_ms:30000,muzzy_decay_ms:30000
# Fallback if jemalloc is ever removed: cap glibc malloc arenas.
ENV MALLOC_ARENA_MAX=2
COPY binaries/${TARGETARCH}/telegram-bot-api /usr/local/bin/telegram-bot-api
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
# Starts as root only to chown the data volume, then drops to uid 10000
# via setpriv (see docker-entrypoint.sh).
WORKDIR /data
EXPOSE 8081 8082
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
  CMD curl -fsS http://127.0.0.1:8082/ >/dev/null || exit 1
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
