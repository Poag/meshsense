# MeshSense (https://github.com/Affirmatech/MeshSense) as a headless web service.
# Built from upstream source; connect to a Meshtastic node over WiFi/TCP.

FROM node:22-bookworm AS build

RUN apt-get update \
 && apt-get install -y --no-install-recommends cmake build-essential libdbus-1-dev \
 && rm -rf /var/lib/apt/lists/*

# Upstream branch, tag or commit to build (e.g. master, v1.1.0-beta.8)
ARG MESHSENSE_REF=master
RUN git clone --recurse-submodules --shallow-submodules --depth 1 --branch "${MESHSENSE_REF}" \
      https://github.com/Affirmatech/MeshSense.git /src
WORKDIR /src

# Submodules the API imports at build time
RUN cd api/webbluetooth && npm i --ignore-scripts && npx cmake-js compile && npx tsc
RUN cd api/meshtastic-js && npm ci && npm run build

# The UI imports api/src/vars, so the API dependencies must be installed first
RUN cd api && npm ci
RUN cd ui && npm ci && npm run build
RUN cd api && npx rollup -c && node copyfiles.js

FROM node:22-bookworm-slim

# libdbus is linked by the bundled simpleble.node; util-linux provides setpriv
RUN apt-get update \
 && apt-get install -y --no-install-recommends libdbus-1-3 util-linux \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /src/api/dist ./dist
COPY --from=build /src/api/prebuilds ./prebuilds
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Persistent state lives in $XDG_DATA_HOME/meshsense
ENV PORT=5920 \
    XDG_DATA_HOME=/config \
    PUID=99 \
    PGID=100

VOLUME /config
EXPOSE 5920

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "dist/index.cjs"]
