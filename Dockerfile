# Use an official Rust image for building Rust projects
FROM rust:1.87-bullseye AS backends-builder

ENV NETWORK_ORIGIN="http://localhost:3000"

WORKDIR /fuiz
COPY backend /fuiz/backend
COPY corkboard /fuiz/corkboard

WORKDIR /fuiz/backend
RUN cargo build --release --all-features

WORKDIR /fuiz/corkboard
RUN cargo build --release --all-features
FROM node:22-bookworm-slim

WORKDIR /fuiz
# Copy built binaries and website
COPY --from=backends-builder /fuiz/corkboard/target/release /fuiz/corkboard
COPY --from=backends-builder /fuiz/backend/target/release /fuiz/backend

WORKDIR /fuiz/frontend

COPY frontend .

RUN npm install -g bun@latest wrangler@latest
RUN bun install --frozen-lockfile

RUN bun run build

# Copy built app files
#COPY frontend/build ./build

EXPOSE 3000 5040 8080
VOLUME ["/fuiz/data"]

WORKDIR /fuiz

COPY "entrypoint.sh" /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]