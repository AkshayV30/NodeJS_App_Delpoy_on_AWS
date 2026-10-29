import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';

const require = createRequire(import.meta.url);
const packageJson = JSON.parse(
  readFileSync(new URL('../package.json', import.meta.url), 'utf8'),
);
const expressPackage = require('express/package.json');

export const APP_NAME = packageJson.name;
export const APP_VERSION = process.env.APP_VERSION || packageJson.version;
export const EXPRESS_VERSION = expressPackage.version;
