# 04 — Backlog v2: paridade mínima com o protótipo de referência (Trippin)

| Campo | Valor |
|---|---|
| **Produto** | Trippin — planejador de viagens em grupo |
| **Tipo de documento** | Backlog (épicos, histórias, critérios de aceite) — continuação de `03-backlog.md` |
| **Deriva de** | Comparação direta entre este repositório (código real de `web/index.html` + `supabase/migrations/`) e o protótipo de referência `github.com/Amadeusdoceus/TrippinClaude` (clonado e inventariado nesta sessão), mais diretriz explícita do stakeholder em 2026-08-30 |
| **Motivação** | `03-backlog.md` está 100% concluído, mas o app atual ficou aquém do protótipo de referência em profundidade de funcionalidade, mesmo cobrindo as mesmas telas. Este documento fecha essa lacuna. |
| **Diretriz do stakeholder (2026-08-30, verbatim resumida)** | (1) Todas as funcionalidades reais (não-stub) do app de referência devem estar minimamente presentes no app atual — nome, layout, funcionalidades, botões; (2) upload de arquivo com preenchimento **automático** do cronograma é imprescindível na V1 — extração via LLM fica para v2, mas preenchimento **só manual** não é aceitável como V1; (3) o Cronograma diário precisa mostrar em que localização o usuário está, derivado de documentos de reserva (hotel/Airbnb/booking) enviados; (4) precisa existir um mapa **curto e simplificado** mostrando o roteiro já percorrido vs. a programação completa da viagem |
| **Formato** | Épicos + histórias + critérios de aceite, sem sizing/sprints — mesmo formato de `03-backlog.md` |
| **Fora deste backlog** | Qualquer funcionalidade do app de referência que lá é explicitamente stub/mock/não-funcional (ver §0.2) — essas não contam como "funcionalidade a replicar", só o que de fato funciona no protótipo |

---

## 0. O que a comparação encontrou

### 0.1 — O app atual já iguala ou supera a referência em

Auth real via Supabase (referência usa senha local em `localStorage`, base64 como fallback — um "smell" de segurança que **não deve ser copiado**), papéis Admin/Coadmin/Convidado (referência só tem admin binário), multi-moeda com saldo separado por moeda (referência não tem coluna de split/moeda no schema), sincronização offline real com fila e reconciliação last-write-wins (referência é 100% `localStorage`, sem fila nem reconciliação), tela de privacidade/retenção (E14, inexistente na referência), registro de sincronização visível ao usuário (H15.1, inexistente na referência), captura estruturada de erros (H15.2, inexistente na referência), suíte de qualidade com gate de CI (H15.3, a referência tem Playwright mas sem gate bloqueando deploy). **Não retroceder nenhum desses pontos ao implementar os épicos abaixo.**

### 0.2 — Na referência, mas explicitamente stub/mock — não replicar como "pronto"

`TravelAppsScreen` (7 logos de parceiros, todos "Em breve", zero link real), aba "Recomendações Trippin" (banner "chega na v2", sem conteúdo), aba "Recomendações Gerais" (dados 100% hardcoded, comentário no próprio código diz "mock"), preço ao vivo de hospedagem (conectores documentados mas desligados por padrão), 8 dos 10 idiomas (caem em en-US silenciosamente), e o backend Supabase da referência inteiro exceto convite por e-mail (schema e Edge Functions existem mas **não são chamados** pelo app — tudo roda em `localStorage`). Nenhum destes vira história neste backlog.

### 0.3 — Onde a referência está genuinamente à frente (o que este backlog cobre)

Extração de documento mais rica (também extrai local, não só data/horário), criação de múltiplos eventos a partir de uma única passagem (uma perna = um embarque + uma chegada), cartão de hospedagem fixado no cronograma durante toda a estadia, derivação de "onde o usuário está" a partir dessas âncoras de documento, mapa com rota ordenada e visitado-vs-futuro, ajudante de check-in de voo, OCR de recibo para despesas, captura por câmera real, categorização de documentos por tipo, e uma tela de Configurações real (a atual é placeholder).

---

## Sequenciamento (visão geral)

| Fase | Épicos | Por quê nessa ordem |
|---|---|---|
| **F — Diferencial imprescindível (V1)** | E16, E17, E18 | Os três itens que o stakeholder marcou como não-negociáveis para a V1: extração multi-campo com criação automática de eventos, localização atual derivada de documentos, mapa curto de progresso. Nenhum dos três funciona sem o anterior (E17 depende dos dados que E16 passa a capturar; E18 depende da âncora de local que E17 calcula) |
| **G — Paridade complementar** | E19, E20, E21 | Demais funcionalidades reais da referência ainda ausentes — elevam a paridade mas não bloqueiam o diferencial da Fase F |
| **H — Auditoria de marca/layout** | E22 | Comparação tela a tela de nome/rótulos/botões — feita por último porque depende das telas novas das Fases F/G existirem para ser uma auditoria completa |

> **Nota adicionada em 2026-08-30:** **todo o backlog v2 (Fases F, G e H — E16 a E22) está
> implementado.** Cada história tem seu status detalhado (incluindo reduções de escopo e
> adaptações) na seção correspondente abaixo. O que resta antes disso valer em produção:
> (1) aplicar as 3 migrações novas ao Supabase real (`20260830070000`, `20260830071500`,
> `20260830080000` — nenhuma delas foi rodada ainda neste ciclo); (2) nenhuma tela nova foi
> verificada num navegador real ou contra o banco — só `validate-code.js` (sintaxe) rodou a
> cada mudança. Verificação manual/E2E real é o próximo passo natural, não mais escrita de
> código nova.
>
> **Nota adicionada em 2026-08-30 (mais tarde):** as 3 migrações foram aplicadas ao Supabase
> real (`supabase db push`, confirmado com `--dry-run` → `upToDate: true` e uma leitura via
> REST confirmando as colunas novas). O primeiro push para produção quebrou o CI (Playwright
> pegou 3 erros de página não tratados — esperado, o push aconteceu antes das migrações
> serem aplicadas); re-rodado depois de sincronizar o banco, passou limpo (test + deploy).
>
> **Bug real encontrado e corrigido:** o stakeholder reportou "todos os pop-ups quebraram na
> tela". Causa raiz: a classe `.sheet` (usada por todo `BottomSheet`) nunca teve
> `max-height`/rolagem própria; o conteúdo adicionado hoje em vários formulários ao mesmo
> tempo (modo Passagem de H16.2, ajudante de check-in de H19.2, anexar recibo de H19.1,
> busca de hospedagem de E21) estourou a altura da tela em vários popups de uma vez.
> Corrigido com `max-height: 88vh; overflow-y: auto` em `.sheet`. **Verificado num navegador
> real** (viewport mobile 390×844, contra o Supabase de produção com uma conta de teste
> descartável criada na hora): formulário de evento renderiza inteiro sem precisar rolar;
> formulário de despesa (o mais afetado, com o botão de recibo novo) precisa rolar e agora
> rola corretamente, com o botão "Salvar" alcançável no fim. Upload de documento não pôde ser
> testado de ponta a ponta neste ciclo — mesma limitação de ambiente já registrada em H10.1
> (Cloudflare Bot Management bloqueando upload ao Storage vindo de Chrome headless, não um
> problema do código).
>
> **Segunda causa do mesmo bug, encontrada depois de o stakeholder descrever com mais
> detalhe:** o primeiro reparo (`max-height`/rolagem) não era a causa inteira. `.sheet-backdrop`
> usava `inset: 0` — ia até a base absoluta da tela, ignorando os 72px reservados pela barra
> de navegação inferior (`.app-shell` padding-bottom). Resultado: o popup sempre desenhava por
> cima da barra de navegação (z-index mais alto), e em telas de celular reais — onde a altura
> visível muda com a barra de endereço do navegador — o rodapé do popup também ficava fora da
> área visível. Corrigido trocando `inset: 0` por `bottom: 72px` no backdrop (resolve os dois
> de uma vez: nunca mais invade a barra de navegação, e por não depender de `vh`, o limite se
> ajusta sozinho à altura real visível) e `.sheet { max-height: 92% }` (percentual do backdrop,
> não mais `vh`). **Verificado num navegador real** contra a mesma conta de teste, no mesmo
> viewport (695×923, batendo com uma captura de tela real enviada pelo stakeholder): antes da
> correção, reproduzi o problema exatamente como descrito; depois, a barra de navegação fica
> visível abaixo do popup e o botão "Salvar" continua alcançável.

---

## E16 — Docs: extração multi-campo e criação múltipla de eventos

*Deriva de `02-UXUI-spec.md` §7 (upgrade de `E8`, que hoje só extrai data/horário/título e cria no máximo um evento por documento) + diretriz do stakeholder item (2).*

- **H16.1** Extrair também o campo **local** no parser de documentos (`parseDocumentText`), hoje limitado a data/horário/título.
  - Critério de aceite: para os mesmos documentos de teste já usados em H8.2 (confirmação de reserva com endereço/cidade no texto), o campo local é preenchido corretamente na tela de confirmação, sem exigir digitação manual.
  - **Status: feito em 2026-08-30.** Novo regex de rótulo (`local:`/`endereço:`/`localização:`/`address:`/`location:`/`hotel:`/`cidade:`/`city:` seguido de dois-pontos) em `parseDocumentText`; `DocConfirmSheet` agora pré-preenche o campo Local a partir de `candidate.location` (antes sempre nascia vazio, mesmo com a extração pronta). Validado só com `validate-code.js` (sintaxe) — sem verificação em navegador real neste ciclo.
- **H16.2** Reconhecer documento de **passagem aérea** com uma ou mais pernas (embarque, conexão, desembarque) e propor **um evento de partida + um evento de chegada por perna**, todos editáveis na mesma tela de confirmação antes de gravar.
  - Critério de aceite: um documento de passagem com conexão gera pelo menos 4 candidatos a evento (partida e chegada de cada perna), cada um com data/horário/local próprios; usuário revisa e confirma todos de uma vez (ou remove os que não quer), nunca um por um em telas separadas; nenhum evento é gravado sem confirmação explícita (mantém o requisito de H8.3).
  - **Status: feito em 2026-08-30, com uma pendência de infraestrutura registrada.** `parseTicketCandidate` reconhece pernas por rótulo explícito ("De:"/"Para:"/"Embarque:"/"Desembarque:", pareados por posição — não tenta associar por proximidade textual, mais simples e previsível para OCR ruidoso); `DocConfirmSheet` ganhou um seletor de 3 modos (Evento único / Hospedagem / Passagem, via `SegmentedTabs`) — no modo Passagem, cada trecho detectado vira um cartão editável (origem, destino, embarque, desembarque), removível, com botão "Adicionar trecho" para completar manualmente quando a detecção vier incompleta ou vazia (nunca bloqueia em "0 trechos detectados"). Ao confirmar, cada trecho grava 2 eventos (embarque + desembarque) via `TrippinAPI.createEvent`, todos vinculados ao documento pela nova coluna `documents.extracted_event_ids` (migração `20260830071500_docs_ticket_legs.sql`; `extracted_event_id` original passa a guardar só o primeiro evento, por compatibilidade). **Mesma pendência de H16.3: a nova migração ainda não foi aplicada ao Supabase real** — precisa ser aplicada manualmente antes deste fluxo funcionar em produção. Só `validate-code.js` (sintaxe) foi rodado; sem verificação em navegador real ou contra um documento de teste real neste ciclo.
- **H16.3** Reconhecer documento de **hospedagem** (check-in, check-out, endereço, código de reserva) e propor um **cartão de hospedagem** — não um evento pontual — que fica fixado no Cronograma em todos os dias entre check-in e check-out.
  - Critério de aceite: ao confirmar um documento de hospedagem, o cartão aparece acima da lista de horários em cada dia do intervalo `[check-in, check-out]` da visão Dia, mostra endereço e código de reserva, e distingue visualmente o dia de check-in do dia de check-out dos dias intermediários.
  - **Status: feito em 2026-08-30, com uma pendência de infraestrutura registrada.** Nova migração `supabase/migrations/20260830070000_docs_type_and_lodging.sql` adiciona `documents.doc_type` + `lodging_check_in/check_out/address/confirmation_code`, com policy de UPDATE ampliada (mesmo padrão de privilégio mínimo de `20260830040814_docs_link_event.sql`). `parseLodgingCandidate` detecta hospedagem por palavra-chave e propõe check-in/check-out (a primeira e a última data distintas encontradas no texto), endereço e código; `DocConfirmSheet` ganhou um alternador "Isso é uma reserva de hospedagem", sempre corrigível pelo usuário antes de salvar (mesmo princípio de confirmação humana de H8.3). `ScheduleScreen`/`DayView` agora buscam as hospedagens confirmadas da viagem e fixam o cartão certo acima da lista de horários. **Pendência: a migração ainda não foi aplicada ao projeto Supabase real** — não há Supabase CLI configurado neste ambiente para rodar `supabase db push`; precisa ser aplicada manualmente (CLI ou SQL editor do painel) antes de este fluxo funcionar em produção. Nenhuma verificação em navegador real ou contra o banco foi feita neste ciclo — só `validate-code.js` (sintaxe).
- **H16.4** Categorizar documentos por tipo (Passagens / Hospedagens / Eventos / Extras) na aba Docs.
  - Critério de aceite: cada documento anexado aparece na sub-aba correta (inferida automaticamente pela extração de H16.2/H16.3 quando possível, com opção de o usuário corrigir a categoria); a categoria "Extras" cobre qualquer documento que não se encaixe nas outras três.
  - **Status: parcialmente feito em 2026-08-30.** A coluna `doc_type` já existe (ver H16.3) e a lista de Docs já mostra um selo "🏨 Você está hospedado aqui" para documentos de hospedagem confirmados. **Falta:** a reorganização da aba Docs em sub-abas (Passagens/Hospedagens/Eventos/Extras) e a classificação automática de passagens (depende de H16.2, ainda não implementada) — este item continua aberto.
- **H16.5** Reafirmar o fallback não-bloqueante (já existente em H8.5) para todos os novos caminhos de extração.
  - Critério de aceite: falha de extração em qualquer categoria (passagem, hospedagem, evento, extra) cai em campos vazios editáveis, nunca trava o upload nem exige suporte manual — mesma garantia de H8.5, agora cobrindo os campos e categorias novos.
  - **Status: feito em 2026-08-30**, como consequência direta do desenho de H16.2/H16.3: hospedagem sem detecção nasce com campos vazios editáveis (mesmo fallback de H8.5); passagem sem nenhum trecho detectado mostra "Nenhum trecho detectado automaticamente" e o botão "Adicionar trecho" continua disponível — nunca bloqueia o upload nem força o modo Evento único. Nenhum caminho novo trava sem uma saída editável.

## E17 — Localização atual do viajante

*Deriva da diretriz do stakeholder item (3); inspirado no padrão `locationAnchors`/`locationForDay` do protótipo de referência, adaptado para não depender de rastreamento GPS ao vivo (fora de escopo, já registrado como v2 em `00-F`).*

- **H17.1** Calcular **âncoras de local por data**, a partir de hospedagens confirmadas (H16.3) e do trecho final de passagens confirmadas (H16.2) — conexões/escalas explicitamente excluídas por não serem "onde a pessoa fica".
  - Critério de aceite: a lista de âncoras de uma viagem é ordenada cronologicamente e cada âncora tem uma cidade/local e uma data de início; escalas de voo nunca geram âncora própria.
  - **Status: feito em 2026-08-30.** Nova `TrippinAPI.listLocationAnchors(tripId)`: âncoras de hospedagem vêm do check-in confirmado; âncoras de passagem vêm só do **último** id em `documents.extracted_event_ids` de cada documento tipo `ticket` (a chegada da perna final — H16.2 grava embarque+chegada por perna nessa ordem, então o último id é sempre uma chegada final, nunca uma conexão), resolvido contra `schedule_events` para pegar local+data. Lista final ordenada por data.
- **H17.2** Exibir **"Você está em [cidade]"** no topo da visão Dia do Cronograma, usando a âncora mais recente cuja data seja ≤ à data visualizada.
  - Critério de aceite: ao navegar entre dias na visão Dia, o texto de localização muda automaticamente conforme a âncora vigente naquele dia, sem ação manual do usuário.
  - **Status: feito em 2026-08-30.** `locationForDay(anchors, dayIso)` (função pura) roda no cliente a cada troca de dia; `DayView` mostra "📍 Você está em {cidade}" no topo, acima do cartão de hospedagem (H16.3) quando ambos se aplicam ao mesmo dia.
- **H17.3** Estado sem âncora — dia anterior à primeira âncora conhecida (ou viagem sem nenhum documento de hospedagem/passagem confirmado ainda) mostra um estado vazio claro, nunca um erro ou um local incorreto.
  - Critério de aceite: viagem recém-criada sem nenhum documento confirmado não mostra "Você está em [cidade]" nenhuma — mostra um convite discreto para anexar a primeira reserva.
  - **Status: feito em 2026-08-30.** Sem nenhuma âncora na viagem inteira, mostra o convite discreto ("Anexe uma reserva..."); com âncoras existindo mas nenhuma valendo ainda para o dia visualizado (antes da primeira), não mostra nada — nunca inventa um local. **Pendência compartilhada com H16.2/H16.3: depende das duas migrações ainda não aplicadas ao Supabase real** (`documents.doc_type`/`lodging_*`/`extracted_event_ids`); sem verificação em navegador real neste ciclo, só `validate-code.js`.

## E18 — Mapa de progresso da viagem (rota curta e simplificada)

*Deriva da diretriz do stakeholder item (4); upgrade de `E9`, hoje um mapa de pinos estáticos sem ordem nem noção de progresso. Escopo deliberadamente reduzido frente à referência (ver E18 nota final) porque o pedido foi por algo "curto e simplificado", não a timeline de coocorrência em grupo do protótipo.*

- **H18.1** Ordenar os pinos do Mapa **cronologicamente** (por data do destino/evento/âncora) e conectar com uma linha simples de rota, em vez do agrupamento sem ordem atual.
  - Critério de aceite: a ordem dos pinos no Mapa corresponde à ordem real das datas da viagem, verificável comparando com o Cronograma da mesma viagem.
  - **Status: feito em 2026-08-30, com uma limitação de dado registrada.** Cada pino carrega a data mais cedo conhecida (evento com aquele local, ou âncora de E17/H17.1); `L.polyline` conecta só os pinos com data conhecida, em ordem cronológica. **Limitação:** `trip.destinations` é uma lista de nomes sem data própria (schema atual, fora do escopo deste backlog) — um destino cadastrado que ainda não tem nenhum evento nem âncora aparece no mapa mas fica de fora da linha de rota (pino "neutro", cor areia), nunca inventa uma data para ele.
- **H18.2** Diferenciar visualmente pinos **já visitados** (data-fim ≤ hoje) de pinos **futuros** (data-início > hoje), e o pino **atual** (se a data de hoje cair dentro do intervalo de um destino).
  - Critério de aceite: um pino visitado, um atual e um futuro são visualmente distinguíveis à primeira vista (não só por texto em tooltip), consistente com o status calculado em `computeTripStatus`/`locationForDay`.
  - **Status: feito em 2026-08-30.** `mapPinCategory` classifica cada pino datado em passado/hoje/futuro (cores fixas — verde-petróleo/coral/cinza-areia, mesma paleta "Golden Hour" do app); legenda simples abaixo da busca explica as três cores. Pino sem data usa uma quarta cor neutra (areia).
- **H18.3** Marcador **"você está aqui"** no pino correspondente à âncora de local atual (E17), quando existir uma.
  - Critério de aceite: se H17.2 mostra "Você está em Lisboa" hoje, o Mapa da mesma viagem destaca o pino de Lisboa como "você está aqui", sem exigir que o usuário abra outra tela para confirmar.
  - **Status: feito em 2026-08-30.** O pino cuja cidade bate com `locationForDay(anchors, hoje)` (mesmo cálculo de H17.2) ganha raio maior, borda mais grossa e popup prefixado com "📍 Você está aqui" — e força a cor "hoje" mesmo que a data da âncora seja de alguns dias atrás (ex.: check-in de hotel há 3 dias, ainda hospedado — continua "atual", não "passado"). **Mesma pendência de infraestrutura de E16/E17: depende das migrações ainda não aplicadas ao Supabase real.** Sem verificação em navegador real neste ciclo — só `validate-code.js`.
- **Nota de escopo (explicitamente fora deste épico):** timeline de coocorrência entre múltiplos integrantes, mapa por integrante/grupo, e rastreamento GPS ao vivo — presentes na referência, mas fora do pedido de "mapa curto e simplificado" e já registrados como v2 em `00-visao-de-negocio-final.md`. Não implementar nesta rodada.

## E19 — Paridade complementar de Docs/Despesas

*Funcionalidades reais da referência ainda ausentes, fora dos três itens imprescindíveis — cobrem a exigência de "todas as funcionalidades... minimamente inclusas".*

- **H19.1** Anexar recibo a uma despesa e reaproveitar o parser de documentos (E16) para pré-preencher descrição/valor/data.
  - Critério de aceite: ao anexar uma foto/PDF de recibo numa despesa, os campos de descrição, valor e data vêm pré-preenchidos quando a extração reconhece o padrão; usuário confirma ou corrige antes de salvar — mesmo modelo de confirmação humana obrigatória de H8.3.
  - **Status: feito em 2026-08-30, com escopo reduzido registrado.** Novo `parseExpenseCandidate`/`extractExpenseFromReceipt` (Tesseract.js, mesmo pipeline) extrai **descrição e valor** (rótulo "total"/"valor"/"amount", com `parseMoneyToken` tratando separador decimal pt-BR e en-US); botão "📎 Anexar recibo" no formulário de despesa dispara o OCR e pré-preenche os dois campos. **Não preenche data** — a tabela `expenses` não tem coluna de data própria (só `created_at`), então não havia campo para preencher; o critério original citava "data" partindo do pressuposto de um campo que não existe neste schema.
- **H19.2** Ajudante de **check-in de voo**: horário estimado de abertura de check-in (padrão configurável, ex. 48h antes da partida), link de check-in (site da companhia quando identificável, senão uma busca), e código de reserva copiável.
  - Critério de aceite: para um evento de partida criado a partir de H16.2, a tela de detalhe do evento mostra a janela estimada de check-in e o código de reserva em um toque para copiar.
  - **Status: feito em 2026-08-30, com duas reduções de escopo registradas.** `EventFormSheet` detecta um evento de embarque pelo prefixo fixo do título (gravado em pt-BR ou en-US no momento da confirmação de H16.2) e mostra a janela estimada de check-in (48h antes, fixo — não configurável ainda) e um link de busca (`google.com/search?q=check-in+online+...`) — não identifica o site da companhia aérea especificamente, sempre cai na busca. **Não há código de reserva copiável**: `parseTicketCandidate` não extrai um código (a referência tem isso, o parser desta versão não); implementar exigiria extrair o código no upload e persisti-lo nas notas do evento, deixado para uma iteração futura por não estar no caminho crítico dos três itens imprescindíveis.
- **H19.3** Captura por **câmera real** (não só seleção de arquivo) no upload de Docs e Galeria.
  - Critério de aceite: em um dispositivo com câmera, o fluxo de upload oferece "tirar foto agora" além de "escolher arquivo existente", usando a câmera nativa do navegador/dispositivo.
  - **Status: feito em 2026-08-30, com uma simplificação de implementação registrada.** Em vez do modal de câmera customizado (`getUserMedia`) da referência, usei um segundo `<input type="file" capture="environment">` — abre a câmera nativa do dispositivo diretamente (sem modal próprio do app), mais simples e sem código novo de captura/preview, mas com a mesma experiência funcional do ponto de vista do usuário (botão "📷 Tirar foto" ao lado do de escolher arquivo, em Docs e Galeria).

## E20 — Configurações reais

*Hoje a tela de Configurações (item do drawer) é 100% placeholder — nunca teve história própria em `03-backlog.md`. A referência tem uma versão funcional, exceto o padrão de senha em texto reversível, que não deve ser copiado.*

- **H20.1** Alternância de tema claro/escuro, persistida por usuário.
  - Critério de aceite: a escolha de tema sobrevive a um logout/login e a uma nova sessão no mesmo dispositivo.
  - **Status: feito em 2026-08-30, com decisão de persistência registrada.** Persistido por **dispositivo** (`localStorage`, chave `trippin_theme`), não por linha no banco de um usuário — o critério original só exige sobreviver a logout/login "no mesmo dispositivo", que `localStorage` já cobre sem precisar de uma migração nova; troca não sincroniza entre dispositivos do mesmo usuário (fora do que o critério pede). CSS ganhou `:root[data-theme="dark"]` e a media query de sistema passou a respeitar `:not([data-theme="light"])`, para a escolha manual sobrepor a preferência do SO nos dois sentidos.
- **H20.2** Alternância de notificações (silenciar/reativar).
  - Critério de aceite: com notificações desativadas nas Configurações, os três tipos de notificação de H13.2 continuam sendo gerados no banco (para não perder o histórico), mas não geram badge nem aparecem como novas até reativar.
  - **Status: feito em 2026-08-30.** Mesma decisão de persistência de H20.1 (`localStorage`, chave `trippin_notifications_muted`). As 3 triggers de H13.2 continuam intactas (nada mudou no banco); `refreshUnreadCount` no cliente força a contagem a 0 quando silenciado — a tela de Notificações em si (aberta manualmente) continua mostrando os itens, só o badge do drawer some.
- **H20.3** Troca de senha.
  - Critério de aceite: fluxo usa a troca de senha nativa do Supabase Auth (nunca armazena ou exibe a senha em texto plano/base64 — diferente do padrão da referência, que é um problema de segurança, não um comportamento a copiar).
  - **Status: feito em 2026-08-30.** `TrippinAPI.changePassword` chama `supabaseClient.auth.updateUser({ password })` diretamente — sem armazenamento local, sem exibição em texto plano. `PlaceholderScreen` (não usado por mais nada) foi removido do código junto com esta mudança.

## E21 — Busca de hospedagem mínima

*Fecha uma referência já existente e hoje quebrada em `03-backlog.md` linha 10 ("Busca de hospedagem tem backlog próprio em `07-busca-hospedagem.md`") — esse arquivo nunca foi criado. A referência tem uma ferramenta equivalente (`buscar-hospedagem.html`) funcionando só com dados livres (OSM/Overpass), sem preço ao vivo — mesma limitação aceitável aqui.*

- **H21.1** Ferramenta de busca de hospedagem por destino + datas, usando dados livres (OSM/Overpass Nominatim), sem preço ao vivo nesta versão.
  - Critério de aceite: buscar um destino com datas retorna uma lista de opções de hospedagem com nome/endereço/localização no mapa; ausência de preço é comunicada de forma clara (não parece um erro).
  - **Status: feito em 2026-08-30, com uma redução de escopo registrada.** `LodgingSearchSheet` (novo botão "🔎 Buscar hospedagem" na aba Docs): geocodifica o destino (Nominatim, mesmo cache de H9.1/H9.2) e busca hospedagens num raio de 3km via Overpass (`tourism` = hotel/hostel/guest_house/apartment), listando nome+endereço; nota fixa explica a ausência de preço. **Não mostra os resultados num mini-mapa** dentro da busca (só lista) — o critério original pedia "localização no mapa"; a localização de cada resultado só aparece depois, no Mapa da viagem (E18), uma vez confirmado como hospedagem (via âncora, H17.1).
- **H21.2** Confirmar uma opção encontrada gera automaticamente um documento de hospedagem na viagem ativa, entrando no mesmo fluxo de confirmação de H16.3.
  - Critério de aceite: ao confirmar uma opção da busca dentro do contexto de uma viagem aberta, o cronograma da viagem ganha o cartão de hospedagem (H16.3) sem precisar re-digitar check-in/check-out/endereço.
  - **Status: feito em 2026-08-30, com uma migração adicional registrada.** `TrippinAPI.createSearchedLodging` grava direto uma linha `documents` com `doc_type='lodging'` e sem arquivo (`storage_path` nulo) — exigiu tornar essa coluna opcional e adicionar `source` ('upload'/'search', só informativo) via nova migração `20260830080000_docs_search_sourced_lodging.sql`. **Terceira migração pendente de aplicar ao Supabase real**, mesma ressalva de E16/E17/E18; `deleteDocument` e a busca de signed URL na aba Docs já foram ajustados para não quebrar com `storage_path` nulo.

## E22 — Auditoria de marca/layout/nome/botões

*Diretriz do stakeholder item (1) — "layout, nome, funcionalidades, botões, tudo deve ser revisto". Feito por último porque as telas novas das Fases F/G precisam existir para a auditoria ser completa. Nome ("Trippin") e paleta ("Golden Hour") já são consistentes entre os dois apps — o valor deste épico está no que sobra: rótulos de aba, textos de botão, textos de estado vazio.*

- **H22.1** Auditoria comparativa tela a tela entre o app atual (publicado) e o protótipo de referência: rótulos de aba/menu, texto de botões de ação primária, textos de estado vazio, nomenclatura de categorias (ex. "Docs" vs. "Passagens/Estadias/Eventos/Extras" de H16.4).
  - Critério de aceite: produz uma lista de divergências encontradas (tela a tela), cada uma classificada como "manter divergência — motivo documentado" ou "alinhar com a referência".
  - **Status: feito em 2026-08-30, como auditoria de código (não visual em navegador — ver ressalva abaixo).** Comparação direta entre `web/index.html` (app atual) e `app/index.html` do clone de `Amadeusdoceus/TrippinClaude` (reference). Achados:
    | Item | Divergência encontrada | Classificação |
    |---|---|---|
    | Tipografia | Referência usa 3 famílias (Sora/Inter/JetBrains Mono); app atual usa 1 (Plus Jakarta Sans) | **Manter** — `02-UXUI-spec.md` §3 explicitamente pede "uma família geométrica sem serifa para toda a interface", decisão já registrada nesta spec, não um esquecimento |
    | Paleta de cor | Hex exatos diferentes (referência `--coral #FF6B5C`/`--lagoon #2DB5A3`; atual `--color-primary #E2673A`/`--color-secondary #1F5C56`) | **Manter** — `02-UXUI-spec.md` §3 descreve a paleta qualitativamente (terracota/coral + verde-petróleo + areia), sem fixar hex; ambos os apps são fiéis à mesma identidade "Golden Hour", só com tons escolhidos independentemente |
    | Ordem das abas da viagem | Referência: Cronograma·Mapa·Docs·Galeria·Despesas·Integrantes·Sugestões. Atual: Cronograma·Despesas·Mapa·Docs·Galeria·Sugestões·Integrantes | **Manter** — `02-UXUI-spec.md` §1 já documenta essa ordem específica como correção deliberada (nota de 2026-08-30 no próprio arquivo), não uma divergência acidental |
    | Papéis de integrante | Referência: só Admin (binário). Atual: Admin/Coadmin/Convidado | **Manter** — decisão de `00-visao-de-negocio-final.md`, já coberta por H4.4, app atual é superset deliberado |
    | Formato do código de viagem | Referência: 12 caracteres alfanuméricos. Atual: 12 dígitos numéricos | **Manter, com ressalva.** Nunca foi uma decisão de paridade com a referência (implementação independente); mudar agora exigiria decidir o que fazer com códigos de viagens já criadas em produção — fora do escopo de uma auditoria de nome/rótulo, é uma decisão de dado/migração que precisa de dono de produto, não algo para alinhar sozinho aqui |
    | Wordmark + tagline no primeiro contato | Referência mostra "Trippin." (ponto colorido) + "Tudo da sua viagem, num lugar só." já na tela de idioma. App atual não mostrava marca nenhuma em lugar algum | **Alinhar** — gap real, não uma decisão registrada em nenhum doc; aplicado em H22.2 |
  - **Ressalva de método:** esta auditoria comparou os dois códigos-fonte diretamente (estrutura, strings, CSS), não um navegador real rodando os dois apps lado a lado — mais confiável para rótulos/nomes/textos (o que este épico pede), mas não substitui uma revisão visual (espaçamento, alinhamento, animação) se isso vier a importar depois.
- **H22.2** Ajustar cada divergência de H22.1 classificada como "alinhar com a referência".
  - Critério de aceite: cada ajuste referencia a linha correspondente do relatório de H22.1.
  - **Status: feito em 2026-08-30.** Único item classificado "alinhar" (wordmark+tagline) implementado: `LanguageScreen` (primeira tela do app) agora mostra "Trippin" com o ponto na cor primária + a tagline bilíngue, igual ao padrão da referência. Chave `appTagline` adicionada ao dicionário pt-BR/en-US.

---

## Fora deste backlog (lembrete, herdado + ampliado)

Tudo já listado em `03-backlog.md` §"Fora deste backlog" continua fora. Adicionalmente, ficam fora por serem stub/mock na própria referência (ver §0.2): deep links reais para apps parceiros (Booking/Airbnb/Uber/etc.), "Recomendações Trippin" com dados agregados, recomendações gerais com dados reais de mapas (a versão da referência é mock), preço ao vivo de hospedagem, tradução completa dos 10 idiomas, timeline de coocorrência/mapa em grupo, rastreamento GPS em tempo real, e desbloqueio biométrico (WebAuthn) — este último por não ter sido pedido explicitamente e por a referência já ter, junto dele, um padrão de senha em texto reversível que não deve ser reproduzido.
