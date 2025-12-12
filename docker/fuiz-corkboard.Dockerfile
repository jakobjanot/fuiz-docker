# syntax=docker/dockerfile:1

FROM rust:slim-trixie AS build
WORKDIR /src

# Copy source from the upstream clone pulled by scripts/fetch-upstream.sh
COPY upstream/fuiz-corkboard/ ./

# Build a release binary
RUN cargo build --release

FROM debian:trixie-slim
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /src/target/release/corkboard /app/corkboard

EXPOSE 5040

CMD ["/app/corkboard"]
