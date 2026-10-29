import { Router } from 'express';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { APP_VERSION } from './config.js';

const router = Router();
const viewsDirectory = join(dirname(fileURLToPath(import.meta.url)), 'views');
const startedAt = new Date();

router.get(
  '/health/live', 
  (_req, res) => res.status(200).json({ status: 'alive' }));

router.get(
  '/health/ready',
   (_req, res) => res.status(200).json({ status: 'ready' }));

router.get(
  '/api/v1/info',
   (_req, res) => {
            res.json({
              name: 'pearl-node-service',
              version: APP_VERSION,
              environment: process.env.NODE_ENV || 'development',
              runtime: `Node.js ${process.versions.node}`,
              uptimeSeconds: Math.floor(process.uptime()),
              startedAt: startedAt.toISOString(),
            });
});

router.get('/', (_req, res) => {
  res.sendFile(join(viewsDirectory, 'home.html'));
});

export default router;
