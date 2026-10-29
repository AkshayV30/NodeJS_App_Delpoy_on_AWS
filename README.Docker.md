# Container quick start

Build and run the production image locally:

```sh
docker build -t pearl-node-service .
docker run --rm -p 3000:3000 pearl-node-service
```

The container runs as the non-root `node` user, sets `NODE_ENV=production`, and includes a readiness health check. See [README.md](README.md) for API endpoints, local development, testing, and AWS deployment details.
