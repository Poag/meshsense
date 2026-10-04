# meshsense

Unraid-friendly Docker image for [MeshSense](https://github.com/Affirmatech/MeshSense), the Meshtastic network monitor and mapper from Affirmatech. It runs MeshSense's API and web UI headless, built from upstream source.

Image: `ghcr.io/poag/meshsense:latest`. It is rebuilt daily from upstream `master`.

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
| `ACCESS_KEY` | empty | Key that grants full permissions to remote (non-localhost) clients. Without it, connect/disconnect/send/position changes are refused from other machines. |
| `PORT` | `5920` | Port the web UI listens on inside the container. |
| `PUID` / `PGID` | `99` / `100` | User and group that own `/config` and run the process (Unraid `nobody:users`). |

State is stored in `/config/meshsense`. Mount `/config` as a directory.

## Limits

- Connect to the node over WiFi/TCP. Bluetooth and USB serial are not set up in the container, and the logged D-Bus errors at startup are harmless.
- The app calls out to `affirmatech.com` for its news check and to `meshsense.affirmatech.com` for map forwarding, so it needs internet access.

## Build

```sh
docker build -t meshsense .
# pin a specific upstream release
docker build --build-arg MESHSENSE_REF=v1.1.0-beta.8 -t meshsense .
```

The Unraid template is in [Poag/docker-xml](https://github.com/Poag/docker-xml) as `templates/meshsense.xml`.
