# syntax=docker/dockerfile:1

FROM rust:slim-trixie AS build
WORKDIR /src

# Copy source from the upstream submodule
COPY upstream/fuiz-backend/ ./

# Build a release binary
RUN cargo build --release

FROM debian:trixie-slim
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /src/target/release/fuiz-server /app/fuiz-server

ENV PORT=8080
EXPOSE 8080

CMD ["/app/fuiz-server"]
