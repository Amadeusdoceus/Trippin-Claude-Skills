-- Trippin — schema inicial (épico E2, backlog 03-backlog.md H2.2/H2.3)
-- Cobre: perfil, viagem, integrante, histórico de auditoria, cronograma, despesas
-- (multi-moeda, decisão confirmada em 2026-08-28) e documentos.
-- RLS em todas as tabelas, por viagem/integrante (H2.3), seguindo o padrão de
-- funções security definer em schema privado para evitar checagem por-linha.

create schema if not exists private;

-- ---------------------------------------------------------------------------
-- Perfis (espelha auth.users; E3 / H3.1-H3.3)
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  name text not null default '',
  phone text not null default '',
  cpf text not null default '',
  user_code text not null unique,
  language text not null default 'pt-BR',
  onboarded boolean not null default false,
  created_at timestamptz not null default now()
);

comment on table public.profiles is 'Perfil de usuário — CPF sempre opcional (00-F §11/§14).';

-- Cria o perfil automaticamente quando um usuário se cadastra via Supabase Auth,
-- gerando o código de usuário de 6 dígitos (H3.2).
create or replace function private.generate_user_code()
returns text
language plpgsql
as $$
declare
  candidate text;
  exists_already boolean;
begin
  loop
    candidate := lpad(floor(random() * 1000000)::text, 6, '0');
    select exists(select 1 from public.profiles where user_code = candidate) into exists_already;
    exit when not exists_already;
  end loop;
  return candidate;
end;
$$;

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, user_code)
  values (new.id, new.email, private.generate_user_code());
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- ---------------------------------------------------------------------------
-- Viagens (E4 / H4.1-H4.2)
-- ---------------------------------------------------------------------------
create table public.trips (
  id bigint generated always as identity primary key,
  code text not null unique,
  name text not null,
  start_date date not null,
  end_date date not null,
  destinations jsonb not null default '[]'::jsonb,
  created_by uuid not null references public.profiles (id),
  created_at timestamptz not null default now()
);

create index trips_created_by_idx on public.trips (created_by);

comment on table public.trips is 'Código de 12 dígitos gerado na criação (H4.1); destinos como lista jsonb (busca real fica para o épico E9/Mapa).';

-- ---------------------------------------------------------------------------
-- Integrantes da viagem — papéis e permissões (E4 / H4.3-H4.4)
-- ---------------------------------------------------------------------------
create table public.trip_members (
  id bigint generated always as identity primary key,
  trip_id bigint not null references public.trips (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null check (role in ('admin', 'coadmin', 'convidado')),
  joined_at timestamptz not null default now(),
  unique (trip_id, user_id)
);

create index trip_members_trip_id_idx on public.trip_members (trip_id);
create index trip_members_user_id_idx on public.trip_members (user_id);

-- Quem cria a viagem entra automaticamente como Admin (mesma regra do mock TrippinAPI).
create or replace function private.add_trip_creator_as_admin()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.trip_members (trip_id, user_id, role)
  values (new.id, new.created_by, 'admin');
  return new;
end;
$$;

create trigger on_trip_created
  after insert on public.trips
  for each row execute function private.add_trip_creator_as_admin();

-- ---------------------------------------------------------------------------
-- Histórico leve de auditoria (E4 / H4.5)
-- ---------------------------------------------------------------------------
create table public.audit_log (
  id bigint generated always as identity primary key,
  trip_id bigint not null references public.trips (id) on delete cascade,
  user_id uuid references public.profiles (id) on delete set null,
  message text not null,
  created_at timestamptz not null default now()
);

create index audit_log_trip_id_idx on public.audit_log (trip_id);

-- ---------------------------------------------------------------------------
-- Cronograma (E6 — schema adiantado; UI ainda não construída)
-- ---------------------------------------------------------------------------
create table public.schedule_events (
  id bigint generated always as identity primary key,
  trip_id bigint not null references public.trips (id) on delete cascade,
  title text not null,
  location text not null default '',
  starts_at timestamptz not null,
  ends_at timestamptz,
  notes text not null default '',
  created_by uuid not null references public.profiles (id),
  created_at timestamptz not null default now()
);

create index schedule_events_trip_id_idx on public.schedule_events (trip_id);
create index schedule_events_created_by_idx on public.schedule_events (created_by);

create table public.event_participants (
  id bigint generated always as identity primary key,
  event_id bigint not null references public.schedule_events (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  unique (event_id, user_id)
);

create index event_participants_event_id_idx on public.event_participants (event_id);
create index event_participants_user_id_idx on public.event_participants (user_id);

-- ---------------------------------------------------------------------------
-- Despesas — multi-moeda desde o MVP (E7 / H7.4, decisão confirmada em 2026-08-28)
-- ---------------------------------------------------------------------------
create table public.expenses (
  id bigint generated always as identity primary key,
  trip_id bigint not null references public.trips (id) on delete cascade,
  event_id bigint references public.schedule_events (id) on delete set null,
  description text not null,
  amount numeric(12, 2) not null check (amount > 0),
  currency text not null,
  split_method text not null default 'equal' check (split_method in ('equal', 'custom', 'fixed')),
  paid_by uuid not null references public.profiles (id),
  created_at timestamptz not null default now()
);

comment on column public.expenses.currency is 'Código ISO da moeda (ex.: BRL, USD). Sem conversão automática entre moedas (02-UXUI-spec.md §0).';

create index expenses_trip_id_idx on public.expenses (trip_id);
create index expenses_event_id_idx on public.expenses (event_id);
create index expenses_paid_by_idx on public.expenses (paid_by);

create table public.expense_shares (
  id bigint generated always as identity primary key,
  expense_id bigint not null references public.expenses (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  share_amount numeric(12, 2) not null check (share_amount >= 0),
  settled boolean not null default false,
  unique (expense_id, user_id)
);

create index expense_shares_expense_id_idx on public.expense_shares (expense_id);
create index expense_shares_user_id_idx on public.expense_shares (user_id);

-- ---------------------------------------------------------------------------
-- Documentos — inteligência de Docs (E8) + retenção/privacidade (E14)
-- ---------------------------------------------------------------------------
create table public.documents (
  id bigint generated always as identity primary key,
  trip_id bigint not null references public.trips (id) on delete cascade,
  uploaded_by uuid not null references public.profiles (id),
  storage_path text not null,
  extracted_event_id bigint references public.schedule_events (id) on delete set null,
  uploaded_at timestamptz not null default now()
);

comment on table public.documents is 'uploaded_at alimenta a tela "Privacidade e dados" (H14.1) — exclusão remove o arquivo e os campos extraídos, não o evento já confirmado (H14.2).';

create index documents_trip_id_idx on public.documents (trip_id);
create index documents_uploaded_by_idx on public.documents (uploaded_by);
create index documents_extracted_event_id_idx on public.documents (extracted_event_id);

-- ---------------------------------------------------------------------------
-- RLS — funções privadas (security definer, schema não exposto pela API)
-- ---------------------------------------------------------------------------
create or replace function private.is_trip_member(p_trip_id bigint)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select exists (
    select 1 from public.trip_members
    where trip_id = p_trip_id and user_id = (select auth.uid())
  );
$$;

create or replace function private.is_trip_admin(p_trip_id bigint)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select exists (
    select 1 from public.trip_members
    where trip_id = p_trip_id and user_id = (select auth.uid()) and role = 'admin'
  );
$$;

revoke execute on function private.is_trip_member(bigint) from public, anon, authenticated;
revoke execute on function private.is_trip_admin(bigint) from public, anon, authenticated;
grant execute on function private.is_trip_member(bigint) to authenticated;
grant execute on function private.is_trip_admin(bigint) to authenticated;

-- ---------------------------------------------------------------------------
-- RLS — habilitar e forçar em todas as tabelas
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.profiles force row level security;
alter table public.trips enable row level security;
alter table public.trips force row level security;
alter table public.trip_members enable row level security;
alter table public.trip_members force row level security;
alter table public.audit_log enable row level security;
alter table public.audit_log force row level security;
alter table public.schedule_events enable row level security;
alter table public.schedule_events force row level security;
alter table public.event_participants enable row level security;
alter table public.event_participants force row level security;
alter table public.expenses enable row level security;
alter table public.expenses force row level security;
alter table public.expense_shares enable row level security;
alter table public.expense_shares force row level security;
alter table public.documents enable row level security;
alter table public.documents force row level security;

-- profiles: cada um vê e edita só o próprio perfil.
create policy profiles_select_own on public.profiles
  for select to authenticated
  using ((select auth.uid()) = id);

create policy profiles_update_own on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id);

-- trips: só quem participa vê; criação livre para qualquer autenticado
-- (o gatilho on_trip_created cuida de inserir o criador como admin).
create policy trips_select_member on public.trips
  for select to authenticated
  using ((select private.is_trip_member(id)));

create policy trips_insert_own on public.trips
  for insert to authenticated
  with check ((select auth.uid()) = created_by);

-- trip_members: visível a quem já participa; entrada por código cria a própria
-- linha como convidado (H4.2); promoção (update de role) só por Admin (H4.4).
create policy trip_members_select_member on public.trip_members
  for select to authenticated
  using ((select private.is_trip_member(trip_id)));

create policy trip_members_insert_self_as_guest on public.trip_members
  for insert to authenticated
  with check (user_id = (select auth.uid()) and role = 'convidado');

create policy trip_members_update_role_by_admin on public.trip_members
  for update to authenticated
  using ((select private.is_trip_admin(trip_id)));

-- audit_log: qualquer integrante lê e registra atividade da própria viagem.
create policy audit_log_select_member on public.audit_log
  for select to authenticated
  using ((select private.is_trip_member(trip_id)));

create policy audit_log_insert_member on public.audit_log
  for insert to authenticated
  with check ((select private.is_trip_member(trip_id)) and user_id = (select auth.uid()));

-- schedule_events / event_participants: qualquer integrante da viagem lê e edita
-- (regras mais finas por papel ficam para quando o épico E6 for implementado).
create policy schedule_events_all_member on public.schedule_events
  for all to authenticated
  using ((select private.is_trip_member(trip_id)))
  with check ((select private.is_trip_member(trip_id)));

create policy event_participants_all_member on public.event_participants
  for all to authenticated
  using ((select private.is_trip_member((select trip_id from public.schedule_events where id = event_id))))
  with check ((select private.is_trip_member((select trip_id from public.schedule_events where id = event_id))));

-- expenses / expense_shares: qualquer integrante da viagem lê e edita
-- (regras mais finas ficam para quando o épico E7 for implementado).
create policy expenses_all_member on public.expenses
  for all to authenticated
  using ((select private.is_trip_member(trip_id)))
  with check ((select private.is_trip_member(trip_id)));

create policy expense_shares_all_member on public.expense_shares
  for all to authenticated
  using ((select private.is_trip_member((select trip_id from public.expenses where id = expense_id))))
  with check ((select private.is_trip_member((select trip_id from public.expenses where id = expense_id))));

-- documents: qualquer integrante lê; exclusão restrita a quem subiu ou a um
-- Admin, para dar suporte à ação "Excluir documento e dados extraídos" (H14.2).
create policy documents_select_member on public.documents
  for select to authenticated
  using ((select private.is_trip_member(trip_id)));

create policy documents_insert_member on public.documents
  for insert to authenticated
  with check ((select private.is_trip_member(trip_id)) and uploaded_by = (select auth.uid()));

create policy documents_delete_owner_or_admin on public.documents
  for delete to authenticated
  using (uploaded_by = (select auth.uid()) or (select private.is_trip_admin(trip_id)));
