-- Bug real encontrado via smoke test: `insert(...).select()` no cliente gera um
-- INSERT ... RETURNING, que precisa passar pela policy de SELECT de `trips`.
-- A policy original só permitia via private.is_trip_member(id), que depende do
-- trigger add_trip_creator_as_admin já ter sido "visto" dentro do mesmo comando
-- — na prática, a criação da viagem falhava com 42501 mesmo com created_by correto.
-- Corrige adicionando uma condição direta para o próprio criador, independente
-- do timing do trigger.

drop policy trips_select_member on public.trips;

create policy trips_select_member_or_creator on public.trips
  for select to authenticated
  using (
    (select private.is_trip_member(id))
    or created_by = (select auth.uid())
  );

-- Remove a função de diagnóstico temporária usada para investigar este bug.
drop function if exists public.debug_whoami();
