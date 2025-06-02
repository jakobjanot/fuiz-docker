# Use an official Rust image for building Rust projects
FROM rust:1.87-bullseye AS builder

WORKDIR /fuiz

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /fuiz
COPY backend /fuiz/backend
COPY corkboard /fuiz/corkboard

WORKDIR /fuiz/backend
RUN cargo build --release --all-features

WORKDIR /fuiz/corkboard
RUN cargo build --release --all-features

FROM oven/bun:1 AS frontend-builder
WORKDIR /fuiz/frontend

RUN mkdir -p /temp/frontend
COPY package.json bun.lock /temp/frontend/
RUN cd /temp/frontend && \
    bun install --frozen-lockfile

FROM node:22-bookworm-slim

WORKDIR /fuiz
# Copy built binaries and website
COPY --from=builder /fuiz/corkboard/target/release /fuiz/corkboard
COPY --from=builder /fuiz/backend/target/release /fuiz/backend
COPY --from=frontend-builder /temp/frontend/node_modules /fuiz/frontend/node_modules
COPY build /fuiz/frontend/build
COPY frontend/package-build.json /fuiz/frontend/package.json

EXPOSE 5173 5040 8080 8787
VOLUME ["/fuiz/data"]

CMD ["/fuiz/corkboard/corkboard", "&", "/fuiz/backend/fuiz-server", "&", "node", "-r", "/fuiz/frontend/dotenv/config", "/fuiz/frontend/build"]