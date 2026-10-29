import { after, before, describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { app } from '../src/app.js';

let server;
let baseUrl;

before(async () => {
  server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve())));

describe('service HTTP contract', () => {
  it('serves liveness and readiness checks', async () => {
    for (const path of ['/health/live', '/health/ready']) {
      const response = await fetch(`${baseUrl}${path}`);
      assert.equal(response.status, 200);
      assert.equal((await response.json()).status, path.endsWith('live') ? 'alive' : 'ready');
    }
  });

  it('returns operational service metadata', async () => {
    const response = await fetch(`${baseUrl}/api/v1/info`);
    const body = await response.json();
    assert.equal(response.status, 200);
    assert.equal(body.name, 'pearl-node-service');
    assert.ok(body.uptimeSeconds >= 0);
    assert.ok(body.startedAt);
  });

  it('serves the demo page and its stylesheet', async () => {
    const response = await fetch(baseUrl);
    const html = await response.text();
    assert.equal(response.status, 200);
    assert.match(html, /AWS ECS Fargate/);
    assert.match(html, /\/assets\/css\/styles\.css/);
    assert.equal(response.headers.get('x-content-type-options'), 'nosniff');
    assert.equal(response.headers.get('x-frame-options'), 'DENY');
    assert.ok(response.headers.get('x-request-id'));

    const stylesheet = await fetch(`${baseUrl}/assets/css/styles.css`);
    assert.equal(stylesheet.status, 200);
    assert.match(await stylesheet.text(), /\.card/);
  });

  it('preserves a safe caller request ID', async () => {
    const response = await fetch(`${baseUrl}/health/live`, { headers: { 'x-request-id': 'demo-request-42' } });
    assert.equal(response.headers.get('x-request-id'), 'demo-request-42');
  });

  it('returns a consistent JSON 404 response', async () => {
    const response = await fetch(`${baseUrl}/missing`);
    assert.equal(response.status, 404);
    assert.deepEqual(await response.json(), { error: { code: 'NOT_FOUND', message: 'Route not found' } });
  });

  it('returns a request ID and safe JSON error for malformed JSON', async () => {
    const response = await fetch(`${baseUrl}/api/v1/info`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: '{bad json',
    });
    assert.equal(response.status, 400);
    assert.ok(response.headers.get('x-request-id'));
    assert.equal((await response.json()).error.code, 'INVALID_REQUEST');
  });
});
