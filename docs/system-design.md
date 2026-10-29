# System design

## Application structure

```text
src/
├── app.js                 # Creates and configures the Express app
├── server.js              # Validates configuration, listens, and shuts down cleanly
├── config.js              # Service name, version, and Express version
├── middleware.js          # Request IDs, response headers, and structured request logs
├── routes.js              # Page, service-info, and health endpoints
├── healthcheck.js         # HTTP readiness probe used by Docker and ECS
├── public/                # Static CSS and browser-side page behavior
└── views/home.html        # Demo landing page
```

`createApp()` builds the Express application without opening a network listener. This keeps HTTP behavior testable without starting a separate server. `server.js` is the process entry point: it validates `PORT`, listens on `0.0.0.0`, logs startup, and handles `SIGTERM`/`SIGINT` by closing the server with a timeout.

## Request flow

1. The request middleware assigns or validates a request ID, adds baseline response headers, and logs the method, path, status, and duration as JSON.
2. Express parses JSON bodies with a `16kb` limit.
3. Static browser assets are served from `/assets` and application routes handle the page and APIs.
4. Unknown routes receive a consistent JSON `404`; the error handler returns safe JSON errors and includes the request ID.

The landing page fetches `/api/v1/info` and `/health/ready` to display live service metadata and current readiness. Service metadata includes the package/app version, Node.js and Express versions, configured platform/environment, port, process uptime, and startup time.

## Health checks

- `/health/live` returns `200` while the process can handle requests.
- `/health/ready` returns `200` while the application is ready to accept traffic.
- `src/healthcheck.js` requests the readiness endpoint with a four-second timeout and exits non-zero if it cannot reach a successful response.
- Docker and the ECS task definition call this same health-check script. The Application Load Balancer independently probes `/health/ready`.

Readiness currently means the process is available. If the application gains a database or another required service, extend readiness to check that dependency with a bounded timeout.

## Reliability and security choices

- The Docker runtime uses the built-in non-root `node` user and installs production dependencies only.
- Express hides its identifying header, bounds JSON request bodies, and supports trusting one proxy hop only when `TRUST_PROXY=true` is explicitly set.
- Error responses avoid leaking internal details for server errors; structured logs retain request IDs for correlation.
- Graceful shutdown lets the HTTP server stop accepting new work before the process exits.
- The ECR image uses a run-specific tag; the deployment action registers a new ECS task definition revision pointing at that exact image before updating the service.

These are educational production-minded patterns. They do not make the sample a production-ready system; see [Architecture](architecture.md) for the demo network boundaries and [AWS deployment](aws-deployment.md) for setup constraints.
