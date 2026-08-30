-- Backlog v2 (docs/04-backlog-v2.md) / H16.2 — uma passagem aérea com uma ou
-- mais pernas (embarque, conexão, desembarque) agora pode gerar vários
-- eventos (um de embarque + um de desembarque por perna), não só um. A
-- coluna original `extracted_event_id` (H8.3) segue existindo e passa a
-- guardar só o primeiro evento criado, para não quebrar nada que já lê essa
-- coluna (ex.: o selo "vinculado a um evento" na aba Docs); a lista completa
-- vive em `extracted_event_ids`.

alter table public.documents
  add column extracted_event_ids bigint[] not null default '{}';

comment on column public.documents.extracted_event_ids is 'H16.2 — todos os eventos gerados a partir deste documento (uma passagem com N pernas gera até 2N eventos); extracted_event_id guarda só o primeiro, por compatibilidade.';

-- mesmo padrão de privilégio mínimo já usado para extracted_event_id em
-- 20260830040814_docs_link_event.sql — a policy de UPDATE já existe, só
-- ampliamos a coluna liberada.
grant update (extracted_event_ids) on public.documents to authenticated;
