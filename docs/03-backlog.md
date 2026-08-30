# 03 — Backlog (Trippin)

| Campo | Valor |
|---|---|
| **Produto** | Trippin — planejador de viagens em grupo |
| **Tipo de documento** | Backlog (épicos, histórias, critérios de aceite) |
| **Deriva de** | `02-UXUI-spec.md` (revisão de 2026-08-28, que deriva de `00-visao-de-negocio-final.md`) |
| **Formato** | Épicos + histórias + critérios de aceite, sem sizing/sprints (projeto pré-MVP, sem cadência de time definida) |
| **Data** | 2026-08-28 (revisão que substitui integralmente a versão de 2026-08-26, escopada em `briefing.md`) |
| **Fora deste backlog** | Integração com e-mail (v2), rastreamento de localização em tempo real (v2), "Recomendações Trippin" com dados agregados (v2), preços ao vivo de hospedagem, tradução completa dos 10 idiomas. Busca de hospedagem tem backlog próprio em `07-busca-hospedagem.md` |
| **Pendência de negócio não representável em épico** | Modelo de negócio do Trippin segue em aberto, agora com dono confirmado — o stakeholder de negócio (`00-F` §14, item 1, atualizado em 2026-08-28) — nenhum épico deste backlog depende disso, mas priorização futura ligada a receita (ex.: preço ao vivo de hospedagem) deve aguardar essa decisão |

---

## Sequenciamento (visão geral)

| Fase | Épicos | Por quê nessa ordem | Status |
|---|---|---|---|
| **A — Fundação** | E1, E2, E3, E4 | Nada mais funciona sem design system, infraestrutura (Supabase, hosting, wrapper mobile), autenticação e o conceito de "viagem" com integrantes | ✅ feito |
| **B — Esqueleto vertical (versão mínima)** | E5-min, E6-min, E7-min | Fluxo ponta-a-ponta usável o mais rápido possível: criar viagem → ver algo no painel → um evento → uma despesa | ✅ feito |
| **C — Diferencial central** | E8 | Inteligência de Docs é o must-have que justifica o produto (`00-F` §4) — entra logo após o esqueleto mínimo existir, não no fim | ✅ feito (2026-08-30) |
| **D — Completar módulos** | E6-completo, E7-completo, E9, E10, E11 | Semana/mês, reordenar, conflitos, métodos de divisão avançados, Mapa, Galeria, Sugestões | ✅ feito (2026-08-30; H10.1 com verificação manual pendente, ver E10) |
| **E — Infraestrutura transversal** | E12, E13, E14, E15 | Offline, notificações/drawer, retenção/privacidade e log de erros só fazem sentido depois de existirem fluxos reais para sincronizar, notificar e logar | E12 e H15.2 feitos; E13/E14/H15.1/H15.3 não iniciados |

> **Nota adicionada em 2026-08-29 (`00-F` §17.2):** a parte de E15 mais urgente para crescer com
> segurança — H15.2, captura estruturada de erros — foi adiantada e concluída fora de ordem, antes
> do restante da Fase B/C. H15.1 (tela de sincronização) segue adiada até existir E12; H15.3
> (Playwright/CI) segue não iniciada.
>
> **Nota adicionada em 2026-08-30:** a Fase D foi concluída fora de ordem, adiantada da Fase C
> (Docs/E8, o diferencial central) a pedido explícito de completar as telas do front que faltavam.
>
> **Nota adicionada em 2026-08-30 (mais tarde):** E8 foi concluída. Com isso, todo o MVP core
> (Fases A-D) está feito; resta apenas a Fase E (infraestrutura transversal), hoje com só H15.2
> feita.
>
> **Nota adicionada em 2026-08-30 (mais tarde ainda):** E12 (sincronização offline) foi concluída,
> a pedido explícito de seguir a ordem do backlog dentro da Fase E. H12.3 (last-write-wins) tem uma
> lacuna de verificação registrada: o cenário de conflito real entre dois usuários não foi testado
> de ponta a ponta neste ciclo por limitação do ambiente de teste (ver H12.3), não do código.

---

## E1 — Fundação de design system

*Deriva de `02-UXUI-spec.md` §3 e decisões de escopo (§0).*

- **H1.1** Definir tokens de cor, tipografia e ícone da identidade "Golden Hour" (claro e escuro).
  - Critério de aceite: tokens documentados e utilizáveis por qualquer tela; modo escuro mantém a paleta quente (não vira cinza-frio).
- **H1.2** Construir componentes base reutilizáveis: bottom sheet, sidebar/drawer, tab bar inferior, faixa de abas horizontal (nível 2 da IA), cards.
  - Critério de aceite: cada componente é usado por pelo menos duas telas diferentes sem duplicação de estilo; a faixa de abas horizontal funciona por scroll em telas estreitas.
- **H1.3** Configurar infraestrutura de i18n (PT-BR + EN-US completos, 8 idiomas restantes como stub) com trocador de idioma no Perfil.
  - Critério de aceite: nenhuma string de UI é hardcoded fora do sistema de tradução a partir deste ponto; alternar idioma no Perfil atualiza toda a interface sem reiniciar o app; idiomas stub não quebram a navegação (caem em EN-US como fallback).

## E2 — Infraestrutura de hospedagem e backend

*Deriva de `00-visao-de-negocio-final.md` §10, decisões #1–#3 — sem equivalente na versão anterior deste backlog, que não tinha stack decidida.*

- **H2.1** App em arquivo único HTML + React 18 via CDN, sem bundler, com pipeline de deploy automático para GitHub Pages via GitHub Actions.
  - Critério de aceite: um `git push` na branch principal publica a versão nova no GitHub Pages sem passo manual.
- **H2.2** Projeto Supabase provisionado: Postgres, Auth, Storage, Edge Functions (Deno/TS).
  - Critério de aceite: schema inicial cobre viagem, integrante, evento, despesa, documento; chave `anon/publishable` é a única exposta no cliente.
- **H2.3** Row Level Security (RLS) cobrindo todas as tabelas por viagem/integrante.
  - Critério de aceite: um usuário autenticado não consegue ler nem escrever dados de uma viagem da qual não participa, mesmo manipulando a chamada diretamente (testado via chamada direta à API, não só pela UI).
- **H2.4** Segredos (chave `service_role`, chaves de e-mail) vivem apenas como *secrets* de Edge Functions.
  - Critério de aceite: nenhum segredo de servidor aparece no bundle do cliente nem no histórico do repositório.

## E3 — Autenticação e perfil

*Deriva de `02-UXUI-spec.md` §2 (Onboarding, Perfil).*

- **H3.1** Cadastro e login por e-mail + senha via Supabase Auth.
  - Critério de aceite: usuário novo cria conta e cai no fluxo de Onboarding; usuário existente faz login e vê a Home com suas viagens.
- **H3.2** Onboarding: seleção de idioma + criação de perfil, gerando código de usuário de 6 dígitos.
  - Critério de aceite: código de 6 dígitos é único por usuário e visível no Perfil a qualquer momento depois.
- **H3.3** Campo de CPF opcional no perfil.
  - Critério de aceite: usuário completa o cadastro e usa o app normalmente sem jamais informar CPF; nenhum fluxo bloqueia por falta de CPF.

## E4 — Viagens, convites e permissões

*Deriva de `02-UXUI-spec.md` §1–2 (Home, Criar viagem, Integrantes).*

- **H4.1** Criar viagem (nome, datas, múltiplos destinos com busca) — calendário nasce automaticamente do intervalo de dias; código de viagem de 12 dígitos gerado ao salvar.
  - Critério de aceite: ao salvar, a viagem aparece na Home no estado "pré-viagem" com a contagem regressiva correta e um código de 12 dígitos exclusivo.
- **H4.2** Participar de uma viagem por código de 12 dígitos.
  - Critério de aceite: código válido leva o usuário direto para a "Viagem" correspondente; código inválido mostra erro inline, sem travar a tela.
- **H4.3** Convidar integrantes por e-mail e por link/QR/código curto.
  - Critério de aceite: qualquer um dos métodos leva um novo usuário direto para a tela de entrada da viagem correspondente.
- **H4.4** Papéis e permissões: Admin, Coadmin, Convidado — múltiplos admins por viagem.
  - Critério de aceite: Convidado não vê nenhuma ação de editar conteúdo de outra pessoa (a ação não aparece, não é apenas desabilitada); Admin pode promover Convidado a Coadmin, e pode haver mais de um Admin/Coadmin simultaneamente.
- **H4.5** Histórico leve de auditoria.
  - Critério de aceite: toda edição relevante (evento, despesa, integrante, documento) gera uma linha legível no histórico, visível a Admins.

## E5 — Home e painel sensível ao estado (versão mínima primeiro)

*Deriva de `02-UXUI-spec.md` §1.*

- **H5.1 (mínimo)** Estado pré-viagem: contagem regressiva + checklist básica (convidar integrantes, montar cronograma).
  - Critério de aceite: contagem regressiva reflete `data_início` corretamente em qualquer fuso horário do dispositivo.
  - **Status: feito** (ciclo 3 do status-report).
- **H5.2** Transição automática pré-viagem → ativa → concluída, sem toggle manual, usando a definição operacional de "concluída" de `00-F` §6 (N dias após a data final, com override manual do organizador).
  - Critério de aceite: no primeiro dia dentro de `[data_início, data_fim]`, o painel troca de conteúdo sem exigir ação do usuário; a viagem entra em "concluída" automaticamente N dias após `data_fim` ou antes, se o organizador encerrar manualmente.
  - **Status: feito em 2026-08-30.** N fixado em 3 dias (parâmetro a calibrar, `computeTripStatus` no código). Encerramento manual implementado como botão "Encerrar viagem" (Admin, aba Integrantes), gravando `trips.closed_at`.
- **H5.3** Estado ativo: cartão "Hoje na viagem" como destaque da aba Cronograma.
  - Critério de aceite: eventos do dia atual aparecem em ordem cronológica; se não houver evento no dia, mostra estado vazio próprio.
  - **Status: feito em 2026-08-30.** Implementado como o próprio Cronograma abrindo no dia de hoje por padrão (H6.1), não como um card separado — mesmo comportamento, sem duplicar UI.
- **H5.4** Estado concluída: acesso somente-leitura ao histórico da viagem.
  - Critério de aceite: nenhuma ação de criar/editar aparece em uma viagem concluída, em nenhuma aba.
  - **Status: feito em 2026-08-30.** `readOnly` calculado uma vez em `TripScreen` e propagado a Cronograma, Despesas e Integrantes (convite/promoção/encerrar somem).

## E6 — Cronograma

*Deriva de `02-UXUI-spec.md` §2, §4.*

- **H6.1 (mínimo)** CRUD de evento com visão diária apenas (local, horário, notas).
  - Critério de aceite: criar, editar e excluir evento refletem imediatamente na visão diária e no cartão "Hoje" quando aplicável.
  - **Status: feito em 2026-08-30.** Navegação dia a dia com setas, limitada ao intervalo da viagem.
- **H6.2 (mínimo)** Painel de detalhe do evento em bottom sheet.
  - Critério de aceite: abrir o detalhe não perde a posição de rolagem da visão do dia ao fechar.
  - **Status: feito em 2026-08-30.**
- **H6.3 (completo)** Visões Semana e Mês.
  - Critério de aceite: alternar entre Dia/Semana/Mês mantém a data selecionada em foco.
  - **Status: feito em 2026-08-30.** Semana lista os dias da semana (segunda a domingo) recortados ao intervalo da viagem; Mês mostra uma grade de calendário com um ponto nos dias com evento. Tocar num dia leva à visão Dia daquela data.
- **H6.4 (completo)** Reordenar evento por arrastar dentro do mesmo dia.
  - Critério de aceite: long-press levanta o card com feedback tátil; soltar reordena com animação de spring, sem trava de duração fixa.
  - **Status: feito em 2026-08-30, com adaptação registrada.** O critério original pressupõe um gesto físico de app nativo (long-press + arrastar com spring). Fora de um app nativo, isso não existe num navegador — implementado como botões ↑/↓ trocando a posição com o vizinho (nova coluna `schedule_events.sort_order`), mesmo resultado funcional sem o gesto físico. Reavaliar a UX de gesto real se/quando o app for empacotado como nativo (decisão de tecnologia #6, `00-F` §10).
- **H6.5 (completo)** Indicador de conflito quando dois eventos se sobrepõem.
  - Critério de aceite: conflito aparece inline no card (marcação colorida), nunca como modal bloqueante; tocar mostra o que conflita.
  - **Status: adiantado e feito em 2026-08-30**, junto com o mínimo — a checagem (`eventsOverlap`) já existia como necessidade natural do CRUD e não fazia sentido adiar.
- **H6.6** Vincular participantes específicos a um evento.
  - Critério de aceite: lista de participantes do evento é usada depois para pré-preencher a divisão de uma despesa nascida desse evento (ver H7.1).
  - **Status: feito em 2026-08-30.**

## E7 — Despesas

*Deriva de `02-UXUI-spec.md` §2.*

> **Correção de navegação (2026-08-30):** Despesas nunca tinha um lugar definido na IA — não estava
> nem nas "seis abas" de `02-UXUI-spec.md` §1 nem na bottom tab bar. Corrigido como sétima aba
> dentro de "Viagem" (ver `02-UXUI-spec.md` §1, nota de correção).

- **H7.1 (mínimo)** Criar despesa vinculada a um evento, com divisão igual entre os participantes daquele evento.
  - Critério de aceite: participantes vêm pré-preenchidos do evento de origem (H6.6); usuário pode ajustar a lista antes de salvar.
  - **Status: feito em 2026-08-30.**
- **H7.2 (mínimo)** Criar despesa avulsa (sem evento de origem).
  - Critério de aceite: fluxo idêntico ao H7.1, exceto que a lista de participantes começa vazia.
  - **Status: feito em 2026-08-30.**
- **H7.3 (mínimo)** Saldo por participante ("você deve" / "te devem"), **agrupado por moeda**, e notificação ao integrante impactado por uma despesa nova.
  - Critério de aceite: saldo recalcula automaticamente a cada despesa criada, editada ou excluída, com um saldo independente por moeda (ex.: "você deve R$ 50 e US$ 20", sem somar as duas); integrante impactado recebe notificação (E14) ao ser adicionado a uma despesa.
  - **Status: parcial.** Saldo por moeda calculado e exibido (verificado em teste real). A notificação em si depende de E13 (Notificações), que não existe — a parte de notificar continua pendente, registrada aqui e não escondida.
- **H7.4 (mínimo)** Selecionar moeda por despesa (multi-moeda desde o MVP, confirmado com o stakeholder em 2026-08-28).
  - Critério de aceite: toda despesa tem um campo de moeda obrigatório; **não há conversão automática entre moedas** — despesas em moedas diferentes na mesma viagem nunca são somadas num único saldo.
  - **Status: feito em 2026-08-30.** Seletor BRL/USD/EUR (lista curada; sem campo livre por ora).
- **H7.5 (completo)** Métodos de divisão: partes customizadas e valor fixo (além de igual).
  - Critério de aceite: soma das partes customizadas é validada contra o valor total (na moeda daquela despesa) antes de permitir salvar.
  - **Status: feito em 2026-08-30.** "Valor fixo" pede o valor exato de cada participante e bloqueia salvar se a soma não bater com o total (validação em tempo real, com mensagem de erro). "Partes customizadas" pede um peso relativo por pessoa (ex.: 2 = o dobro de 1) e calcula os valores proporcionalmente — essa é a leitura adotada para "partes customizadas", que a spec original não detalhava.
- **H7.6 (completo)** Quitação manual entre dois participantes.
  - Critério de aceite: quitação é feita na mesma moeda do saldo que está sendo quitado, atualiza o saldo de ambos naquela moeda e aparece no histórico de auditoria (H4.5), sem mover dinheiro real.
  - **Status: feito em 2026-08-30.** Botão "Marcar como quitado" por participante em cada despesa; reabrir também é possível. `computeBalancesForUser` corrigido para excluir partes quitadas do saldo (bug real: a versão mínima não tinha esse conceito ainda).
- **H7.7 (completo)** Extrato consolidado ao final da viagem, separado por moeda.
  - Critério de aceite: extrato lista todas as despesas, por quem foram pagas e o saldo final de cada participante, com uma seção (ou totalizador) por moeda — nunca um total único somando moedas diferentes; disponível assim que a viagem entra em estado "concluída" (H5.4).
  - **Status: feito em 2026-08-30.** Botão "Ver extrato" na aba Despesas (disponível sempre, não só quando concluída — mais simples e não contradiz o critério, que só exige disponibilidade *a partir* de "concluída"), mostrando total por moeda e saldo final de cada integrante.

## E8 — Docs com inteligência (diferencial central, must-have)

*Deriva de `02-UXUI-spec.md` §7 — área nova neste backlog; não existia na versão anterior, que a tratava como Fase 2 fora de escopo.*

- **H8.1** Upload de documento (PDF ou foto) a partir da aba Docs de uma viagem ativa.
  - Critério de aceite: documento anexado fica associado à viagem e visível na lista de Docs, independentemente do resultado da extração.
  - **Status: feito em 2026-08-30.** Upload direto para o bucket `trip-documents` (mesmo padrão de RLS de `trip-photos`), registro em `documents` acontece imediatamente ao selecionar o arquivo — antes mesmo de a extração terminar, exatamente como o critério exige.
- **H8.2** Parser estruturado + OCR no cliente extraem candidatos a evento (data, horário, local, título), sem LLM (decisão #7 de `00-F` §10).
  - Critério de aceite: para os padrões de documento conhecidos (definidos em conjunto com engenharia), a extração preenche corretamente pelo menos data e horário em um conjunto de documentos de teste.
  - **Status: feito em 2026-08-30, com redução de escopo registrada.** OCR via Tesseract.js (client-side, sem LLM) roda **apenas sobre imagens** (`file.type` começando com `image/`); PDF não é OCRizado — cai direto no fallback H8.5 com campos vazios, sem travar o upload. Parser (`parseDocumentText`) extrai data (numérica `dd/mm/aaaa` e por extenso pt-BR/en-US), horário 24h (`HH:MM`) e um título heurístico (primeira linha substantiva do texto). Verificado em teste real ponta-a-ponta (Puppeteer): documento de teste com "Confirmacao de Reserva / Hotel Central Lisboa / Data: 05/09/2026 / Horario check-in: 14:30" extraiu os três campos corretamente.
- **H8.3** Tela de confirmação humana obrigatória antes de gravar no cronograma, com edição de qualquer campo extraído.
  - Critério de aceite: nenhum evento é criado a partir de um documento sem uma ação explícita de confirmação do usuário; usuário consegue corrigir qualquer campo antes de confirmar.
  - **Status: feito em 2026-08-30.** `DocConfirmSheet` abre sempre após o upload (extração tendo funcionado ou não), com os três campos editáveis; evento só é criado ao clicar em "Criar evento com estes dados", que também grava o vínculo `documents.extracted_event_id` (nova policy de UPDATE, migração `20260830040814_docs_link_event.sql`, coluna liberada via GRANT mínimo). Verificado tanto na UI ("✓ Vinculado a um evento" na lista de Docs) quanto direto no banco (evento e documento devidamente unidos por `extracted_event_id`).
- **H8.4** Alerta de conflito de horário exibido antes da confirmação, reaproveitando o indicador de H6.5.
  - Critério de aceite: se o horário extraído colide com um evento existente, o alerta aparece na própria tela de confirmação, não depois de o evento já ter sido criado.
  - **Status: feito em 2026-08-30.** `DocConfirmSheet` busca os eventos do dia (`listEventsForDay`) sempre que a data muda e reutiliza `eventsOverlap` (mesma função de H6.5) para mostrar o aviso antes da confirmação.
- **H8.5** Fallback para documento fora dos padrões conhecidos: tela de confirmação abre com campos vazios e mensagem não bloqueante.
  - Critério de aceite: falha de extração nunca trava o fluxo nem exige suporte manual — o usuário sempre pode preencher os campos e seguir.
  - **Status: feito em 2026-08-30.** Qualquer falha de extração (PDF, erro do OCR, texto sem padrão reconhecido) resulta em candidato com campos vazios e uma dica não bloqueante (`extractionEmptyHint`); o fluxo de confirmação/edição/criação segue idêntico ao caminho com extração bem-sucedida.

## E9 — Mapa

*Deriva de `02-UXUI-spec.md` §2 — área nova neste backlog.*

- **H9.1** Renderização local de mapa (DestPinMap) com pinos dos destinos e eventos com local associado.
  - Critério de aceite: todo evento do cronograma com local preenchido aparece como pino no Mapa da mesma viagem.
  - **Status: feito em 2026-08-30.** Mapa Leaflet + tiles OpenStreetMap (decisão de tecnologia #8), com destinos da viagem e locais de eventos geocodificados via Nominatim e cacheados por sessão. Verificado com uma chamada real ao Nominatim (destino "Lisboa, Portugal" geocodificado e pino renderizado).
- **H9.2** Busca de lugar via Nominatim/OSM, a partir de 3 letras, com debounce e cache.
  - Critério de aceite: busca não dispara chamada de rede antes do terceiro caractere; resultado repetido dentro da sessão vem do cache, sem nova chamada.
  - **Status: feito em 2026-08-30.** Debounce de 400ms, mínimo de 3 letras, mesmo cache em memória do H9.1.

## E10 — Galeria

*Deriva de `02-UXUI-spec.md` §2 — área nova neste backlog.*

- **H10.1** Upload de fotos (individual ou em lote) por qualquer integrante da viagem.
  - Critério de aceite: foto enviada por um integrante aparece na Galeria de todos os outros integrantes da mesma viagem.
  - **Status: implementado; verificação end-to-end em navegador real inconclusiva por um motivo externo ao código.** Bucket `trip-photos` (RLS por integrante, mesmo padrão de `trip-documents`), tabela `trip_photos`, upload múltiplo e grade de fotos com signed URL. O teste em Chrome headless travou na chamada de upload com `net::ERR_FAILED`, e a resposta do Supabase Storage trazia um cookie de Bot Management do Cloudflare (`__cf_bm`) — sinal de que a automação (não o app) estava sendo bloqueada. **Confirmado via chamada direta em Node.js (sem navegador), mesma chave, mesma policy, mesmo bucket: upload concluído em 416ms com sucesso.** Isso isola o problema no ambiente de teste automatizado (fingerprint de Chrome headless), não no código — mas fica registrado como uma verificação manual recomendada (abrir o app publicado num navegador de verdade e enviar uma foto) antes de considerar 100% confirmado.
- **H10.2** Cache offline de fotos já baixadas, mesma política do cronograma/despesas (E12).
  - Critério de aceite: foto já visualizada uma vez permanece acessível com o dispositivo em modo avião.
  - **Status: não iniciado** — depende de E12 (offline), que não existe.

## E11 — Sugestões (escopo mínimo, sem dados agregados)

*Deriva de `02-UXUI-spec.md` §8 — resolução de uma ambiguidade herdada de `00-F`, confirmada com o stakeholder em 2026-08-28.*

- **H11.1** Sugestões derivadas apenas dos dados da própria viagem (janelas livres na agenda + destinos já no Mapa).
  - Critério de aceite: nenhuma sugestão depende de dados de outra viagem ou de outro usuário da base — a funcionalidade funciona identicamente para a primeira viagem já criada na plataforma.
  - **Status: feito em 2026-08-30.** Calcula vãos livres ≥ 90 min entre eventos do dia e sugere um dos destinos cadastrados da própria viagem para cada vão — nenhuma consulta a dados de outros usuários ou viagens.
- **Nota:** este épico é deliberadamente separado de "Recomendações Trippin" (`00-F` §8, v2, dados agregados), que fica fora deste backlog.

## E12 — Sincronização offline

*Deriva de `02-UXUI-spec.md` §4, §6; decisão de tecnologia #5 de `00-F` §10.*

- **H12.1** Cache local (`localStorage`) de cronograma, despesas, docs confirmados e fotos da viagem ativa.
  - Critério de aceite: com o dispositivo em modo avião, abrir o app ainda mostra os dados da viagem ativa carregados anteriormente, em qualquer aba.
  - **Status: feito em 2026-08-30, com uma ressalva arquitetural registrada.** Leitura com cache: toda consulta (cronograma do dia/semana/mês, despesas, documentos, fotos, dados da viagem) tenta a rede primeiro e só cai no cache salvo se a chamada falhar por conectividade — nunca esconde um erro de negócio (RLS, validação) atrás do cache. Documentos e fotos ficam com os **metadados** em cache (nome, data de upload, vínculo com evento); abrir o arquivo em si continua exigindo rede, porque o bucket é privado e só entrega uma signed URL sob demanda — limitação arquitetural do Storage, não um detalhe adiado.
- **H12.2** Fila local de operações pendentes (criar/editar feito offline), via camada `TrippinAPI`.
  - Critério de aceite: item criado ou editado offline mostra indicador "pendente de sincronização" imediatamente, sem esperar reconexão.
  - **Status: feito em 2026-08-30, com escopo reduzido registrado.** Cronograma (criar/editar/excluir evento) e Despesas (criar despesa, quitar/reabrir) entram na fila; upload de foto/documento fica **fora** da fila offline — é um binário indo para o Storage, que exige rede de qualquer forma, então enfileirar não faria sentido. Reordenar evento (H6.4, um recurso já adaptado do gesto nativo original) também fica fora: offline, é ignorado silenciosamente em vez de arriscar uma reconciliação de ordem complexa por um ganho pequeno. Editar/excluir um item ainda não sincronizado (criado durante a mesma sessão offline) mescla direto na operação de criação já enfileirada, em vez de gerar uma segunda operação — evita tentar "atualizar" algo que o servidor ainda não conhece.
- **H12.3** Sincronização na reconexão com estratégia last-write-wins.
  - Critério de aceite: ao reconectar, itens pendentes sincronizam automaticamente; se houve edição concorrente, a versão mais recente prevalece e o histórico de auditoria (H4.5) registra ambas as tentativas.
  - **Status: feito em 2026-08-30, com uma lacuna de verificação registrada.** Nova coluna `schedule_events.updated_at` (com trigger automático) permite comparar o timestamp local da edição offline contra a última alteração real no servidor: se o servidor tem uma edição mais recente, a ação offline é descartada e registrada no histórico de auditoria (mensagem explicando o descarte); senão, a edição offline é aplicada normalmente. **Verificado de ponta a ponta:** criar evento offline, reconectar e sincronizar automaticamente (banner some, fila esvazia, evento aparece no banco com o `updated_at` correto) — confirmado tanto na UI quanto direto no banco. **Não verificado:** o cenário de conflito real (dois usuários editando o mesmo evento, um deles offline) foi implementado e revisado no código, mas a tentativa de testá-lo com dois navegadores simultâneos falhou repetidamente neste ciclo por esgotamento de memória do ambiente de teste (0,18 GB livres de 7,69 GB, não um defeito do app) — registrado aqui como lacuna de verificação a fechar quando o ambiente permitir, não escondido como "feito e testado".
- **H12.4** Splash/loading intencional no wrapper mobile durante o cache-busting inicial (`02-UXUI-spec.md` §6).
  - Critério de aceite: abrir o app mobile nunca mostra uma tela branca sem conteúdo, mesmo durante a checagem de versão nova.
  - **Status: feito em 2026-08-30, com adaptação registrada.** O critério original pressupõe um wrapper mobile nativo fazendo cache-busting, que não existe aqui (decisão de tecnologia #1). Adaptação: a tela da viagem nasce direto do cache local (H12.1), se houver — nunca fica só "Carregando…" quando já existe um retrato salvo da viagem, mesmo antes da resposta de rede chegar. Sem splash screen dedicada; o mesmo mecanismo de cache que resolve H12.1 resolve esta história.

## E13 — Notificações e navegação transversal (drawer)

*Deriva de `02-UXUI-spec.md` §1.*

- **H13.1** Drawer com Notificações, Configurações da conta, Privacidade e dados, Sair.
  - Critério de aceite: drawer é acessível de qualquer tela do app via ícone hambúrguer, sem sair do contexto da viagem ativa.
- **H13.2** Notificações para: convite recebido, despesa nova impactando o usuário, conflito de agenda detectado.
  - Critério de aceite: cada um dos três eventos gera uma notificação visível na tela de Notificações, mesmo se o app estiver em segundo plano (mobile).

## E14 — Retenção e privacidade de dados sensíveis

*Deriva de `02-UXUI-spec.md` §7; `00-visao-de-negocio-final.md` §13 — épico novo, sem equivalente na versão anterior deste backlog.*

- **H14.1** Tela "Privacidade e dados" (Perfil/drawer) listando, por documento anexado, a data de upload.
  - Critério de aceite: todo documento confirmado em H8.3 aparece nesta lista, com data de upload visível.
- **H14.2** Ação "Excluir documento e dados extraídos", removendo o arquivo e os campos extraídos associados.
  - Critério de aceite: após a exclusão, nem o arquivo original nem os campos extraídos (data/local/horário vindos daquele documento) continuam acessíveis em nenhuma tela do app; o evento criado a partir dele permanece (a exclusão remove a prova/origem, não o evento já confirmado pelo usuário), a menos que o usuário também exclua o evento manualmente.
- **H14.3** Definição e documentação do prazo de retenção padrão do conteúdo extraído de documentos (parâmetro a calibrar com engenharia/jurídico).
  - Critério de aceite: existe um valor padrão documentado e comunicado ao usuário na própria tela de Privacidade e dados (ex.: "mantido por X, ou até você excluir manualmente").

## E15 — Log de erros e observabilidade

*Deriva de `02-UXUI-spec.md` §5.*

- **H15.1 (lado usuário)** Tela "Registro de sincronização" (Perfil ou config. da Viagem).
  - Critério de aceite: toda falha de sincronização aparece como uma linha com horário, descrição e ação "Tentar novamente"; sucesso automático em segundo plano marca o item como "Corrigido automaticamente".
  - **Status: adiada.** Depende do épico E12 (offline/sincronização), que ainda não existe — não há hoje nenhuma "falha de sincronização" real para essa tela mostrar. Construir uma tela vazia agora seria trabalho descartável; revisitar junto com E12.
- **H15.2 (lado engenharia)** Camada de captura estruturada de erros e crashes (ex.: Sentry ou equivalente).
  - Critério de aceite: qualquer crash ou erro de API não tratado no cliente gera um evento capturado com contexto suficiente para reproduzir (usuário, viagem, ação, stack trace), sem exigir que o usuário relate o problema manualmente.
  - **Status: feito em 2026-08-29**, adiantado antes do restante da Fase B/C (recomendação de `00-F` §17.2). Implementado como tabela `client_errors` no Supabase (sem policy de leitura — é para revisão de engenharia via banco, não uma tela do produto) e um wrapper que envolve todo método de `TrippinAPI`, logando automaticamente qualquer erro que não seja um código já tratado pela UI (evita logar "senha errada" como se fosse bug). Cobre também erros de render (`ErrorBoundary`) e erros/promises não tratadas em qualquer ponto do app. Verificado com teste dedicado: erro inesperado gera 1 linha com contexto (método, argumentos sem senha, stack); erro esperado não gera nenhuma; ninguém consegue ler a tabela pelo cliente.
- **H15.3** Suíte de qualidade: `validate-code.js` (sintaxe/chaves) + Playwright E2E, rodando via `npm run review` antes de qualquer push (decisão #10 de `00-F` §10).
  - Critério de aceite: um push com erro de sintaxe ou que quebre um fluxo E2E coberto é bloqueado antes de chegar ao GitHub Pages (E2.1).
  - **Status: não iniciado.** É uma frente de tooling/CI separada de "log de erros" — pedir explicitamente quando quiser priorizar.

---

## Fora deste backlog (lembrete)

Integração com e-mail (Gmail/Outlook — v2, depende de verificação de escopo restrito do Google e
registro no Microsoft Graph, `00-F` §9/§11), rastreamento de localização em tempo real (v2),
"Recomendações Trippin" com dados agregados (v2), preços ao vivo de hospedagem (aguarda chave de
parceiro), tradução completa dos 10 idiomas (contínuo). Busca de hospedagem já é um incremento
pós-MVP com spec e backlog próprios em `07-busca-hospedagem.md`.

O modelo de negócio do Trippin (`00-F` §14, item 1) segue sem definição, mas já tem dono confirmado
(o stakeholder de negócio, desde 2026-08-28) — nenhum épico deste backlog depende disso, mas ele
deveria ser resolvido antes de qualquer priorização futura ligada a receita.
