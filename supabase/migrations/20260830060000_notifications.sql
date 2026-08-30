-- E13 / H13.2 — notificações reais para os três eventos do backlog:
-- integrante novo entrando na viagem (interpretação adotada para "convite
-- recebido" — o fluxo real é entrar por código, não um convite nominal;
-- ver nota no backlog), despesa nova que afeta o usuário, e conflito de
-- horário. Inserção só acontece via trigger (security definer, roda como
-- dono da função — as mesmas que já inserem em audit_log/trip_members
-- neste schema), nunca direto pelo cliente: RLS não dá nenhuma policy de
-- insert para authenticated, então tentar forjar uma notificação própria
-- simplesmente falha.
create table public.notifications (
  id bigint generated always as identity primary key,
  trip_id bigint not null references public.trips (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null check (type in ('member_joined', 'expense_impact', 'schedule_conflict')),
  payload jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index notifications_user_id_idx on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;
alter table public.notifications force row level security;

create policy notifications_select_own on public.notifications
  for select to authenticated
  using (user_id = (select auth.uid()));

-- Só a coluna read_at é editável pelo próprio dono (marcar como lida) —
-- mesmo padrão de privilégio mínimo já usado em documents/trip_members.
create policy notifications_update_own on public.notifications
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

revoke update on public.notifications from authenticated;
grant update (read_at) on public.notifications to authenticated;

-- ---------------------------------------------------------------------------
-- "Convite recebido" → integrante novo entrando na viagem: notifica quem já
-- estava na viagem, não quem entrou (quem entrou já sabe que entrou).
-- Também dispara quando o criador é adicionado como admin (trigger
-- on_trip_created), mas nesse instante não existe mais ninguém na viagem
-- ainda, então o select não gera nenhuma linha — sem notificação espúria.
-- ---------------------------------------------------------------------------
create or replace function private.notify_trip_joined()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_name text;
begin
  select coalesce(name, email) into v_name from public.profiles where id = new.user_id;
  insert into public.notifications (trip_id, user_id, type, payload)
  select new.trip_id, tm.user_id, 'member_joined', jsonb_build_object('memberName', v_name)
  from public.trip_members tm
  where tm.trip_id = new.trip_id and tm.user_id <> new.user_id;
  return new;
end;
$$;

create trigger trip_members_notify_join
  after insert on public.trip_members
  for each row execute function private.notify_trip_joined();

-- ---------------------------------------------------------------------------
-- "Despesa nova impactando o usuário": notifica cada participante de uma
-- despesa nova, exceto quem pagou (a própria ação de quem criou não precisa
-- virar notificação para si mesmo).
-- ---------------------------------------------------------------------------
create or replace function private.notify_expense_impact()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_expense record;
begin
  select trip_id, description, currency, paid_by into v_expense
    from public.expenses where id = new.expense_id;
  if new.user_id <> v_expense.paid_by then
    insert into public.notifications (trip_id, user_id, type, payload)
    values (v_expense.trip_id, new.user_id, 'expense_impact',
      jsonb_build_object('description', v_expense.description, 'amount', new.share_amount, 'currency', v_expense.currency));
  end if;
  return new;
end;
$$;

create trigger expense_shares_notify_impact
  after insert on public.expense_shares
  for each row execute function private.notify_expense_impact();

-- ---------------------------------------------------------------------------
-- "Conflito de agenda detectado": dispara quando um participante é
-- adicionado a um evento (event_participants, não schedule_events — no
-- momento em que o evento é inserido os participantes ainda não existem,
-- o cliente faz as duas inserções em sequência) e essa mesma pessoa já
-- participa de outro evento da viagem que colide em horário. Mesma lógica
-- de sobreposição do eventsOverlap() do cliente (H6.5), só que em SQL.
-- ---------------------------------------------------------------------------
create or replace function private.notify_schedule_conflict()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_new_event record;
  v_conflict record;
begin
  select id, trip_id, title, starts_at, coalesce(ends_at, starts_at) as ends_at
    into v_new_event
    from public.schedule_events where id = new.event_id;

  select se.title into v_conflict
    from public.schedule_events se
    join public.event_participants ep on ep.event_id = se.id
    where ep.user_id = new.user_id
      and se.trip_id = v_new_event.trip_id
      and se.id <> v_new_event.id
      and se.starts_at < v_new_event.ends_at
      and coalesce(se.ends_at, se.starts_at) > v_new_event.starts_at
    limit 1;

  if found then
    insert into public.notifications (trip_id, user_id, type, payload)
    values (v_new_event.trip_id, new.user_id, 'schedule_conflict',
      jsonb_build_object('eventTitle', v_new_event.title, 'conflictTitle', v_conflict.title));
  end if;
  return new;
end;
$$;

create trigger event_participants_notify_conflict
  after insert on public.event_participants
  for each row execute function private.notify_schedule_conflict();
