const port = process.env.PORT || '3000';
const url = process.env.HEALTH_CHECK_URL || `http://127.0.0.1:${port}/health/ready`;

async function checkHealth() {
  try {
    const response = await fetch(url, { signal: AbortSignal.timeout(4000) });
    await response.body?.cancel();
    if (!response.ok) process.exitCode = 1;
  } catch {
    process.exitCode = 1;
  }
}

checkHealth();
