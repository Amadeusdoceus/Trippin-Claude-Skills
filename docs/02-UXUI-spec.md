# 02 — Especificação de UX/UI (Trippin)

| Campo | Valor |
|---|---|
| **Produto** | Trippin — planejador de viagens em grupo |
| **Tipo de documento** | Especificação de UX/UI |
| **Deriva de** | `00-visao-de-negocio-final.md` (nova fonte de verdade — ver decisão registrada abaixo) |
| **Não deriva de** | `briefing.md` — era a fonte de verdade da versão anterior desta spec; a troca foi uma decisão explícita do stakeholder de produto em 2026-08-28 (ver seção 0) |
| **Data** | 2026-08-28 (revisão que troca a fonte de verdade; substitui integralmente a versão de 2026-08-26) |
| **Escopo desta versão** | MVP v1 completo, conforme `00-visao-de-negocio-final.md` §7: Onboarding, Home, Criar viagem, Viagem ativa (Cronograma, Mapa, Docs, Galeria, Sugestões, Integrantes), Despesas, Notificações + drawer |
| **Fora desta versão** | Integração com e-mail (Gmail/Outlook — v2, `00-F` §9), rastreamento de localização em tempo real (v2), "Recomendações Trippin" com dados agregados (v2), preços ao vivo de hospedagem (quando houver parceiro), tradução completa dos 10 idiomas. Busca de hospedagem (incremento pós-MVP) tem spec própria em `07-busca-hospedagem.md` |
| **Documento seguinte** | `03-backlog.md` — épicos e tarefas derivados desta especificação |

---

## 0. Decisões de escopo confirmadas

Estas decisões foram tomadas explicitamente antes de detalhar as telas, porque mudam a arquitetura da spec. Onde uma decisão não é derivável diretamente de `00-F`, isso está marcado como **decisão desta spec** (autoral, não herdada).

| Decisão | Escolha |
|---|---|
| Fonte de verdade | `00-visao-de-negocio-final.md` é o produto de referência; `briefing.md` não influencia mais este documento |
| Plataforma | **Um único web app** (React 18 via CDN, sem bundler/build — decisão de tecnologia #1 de `00-F` §10), hospedado no GitHub Pages, responsivo. Não existe "app nativo" nem "companion web" como produtos separados — os apps iOS/Android são um **wrapper Expo + React Native WebView** carregando essa mesma web app com cache-busting (decisão #6) |
| Offline | Tratado como requisito rígido no contexto de uso mobile (viagem em trânsito); no navegador desktop a mesma implementação funciona, mas não é bloqueante — desktop assume conectividade normal (planejamento em mesa) |
| Autenticação | E-mail + senha via Supabase Auth (decisão #3/#4 de `00-F` §10) |
| CPF | Opcional (resposta adotada à pergunta 2 de `00-F` §14) |
| Navegação primária | Bottom tab bar em telas estreitas / navegação lateral fixa em telas largas — mesma app, layout responsivo (não duas implementações) |
| Moeda | **Multi-moeda desde o MVP** (confirmado com o stakeholder em 2026-08-28, substitui a suposição anterior de moeda única) — cada despesa tem sua própria moeda dentro da mesma viagem; **sem conversão automática entre moedas** (não há decisão de tecnologia para taxa de câmbio em `00-F` §10) — saldo e extrato são calculados e exibidos **separados por moeda** |
| Idiomas | Infra i18n completa desde o MVP; PT-BR + EN-US traduzidos integralmente, demais 8 idiomas como stub (decisão #11) |
| Identidade visual | **Decisão desta spec, não sourced de `00-F`:** sem branding definido a montante — mantida a identidade "Golden Hour" definida na versão anterior desta spec (seção 3), por não haver motivo em `00-F` para descartá-la |
| Mapa | Renderizado localmente (DestPinMap) + Nominatim/OSM para busca de lugar, sem custo por chamada (decisão #8) |
| Inteligência de Docs | Must-have do MVP; parser estruturado por padrões conhecidos + OCR no cliente + **confirmação humana obrigatória antes de gravar** (decisão #7) — sem LLM na v1 |
| Retenção de dados sensíveis | Bloqueante definir política antes de codificar o fluxo de Docs (herdado de `00-F` §13) — ver seção 7 desta spec |

---

## 1. Arquitetura de informação

Dado que a "viagem ativa" tem **seis** destinos de navegação (Cronograma, Mapa, Docs, Galeria,
Sugestões, Integrantes — `00-F` §7 item 4), uma bottom tab bar plana de 6 itens não é viável em
mobile. A IA usa dois níveis:

**Nível 1 — bottom tab bar (mobile) / sidebar (telas largas):** Início · Viagem · Perfil.

**Nível 2 — dentro de "Viagem":** faixa de abas horizontal (scrollável em mobile, fixa em telas
largas) com **sete** destinos: **Cronograma · Despesas · Mapa · Docs · Galeria · Sugestões ·
Integrantes.** Cronograma é a aba padrão ao entrar.

> **Correção (2026-08-30):** `00-F` §7 lista "Despesas" (item 9) como parte do MVP mas nunca a
> associa a nenhuma navegação — nem às "seis abas" de "Viagem ativa" (item 4), nem à bottom tab bar.
> Essa spec originalmente também esqueceu Despesas na contagem ("seis destinos"). Corrigido aqui: a
> leitura mais coerente é que Despesas é mais uma aba de segundo nível dentro de "Viagem" (mesma
> natureza de Cronograma — dado por viagem, não global como Perfil), não um destino de nível 1.

**Drawer (menu lateral, ícone hambúrguer, qualquer tela):** Notificações, Configurações da conta,
Privacidade e dados (seção 7), Sair — itens transversais que não pertencem a uma viagem específica
(`00-F` §7 item 8: "Notificações + barra lateral de navegação").

**Fluxo pré-viagem (antes de existir uma viagem ativa):**
Onboarding (idioma → criação de perfil com código de usuário de 6 dígitos, `00-F` §7 item 1) →
Home (viagens ativas, "Criar viagem", "Participar de viagem" por código, viagens anteriores,
`00-F` §7 item 2) → formulário de criação (nome, datas, múltiplos destinos com busca — código de
viagem de 12 dígitos gerado ao salvar, `00-F` §7 item 3) **ou** entrada por código de 12 dígitos →
cai na "Viagem" recém-criada ou encontrada.

**Início é sensível ao estado da viagem** — não é uma tela fixa. A transição é automática: a
viagem passa de "pré-viagem" para "ativa" quando a data atual entra em `[data_início, data_fim]`,
e para "concluída" segundo a regra operacional definida em `00-F` §6 (N dias após a data final,
ou quando o organizador encerra manualmente).
- **Antes da partida:** contagem regressiva, checklist de planejamento (convidar integrantes,
  montar cronograma), progresso de convites.
- **Durante a viagem:** cartão "Hoje na viagem" (linha do tempo do dia) como destaque da aba
  Cronograma.
- **Concluída:** acesso somente-leitura ao histórico da viagem (cronograma, despesas, extrato,
  galeria), sem ações de edição.

---

## 2. Inventário de telas por área

**Onboarding**
- Seleção de idioma
- Criação de perfil (nome, foto opcional, telefone) — gera código de usuário de 6 dígitos
- CPF opcional, coletado apenas se o usuário optar por informar (nunca bloqueante)

**Home**
- Lista de viagens ativas / pré-viagem
- "Criar viagem" / "Participar de viagem" (código de 12 dígitos)
- Viagens anteriores (somente leitura)

**Criar viagem**
- Nome, datas (o calendário nasce do intervalo), múltiplos destinos com busca (usa o mesmo serviço
  de busca de lugar do Mapa — Nominatim/OSM, a partir de 3 letras, com debounce)
- Geração do código de viagem de 12 dígitos ao salvar

**Cronograma**
- Cartão-herói (pré-viagem: contagem regressiva + checklist; ativa: "Hoje na viagem")
- Visão Dia / Semana / Mês
- Painel de detalhe do evento (local, horário, link de mapa, notas, participantes vinculados)
- Reordenar evento por arrastar dentro do mesmo dia
- Formulário de criar/editar evento (manual, ou pré-preenchido pela Inteligência de Docs — ver
  seção 7)
- Indicador de conflito quando dois eventos se sobrepõem

**Mapa**
- Mapa local (DestPinMap) com pinos de todos os destinos e eventos com local associado
- Busca de lugar (Nominatim/OSM), mínimo 3 letras, com debounce e cache local

**Docs** — ver detalhamento completo na seção 7

**Galeria**
- Grade de fotos enviadas pelos integrantes da viagem
- Upload em lote; fotos ficam disponíveis offline uma vez baixadas (mesma política de cache do
  cronograma)

**Sugestões** — ver nota de escopo na seção 8

**Integrantes**
- Lista com badge de papel (Admin / Coadmin / Convidado)
- Convite por e-mail e por código/link/QR da viagem
- Promover integrante a coadministrador
- Histórico leve de auditoria, visível a admins ("Fulano editou o evento X, há 2h")

**Despesas**
- Lista de despesas da viagem ativa
- "Adicionar despesa" — nascida de um evento (pré-preenche participantes) ou avulsa, com seleção de **moeda** por despesa (multi-moeda desde o MVP, ver seção 0)
- Divisão: igual / partes customizadas / valor fixo
- Saldo por participante ("você deve" / "te devem"), **agrupado por moeda** — sem conversão automática; quitação manual dentro da mesma moeda
- Extrato consolidado ao final da viagem, **separado por moeda**, e notificação ao integrante impactado por uma despesa nova

**Perfil**
- Dados pessoais, código de usuário, idioma
- Acesso à Privacidade e dados (seção 7) e ao Registro de sincronização (seção 9)

---

## 3. Identidade visual — "Golden Hour"

**Paleta:** terracota/coral como cor primária (CTAs, estado ativo das abas); verde-petróleo profundo como acento secundário (links, datas selecionadas); neutros em tom areia/creme para superfícies — não branco puro, para evocar o calor de papel/filme em vez de um visual clínico de SaaS; cinza quase-preto (não preto puro) para texto. No modo escuro, a base passa para um azul-crepúsculo profundo, mantendo os mesmos acentos terracota/verde-petróleo — o app permanece "quente" em vez de virar cinza-frio.

**Tipografia:** uma família geométrica sem serifa para toda a interface e números (saldos, datas — exige bons algarismos tabulares), com ajuste óptico por tamanho: tracking mais fechado em textos grandes (nome da viagem, títulos), mais aberto em textos pequenos (legendas), conforme os fundamentos de tipografia do `apple-design`.

**Iconografia e movimento:** ícones de linha simples (não preenchidos, não skeuomórficos) — o calor da identidade vem da cor, não da textura do ícone. Movimento segue os princípios do `apple-design`: transições baseadas em spring (não easing linear), gestos interrompíveis nos painéis de detalhe (arrastar para baixo para dispensar, acompanhando o dedo, sem trava de duração fixa).

---

## 4. Interação e comportamento offline

Painéis de evento/despesa/doc são **bottom sheets**, não telas cheias — mantém a posição de
rolagem da visão do dia e segue o padrão "adicionar rápido sem perder contexto" do `apple-design`.
Reordenar evento usa "long-press para levantar" com feedback tátil e soltar com momentum.

**Offline (decisão de tecnologia #5 de `00-F` §10):** cronograma, despesas, docs já processados e
fotos de galeria já baixadas ficam em cache local (`localStorage` + camada de sync `TrippinAPI`) e
legíveis offline; qualquer criação/edição feita offline entra numa fila local com indicador
"pendente de sincronização" no item afetado, sincronizando na reconexão com estratégia
*last-write-wins* — o histórico de auditoria (área Integrantes) torna conflitos visíveis depois do
fato. Isso vale tanto para o wrapper mobile (WebView) quanto para o navegador desktop, por ser a
mesma aplicação; no desktop, a ausência de rede aparece apenas como um indicador discreto, não como
bloqueio.

---

## 5. Tratamento de erros e log de detecção/correção

Estados vazios claros para: nenhuma viagem ainda, viagem sem eventos, viagem sem despesas, viagem
sem docs anexados, galeria vazia — cada um com uma única ação clara, nunca uma tela em branco.
Erros de permissão (convidado tentando editar contribuição de outra pessoa) são bloqueados na
interface (a ação de editar simplesmente não aparece). Avisos de conflito no calendário ficam
inline no card do evento (marcação colorida + toque para ver o que conflita), nunca um modal
bloqueante.

**Log de erros — visível ao usuário:** tela "Registro de sincronização" (Perfil ou configurações
da Viagem) lista operações que falharam (ex.: "Falha ao sincronizar despesa X às 14:32") com ação
manual "Tentar novamente", e marca "Corrigido automaticamente" quando uma nova tentativa em segundo
plano é bem-sucedida. Estende o histórico de auditoria da área Integrantes para falhas técnicas.

**Log de erros — lado da engenharia (requisito técnico, não tela):** todo erro do cliente (falha de
sincronização, chamada de API com erro, crash) precisa ser capturado por uma camada estruturada de
logging/crash-reporting (ex.: Sentry ou equivalente). Não é uma tela desta spec — vira épico próprio
em `03-backlog.md`.

---

## 6. Arquitetura de plataforma (implicações de UX)

Como o mobile é um wrapper WebView (decisão #6 de `00-F` §10), há implicações diretas de UX que
esta spec precisa registrar:

- **Cache-busting ao abrir o app** pode gerar um instante de recarregamento perceptível — a tela de
  abertura do app mobile precisa de um splash/loading intencional (não uma tela branca), para não
  reproduzir o risco de "tela branca" já mapeado em `00-F` §11.
- **Gestos e performance** ficam limitados ao que a WebView oferece — animações spring e gestos
  interrompíveis (seção 3/4) devem ser validados dentro da WebView real, não só no navegador
  desktop, antes de considerar uma tela "pronta".
- **Não há divergência de fluxo entre mobile e desktop** — qualquer decisão de UX nesta spec vale
  para os dois, exceto onde explicitamente marcado (offline como bloqueante só em mobile, seção 4).

---

## 7. Docs com inteligência (must-have do MVP)

Área antes fora de escopo desta spec (era "Módulo 04 — Fase 2" quando a fonte de verdade era
`briefing.md`); com `00-F` como fonte, esta é **a área que justifica o produto existir**
(`00-F` §4/§7) e entra no MVP.

**Fluxo:**
1. Usuário anexa um documento (PDF ou foto) na aba Docs, a partir de uma viagem ativa.
2. Parser estruturado + OCR no cliente extraem candidatos a evento (data, horário, local, título) —
   sem LLM na v1 (decisão #7).
3. Tela de **confirmação humana obrigatória**: mostra o que foi extraído lado a lado com o
   documento original, permite editar qualquer campo antes de gravar. Nada é escrito no cronograma
   sem essa confirmação explícita.
4. Se o horário extraído conflitar com um evento existente, o alerta de conflito (mesmo padrão da
   seção 5) aparece **antes** da confirmação, não depois.
5. Documento confirmado fica anexado ao evento criado e acessível offline, como qualquer outro
   conteúdo da viagem.

**Estados de falha:** documento fora dos padrões conhecidos do parser cai em preenchimento manual —
a tela de confirmação abre com os campos vazios e uma mensagem curta ("não conseguimos ler este
documento automaticamente"), nunca um erro bloqueante.

**Privacidade e retenção (bloqueante — herdado de `00-F` §13):** antes deste fluxo entrar em
produção, precisa existir uma tela de **"Privacidade e dados"** (acessível via Perfil/drawer) que
mostre, por documento anexado, a data de upload e uma ação explícita **"Excluir documento e dados
extraídos"**. A UX aqui não é opcional/nice-to-have — é a mesma pendência de compliance que a VN
marca como bloqueante para a futura integração de e-mail, e recomendada desde já para Docs.

---

## 8. Sugestões — nota de escopo (confirmada com o stakeholder em 2026-08-28)

`00-F` §7 lista "Sugestões" como uma das seis abas do MVP, mas `00-F` §8 trata "Recomendações
Trippin" (baseadas em dados agregados da base de usuários) como item de **v2**, adiado por
depender de massa de usuários que ainda não existe. Essas duas coisas podem ou não ser a mesma
funcionalidade — `00-F` não resolve isso explicitamente, porque herda a ambiguidade de `00`.

**Resolução adotada por esta spec, confirmada com o stakeholder em 2026-08-28:** tratar como
funcionalidades distintas:
- **Sugestões (MVP, esta aba):** conteúdo estático ou derivado apenas dos dados **da própria
  viagem** (ex.: "vocês têm 3h livres entre o check-in e o jantar — que tal um passeio perto do
  hotel?", usando os pinos já no Mapa) — não depende de dados agregados de outros usuários.
- **Recomendações Trippin (v2, fora desta versão):** sugestões baseadas em padrões agregados de
  toda a base de usuários, conforme `00-F` §8.

---

## 9. Próximos passos

Este documento alimenta `03-backlog.md`: cada seção acima (telas do inventário, Docs com
inteligência, offline, identidade visual, log de erros, retenção/privacidade) se torna um ou mais
épicos, com critérios de aceite derivados diretamente das decisões da seção 0 e dos comportamentos
descritos nas seções 1–8.
