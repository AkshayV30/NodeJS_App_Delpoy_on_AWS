import express from 'express';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { requestMiddleware } from './middleware.js';
import routes from './routes.js';

const publicDirectory = join(dirname(fileURLToPath(import.meta.url)), 'public');

/**
 * Create the Express application without opening a network listener.
 * Keeping startup separate makes the app straightforward to exercise in tests.
 */
export function createApp() {
  const app = express();

  app.disable('x-powered-by');
  app.set('trust proxy', process.env.TRUST_PROXY === 'true' ? 1 : false);
  app.use(requestMiddleware);
  app.use(express.json({ limit: '16kb', strict: true }));
  app.use('/assets', express.static(publicDirectory));
  app.use(routes);

  app.use((_req, res) => {
    res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Route not found' } });
  });

  app.use((err, req, res, _next) => {
    const error = err instanceof Error ? err : new Error('Request failed');
    const status = Number.isInteger(error.status) && error.status >= 400 && error.status < 500
      ? error.status
      : 500;
    const code = status === 400
      ? 'INVALID_REQUEST'
      : status === 413
        ? 'REQUEST_TOO_LARGE'
        : 'INTERNAL_ERROR';

    console.error(JSON.stringify({
      level: 'error',
      event: 'request_error',
      requestId: req.requestId,
      status,
      message: error.message,
    }));

    res.status(status).json({
      error: {
        code,
        message: status === 500 ? 'An unexpected error occurred' : error.message,
        requestId: req.requestId,
      },
    });
  });

  return app;
}
