# docker build -f Dockerfile -t ultracombos/rustdesk-server:latest -t ("ultracombos/rustdesk-server:" + (Get-Date -Format "yyyy-MM-ddTHH-mm-ss-fffZ")) .
# docker save -o rustdesk-server.tar ultracombos/rustdesk-server:latest
# scp .\rustdesk-server.tar ultracombos@192.168.234.247:~/projects/rustdesk-server
# docker load -i rustdesk-server.tar

# Build Stage
FROM rust:slim-bullseye as builder

WORKDIR /app

RUN apt-get update && \
    apt-get install -y libsodium-dev build-essential pkg-config git && \
    rm -rf /var/lib/apt/lists/*

COPY . .

RUN cargo build --release

# Runtime Stage
FROM debian:bullseye-slim

WORKDIR /data

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y xz-utils libsodium23 ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Copy binaries from builder
COPY --from=builder /app/target/release/hbbs /usr/bin/hbbs
COPY --from=builder /app/target/release/hbbr /usr/bin/hbbr

# Set permissions
RUN chmod +x /usr/bin/hbbs /usr/bin/hbbr

ENV RELAY=relay.example.com
ENV ENCRYPTED_ONLY=0

EXPOSE 21115 21116 21116/udp 21117 21118 21119

VOLUME /data

CMD ["hbbs"]