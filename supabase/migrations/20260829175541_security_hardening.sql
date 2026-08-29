-- Reforço de segurança/privacidade encontrado numa auditoria manual das
-- policies em produção (não hipotético — as duas falhas abaixo eram
-- exploráveis com uma chamada REST simples usando qualquer sessão válida).

-- ---------------------------------------------------------------------------
-- 1) Fecha o furo de enumeração de viagens: hoje qualquer autenticado pode
--    virar "convidado" de QUALQUER trip_id (bigint sequencial, fácil de
--    adivinhar) sem nunca ter visto o código de 12 dígitos, porque a policy
--    de insert em trip_members só checa user_id/role, não posse do código.
--    Fix: a única forma de virar convidado passa a ser esta função
--    security definer, que exige o código exato — a policy de insert direto
--    é removida.
-- ---------------------------------------------------------------------------
drop policy trip_members_insert_self_as_guest on public.trip_members;
drop function if exists public.get_trip_by_code(text); -- superada pela função abaixo

create or replace function public.join_trip_by_code(p_code text)
returns public.trips
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trip public.trips;
begin
  select * into v_trip from public.trips where code = p_code;
  if not found then
    raise exception 'TRIP_NOT_FOUND' using errcode = 'P0002';
  end if;

  insert into public.trip_members (trip_id, user_id, role)
  values (v_trip.id, auth.uid(), 'convidado')
  on conflict (trip_id, user_id) do nothing;

  if found then
    insert into public.audit_log (trip_id, user_id, message)
    values (v_trip.id, auth.uid(), 'entrou na viagem');
  end if;

  return v_trip;
end;
$$;

grant execute on function public.join_trip_by_code(text) to authenticated;

-- ---------------------------------------------------------------------------
-- 2) Fecha o vazamento de CPF/telefone: a policy de "co-integrante" liberava
--    a LINHA inteira de profiles (cpf, telefone, user_code...), não só o
--    nome que a UI exibe. Substitui por uma função que só devolve as
--    colunas necessárias para a tela de Integrantes/histórico.
-- ---------------------------------------------------------------------------
drop policy profiles_select_trip_co_member on public.profiles;

create or replace function public.get_trip_member_profiles(p_trip_id bigint)
returns table(user_id uuid, name text, email text)
language sql
security definer
set search_path = ''
stable
as $$
  select p.id, p.name, p.email
  from public.profiles p
  join public.trip_members tm on tm.user_id = p.id
  where tm.trip_id = p_trip_id
    and (select private.is_trip_member(p_trip_id));
$$;

grant execute on function public.get_trip_member_profiles(bigint) to authenticated;

-- ---------------------------------------------------------------------------
-- 3) Privilégio mínimo: restringe UPDATE a só as colunas que cada fluxo
--    realmente precisa alterar, fechando a possibilidade de um cliente
--    malicioso reescrever colunas fora do que a UI usa (ex.: um Admin
--    sequestrando trip_members.user_id, ou um usuário forjando o próprio
--    user_code/email em profiles).
-- ---------------------------------------------------------------------------
revoke update on public.profiles from authenticated;
grant update (name, phone, cpf, language, onboarded) on public.profiles to authenticated;

revoke update on public.trip_members from authenticated;
grant update (role) on public.trip_members to authenticated;

-- ---------------------------------------------------------------------------
-- 4) Integridade de dados na própria base (defesa em profundidade — o
--    formulário já valida no cliente, mas isso é trivialmente contornável
--    via chamada direta à API).
-- ---------------------------------------------------------------------------
alter table public.trips
  add constraint trips_end_after_start check (end_date >= start_date);
