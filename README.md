# meshsense

Unraid-friendly Docker image for [MeshSense](https://github.com/Affirmatech/MeshSense), the Meshtastic network monitor and mapper from Affirmatech. It runs MeshSense's API and web UI headless, built from upstream source.

Image: `ghcr.io/poag/meshsense:latest` (multi-arch: `linux/amd64` and `linux/arm64`, each built on a native runner). It is rebuilt on every push to `main` and monthly (1st of the month, uncached, with fresh base images) so it picks up upstream `master` and OS/Node security updates. Run the workflow manually from the Actions tab for an out-of-band rebuild.

## Run

```sh
docker run -d --name meshsense \
  -p 5920:5920 \
  -e ADDRESS=192.168.1.50 \
  -e ACCESS_KEY=changeme \
  -v /mnt/user/appdata/meshsense:/config \
  ghcr.io/poag/meshsense:latest
```

Open `http://<host>:5920`.

| Variable | Default | Purpose |
| --- | --- | --- |
| `ADDRESS` | empty | IP/hostname of the Meshtastic node (WiFi/TCP). Connects on startup. Can also be set in the UI. |
| `ACCESS_KEY` | empty | Optional Bearer token that grants full API permissions to remote clients. Upstream already trusts IPv4 clients (`::ffff:` addresses), so this is not a web UI login; do not expose the port to the internet. |
| `PORT` | `5920` | Port the web UI listens on inside the container. |
| `PUID` / `PGID` | `99` / `100` | User and group that own `/config` and run the process (Unraid `nobody:users`). |

State is stored in `/config/meshsense`. Mount `/config` as a directory.

## Limits

- Connect to the node over WiFi/TCP. Bluetooth and USB serial are not set up in the container, and the logged D-Bus errors at startup are harmless.
- The app checks `affirmatech.com` for news, and sends node data to `meshsense.affirmatech.com` only if you enable map forwarding in the UI. Override that endpoint with `MESHMAP_URL`.

## Build

```sh
docker build -t meshsense .
# pin a specific upstream release
docker build --build-arg MESHSENSE_REF=v1.1.0-beta.8 -t meshsense .
```

The Unraid template is in [Poag/docker-xml](https://github.com/Poag/docker-xml) as `templates/meshsense.xml`.
