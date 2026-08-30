-- Backlog v2 (docs/04-backlog-v2.md) / H21.2 — uma hospedagem confirmada
-- pela busca de hospedagem (E21) não tem um arquivo físico anexado (não veio
-- de upload, H8.1) — storage_path passa a ser opcional. `source` só existe
-- para a UI distinguir as duas origens (upload vs. busca); nunca afeta RLS,
-- que continua por trip_id/uploaded_by como sempre.

alter table public.documents
  alter column storage_path drop not null,
  add column source text not null default 'upload' check (source in ('upload', 'search'));

comment on column public.documents.source is 'H21.2 — upload (H8.1) ou search (busca de hospedagem, E21); só informativo para a UI. Não precisa de GRANT de UPDATE — só é definido no insert.';
