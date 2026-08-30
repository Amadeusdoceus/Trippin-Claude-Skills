// H15.3 / decisão de tecnologia #10 (00-F §10) — suíte de qualidade que roda
// via `npm run review` antes de qualquer push, garantindo que nenhuma tela
// quebra. Cresce junto com cada feature (ver 00-F §10, trade-off aceito).
//
// Nota de arquitetura de teste: este projeto não tem um Supabase de staging
// separado (decisão não tomada nesta entrega) — os testes rodam contra o
// mesmo banco de produção usado pelo app real, com uma conta dedicada
// (E2E_TEST_EMAIL/E2E_TEST_PASSWORD, guardada como secret do GitHub Actions,
// nunca commitada) criada uma única vez e reutilizada a cada execução, para
// não acumular contas novas no banco a cada push. As viagens criadas por
// cada execução, por outro lado, **acumulam** — a tabela `trips` não tem uma
// política de DELETE (nenhuma tela do produto oferece excluir viagem), então
// o teste não consegue se autolimpar. São linhas pequenas sem custo real;
// uma limpeza periódica manual (mesmo padrão usado por engenharia durante o
// desenvolvimento) é a mitigação aceita em vez de dar à suíte de testes uma
// chave `service_role` só para isso.
const { test, expect } = require('@playwright/test');

const EMAIL = process.env.E2E_TEST_EMAIL;
const PASSWORD = process.env.E2E_TEST_PASSWORD;

test.beforeAll(() => {
  if (!EMAIL || !PASSWORD) {
    throw new Error('E2E_TEST_EMAIL / E2E_TEST_PASSWORD não definidos — configure as variáveis de ambiente (ou os secrets do GitHub Actions) antes de rodar `npm run review`.');
  }
});

test('fluxo principal não quebra nenhuma tela', async ({ page }) => {
  const pageErrors = [];
  page.on('pageerror', (err) => pageErrors.push(String(err)));

  await page.goto('/index.html');
  await page.getByRole('button', { name: 'Português' }).click();

  // Login (conta de e2e persistente, não signup — evita acumular usuários novos a cada execução).
  await page.getByText('Já tenho conta').click();
  await page.locator('input[type=email]').fill(EMAIL);
  await page.locator('input[type=password]').fill(PASSWORD);
  await page.getByRole('button', { name: 'Entrar' }).click();
  await expect(page.getByText('Suas viagens')).toBeVisible({ timeout: 15_000 });

  // Cria uma viagem nova nesta execução (nome com timestamp, para não colidir com viagens de execuções anteriores).
  const tripName = `E2E CI ${Date.now()}`;
  await page.getByRole('button', { name: 'Criar viagem' }).click();
  await expect(page.getByText('Nome da viagem')).toBeVisible();
  const formInputs = page.locator('form input');
  await formInputs.nth(0).fill(tripName);
  const today = new Date();
  const end = new Date(today.getTime() + 5 * 86400000);
  const iso = (d) => d.toISOString().slice(0, 10);
  const dateInputs = page.locator('input[type=date]');
  await dateInputs.nth(0).fill(iso(today));
  await dateInputs.nth(1).fill(iso(end));
  await page.getByRole('button', { name: 'Salvar' }).click();
  await expect(page.getByText('Cronograma')).toBeVisible({ timeout: 10_000 });

  // Visita as 7 abas da Viagem — cada uma precisa renderizar sem estourar erro de página.
  const tabs = ['Cronograma', 'Despesas', 'Mapa', 'Docs', 'Galeria', 'Sugestões', 'Integrantes'];
  for (const tab of tabs) {
    await page.getByRole('button', { name: tab, exact: true }).click();
    await page.waitForTimeout(400); // dá tempo para o fetch da aba (Mapa/Docs fazem chamadas assíncronas)
  }

  // Drawer — acessível de qualquer tela (H13.1), deve mostrar os 4 itens.
  await page.locator('.top-bar .icon-btn').first().click();
  await expect(page.getByText('Notificações')).toBeVisible();
  await expect(page.getByText('Configurações')).toBeVisible();
  await expect(page.getByText('Privacidade e dados')).toBeVisible();
  await expect(page.getByText('Sair')).toBeVisible();

  // Notificações (E13) e Privacidade e dados (E14) — telas novas desta fase, cada uma precisa abrir sem quebrar.
  await page.getByText('Notificações').click();
  await page.waitForTimeout(600);
  await page.locator('.icon-btn').first().click(); // volta para Home

  await page.locator('.top-bar .icon-btn').first().click();
  await page.getByText('Privacidade e dados').click();
  await page.waitForTimeout(600);

  expect(pageErrors, `erros de página não tratados: ${pageErrors.join(' | ')}`).toEqual([]);
});
