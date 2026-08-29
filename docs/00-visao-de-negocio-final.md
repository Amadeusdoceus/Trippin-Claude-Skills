# 00-F — Visão de Negócio Consolidada (Trippin)

> **Este documento consolida `00-visao-de-negocio.md` (v1.0) e `01-VN-revisada.md` (crivo crítico)
> em uma única Visão de Negócio final.** Ele substitui os dois como referência de leitura corrida;
> `00` e `01` permanecem no repositório como registro histórico (a visão original e o processo de
> crítica que a revisou), e a seção 15 documenta exatamente o que mudou de um para o outro.
>
> Como em `00`, este é ao mesmo tempo um artefato de negócio real e material de estudo de PM — mas,
> diferente de `00`/`01`, aqui as caixas "💡 Nota do PM" foram removidas: esta é a **versão
> executiva limpa** que o próprio `00 §"Como usar"` e o rodapé de `00` preveem como destino final.

| Campo | Valor |
|---|---|
| **Produto** | Trippin — planejador de viagens em grupo |
| **Tipo de documento** | Visão de Negócio (versão final consolidada) |
| **Autor (papel)** | Product Manager |
| **Versão** | 2.0 (consolida `00` v1.0 + `01`) |
| **Data** | 2026-08-28 |
| **Status** | Vigente, com um item explicitamente em aberto (ver seção 14, item 1 — modelo de negócio) |
| **Deriva de** | `00-visao-de-negocio.md` (2026-06-26) + `01-VN-revisada.md` (2026-08-26) |
| **Público do documento** | Liderança, time de engenharia, design, QA e stakeholders de negócio |
| **Documentos derivados** | `02-UXUI-spec`, `03-backlog`, `04-qa-report`, `05-vv-report`, `06-rollout-plan`, `07-*` |

> **Nota de escopo (herdada de `01 §1`):** o "estado entregue" descrito originalmente em `00` (app
> em produção v1.0.2, Supabase, GitHub Pages, mobile via Expo/WebView) é **hipotético/pedagógico** —
> o repositório real, na data desta consolidação, contém apenas `briefing.md`. As "decisões de
> tecnologia" da seção 11 abaixo devem ser lidas como **ponto de partida assumido** para quando a
> construção começar, não como arquitetura já validada em produção. Note também que `02-UXUI-spec.md`
> e `03-backlog.md` já foram construídos a partir de `briefing.md`, não desta linha de documentos —
> `00/01/00-F` seguem sendo um exercício autocontido de VN, mantido coerente internamente.

---

## 1. Resumo executivo (TL;DR)

Viajar em grupo hoje significa caçar informação em seis apps diferentes. O **Trippin** centraliza
voos, estadias, eventos, despesas, fotos, roteiro e mapa em um só lugar que funciona **offline** e
mantém o grupo sincronizado. Seu maior gerador de valor é **ler os documentos anexados** (a
passagem em PDF, a reserva) para **preencher o cronograma automaticamente**, alertando sobre
conflitos — hoje via upload manual, com integração direta a Gmail/Outlook prevista para v2.
Sucesso = grupos organizando viagens inteiras **sem sair do app**, com onboarding em menos de 3
minutos. O modelo de negócio e o motor de aquisição da v1 ainda dependem de decisões do stakeholder
de negócio (seção 14).

---

## 2. Problema / oportunidade

Viajantes em grupo lidam com informação **fragmentada** em múltiplos apps e canais:

- passagens no **e-mail**,
- reservas no **Booking / Airbnb**,
- ingressos em **PDFs soltos**,
- despesas no **Splitwise**,
- roteiro combinado no **WhatsApp**,
- localização no **Google Maps**.

Não existe um lugar único que **reúna tudo**, funcione **offline** (sinal ruim é a norma em
viagem) e mantenha **o grupo sincronizado**. O custo disso é tempo perdido, retrabalho de
organização e o atrito recorrente de "quem tem a reserva?", "que horas é o voo?", "quanto cada um
já pagou?".

**Concorrência indireta** (o hábito atual do usuário): e-mail, Booking, Splitwise, WhatsApp, Maps —
é contra isso que o Trippin compete no dia a dia.

**Concorrência direta** (adicionado nesta consolidação — resposta à lacuna `01 §2.7`): existem apps
dedicados a planejamento de viagem (ex.: TripIt, Wanderlog). A aposta do Trippin contra eles é a
combinação **inteligência de documentos + offline + grupo sincronizado em um único fluxo**, não
qualquer um desses recursos isolado — ferramentas de roteiro concorrentes cobrem parte disso, mas
tipicamente exigem entrada manual de dados ou não priorizam uso sem conexão.

**Oportunidade:** transformar esse esforço manual de consolidação em algo automático — começando
pelo ponto de maior dor, que é montar e manter o **roteiro/cronograma**.

---

## 3. Usuários-alvo & personas

| Persona | Quem é | O que mais valoriza |
|---|---|---|
| **Organizador** | Cria o grupo, convida pessoas, administra integrantes, finaliza a viagem | Controle, visão geral, reduzir trabalho de coordenação |
| **Integrante** | Participa, consulta o roteiro, anexa documentos, registra despesas e fotos | Saber o que/quando/onde sem perguntar; contribuir sem fricção |
| **Convidado externo** | Recebe convite por e-mail, instala o app e ingressa na viagem | Entrar rápido, sem cadastro penoso |

**Perfil comum:** familiaridade média com apps de viagem (Maps, Airbnb), valoriza **simplicidade**
e quer **reduzir o esforço** de organização — não quer aprender uma ferramenta complexa.

---

## 4. Proposta de valor & diferencial

**Promessa central:** um app que **centraliza toda a viagem** (voos, estadias, eventos, ingressos,
despesas, fotos, roteiro e mapa) e que **lê os documentos anexados para preencher o cronograma
automaticamente** — transformando um PDF de passagem em blocos de agenda, alertando sobre conflitos
e mantendo tudo disponível **offline**.

| Pilar | Sem Trippin | Com Trippin |
|---|---|---|
| **Centralização** | 6 apps + WhatsApp | 1 app, todas as abas |
| **Inteligência de documentos** | digitar o roteiro à mão | anexou a passagem → cronograma se preenche |
| **Offline** | abre o e-mail… sem sinal | conteúdo baixado fica acessível |
| **Grupo sincronizado** | "manda print aí" | todos veem a mesma viagem |

**Sobre o "diferencial defensável" (reformulado nesta consolidação — resposta à lacuna `01 §2.4`):**
a versão original (`00 §5`) descrevia a inteligência de documentos como "difícil de copiar". Isso
superestima o fosso da v1: a decisão técnica #7 (seção 11) escolhe deliberadamente um **parser
estruturado por padrões conhecidos, sem LLM**, exatamente para evitar custo de infraestrutura de IA
na v1 — e um parser desse tipo é replicável por um concorrente competente em pouco tempo.

A leitura correta é: **a inteligência de documentos é o maior gerador de valor da v1** — é o que
mais diferencia a experiência do usuário do dia a dia manual — mas só se torna **defensável** de
fato quando evoluir para extração via LLM (fora do escopo v1, ver decisão #7). Até lá, a vantagem
competitiva real do Trippin é a **velocidade de execução e a integração dos pilares em um único
fluxo**, não uma barreira técnica intransponível. Isso significa que o time não deve subinvestir em
outras formas de retenção de longo prazo (rede social do grupo dentro do app, histórico acumulado
de viagens, hábito) só porque acredita ter um fosso técnico permanente.

---

## 5. Modelo de negócio

**Seção nova nesta consolidação — resposta direta à lacuna `01 §2.1`** (ausência total de modelo de
negócio na versão original, que definia produto e métricas sem nunca declarar como o Trippin gera
receita).

**Posição na v1: nenhuma monetização direta.** O foco da v1 é validar uso e retenção (ver North
Star, seção 7); cobrar do usuário nesta fase competiria com a meta de adoção. A única fonte de
receita mencionada em qualquer versão anterior é uma nota lateral sobre **afiliados de hospedagem**
("quando houver chave de parceiro", `00 §8` / decisão #9 na seção 11) — hoje isso é uma
possibilidade arquitetural (conectores plugáveis já preparados), não um modelo de negócio decidido.

**Isso é uma pergunta em aberto, não uma decisão** — ver seção 14, item 1. Ela importa porque
afeta priorização real: por exemplo, vale investir em preço-ao-vivo de hospedagem antes do MVP se
essa for a única fonte de receita futura prevista? Sem resposta do stakeholder de negócio, a
priorização de itens de roadmap ligados a receita (preços ao vivo, parcerias) fica sem critério
objetivo além de "quando houver chave de parceiro".

**Dono confirmado em 2026-08-28:** o próprio stakeholder de negócio do projeto assume a
responsabilidade por esta decisão. Isso não resolve o modelo de negócio em si — nenhuma
monetização foi definida — mas remove a lacuna de "pergunta sem dono" apontada por `01 §2.1`.
Ainda não há prazo de decisão declarado.

---

## 6. Objetivos & métricas de sucesso

**North Star Metric:** **viagens organizadas e concluídas por usuário ativo** — captura o valor
central (centralizar e organizar a viagem de ponta a ponta).

**Definição operacional de "concluída" (adicionada nesta consolidação — resposta à lacuna
`01 §2.2`):** uma viagem é considerada **concluída automaticamente N dias após a data final**
informada na criação da viagem, com opção de o organizador marcar a conclusão manualmente antes
disso. Sem essa regra, a métrica não pode ser instrumentada — o valor de N fica como parâmetro a
calibrar antes do rollout (`06-rollout-plan`), mas a mecânica (automática + override manual) já é a
decisão de produto.

**Métricas de negócio (metas de 30 dias após GA):**

| Métrica | Definição | Meta 30d |
|---|---|---|
| MAU | usuários únicos ativos no mês | 1.000 |
| Viagens criadas | total de grupos criados | 300 |
| Taxa de convite aceito | convidados que instalam e entram | 35% |
| NPS | pesquisa pós-viagem | ≥ 50 |

**Premissa de aquisição (adicionada nesta consolidação — resposta à lacuna `01 §2.3`):** as metas
acima assumem **aquisição 100% orgânica via convite do organizador, sem orçamento de marketing
pago**. Essa premissa não estava declarada na versão original, e as metas dependiam inteiramente de
virilidade por convite sem nenhum canal de aquisição, orçamento ou data de GA mencionados. Se essa
premissa se mostrar falsa (viralidade insuficiente), as metas de MAU e viagens criadas precisam ser
recalibradas — não é um problema do produto, é um problema do motor de aquisição por trás da meta.

**Métricas de produto/qualidade (gatilhos internos):** taxa de erro de API < 1%, latência p95 <
500 ms, abandono no onboarding < 25%, **sucesso de leitura de Docs ≥ 80%**, conflitos de
cronograma resolvidos ≥ 60%.

**Critério de experiência:** onboarding completo em **menos de 3 minutos**.

---

## 7. Escopo do MVP (v1)

Priorizado por **valor central × viabilidade**. O MVP entrega a espinha dorsal de organização da
viagem:

1. **Onboarding** — seleção de idioma + criação de perfil (com código de usuário de 6 dígitos).
2. **Home** — viagens ativas, criar viagem, participar de viagem (por código), viagens anteriores.
3. **Criar viagem** — nome, datas, múltiplos destinos com busca, código de viagem de 12 dígitos.
4. **Viagem ativa** com abas: **Cronograma, Mapa, Docs, Galeria, Sugestões, Integrantes**.
5. **Cronograma** estilo calendário (mês/semana/dia), inclusão de atividades, **conflitos visíveis**.
6. **Docs com inteligência (must-have)** — leitura do anexo → preenchimento do cronograma + alerta
   de conflito. Cobre **apenas upload manual** — a integração com e-mail (seção 8) fica para v2.
7. **Integrantes** — administração, convite por e-mail, múltiplos admins.
8. **Notificações** + **barra lateral de navegação (drawer)**.
9. **Despesas** com divisão e notificação ao impactado.

**Incremento pós-MVP já entregue:** **Busca de hospedagem** — página standalone que compara
hotéis/pousadas/aluguéis de vários sites e permite **confirmar uma estadia e adicioná-la ao
cronograma** da viagem (ver seção 11 e `07-busca-hospedagem.md`).

---

## 8. Fora de escopo / roadmap (v2+)

O que **conscientemente não** entra na v1, com o porquê:

| Item adiado | Por quê | Quando |
|---|---|---|
| Rastreamento de localização em tempo real (mapa de calor do percurso) | Alto custo de bateria/privacidade; valor não comprovado | v2 |
| "Recomendações Trippin" (baseadas em dados agregados da base) | Depende de **massa de usuários** que ainda não temos | v2 |
| Tradução completa dos 10 idiomas | v1 entrega a infra i18n + PT-BR e EN-US completos; resto é trabalho contínuo de localização | contínuo |
| Integração nativa de deslocamento (Google Directions) | Custo por chamada; v1 simula o cálculo de tempo | v2 |
| **Preços ao vivo de hospedagem** | APIs gratuitas com preço caíram/fecharam; arquitetura já pronta para plugar parceiro | quando houver chave de parceiro |
| **Integração com e-mail (Gmail/Outlook)** — escopo decidido na seção 8 | Verificação de escopo restrito do Gmail e registro de app no Microsoft Graph são dependências de compliance que não devem travar o MVP; ver seção 8 para o desenho completo, já confirmado com o stakeholder de produto | v2 |

---

## 9. Integração com e-mail (Gmail e Outlook) — capacidade v2

Capacidade não presente na VN original; identificada e desenhada na revisão crítica (`01 §3`),
com decisões confirmadas com o stakeholder de produto em 2026-08-26.

### 9.1 Impacto na proposta de valor

Hoje o pilar "inteligência de documentos" (seção 4) cobre apenas anexos que o usuário sobe
manualmente. A integração de e-mail estende esse pilar para **localizar** — não ler tudo, apenas
localizar — reservas e confirmações que já estão na caixa de entrada do usuário, reduzindo o
trabalho de "baixar o PDF e depois subir no app" para "apontar a pasta e confirmar".

Isso é uma **extensão do mesmo diferencial**, não um novo pilar de produto — deve ser comunicado e
priorizado como tal, para não diluir a proposta de valor central em uma segunda promessa.

### 9.2 Escopo decidido

| Decisão | Escolha | Alternativa descartada | Por quê |
|---|---|---|---|
| **Momento** | v2 (roadmap), não MVP v1 | Incluir na v1 | O upload manual já é o must-have validado da v1 (seção 7, item 6). A verificação de escopo restrito do Gmail (processo de semanas) e o registro de app no Microsoft Graph são dependências de compliance que não devem travar o lançamento do MVP. |
| **Escopo de busca** | Usuário aponta uma **pasta/rótulo específico** (ex.: rótulo Gmail "Viagens" ou pasta Outlook dedicada) | Busca por palavra-chave/remetente em toda a caixa de entrada | Escopo de leitura muito menor (`gmail.readonly` restrito a um rótulo, ou `Mail.Read` do Graph restrito a uma pasta) — reduz superfície de dados sensíveis acessada, facilita a revisão de privacidade do Google/Microsoft, e é mais fácil de explicar ao usuário do que "o app varre tudo". |
| **Gatilho** | **Sob demanda** — usuário toca em algo como "buscar no e-mail" ao montar a viagem | Sincronização automática em segundo plano | Sem infra de armazenamento de token persistente + jobs de background na v1 deste recurso; consentimento fica mais simples de justificar ("acesso pontual, quando você pede") do que acesso contínuo. |

### 9.3 Retenção e privacidade

Como a leitura de e-mail é estritamente mais sensível que o upload manual de um PDF (o usuário nem
sempre pensa em "quem mais aparece nesse e-mail"), a política de retenção de dados sensíveis (seção
12) passa a ser **bloqueante** para este recurso, não apenas recomendada: definir, antes de
escrever qualquer código de integração, por quanto tempo o conteúdo extraído fica armazenado e como
o usuário revoga o acesso e solicita exclusão.

---

## 10. Decisões de tecnologia e seus porquês

Cada decisão segue o formato **o quê → alternativas → porquê → trade-off**.

| # | Decisão | Alternativas consideradas | Por que escolhemos | Trade-off aceito |
|---|---|---|---|---|
| 1 | **Front em arquivo único HTML + React 18 via CDN, sem bundler/build** | Create React App, Vite, Next.js | Iteração instantânea (salvar → recarregar), zero toolchain, hospedável como arquivo estático, fácil de depurar | Script inline gigante → risco de "tela branca" por chave/parêntese desbalanceado (risco rastreado na seção 12) |
| 2 | **Hospedagem em GitHub Pages** (repo privado, URL pública) | Vercel, Netlify, servidor próprio | Custo zero, deploy automático por `git push` via GitHub Actions, sem operação de servidor | Site é estático — toda lógica de servidor precisa morar em outro lugar (→ decisão 3) |
| 3 | **Backend no Supabase** (Postgres + Auth + Storage + Edge Functions em Deno/TS) | Firebase, backend próprio (Node/Express) | BaaS elimina ops; banco relacional de verdade; **Row Level Security** protege dados por usuário; tier gratuito; Edge Functions guardam segredos | Lock-in parcial no fornecedor; limites do tier free |
| 4 | **Modelo de segurança: chave pública no front, segredos só no servidor** | Esconder todas as chaves | A chave `anon/publishable` **pode** ser pública — quem protege os dados é o **RLS**, não a chave. `service_role` e chaves de e-mail vivem só como *secrets* das Edge Functions | Exige disciplina: nunca commitar `service_role` |
| 5 | **Persistência offline-first com `localStorage` + camada de sync `TrippinAPI`** | Só nuvem; banco local complexo (IndexedDB/SQLite) | Requisito de produto é **funcionar offline**; `localStorage` é simples e suficiente; sync com estratégia *last-write-wins* | Conflitos de edição simultânea resolvidos de forma simples (último a escrever vence) + log de auditoria |
| 6 | **Mobile = Expo + React Native WebView** carregando o GitHub Pages com *cache-busting* | App nativo do zero; PWA pura | **Um código só** (a web app) serve web, Android e iOS; publica nas lojas via Expo/EAS sem reescrever; cache-busting garante sempre a versão mais nova | Não é nativo puro — gestos/performance limitados ao que a WebView oferece |
| 7 | **Inteligência de Docs = parser estruturado + OCR no cliente + confirmação humana** | OCR/LLM em servidor desde a v1 | Evita custo e complexidade de infra de IA na v1; o usuário confirma antes de gravar, controlando o risco de leitura errada | Cobre só padrões conhecidos de documento; casos fora do padrão exigem preenchimento manual. **Nota:** esta escolha é também a razão pela qual o "diferencial defensável" da seção 4 precisou ser reformulado nesta consolidação |
| 8 | **Mapa renderizado localmente (DestPinMap) + Nominatim/OSM para busca de lugar** | Google Maps / Places API | Sem custo por chamada e sem chave; suficiente para a visão de cidades/pinos da v1 | Menos recursos que o Google Maps (sem rotas nativas, etc.) |
| 9 | **Busca de hospedagem via Edge Function com conectores plugáveis** | Scraping direto dos sites; uma API fixa | Scraping fere ToS/anti-bot; conectores plugáveis permitem ligar fontes sem reescrever. Padrão keyless **OpenStreetMap/Overpass** traz hotéis reais (sem preço ao vivo), e os "slots" de parceiro ligam sozinhos quando a chave existir | Sem chave de parceiro, não há **preço ao vivo** — o card leva à reserva no site |
| 10 | **Qualidade: Playwright E2E + `validate-code.js`, com `npm run review` antes do push** | Testar manualmente; sem CI | Incidentes repetidos de "tela branca" tornaram a revisão **obrigatória**: `validate-code.js` pega sintaxe/chaves; Playwright garante que nenhuma tela quebra. A suíte **cresce junto com cada feature** | Custo de manter testes — aceito, porque o custo de uma tela branca em produção é maior |
| 11 | **i18n: infra completa + PT-BR e EN-US; demais idiomas como stub** | Traduzir os 10 de uma vez | Entrega o alcance principal sem travar o cronograma na localização | Idiomas restantes ficam incompletos até o trabalho contínuo de tradução |
| 12 | **Integração de e-mail via OAuth (Gmail API + Microsoft Graph), leitura restrita a pasta/rótulo indicado pelo usuário, disparada sob demanda** (nova — de `01 §3.3`) | Sincronização automática em background; acesso de caixa de entrada inteira; apenas upload manual (sem integração) | Menor escopo de OAuth possível reduz revisão de segurança e risco de privacidade; "sob demanda" evita infra de sync persistente na primeira versão do recurso | Usuário precisa organizar um rótulo/pasta manualmente antes de usar; sem esse passo, a busca não encontra nada — pior recall que uma busca ampla |

---

## 11. Riscos, premissas & dependências

| Risco | Impacto | Mitigação |
|---|---|---|
| Leitura/parsing de documentos heterogêneos | Alto | Parser com padrões conhecidos + **confirmação do usuário** antes de gravar |
| Dependência de Maps/Places (custo por chamada) | Médio | Mapa local + OSM; busca só a partir de 3 letras; debounce; cache |
| Sincronização offline ↔ online com conflitos | Alto | *Last-write-wins* + log de auditoria por ação |
| Privacidade (CPF, localização) — LGPD | Alto | CPF **opcional** na v1; **sem** rastreio de localização na v1 |
| Fontes gratuitas de preço de hospedagem instáveis | Médio | Conectores plugáveis; padrão keyless (OSM) sem preço ao vivo; pronto para parceiro |
| **Manutenibilidade do frontend em arquivo único** (novo — resposta à lacuna `01 §2.5`), à medida que features se acumulam (docs, hospedagem, e-mail) | Médio | Mitigado por `validate-code.js` + Playwright (decisão #10); reavaliar migração para bundler se o arquivo ultrapassar um limiar de tamanho a definir |
| **Dados sensíveis em documentos de viagem** (novo — resposta à lacuna `01 §2.6`): passaporte, cartão de embarque, dados financeiros de despesas, sem política de retenção/exclusão declarada | Alto | Definir por quanto tempo o conteúdo extraído fica armazenado e como o usuário solicita exclusão — **bloqueante** antes de iniciar a integração de e-mail (seção 9.3), recomendado também antes do MVP de Docs |
| Verificação de escopo restrito do Gmail (Google) tem prazo incerto e pode exigir avaliação de segurança (CASA) | Alto — pode atrasar o v2 inteiro se subestimado | Iniciar o processo de verificação com Google assim que o escopo técnico for definido, independente da data de código pronto |
| Registro/aprovação de app no Microsoft Entra/Graph para `Mail.Read` | Médio | Registrar o app cedo; usar permissão delegada restrita a pasta, não `Mail.ReadWrite` nem acesso a toda a organização |
| Dado sensível de terceiros dentro dos e-mails do usuário (ex.: confirmação com dados de outro passageiro) | Alto | Extrair apenas os campos necessários (datas, local, código de reserva) e descartar o corpo do e-mail após a extração; não armazenar o e-mail bruto |
| Revogação de acesso pelo usuário não propagando corretamente (token continua válido após revogação no provedor) | Médio | Verificar validade do token a cada uso sob demanda (natural, já que não há sync em background) |
| Custo/quota das APIs (Gmail API e Microsoft Graph) | Baixo na v2 (uso sob demanda, baixo volume) | Monitorar quota; reavaliar se o recurso evoluir para sincronização automática |

**Premissas:**
- Existe demanda por organização de viagem em grupo.
- Usuários topam instalar um app dedicado.
- O tier gratuito de Supabase/Pages suporta o volume inicial.
- **Aquisição orgânica via convite do organizador, sem orçamento de marketing pago** (formalizada
  nesta consolidação — resposta à lacuna `01 §2.3`; ver seção 6). Se falsa, as metas de 30 dias
  precisam ser recalibradas.

---

## 12. Critérios de sucesso (definição de "visão atingida")

A visão da v1 é considerada cumprida quando:

- Um grupo consegue **criar uma viagem, convidar e organizar o roteiro sem sair do app**.
- **Anexar um documento de passagem popula o cronograma** sem digitação manual.
- Conteúdo (ingressos/arquivos) fica **acessível offline**.
- **Onboarding** completo em **menos de 3 minutos**.

---

## 13. Política de retenção e privacidade de dados sensíveis

Seção nova nesta consolidação, elevando a recomendação de `01 §2.6`/`§3.5` a um item formal da VN
(estava referenciada apenas dentro da tabela de riscos em `00`).

Documentos de viagem carregam dado sensível por natureza — identidade (passaporte, cartão de
embarque) e financeiro (despesas, comprovantes). A VN original cobria CPF e localização (LGPD) mas
não definia retenção/exclusão para o conteúdo extraído de documentos. Isso deve ser resolvido:

- **Antes do MVP de Docs (seção 7, item 6):** por quanto tempo o conteúdo extraído de um documento
  anexado manualmente fica armazenado, e como o usuário solicita exclusão.
- **Antes de qualquer código da integração de e-mail (seção 9):** o mesmo, de forma ainda mais
  estrita — sem armazenar o corpo do e-mail bruto, extraindo apenas os campos necessários.

Este item é tratado como **bloqueante para a v2 de e-mail** e como **pendência de compliance
recomendada** para o MVP de Docs — não é opcional em nenhum dos dois casos.

---

## 14. Perguntas em aberto (decisões de negócio pendentes)

| # | Pergunta | Recomendação | Status nesta consolidação |
|---|---|---|---|
| 1 | **Qual é o modelo de negócio do Trippin?** | Sem recomendação própria — decisão de negócio que precede a priorização de itens como preço-ao-vivo de hospedagem. | **Aberta, mas com dono desde 2026-08-28:** o stakeholder de negócio do projeto. Nenhum modelo nem prazo definidos ainda; ver seção 5. |
| 2 | **CPF é obrigatório?** | Opcional na v1 — cria fricção alta e implica LGPD. | **Adotada como decisão de trabalho.** Refletida na seção 11 (riscos/mitigação). |
| 3 | **A inteligência de Docs usará OCR/LLM?** | Parser estruturado + fallback manual na v1; reavaliar com base na taxa de sucesso real. | **Adotada como decisão de trabalho.** Ver decisão #7, seção 10. |
| 4 | **Rastreio de localização em tempo real justifica o custo de privacidade/bateria?** | Adiar para v2. | **Adotada como decisão de trabalho.** Ver seção 8. |
| 5 | **Qual é o motor de aquisição assumido para as metas de 30 dias?** | Declarar explicitamente "orgânico via convite, sem budget pago" como premissa. | **Adotada como decisão de trabalho.** Ver seção 6 e seção 11 (premissas). |
| 6 | **A integração de e-mail deve, no futuro, oferecer sincronização automática (não só sob demanda)?** | Não decidir agora — reavaliar após medir taxa de uso e taxa de sucesso do modo sob demanda na v2. | **Mantida em aberto deliberadamente**, mesmo critério usado para a pergunta 3 (OCR/LLM). |

Cada pergunta aberta deveria ter um dono e um prazo de decisão. A única sem dono e prazo definidos
nesta consolidação é a **pergunta 1** — é o item que mais bloqueia `06-rollout-plan`, porque sem
modelo de negócio não há como priorizar com confiança investimentos ligados a receita futura.

---

## 15. O que mudou: registro da consolidação (`00` + `01` → esta versão)

Registro explícito de rastreabilidade — cada item abaixo aponta de onde veio e onde foi incorporado
nesta versão final.

| Origem | Mudança incorporada | Onde está nesta versão |
|---|---|---|
| `01 §2.1` | Lacuna: ausência de modelo de negócio | Seção 5 (nova) + pergunta 1 na seção 14 |
| `01 §2.2` | Lacuna: North Star sem definição operacional de "concluída" | Seção 6 |
| `01 §2.3` | Lacuna: motor de crescimento não declarado como premissa | Seção 6 + Seção 11 (premissas) |
| `01 §2.4` | Lacuna: diferencial defensável superestimado frente à decisão técnica #7 | Seção 4 (reescrita) |
| `01 §2.5` | Lacuna: risco de manutenibilidade do frontend não rastreado | Seção 11 (nova linha de risco) |
| `01 §2.6` | Lacuna: privacidade de documentos sensíveis sem política de retenção | Seção 13 (nova) + Seção 11 |
| `01 §2.7` | Lacuna: nenhum concorrente direto mencionado | Seção 2 |
| `01 §3` (3.1–3.5) | Nova capacidade: integração com e-mail (Gmail/Outlook), decisões de escopo confirmadas | Seção 8 (linha de roadmap) + Seção 9 (detalhamento completo) + decisão #12 (seção 10) + riscos novos (seção 11) |
| `01 §4` | Três novas perguntas em aberto | Incorporadas à tabela única da seção 14 (itens 1, 5, 6) |
| `00 §12` | Três perguntas em aberto originais | Incorporadas à tabela única da seção 14 (itens 2, 3, 4) — adotadas como decisão de trabalho, conforme a recomendação original |

**O que não mudou:** problema/oportunidade (exceto o acréscimo de concorrência direta), personas,
escopo do MVP v1, critérios de sucesso, e a íntegra da tabela de decisões de tecnologia #1–#11.

---

## 16. Mapa do ciclo de documentação de produto

Este documento consolida os dois primeiros elos da cadeia de documentação de produto:

```
00 Visão de Negócio (original)   ← POR QUE / PARA QUEM / O QUE / COMO MEDIR
        │
        ▼
01 VN revisada                   ← a VN passada por um crivo crítico (escopo afiado, riscos)
        │
        ▼
00-F VN final (este documento)   ← 00 + 01 consolidados em uma única referência de leitura
        │
        ▼
02 Especificação UX/UI           ← COMO o usuário experimenta (fluxos, telas, estados, identidade)
        │
        ▼
03 Backlog (épicos e tarefas)    ← O QUE construir, em que ordem, com critérios de aceite
        │
        ▼
04 QA report → 05 V&V report → 06 Rollout plan → 07 Operação contínua
```

> Nota de coerência do repositório (atualizada em 2026-08-28): `02-UXUI-spec.md` e `03-backlog.md`
> derivavam originalmente de `briefing.md`, tratando esta linha `00/01/00-F` como exercício didático
> à parte — essa decisão foi revertida a pedido do stakeholder, e ambos os documentos passaram a
> derivar deste `00-F`. O mapa acima já reflete a dependência real em vigor.

---

## 17. Arquitetura de segurança e crescimento (atualizado após E2 ir ao ar)

Adicionado em 2026-08-29, quando a infraestrutura descrita na seção 10 deixou de ser hipotética —
Supabase e GitHub Pages estão em produção. Esta seção documenta a postura **real** adotada para
proteção de dados e para crescer o número de usuários, não uma intenção.

### 17.1 Modelo de proteção de dados

Todo dado de usuário mora atrás de Row Level Security forçado (nenhuma tabela é acessível sem
policy explícita), com um princípio central: **a UI nunca é a linha de defesa — o banco é.**
Qualquer campo que a UI decide não mostrar (CPF, telefone) é adicionalmente bloqueado por regra de
acesso na própria tabela, não só omitido da tela.

- **Dados sensíveis (CPF, telefone) nunca saem do dono.** A política de linha de `profiles` só
  libera a leitura da própria linha; o que outros integrantes de uma viagem veem (nome, e-mail)
  vem de uma função `security definer` (`get_trip_member_profiles`) que devolve só essas duas
  colunas — mesmo que a policy de `profiles` mude no futuro, essa função não passa a vazar CPF
  junto. Verificado com um teste adversarial real (um segundo usuário tentando ler o perfil
  completo de outro, com e sem serem colegas de viagem — ambos os casos vieram vazios).
- **Entrar numa viagem exige o código, sempre.** Não existe caminho de escrita que torne alguém
  integrante de uma viagem sem ter passado pela função `join_trip_by_code`, que exige o código de
  12 dígitos exato. Isso foi corrigido depois de um teste adversarial mostrar que a política
  original permitia a qualquer usuário autenticado virar "convidado" de qualquer viagem só
  adivinhando o identificador sequencial — sem nunca ver o código.
- **Privilégio mínimo em updates.** Cada papel só recebeu permissão de UPDATE nas colunas que o
  produto realmente precisa alterar (ex.: um Admin só pode mudar `role` de um integrante, nunca
  `user_id`; um usuário só atualiza os campos do próprio formulário de Perfil) — não a tabela
  inteira.
- **Segredos:** só a chave `publishable` (pensada para ser pública) vive no código do cliente. A
  chave `service_role`/`secret` nunca foi usada em lugar nenhum ainda — só entrará quando Edge
  Functions existirem (E8, integração de e-mail), e aí como *secret* da função, nunca no repositório
  ou no bundle do cliente (decisão de tecnologia #4).
- **CPF continua opcional** (resposta à pergunta 2 da seção 14) e a política de retenção de
  documentos sensíveis (seção 13) segue como pendência bloqueante para quando o épico de Docs (E8)
  for implementado — nada mudou aqui, só reafirmando que a lacuna é conhecida, não esquecida.

### 17.2 O que ainda falta para "seguro o suficiente para crescer"

Registrado explicitamente para não virar suposição otimista:

- ~~Sem observabilidade de erros em produção~~ — **resolvido em 2026-08-29** (H15.2, adiantada fora
  de ordem): todo erro inesperado do cliente (crash de render, erro de API não tratado, promise sem
  handler) é capturado com contexto (usuário, método/ação, argumentos sem dados sensíveis, stack) em
  `client_errors`, sem policy de leitura pela UI — é revisado direto no banco pela engenharia. Erros
  já tratados pela UI (senha errada, código inválido) são deliberadamente excluídos para não virar
  ruído. H15.1 (tela de sincronização voltada ao usuário) segue adiada até existir E12; H15.3
  (Playwright/CI antes do push) segue não iniciada.
- **Sem fluxo de "esqueci minha senha"** — Supabase Auth suporta nativamente, mas a tela não foi
  construída. Aceitável para os primeiros usuários de teste, não para uma base maior.
- **Sem teste automatizado de RLS** — os dois bugs desta rodada só apareceram porque testamos com
  dois usuários reais num navegador. Não há suíte que rode isso a cada mudança de schema; hoje isso
  depende de repetir esse tipo de teste manualmente antes de mudanças em políticas de acesso.

### 17.3 Arquitetura para crescer o número de usuários

O crescimento aqui é majoritariamente uma questão de **não se importar com ele cedo demais** — as
únicas alavancas que valem preparar agora são as que custam muito para trocar depois:

- **Banco:** todas as chaves estrangeiras têm índice (decisão padrão desde a migração inicial);
  checagens de posse usam funções `security definer` (`is_trip_member`/`is_trip_admin`) em vez de
  subconsultas repetidas por linha — é a otimização de RLS recomendada para não pagar `auth.uid()`
  por linha em tabelas grandes. Pooling de conexão é gerenciado pelo próprio Supabase (Supavisor);
  nada a configurar manualmente até haver sinal real de esgotamento.
- **Frontend:** React agora carrega em build de produção (antes estava em build de desenvolvimento
  por engano — trocado nesta rodada), reduzindo o peso e o tempo de parse. A decisão de arquivo
  único sem bundler (decisão #1) continua valendo, mas com um **gatilho concreto de revisão**, que
  antes só dizia "reavaliar quando o arquivo crescer": revisitar a decisão de bundler quando **(a)**
  o arquivo único ultrapassar ~150 KB de JavaScript não-minificado, **(b)** mais de uma pessoa
  precisar editar o mesmo arquivo em paralelo com frequência, ou **(c)** o Time to Interactive em
  uma rede 4G comum ultrapassar ~3s — o que vier primeiro.
- **Auth:** os limites de taxa padrão do Supabase (`config.toml`, ex.: 2 e-mails/hora) seguem
  ativos; nenhum ajuste foi necessário para o volume atual. Revisitar quando houver campanha de
  aquisição real (ligado à premissa de aquisição orgânica da seção 6).

---

> *Documento mantido em `docs/00-visao-de-negocio-final.md`. Os documentos-fonte `00-visao-de-negocio.md`
> e `01-VN-revisada.md` permanecem no repositório como registro histórico da visão original e do
> processo de revisão crítica que a gerou.*
