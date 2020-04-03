FROM alpine:latest

RUN addgroup -S mosquitto && \
    adduser -S -H -h /var/empty -s /sbin/nologin -D -G mosquitto mosquitto

ENV PATH=/usr/local/bin:/usr/local/sbin:$PATH
ENV MOSQUITTO_VERSION=master

COPY docker-entrypoint.sh /

RUN apk --no-cache add --virtual buildDeps git cmake build-base openssl-dev c-ares-dev util-linux-dev; \
    chmod +x /docker-entrypoint.sh && \
    mkdir -p /var/lib/mosquitto && \
    touch /var/lib/mosquitto/.keep && \
    mkdir -p /etc/mosquitto.d && \
    apk add libuuid c-ares openssl ca-certificates && \
    git clone -b ${MOSQUITTO_VERSION} https://github.com/eclipse/mosquitto.git && \
    cd mosquitto && \
    make -j "$(nproc)" \
      WITH_SRV=yes \
      WITH_STRIP=yes \
      WITH_ADNS=no \
      WITH_DOCS=no \
      WITH_MEMORY_TRACKING=no \
      WITH_TLS_PSK=no \
      binary && \
    install -s -m755 client/mosquitto_pub /usr/bin/mosquitto_pub && \
    install -s -m755 client/mosquitto_rr /usr/bin/mosquitto_rr && \
    install -s -m755 client/mosquitto_sub /usr/bin/mosquitto_sub && \
    install -s -m644 lib/libmosquitto.so.1 /usr/lib/libmosquitto.so.1 && \
    ln -sf /usr/lib/libmosquitto.so.1 /usr/lib/libmosquitto.so && \
    install -s -m755 src/mosquitto /usr/sbin/mosquitto && \
    install -s -m755 src/mosquitto_passwd /usr/bin/mosquitto_passwd && \
    cd / && rm -rf mosquitto && \
    apk del buildDeps && rm -rf /var/cache/apk/*

ADD mosquitto.conf /etc/mosquitto/mosquitto.conf

# MQTT default port and default port over TLS
EXPOSE 1883 8883

# VOLUME ["/var/lib/mosquitto", "/etc/mosquitto", "/etc/mosquitto.d"]

ENTRYPOINT ["/docker-entrypoint.sh"]
