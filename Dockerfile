ARG DEBIAN_VERSION=bookworm

FROM debian:${DEBIAN_VERSION}-slim AS builder
ARG PSOTNIC_COMMIT=b598a8dc25686e2785fb0f9970103cb6a39cdaa6
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates git libssl-dev perl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN git clone https://github.com/psotnic/psotnic.git . \
    && git checkout --detach "${PSOTNIC_COMMIT}" \
    && test "$(git rev-parse HEAD)" = "${PSOTNIC_COMMIT}" \
    && perl ./configure --with-ssl \
    && make -j"$(nproc)" dynamic \
    && test -x bin/psotnic

FROM debian:${DEBIAN_VERSION}-slim
ARG PSOTNIC_COMMIT=b598a8dc25686e2785fb0f9970103cb6a39cdaa6
ARG PSOTNIC_VERSION=0.2.14
ARG CONTAINER_VERSION=0.1.0
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 procps tini \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 1000 psotnic \
    && useradd --uid 1000 --gid 1000 --create-home --home-dir /data --shell /usr/sbin/nologin psotnic
COPY --from=builder /src/bin/psotnic /usr/local/bin/psotnic
COPY rootfs/usr/local/bin/entrypoint /usr/local/bin/entrypoint
COPY rootfs/usr/local/bin/healthcheck /usr/local/bin/healthcheck
RUN chmod 0755 /usr/local/bin/psotnic /usr/local/bin/entrypoint /usr/local/bin/healthcheck \
    && chown -R 1000:1000 /data
WORKDIR /data
VOLUME ["/data"]
USER 1000:1000
ENV PSOTNIC_CONFIG=/data/psotnic.conf
LABEL org.opencontainers.image.title="Psotnic" \
      org.opencontainers.image.description="Production-oriented OCI packaging of upstream Psotnic" \
      org.opencontainers.image.source="https://github.com/Ploos-AS/psotnic" \
      org.opencontainers.image.version="${CONTAINER_VERSION}" \
      org.opencontainers.image.licenses="MIT AND GPL-2.0-or-later" \
      org.opencontainers.image.revision="${PSOTNIC_COMMIT}" \
      io.ploos.upstream.version="${PSOTNIC_VERSION}"
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 CMD ["/usr/local/bin/healthcheck"]
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint"]
