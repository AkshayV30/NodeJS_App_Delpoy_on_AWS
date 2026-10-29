import { Router } from 'express';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { APP_NAME, APP_VERSION, EXPRESS_VERSION } from './config.js';

const router = Router();
const viewsDirectory = join(dirname(fileURLToPath(import.meta.url)), 'views');
const startedAt = new Date();

router.get('/health/live', (_req, res) => {
  res.status(200).json({ status: 'alive' });
});

router.get('/health/ready', (_req, res) => {
  res.status(200).json({ status: 'ready' });
});

router.get('/api/v1/info', (_req, res) => {
  res.json({
    name: APP_NAME,
    version: APP_VERSION,
    environment: process.env.NODE_ENV || 'development',
    platform: process.env.APP_PLATFORM
      || (process.env.ECS_CONTAINER_METADATA_URI_V4 ? 'Amazon ECS' : 'Local or self-hosted'),
    runtime: `Node.js ${process.version}`,
    framework: `Express ${EXPRESS_VERSION}`,
    port: Number.parseInt(process.env.PORT || '3000', 10),
    uptimeSeconds: Math.floor(process.uptime()),
    startedAt: startedAt.toISOString(),
  });
});

router.get('/', (_req, res) => {
  res.sendFile(join(viewsDirectory, 'home.html'));
});

export default router;
