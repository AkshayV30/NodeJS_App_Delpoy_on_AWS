import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { APP_VERSION } from './config.js';
import { createApp } from './app.js';

export function startServer() {
  const port = Number.parseInt(process.env.PORT || '3000', 10);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer from 1 to 65535');
  }

  const server = createApp().listen(port, '0.0.0.0');

  server.once('listening', () => {
    console.log(JSON.stringify({
      level: 'info',
      event: 'server_started',
      port,
      environment: process.env.NODE_ENV || 'development',
      version: APP_VERSION,
    }));
  });

  server.once('error', (error) => {
    console.error(JSON.stringify({
      level: 'error',
      event: 'server_start_failed',
      message: error.message,
    }));
    process.exitCode = 1;
  });

  let shuttingDown = false;
  function shutdown(signal) {
    if (shuttingDown) return;
    shuttingDown = true;
    console.log(JSON.stringify({ level: 'info', event: 'shutdown_started', signal }));

    const timeout = setTimeout(() => {
      console.error(JSON.stringify({ level: 'error', event: 'shutdown_timed_out' }));
      process.exit(1);
    }, 10000).unref();

    server.close((error) => {
      clearTimeout(timeout);
      if (error) {
        console.error(JSON.stringify({
          level: 'error',
          event: 'shutdown_failed',
          message: error.message,
        }));
        process.exitCode = 1;
        return;
      }
      console.log(JSON.stringify({ level: 'info', event: 'shutdown_complete' }));
    });
  }

  process.once('SIGTERM', () => shutdown('SIGTERM'));
  process.once('SIGINT', () => shutdown('SIGINT'));
  return server;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  startServer();
}
