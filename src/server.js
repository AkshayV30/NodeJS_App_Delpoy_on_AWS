import express, { json } from 'express';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { requestMiddleware } from './middleware.js';
import routes from './routes.js';

const publicDirectory = join(dirname(fileURLToPath(import.meta.url)), 'public');

export function createApp() {
  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', process.env.TRUST_PROXY === 'true' ? 1 : false);
  app.use(requestMiddleware);
  app.use(json({ limit: '16kb', strict: true }));
  app.use('/assets', express.static(publicDirectory));
  app.use(routes);

  app.use((_req, res) => {
    res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Route not found' } });
  });

  app.use((err, req, res, _next) => {
    const status = Number.isInteger(err.status) && err.status >= 400 && err.status < 500
      ? err.status
      : 500;
    const code = status === 400 ? 'INVALID_REQUEST' : status === 413 ? 'REQUEST_TOO_LARGE' : 'INTERNAL_ERROR';

    console.error(JSON.stringify({
      level: 'error',
      event: 'request_error',
      requestId: req.requestId,
      status,
      message: err.message,
    }));

    res.status(status).json({
      error: {
        code,
        message: status === 500 ? 'An unexpected error occurred' : err.message,
        requestId: req.requestId,
      },
    });
  });

  return app;
}
