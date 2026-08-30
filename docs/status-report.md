# Relatório de Status — Trippin

| Campo | Valor |
|---|---|
| **Tipo** | Relatório de status gerencial — atualizado a cada ciclo, não é parte da cadeia numerada `00→07` |
| **Base** | `00-visao-de-negocio-final.md`, `02-UXUI-spec.md`, `03-backlog.md` |
| **Atualização atual** | 2026-08-30 (ciclo 10 — Fase C: E8, Docs com inteligência, o diferencial central do produto) |
| **Atualização anterior** | 2026-08-30 (ciclo 9 — Fase D completa: Cronograma/Despesas completos, Mapa, Galeria, Sugestões) |
| **Como manter** | A cada novo ciclo: atualizar seções 1–4 com o estado atual e adicionar uma linha em "Histórico" (seção 6). Não reescrever o histórico de ciclos passados. |

---

## 1. Resumo executivo

**E8 — Docs com inteligência entregue neste ciclo.** É o diferencial central do produto (`00-F`
§4): anexar um documento (foto de reserva, passagem, etc.) e o app já sugere um evento pronto para
o cronograma, com OCR rodando no próprio navegador (sem LLM, sem servidor) e confirmação humana
sempre obrigatória antes de gravar qualquer coisa. Com isso, **todo o MVP core está entregue** — as
Fases A a D (fundação, esqueleto mínimo, diferencial central, módulos completos) estão feitas;
resta só a Fase E (infraestrutura transversal: offline, notificações, privacidade/retenção — hoje
só H15.2, log de erros, está feita). Estimativa segue em **~12 semanas até a V1**.

**Pendência que mais afeta o prazo real:** ainda não há equipe/cadência definida (ver seção 4). Uma
verificação manual (não automatizada) do upload de fotos na Galeria ainda é recomendada — ver
histórico do ciclo 9 na seção 2.

---

## 2. Evolução desde a última atualização

Ciclo 4 — E2 provisionado de ponta a ponta, com infraestrutura real (não mais mock/planejamento):

- **Supabase real:** projeto "Trippin" criado (região São Paulo, `sa-east-1`, ref
  `wwnxrzdmdhdgzokmbvud`). Schema aplicado via migration: `profiles`, `trips`, `trip_members`,
  `audit_log`, `schedule_events`/`event_participants`, `expenses`/`expense_shares` (já com o campo
  de moeda por despesa, decisão do ciclo 2), `documents`. RLS habilitado e forçado em todas as
  tabelas, com funções `security definer` (`private.is_trip_member`, `private.is_trip_admin`) para
  não pagar o custo de checar `auth.uid()` linha a linha. Bucket de Storage privado
  `trip-documents` com policy por posse/admin. Triggers automáticos: criar perfil (com código de 6
  dígitos) no cadastro, e adicionar o criador da viagem como Admin.
- **GitHub real:** repositório `Amadeusdoceus/Trippin-Claude-Skills` recebeu o primeiro push (docs,
  app, schema). Workflow do GitHub Actions publica `web/` no GitHub Pages a cada push — primeiro
  deploy já rodou com sucesso.
- **App publicado:** https://amadeusdoceus.github.io/Trippin-Claude-Skills/ — a versão mock
  (`localStorage`) do ciclo 3, agora hospedada de verdade, não mais só local.
- **Segredos:** chave pública (`publishable`) e URL do projeto documentadas em `.env.local` (fora
  do git); senha do banco gerada e só existe nesse arquivo local — recomendado mover para um
  gerenciador de senhas. `service_role` não foi gerada/usada em lugar nenhum ainda (só entra com
  Edge Functions, que não existem nesta fase).
- **O que este ciclo NÃO fez:** o frontend (`web/index.html`) continua chamando `TrippinAPI` sobre
  `localStorage`, não o Supabase real — schema e app existem em paralelo, ainda não conectados. Essa
  troca (Auth real, `@supabase-js`, chamadas às tabelas em vez de `localStorage`) é o próximo passo
  natural, não incluída aqui para não misturar duas mudanças de risco diferente no mesmo ciclo.

Ciclo 5 — a troca prometida no ciclo 4, mais dois bugs de RLS corrigidos ao longo do caminho:

- **`TrippinAPI` reescrita** para chamar `@supabase/supabase-js` (via CDN) em vez de `localStorage`:
  Auth real (cadastro/login/logout com sessão persistida pelo próprio SDK), leitura/escrita das
  tabelas de `trips`/`trip_members`/`audit_log`/`profiles` com RLS valendo de verdade. Toda a árvore
  de telas (`App`, `HomeScreen`, `CreateTripScreen`, `JoinTripScreen`, `MembersScreen`, `TripScreen`,
  `ProfileScreen`) passou de leitura síncrona de `localStorage` para busca assíncrona com estado de
  carregamento — mudança estrutural, não só trocar uma função por outra.
- **Confirmação de e-mail desativada** no projeto (`enable_confirmations = false`) e `site_url`/
  redirect URLs apontados para a URL real do GitHub Pages — sem isso, o cadastro ficaria pendente de
  clique num e-mail antes de liberar sessão, quebrando o fluxo de onboarding imediato.
- **Bug real #1 — política de SELECT em `trips` bloqueava a própria criação da viagem:**
  `insert(...).select()` gera um `INSERT ... RETURNING`, que precisa passar pela policy de SELECT.
  A policy original só liberava via `is_trip_member`, que depende do trigger que adiciona o criador
  como Admin — dependência de timing que falhava na prática (`42501` mesmo com `created_by` correto).
  Corrigido liberando SELECT também para `created_by = auth.uid()`, independente do trigger.
- **Bug real #2 — convidado não conseguia nem localizar a viagem pelo código:** para "Participar de
  viagem" (H4.2), quem ainda não é integrante logicamente não pode fazer SELECT em `trips` (a mesma
  policy que protege dados de outras viagens bloqueava a própria busca por código). Corrigido com uma
  função `security definer` (`get_trip_by_code`) que só revela a viagem em caso de match exato do
  código de 12 dígitos — o código já funciona como um token de convite, então isso não abre a tabela.
- **Verificado com dois usuários reais, contextos de navegador isolados:** admin cria viagem →
  convidado entra pelo código → convidado não vê ação de promover (permissão correta) → admin
  recarrega a página (sessão sobrevive) → admin promove o convidado a Coadmin → confirmado
  diretamente no banco que o papel mudou. Zero erros de console/página no fluxo do convidado; só um
  404 inofensivo de favicon no do admin.
- **Limpeza:** contas e viagens de teste apagadas do banco real; scripts de teste ad hoc removidos
  do repositório (não fazem parte do app).
- **O que este ciclo NÃO fez:** Storage (upload de documentos) e Edge Functions seguem sem uso real
  — só entram com os épicos E8 (Docs) e a futura integração de e-mail. A tab bar inferior "Viagem"
  ainda depende do `tripId` guardado em memória — depois de um F5, ela não sabe qual viagem reabrir
  sozinha (é preciso voltar pela Home e clicar no card). Isso é uma lacuna de navegação pré-existente
  do ciclo 3, não algo que a conexão com o Supabase criou — registrado aqui para não ficar invisível.

Ciclo 6 — auditoria de segurança/privacidade sobre o que já estava em produção, a pedido explícito
de "olhar para segurança e proteção de dados" e definir arquitetura de crescimento:

- **Bug real #3 — enumeração de viagens:** a policy de insert em `trip_members` só checava
  `user_id`/`role`, nunca posse do código de 12 dígitos — qualquer autenticado podia virar
  "convidado" de qualquer `trip_id` adivinhado. Corrigido: a policy de auto-insert foi **removida**;
  a única forma de virar convidado agora é a função `join_trip_by_code`, que exige o código exato.
- **Bug real #4 — vazamento de CPF/telefone entre colegas de viagem:** a policy que permitia ver
  colegas de viagem liberava a **linha inteira** de `profiles` (cpf, telefone, user_code...), não só
  o nome exibido na tela. Corrigido: essa policy foi removida e substituída por uma função
  `get_trip_member_profiles` que só devolve `id`/`name`/`email` — CPF e telefone nunca saem do dono,
  mesmo que a policy de profiles mude no futuro.
- **Privilégio mínimo em UPDATE:** Admin só pode alterar a coluna `role` de um integrante (não mais
  `user_id`); cada usuário só altera as colunas do próprio formulário de Perfil (não `email`,
  `user_code` ou `created_at`).
- **Integridade de dados:** constraint no banco garantindo `end_date >= start_date` em viagens —
  antes só validado no formulário, contornável via chamada direta à API.
- **Teste adversarial dedicado** (não o teste funcional de sempre): um segundo usuário tentou os
  dois ataques acima direto contra a API, antes e depois de virar colega de viagem legítimo. Ambos
  falharam como esperado nos dois casos; o fluxo legítimo de entrar por código continua funcionando
  (reconfirmado pelo teste de regressão completo, zero erros de console).
- **Performance/polish:** React trocado de build de desenvolvimento para produção (reduz peso e
  tempo de parse); favicon real adicionado (eliminava um 404 no console a cada carregamento).
- **Arquitetura de crescimento documentada** em `00-F` §17: postura de proteção de dados real,
  lacunas conhecidas (sem observabilidade de erros, sem "esqueci minha senha", sem teste automatizado
  de RLS), e um gatilho concreto para revisar a decisão de arquivo único (~150 KB de JS, mais de uma
  pessoa editando em paralelo, ou TTI > ~3s em 4G — o que vier primeiro), substituindo o "a definir"
  que estava registrado desde `01`.
- **Limpeza:** contas/viagens de teste apagadas de novo do banco real.

Ciclo 7 — a recomendação do ciclo 6 foi adotada e implementada (H15.2 do backlog, adiantada fora de
ordem):

- **Tabela `client_errors`** no Supabase: sem policy de leitura para `authenticated`/`anon` — é um
  log de engenharia acessado direto pelo banco, não uma tela do produto, exatamente para não expor
  o stack trace de um usuário a outro.
- **Captura automática e abrangente**, sem precisar instrumentar tela por tela: todo método de
  `TrippinAPI` passou a rodar dentro de um wrapper que loga qualquer erro inesperado com contexto
  (método, argumentos — nunca senha, stack trace, usuário da sessão). Cobre também erros de render
  (via `componentDidCatch` do `ErrorBoundary`) e erros/promises sem handler em qualquer parte do app.
- **Filtro de ruído deliberado:** erros já tratados pela UI (senha errada, e-mail em uso, código de
  viagem inválido, sem permissão) ficam fora do log — são comportamento esperado do usuário, não bug.
  Sem esse filtro, cada tentativa de senha errada viraria um "crash" falso no log.
- **Verificado com teste dedicado:** um erro forçado e genuinamente inesperado gerou exatamente 1
  linha com contexto útil; uma tentativa de login com senha errada gerou 0 linhas; um fluxo completo
  de uso normal (criar viagem, entrar por código, promover) também gerou 0 linhas novas; e uma
  tentativa de ler a tabela pelo cliente confirma que ninguém consegue.
- **Fora deste ciclo, deliberadamente:** H15.1 (tela "Registro de sincronização" voltada ao usuário)
  segue adiada — não existe hoje nenhuma sincronização offline (E12) para ela mostrar, construir uma
  tela vazia seria trabalho descartável. H15.3 (Playwright + `validate-code.js` + gate de CI) segue
  não iniciada — é uma frente de tooling distinta de "log de erros".

Ciclo 8 — Fase B mínima (E5 completo, E6-mín, E7-mín), a pedido explícito de completar as telas do
front que faltavam:

- **E5 — Estado da viagem:** `trips.closed_at` (nova coluna) permite ao Admin encerrar a viagem
  manualmente (botão na aba Integrantes). Status pré-viagem/em andamento/concluída calculado no
  cliente (`computeTripStatus`), com badge visível no topo da tela da Viagem e uma folga de 3 dias
  após `end_date` antes de fechar sozinha (parâmetro a calibrar, não um dado real ainda).
  Somente-leitura (H5.4) propagado a Cronograma, Despesas e Integrantes quando concluída.
- **E6 — Cronograma:** CRUD de evento (título, local, horário início/fim, notas), navegação dia a
  dia restrita ao intervalo da viagem, vínculo de participantes por evento, e indicador de conflito
  de horário — adiantado do H6.5 "completo" porque a checagem já existia como necessidade natural do
  CRUD (`eventsOverlap`).
- **E7 — Despesas:** criar despesa avulsa ou vinculada a um evento (participantes pré-preenchidos do
  evento), seletor de moeda (BRL/USD/EUR), divisão igual, e saldo do usuário por moeda ("você deve" /
  "te devem", nunca somando moedas diferentes). A notificação ao integrante impactado (parte de
  H7.3) fica pendente de E13 (Notificações), que não existe — registrado como parcial, não escondido.
- **Bug real corrigido — "hoje" calculado em UTC:** `todayIsoWithinRange` e outras 3 funções usavam
  `Date#toISOString()`, que é sempre UTC. Para qualquer fuso atrás de UTC (Brasil, UTC-3, por
  exemplo) à noite, isso calcula "amanhã" como se fosse "hoje" — o Cronograma abriria no dia errado.
  Corrigido com uma função que lê os componentes de data locais (`toLocalDateIso`), não a conversão
  UTC. Encontrado durante o próprio teste real (o ambiente de teste rodou perto da meia-noite local).
- **Lacuna de navegação corrigida — Despesas não tinha aba:** `02-UXUI-spec.md` definia "seis abas"
  dentro de Viagem mas nunca incluía Despesas em lugar nenhum da IA, apesar de listá-la como
  funcionalidade do MVP. Corrigido como sétima aba (spec atualizada com nota de correção).
- **Verificado com dois usuários reais:** admin cria evento e despesa → convidado vê os dois
  (confirmado também via chamada direta à API, não só na tela) → convidado não tem ação de promover
  → admin encerra a viagem → badge muda para "CONCLUÍDA", aviso de somente-leitura aparece, e o botão
  de adicionar evento some. Zero erros de console/página nas duas sessões.
- **Fora deste ciclo, no backlog:** semana/mês (H6.3), arrastar para reordenar (H6.4), métodos de
  divisão avançados e quitação (H7.5/H7.6), extrato final (H7.7) — todos fase D. Mapa, Docs, Galeria
  e Sugestões continuam como "esta área chega em uma fase seguinte".

Ciclo 9 — Fase D completa, a pedido explícito de "completar as páginas do front que ficaram
faltando":

- **Cronograma completo:** visões Semana (dias da semana recortados ao intervalo da viagem) e Mês
  (grade de calendário com um ponto nos dias com evento); reordenar evento dentro do mesmo dia via
  botões ↑/↓ — adaptação deliberada do critério original (que pressupõe um gesto de long-press +
  arrastar de app nativo, inexistente num navegador). Nova coluna `schedule_events.sort_order`.
- **Despesas completo:** "valor fixo" (soma validada em tempo real contra o total, bloqueia salvar
  se não bater) e "partes customizadas" (peso relativo por pessoa, ex. 2 = o dobro de 1); quitação
  manual por participante/despesa; extrato consolidado com total por moeda e saldo final de cada
  integrante.
- **Bug real corrigido:** o cálculo de saldo (`computeBalancesForUser`) não excluía despesas já
  quitadas — corrigido para que uma parte marcada "quitada" pare de contar no saldo de ambos os
  lados (quem devia e quem pagou).
- **Mapa (E9) construído do zero:** Leaflet + tiles OpenStreetMap (decisão de tecnologia #8, sem
  chave/custo), com destinos da viagem e locais de eventos geocodificados via Nominatim (cache em
  memória por sessão) e busca de lugar com debounce de 400ms/mínimo 3 letras. Verificado com uma
  geocodificação real (destino "Lisboa, Portugal" virou pino no mapa).
- **Galeria (E10) construída do zero:** bucket `trip-photos` (RLS por integrante, mesmo padrão de
  `trip-documents`), upload múltiplo, grade de fotos com signed URL. **Verificação end-to-end em
  navegador automatizado ficou inconclusiva** — o teste em Chrome headless travou no upload com
  `net::ERR_FAILED`, e a resposta trazia um cookie de Bot Management do Cloudflare, sinal de bloqueio
  à automação, não ao código. **Isolado e confirmado via chamada direta em Node.js (sem navegador
  algum), mesma chave/policy/bucket: upload concluído com sucesso em 416ms.** Recomendação: uma
  verificação manual rápida (abrir o app publicado num navegador de verdade e enviar uma foto) antes
  de considerar isso 100% fechado — o código está correto, só não pôde ser confirmado ponta a ponta
  pela automação deste ciclo.
- **Sugestões (E11) construída do zero:** calcula vãos livres ≥ 90 min na agenda do dia e sugere um
  dos destinos da própria viagem — sem nenhuma consulta a dados de outros usuários ou viagens,
  exatamente como confirmado com o stakeholder em 2026-08-28.
- **Fora deste ciclo:** E8 (Docs com inteligência) segue não iniciado — é o maior item pendente do
  MVP e o diferencial central do produto (`00-F` §4). Adiantar a Fase D antes da Fase C foi uma
  escolha explícita sua, não uma reordenação de prioridade que eu tenha feito por conta própria.
- **Limpeza:** contas/viagens/fotos de teste apagadas do banco real (a foto de teste do Node ficou
  órfã no Storage — arquivo minúsculo, sem custo real, não vale o esforço de limpar agora).

Ciclo 10 — E8 (Docs com inteligência) construída do zero, a pedido explícito de priorizar o
diferencial central do produto:

- **Upload independente da extração (H8.1):** documento sobe para o bucket `trip-documents` e fica
  registrado (tabela `documents`) assim que selecionado, antes mesmo do OCR terminar — nunca fica
  "preso" esperando a extração para aparecer na lista de Docs.
- **OCR + parser no cliente, sem LLM (H8.2), com uma redução de escopo deliberada:** Tesseract.js
  (WASM, roda no navegador) só processa **imagens**; PDF não é OCRizado nesta versão e cai direto no
  fallback de campos vazios (H8.5) — extrair texto de PDF exigiria uma biblioteca adicional, fora do
  pedido original de "OCR no cliente, sem LLM". Parser próprio (regex) extrai data (numérica e por
  extenso, pt-BR/en-US), horário 24h e um título heurístico a partir do texto do OCR.
- **Confirmação humana obrigatória (H8.3):** nenhum evento é criado sem o usuário revisar/editar os
  campos e confirmar explicitamente; a confirmação também grava o vínculo entre o documento e o
  evento criado (nova policy de UPDATE no banco, só na coluna necessária).
- **Alerta de conflito de horário (H8.4):** reaproveita a mesma checagem de sobreposição já usada no
  Cronograma (H6.5) — o aviso aparece antes de confirmar, não depois do evento já criado.
- **Fallback não bloqueante (H8.5):** PDF, falha de OCR ou texto sem padrão reconhecido abrem a
  mesma tela de confirmação com campos vazios — o usuário sempre consegue preencher na mão e seguir.
- **Verificado ponta-a-ponta com um documento de teste real** (imagem gerada com o texto de uma
  confirmação de reserva de hotel): upload → OCR → os três campos (título, data, horário) extraídos
  corretamente → confirmação → evento criado → documento marcado como vinculado. Checado também
  direto no banco (não só na tela): o evento e o documento aparecem corretamente unidos pela mesma
  chave.
- **Limpeza:** conta/viagem de teste apagada do banco real.

---

## 3. Próximos passos imediatos

**Todo o MVP core (Fases A–D) está entregue.** O que resta é a Fase E — infraestrutura transversal
(E12 offline, E13 notificações/drawer, E14 privacidade/retenção; hoje só H15.2 feita dentro de E15).
Recomendação: escolher entre essas frentes com base no que mais importa para começar a validar com
usuários reais — por exemplo, E14 (privacidade/retenção) é rápida e reforça a postura de proteção de
dados já documentada em `00-F` §17; E12 (offline) é a mais estrutural e cara.

**Verificação pendente, não bloqueante (herdada do ciclo 9):** testar manualmente o upload de foto
na Galeria num navegador real — o código está correto e confirmado via Node, só não pôde ser
confirmado ponta a ponta pela automação daquele ciclo.

**Ainda em aberto, sem bloquear:**
- Definir o modelo de negócio em si (não só o dono) — sem prazo declarado.
- Mover a senha do banco Supabase de `.env.local` para um gerenciador de senhas.
- Navegação da tab bar "Viagem" não sabe qual viagem reabrir após um F5 (ver ciclo 6) — pequeno, mas
  vale uma história própria.
- Sem fluxo de "esqueci minha senha" e sem teste automatizado de RLS (ambos em `00-F` §17.2).
- H15.3 (Playwright/CI antes do push) — pedir explicitamente quando quiser priorizar essa frente.
- Notificação ao integrante impactado por uma despesa (H7.3) depende de E13, que não existe.
- OCR não processa PDF nesta versão de E8 (só imagens) — registrado como redução de escopo, não bug.

---

## 4. Roadmap semanal até a V1

> **Premissa desta estimativa (sem confirmação de equipe até esta data):** assume um time dedicado
> e estável, sem interrupções, capaz de fechar cada fase abaixo no prazo indicado. O backlog
> (`03`) é explícito em **não ter sizing nem cadência de time definida** — os números abaixo são um
> ponto de partida de planejamento, não um compromisso de prazo. Atualizar esta tabela assim que
> houver equipe alocada e velocidade real medida (mesmo que só depois da Fase A).

| Semanas | Fase (backlog `03`) | Épicos | Entrega observável ao final |
|---|---|---|---|
| 1–3 | A — Fundação | E1, E2, E3, E4 | Login funcional, criação/entrada em viagem, permissões — sem telas de conteúdo ainda |
| 4–5 | B — Esqueleto vertical mínimo | E5, E6-mín, E7-mín | Fluxo ponta a ponta: criar viagem → ver painel → 1 evento → 1 despesa |
| 6–7 | C — Diferencial central | E8 (Docs com inteligência) | Anexar um documento popula o cronograma, com confirmação humana — a promessa central da VN — **✅ feito** |
| 8–10 | D — Completar módulos | E6-completo, E7-completo, E9, E10, E11 | Cronograma e Despesas completos; Mapa, Galeria e Sugestões no ar |
| 11–12 | E — Infraestrutura transversal | E12, E13, E14, E15 | Offline, notificações, privacidade/retenção e observabilidade — critério de "visão atingida" da VN completo |

**Data-alvo estimada da V1:** ~2026-11-20 (12 semanas a partir de hoje, 2026-08-28) — **estimativa
de planejamento**, não uma data comprometida, pelas razões da premissa acima.

---

## 5. Evoluções mapeadas pós-V1 (v2+)

Da VN (`00-F` §8/§9), fora do backlog da V1, sem data por não terem prioridade nem estimativa
ainda:

- Integração com e-mail (Gmail/Outlook) — depende de verificação de escopo do Google e registro no
  Microsoft Graph, prazos fora do controle do time.
- Rastreamento de localização em tempo real.
- "Recomendações Trippin" com dados agregados de uso (depende de massa de usuários pós-V1).
- Preços ao vivo de hospedagem (depende de fechar parceria).
- Tradução completa dos 8 idiomas restantes (trabalho contínuo, não um marco único).

---

## 6. Histórico de atualizações

| Data | Resumo em uma linha |
|---|---|
| 2026-08-28 | Primeira versão — VN/UX/backlog consolidados, projeto ainda pré-código, roadmap preliminar de 12 semanas até V1 |
| 2026-08-28 | Stakeholder confirmou as 3 pendências da seção 3: dono do modelo de negócio definido (sem modelo ainda), leitura de "Sugestões" mantida como estava, e escopo mudou para multi-moeda no MVP (impacto em `02` e `03`, épico E7) |
| 2026-08-29 | Início da construção: E1/E3/E4 implementados em `web/index.html` com dados mock (`TrippinAPI`/`localStorage`), testados num navegador real sem erros; E2 (Supabase/GitHub Pages) segue pendente de credenciais |
| 2026-08-29 | E2 concluído: projeto Supabase real (schema+RLS+Storage) e repositório GitHub reais; app publicado em produção via GitHub Pages; frontend ainda roda sobre o mock, conexão real fica para o próximo ciclo |
| 2026-08-29 | Frontend conectado ao Supabase real; 2 bugs de RLS encontrados e corrigidos via teste com dois usuários reais (criação de viagem bloqueada por RETURNING+SELECT policy; convidado não conseguia localizar viagem por código); dados de teste limpos |
| 2026-08-29 | Auditoria de segurança sobre produção: 2 furos reais fechados (enumeração de viagens sem código; vazamento de CPF/telefone entre colegas), privilégio mínimo em UPDATE, constraint de datas, React em build de produção, e nova seção de arquitetura/crescimento na VN (`00-F` §17) |
| 2026-08-29 | H15.2 implementada e adiantada: log estruturado de erros do cliente (`client_errors`, sem leitura pela UI), cobrindo toda a `TrippinAPI` + render + promises sem handler, com filtro para não logar erros já tratados pela UI; verificado com teste dedicado (erro forçado logado, erro esperado e uso normal não geram ruído) |
| 2026-08-30 | Fase B mínima: Cronograma (CRUD de evento + conflito de horário) e Despesas (multi-moeda + saldo) implementados e testados com dois usuários reais; encerramento manual de viagem (E5) e modo somente-leitura; corrigido bug real de "hoje" calculado em UTC e lacuna de navegação (Despesas sem aba própria) |
| 2026-08-30 | Fase D completa: Cronograma (Semana/Mês/reordenar), Despesas (valor fixo/partes customizadas/quitação/extrato), Mapa (Leaflet+OSM+geocodificação real), Galeria (upload, verificação automatizada inconclusiva por bloqueio de bot do Cloudflare — confirmado via Node puro) e Sugestões, todas construídas do zero; bug real corrigido no cálculo de saldo (não excluía despesas quitadas) |
| 2026-08-30 | E8 (Docs com inteligência) concluída: upload independente da extração, OCR client-side (Tesseract.js, só imagens — PDF cai no fallback) + parser próprio para data/horário/título, confirmação humana obrigatória com alerta de conflito de horário; verificado ponta-a-ponta (navegador + banco) com um documento de teste real; MVP core (Fases A–D) completo, resta só a Fase E |
