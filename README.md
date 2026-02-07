# Registry

Deploy a private [Docker Registry](https://distribution.github.io/distribution/) on Railway, backed by S3 storage with basic auth.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/xxx)

## Setup

1. Click the Railway button above
2. Add an **S3** service
3. Set the required environment variables below
4. Deploy

## Environment Variables

| Variable | Description |
|---|---|
| `REGISTRY_USERNAME` | Username for `docker login` |
| `REGISTRY_PASSWORD` | Password for `docker login` |
| `REGISTRY_SECRET` | Random string used to sign tokens internally |
| `AWS_ACCESS_KEY_ID` | Provided by Railway S3 service |
| `AWS_SECRET_ACCESS_KEY` | Provided by Railway S3 service |
| `AWS_DEFAULT_REGION` | Provided by Railway S3 service |
| `AWS_ENDPOINT_URL` | Provided by Railway S3 service |
| `AWS_S3_BUCKET_NAME` | Provided by Railway S3 service |

`RAILWAY_SERVICE_NAME` and `RAILWAY_ENVIRONMENT_NAME` are injected automatically by Railway.

## Usage

```sh
docker login <your-railway-domain>
docker tag myimage <your-railway-domain>/myimage:latest
docker push <your-railway-domain>/myimage:latest
docker pull <your-railway-domain>/myimage:latest
```

## Notes

- Images are stored in S3, not on disk
- Credentials are regenerated from env vars on each deploy, so password changes take effect immediately
- Image deletion is enabled by default
- Source: [distribution/distribution](https://github.com/distribution/distribution)
