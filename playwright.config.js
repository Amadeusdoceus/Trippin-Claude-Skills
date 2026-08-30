// H15.3 / decisão de tecnologia #10 (00-F §10) — segunda metade da suíte de
// qualidade: garante que nenhuma tela quebra antes de qualquer push chegar
// ao GitHub Pages. Roda contra web/index.html servido estaticamente (o app
// não tem build — decisão #1), usando o Supabase de produção real (não
// existe projeto de staging separado; ver nota em tests/e2e/smoke.spec.js).
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests/e2e',
  timeout: 45_000,
  expect: { timeout: 10_000 },
  fullyParallel: false, // os testes compartilham a mesma conta de e2e persistente — rodar em série evita corrida entre eles
  retries: process.env.CI ? 1 : 0, // só reduz flakiness real de rede; nunca esconde um erro de sintaxe/render de verdade
  reporter: process.env.CI ? [['list'], ['html', { open: 'never' }]] : 'list',
  use: {
    baseURL: 'http://localhost:4173',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
  webServer: {
    command: 'npx --yes serve web -l 4173',
    url: 'http://localhost:4173/index.html',
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
  },
});
