# Relatório de Status — Trippin

| Campo | Valor |
|---|---|
| **Tipo** | Relatório de status gerencial — atualizado a cada ciclo, não é parte da cadeia numerada `00→07` |
| **Base** | `00-visao-de-negocio-final.md`, `02-UXUI-spec.md`, `03-backlog.md` |
| **Atualização atual** | 2026-08-29 (ciclo 3 — início da construção, Fase A) |
| **Atualização anterior** | 2026-08-28 (ciclo 2 — confirmação de decisões pendentes) |
| **Como manter** | A cada novo ciclo: atualizar seções 1–4 com o estado atual e adicionar uma linha em "Histórico" (seção 6). Não reescrever o histórico de ciclos passados. |

---

## 1. Resumo executivo

**Saiu do papel.** A Fase A começou: E1 (design system), E3 (autenticação/perfil) e E4 (viagens,
convites, permissões) já têm uma primeira versão funcional, rodando localmente e testada num
navegador real. E2 (infraestrutura Supabase/GitHub Pages) segue **fora deste ciclo** — não há
credenciais de nuvem conectadas ainda; por decisão do stakeholder, a construção seguiu com dados
mockados em `localStorage` por trás de uma camada (`TrippinAPI`) que já imita a interface que o
Supabase vai assumir depois, para não bloquear o resto da Fase A. Estimativa segue em **~12 semanas
até a V1**, sem mudança de número nesta rodada.

**Pendência que mais afeta o prazo real:** ainda não há equipe/cadência definida (ver seção 4), e
agora também **E2 precisa de uma decisão de acesso** (criar/conectar o projeto Supabase e o
repositório GitHub) antes de a Fase A ser considerada fechada de verdade.

---

## 2. Evolução desde a última atualização

Ciclo 3 — primeira construção real, escopada aos épicos E1/E3/E4 do backlog (E2 fica para quando
houver credenciais de Supabase/GitHub):

- **App web em arquivo único** (`web/index.html`), seguindo a decisão de tecnologia #1 da VN
  (React 18 via CDN, sem bundler). Nenhum repositório git foi inicializado ainda.
- **E1 — Design system:** tokens de cor/tipografia "Golden Hour" (claro e escuro), i18n completo
  em PT-BR e EN-US com troca em tempo real, e os componentes-base reutilizáveis descritos em
  `02-UXUI-spec.md` (tab bar, drawer, faixa de abas horizontal, bottom sheet, cards).
- **E3 — Autenticação e perfil:** cadastro/login, onboarding com geração de código de usuário de 6
  dígitos, CPF opcional.
- **E4 — Viagens, convites e permissões:** criar viagem (com busca de destino — lista estática
  provisória, busca real via Nominatim/OSM fica para o épico E9/Mapa), entrar por código de 12
  dígitos, papéis Admin/Coadmin/Convidado com múltiplos admins, tela de Integrantes com convite
  (código copiável; e-mail real depende de E2) e histórico de auditoria.
- **TrippinAPI:** camada de persistência mock sobre `localStorage`, desenhada para já ter a
  interface que o Supabase real (E2) vai assumir depois — nenhuma tela toca `localStorage`
  diretamente.
- **Testado num navegador real** (Chrome via `agent-browser`): percurso completo — escolha de
  idioma → cadastro → onboarding → Home vazia → criar viagem com busca de destino → tela da Viagem
  com as 6 abas → Integrantes mostrando Admin sem botão de auto-promoção → bottom sheet de convite
  com o código → troca de idioma ao vivo → drawer → logout — sem nenhum erro de console numa carga
  limpa. A lógica de "entrar por código" e a permissão do Convidado (não vê ações de editar) foram
  confirmadas por revisão de código, não por clique ao vivo, porque a ferramenta de automação do
  navegador travou no meio do teste do segundo usuário (falha da ferramenta, não do app).
- **Bug real encontrado e corrigido durante o teste:** a versão "latest" do Babel Standalone via
  CDN carrega presets dinamicamente com `import`, o que quebra fora de `type="module"`. Resolvido
  chamando `Babel.transform` manualmente em vez do scanner automático de `<script type="text/babel">`.
- Módulos ainda não construídos (fora do escopo deste ciclo): Cronograma, Despesas, Docs, Mapa,
  Galeria, Sugestões, offline, notificações — todos aparecem como "esta área chega em uma fase
  seguinte" dentro da tela de Viagem.

---

## 3. Próximos passos imediatos

**Decisão necessária do stakeholder:** seguir para E5/E6-mín/E7-mín (Fase B, esqueleto vertical)
já sobre o mock local, deixando E2 (Supabase/GitHub Pages) para entrar em paralelo depois — ou
pausar a Fase A até existir projeto Supabase e repositório GitHub reais. `TrippinAPI` foi desenhada
para permitir a primeira opção sem retrabalho.

**Ainda em aberto, sem bloquear:**
- Definir o modelo de negócio em si (não só o dono) — sem prazo declarado.
- **E2 — Infraestrutura:** falta criar/conectar projeto Supabase (Auth/DB/Storage/Edge Functions) e
  repositório GitHub com deploy para GitHub Pages, e então portar `TrippinAPI` do mock para chamadas
  reais, com RLS cobrindo as tabelas por viagem/integrante.

**Se a Fase A continuar:** próximo é o esqueleto vertical mínimo (E5, E6-mín, E7-mín) — Home
sensível ao estado, um evento de cronograma, uma despesa — o primeiro fluxo ponta a ponta usável.

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
