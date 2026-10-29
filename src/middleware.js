import { randomUUID } from 'node:crypto';

export function requestMiddleware(req, res, next) {
  const suppliedId = req.get('x-request-id');
  const requestId = suppliedId && /^[a-zA-Z0-9._-]{1,80}$/.test(suppliedId)
    ? suppliedId
    : randomUUID();

  req.requestId = requestId;
  res.setHeader('x-request-id', requestId);
  res.setHeader('x-content-type-options', 'nosniff');
  res.setHeader('x-frame-options', 'DENY');
  res.setHeader('referrer-policy', 'no-referrer');
  res.setHeader('cache-control', 'no-store');

  const started = process.hrtime.bigint();
  res.once('finish', () => {
    const durationMs = Number(process.hrtime.bigint() - started) / 1e6;
    console.log(JSON.stringify({
      level: 'info',
      event: 'http_request',
      requestId,
      method: req.method,
      path: req.path,
      status: res.statusCode,
      durationMs: Math.round(durationMs * 100) / 100,
    }));
  });

  next();
}
