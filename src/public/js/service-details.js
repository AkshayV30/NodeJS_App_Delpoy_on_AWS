const detailFields = {
  name: 'service-name',
  version: 'service-version',
  environment: 'service-environment',
  platform: 'service-platform',
  runtime: 'service-runtime',
  framework: 'service-framework',
  port: 'service-port',
  startedAt: 'service-started-at',
};

const statusElement = document.querySelector('#service-status');
const uptimeElement = document.querySelector('#service-uptime');
const environmentElement = document.querySelector('#environment-badge');

function formatUptime(totalSeconds) {
  const seconds = Math.max(0, Number(totalSeconds) || 0);
  const days = Math.floor(seconds / 86_400);
  const hours = Math.floor((seconds % 86_400) / 3_600);
  const minutes = Math.floor((seconds % 3_600) / 60);
  const remainingSeconds = seconds % 60;
  const parts = [];

  if (days) parts.push(`${days}d`);
  if (hours || days) parts.push(`${hours}h`);
  if (minutes || hours || days) parts.push(`${minutes}m`);
  parts.push(`${remainingSeconds}s`);
  return parts.join(' ');
}

async function refreshServiceDetails() {
  try {
    const [infoResponse, readinessResponse] = await Promise.all([
      fetch('/api/v1/info', { cache: 'no-store', signal: AbortSignal.timeout(5000) }),
      fetch('/health/ready', { cache: 'no-store', signal: AbortSignal.timeout(5000) }),
    ]);

    if (!infoResponse.ok) throw new Error('Service information is unavailable');
    const info = await infoResponse.json();

    for (const [field, elementId] of Object.entries(detailFields)) {
      const element = document.getElementById(elementId);
      if (element) element.textContent = info[field] ?? 'Unavailable';
    }

    if (uptimeElement) uptimeElement.textContent = formatUptime(info.uptimeSeconds);
    if (environmentElement) environmentElement.textContent = info.environment ?? 'unknown';

    const ready = readinessResponse.ok;
    statusElement.textContent = ready ? 'Service is ready' : 'Service is not ready';
    statusElement.dataset.state = ready ? 'ready' : 'error';
  } catch {
    statusElement.textContent = 'Service details unavailable';
    statusElement.dataset.state = 'error';
  }
}

refreshServiceDetails();
window.setInterval(refreshServiceDetails, 15_000);
