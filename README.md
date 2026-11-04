# Registry

Deploy a private [Docker Registry](https://distribution.github.io/distribution/) on Railway, backed by S3 storage with basic auth.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/registry?referralCode=hbN2rY&utm_medium=integration&utm_source=template&utm_campaign=generic)

## Setup

1. Click the Railway button above
2. Add an **S3** service
3. Set the required environment variables below
4. Deploy

## Environment Variables

| Variable | Description |
|---|---|
| `AUTH_USERNAME` | Username for `docker login` |
| `AUTH_PASSWORD` | Password for `docker login` |
| `HTTP_SECRET` | Random string used to sign tokens internally |
| `AWS_ACCESS_KEY_ID` | Provided by Railway S3 service |
| `AWS_SECRET_ACCESS_KEY` | Provided by Railway S3 service |
| `AWS_DEFAULT_REGION` | Provided by Railway S3 service |
| `AWS_ENDPOINT_URL` | Provided by Railway S3 service |
| `AWS_S3_BUCKET_NAME` | Provided by Railway S3 service |
| `GARBAGE_COLLECT_ON_START` | Optional. `true` frees the storage of deleted images at every start; see [Cleanup](#cleanup) |

`RAILWAY_SERVICE_NAME` and `RAILWAY_ENVIRONMENT_NAME` are injected automatically by Railway.

## Usage

```sh
docker login <your-railway-domain>
docker tag myimage <your-railway-domain>/myimage:latest
docker push <your-railway-domain>/myimage:latest
docker pull <your-railway-domain>/myimage:latest
```

## Cleanup

Deleting an image (`DELETE /v2/<name>/manifests/<digest>`) removes only its manifest. Its layers stay in the bucket, and keep costing storage, until garbage collection removes every blob that no manifest references. The registry never runs it by itself.

**On every start (opt-in).** Set `GARBAGE_COLLECT_ON_START=true` and deploy the change (the dashboard stages variable changes until you deploy them; `railway variables --set` deploys at once). That deploy runs the first cleanup, and every later deploy or restart runs it again before the registry serves, so no push can race it. The deploy log shows the result (`... blobs eligible for deletion`). If collection fails, the log shows a warning and the registry starts anyway. A large bucket makes startup slower, since every manifest and blob is listed first.

**Once, by hand.** From a directory linked to the project (`railway link`), with nothing pushing:

```sh
railway ssh -- registry garbage-collect --dry-run /etc/distribution/config.yml
railway ssh -- registry garbage-collect /etc/distribution/config.yml
```

Pushing a tag again (`:latest`) doesn't delete the image it replaces: that manifest stays, untagged, and so do its layers. In a repository pushed to often, these old manifests hold most of the storage, and the registry's API can't list them: they are the `link` files under `docker/registry/v2/repositories/<name>/_manifests/revisions/sha256/<digest>/` in the bucket, and `DELETE /v2/<name>/manifests/sha256:<digest>` deletes each. `registry garbage-collect --delete-untagged` would remove them, but it is known to delete parts of multi-arch images that are still tagged (distribution/distribution#3004, #4939), so neither option here uses it.

## Notes

- Images are stored in S3, not on disk
- Credentials are regenerated from env vars on each deploy, so changes to `AUTH_USERNAME` or `AUTH_PASSWORD` take effect immediately
- Image deletion is enabled by default; deleting frees storage only after [cleanup](#cleanup)
- Source: [distribution/distribution](https://github.com/distribution/distribution)
