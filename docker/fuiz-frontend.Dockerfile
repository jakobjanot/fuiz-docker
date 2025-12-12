# syntax=docker/dockerfile:1

FROM node:22-bookworm-slim AS build
WORKDIR /app

# Install deps first (better layer caching)
COPY upstream/fuiz-frontend/package.json ./
COPY upstream/fuiz-frontend/package-lock.json* ./
COPY upstream/fuiz-frontend/npm-shrinkwrap.json* ./
RUN npm install

# Copy source
COPY upstream/fuiz-frontend/ ./

# Public env vars are baked into the static build
ARG PUBLIC_DISPLAY_PLAY_URL=http://localhost:5173
ARG PUBLIC_PLAY_URL=http://localhost:5173
ARG PUBLIC_BACKEND_URL=http://localhost:8787
ARG PUBLIC_WS_URL=ws://localhost:8787
ARG PUBLIC_CORKBOARD_URL=http://localhost:43907

ENV PUBLIC_DISPLAY_PLAY_URL=$PUBLIC_DISPLAY_PLAY_URL \
    PUBLIC_PLAY_URL=$PUBLIC_PLAY_URL \
    PUBLIC_BACKEND_URL=$PUBLIC_BACKEND_URL \
    PUBLIC_WS_URL=$PUBLIC_WS_URL \
    PUBLIC_CORKBOARD_URL=$PUBLIC_CORKBOARD_URL

RUN npm run build

FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
