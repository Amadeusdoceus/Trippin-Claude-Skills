-- E15 / H15.2 — captura estruturada de erros e crashes do cliente.
-- Ninguém (nem authenticated, nem anon) tem policy de SELECT: este log é para
-- revisão de engenharia via acesso direto ao banco, não uma tela do produto —
-- evita também que o stack trace de um usuário vaze para outro.
create table public.client_errors (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles (id) on delete set null,
  message text not null,
  stack text,
  context jsonb not null default '{}'::jsonb,
  user_agent text,
  url text,
  created_at timestamptz not null default now()
);

create index client_errors_user_id_idx on public.client_errors (user_id);
create index client_errors_created_at_idx on public.client_errors (created_at);

alter table public.client_errors enable row level security;
alter table public.client_errors force row level security;

-- Insert liberado mesmo para anon (erros podem ocorrer antes do login), mas
-- só é possível gravar em nome de si mesmo — nunca em nome de outro usuário.
create policy client_errors_insert_self_or_anon on public.client_errors
  for insert to authenticated, anon
  with check (user_id is null or user_id = (select auth.uid()));
