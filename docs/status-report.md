# Relatório de Status — Trippin

| Campo | Valor |
|---|---|
| **Tipo** | Relatório de status gerencial — atualizado a cada ciclo, não é parte da cadeia numerada `00→07` |
| **Base** | `00-visao-de-negocio-final.md`, `02-UXUI-spec.md`, `03-backlog.md` |
| **Atualização atual** | 2026-08-29 (ciclo 5 — frontend conectado ao Supabase real) |
| **Atualização anterior** | 2026-08-29 (ciclo 4 — E2: Supabase e GitHub reais) |
| **Como manter** | A cada novo ciclo: atualizar seções 1–4 com o estado atual e adicionar uma linha em "Histórico" (seção 6). Não reescrever o histórico de ciclos passados. |

---

## 1. Resumo executivo

**Fase A (E1/E2/E3/E4) fechada de ponta a ponta.** O app publicado deixou de ser um mock — fala de
verdade com o Supabase real: cadastro/login, criação de perfil, criação de viagem, entrada por
código e promoção de papéis passam pelo banco com RLS, testados com dois usuários reais num
navegador headless (não só revisão de código). No caminho, o teste real encontrou e corrigiu **dois
bugs genuínos de RLS** que só apareciam com tráfego de verdade — nenhum dos dois era visível
olhando o SQL isoladamente. Estimativa segue em **~12 semanas até a V1**, sem mudança de número.

**Pendência que mais afeta o prazo real:** ainda não há equipe/cadência definida (ver seção 4).

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

---

## 3. Próximos passos imediatos

A Fase A (E1–E4) está funcionalmente completa e real. Próximo é a Fase B do backlog — esqueleto
vertical mínimo (E5, E6-mín, E7-mín): Home sensível ao estado, um evento de cronograma, uma
despesa — já direto contra o Supabase, sem passar por mock de novo.

**Ainda em aberto, sem bloquear:**
- Definir o modelo de negócio em si (não só o dono) — sem prazo declarado.
- Mover a senha do banco Supabase de `.env.local` para um gerenciador de senhas.
- Navegação da tab bar "Viagem" não sabe qual viagem reabrir após um F5 (ver seção 2) — pequeno, mas
  vale um épico/história próprio quando a Fase B começar.

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
| 6–7 | C — Diferencial central | E8 (Docs com inteligência) | Anexar um documento popula o cronograma, com confirmação humana — a promessa central da VN |
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
