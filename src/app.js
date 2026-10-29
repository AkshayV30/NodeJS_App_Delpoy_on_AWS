import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { APP_VERSION } from './config.js';
import { createApp } from './server.js';

export const app = createApp();

export function startServer() {
  const port = Number.parseInt(process.env.PORT || '3000', 10);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer from 1 to 65535');
  }

  const server = app.listen(port, '0.0.0.0', () => {
    console.log(JSON.stringify({
      level: 'info',
      event: 'server_started',
      port,
      environment: process.env.NODE_ENV || 'development',
      version: APP_VERSION,
    }));
  });

  let shuttingDown = false;
  function shutdown(signal) {
    if (shuttingDown) return;
    shuttingDown = true;
    console.log(JSON.stringify({ level: 'info', event: 'shutdown_started', signal }));

    const timeout = setTimeout(() => {
      console.error('Graceful shutdown timed out');
      process.exit(1);
    }, 10000).unref();

    server.close((error) => {
      clearTimeout(timeout);
      if (error) {
        console.error(error);
        process.exit(1);
      }
      console.log(JSON.stringify({ level: 'info', event: 'shutdown_complete' }));
      process.exit(0);
    });
  }

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
  return server;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  startServer();
}
