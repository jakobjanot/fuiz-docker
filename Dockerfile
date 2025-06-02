# Use an official Rust image for building Rust projects
FROM node:22-bookworm-slim AS builder

WORKDIR /fuiz

# Install git
RUN apt-get update && \
    apt-get install -y git curl build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /fuiz/backend
RUN cargo build --release --all-features

WORKDIR /fuiz/corkboard
RUN cargo build --release --all-features

# Final image
FROM node:22-bookworm-slim

WORKDIR /fuiz/frontend
RUN npm install
RUN npm install -g bun
RUN bun run build

WORKDIR /fuiz

# Copy built binaries and website
COPY --from=builder /fuiz/corkboard/target/release /fuiz/corkboard
COPY --from=builder /fuiz/hosted-server/target/release /fuiz/fuiz-server
COPY --from=builder /fuiz/website /etc/nginx/html

EXPOSE 5173 5040 8080 8787
VOLUME ["/fuiz/data"]

CMD ["/fuiz/corkboard/corkboard", "&", "/fuiz/fuiz-server/fuiz-server", "&", "nginx", "-g", "daemon off;"]