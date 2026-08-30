-- Fase D: campos/tabelas de suporte para Cronograma completo (E6), Despesas
-- completo (E7) e Galeria (E10). Mapa (E9) e Sugestões (E11) não precisam de
-- schema novo — leem dados que já existem (trips.destinations, eventos).

-- E6 / H6.4 — reordenar evento dentro do mesmo dia, independente do horário
-- (interpretação adaptada para web: sem gesto de long-press/arrastar físico
-- disponível fora de um app nativo, a reordenação é feita por botões
-- ↑/↓ trocando este valor entre dois eventos do mesmo dia).
alter table public.schedule_events add column sort_order integer not null default 0;
create index schedule_events_trip_sort_idx on public.schedule_events (trip_id, sort_order);

-- E10 — Galeria (H10.1). Segue o mesmo padrão de documents/trip-documents:
-- bucket privado, policy por posse/admin para exclusão, membro da viagem
-- para ver e enviar.
create table public.trip_photos (
  id bigint generated always as identity primary key,
  trip_id bigint not null references public.trips (id) on delete cascade,
  uploaded_by uuid not null references public.profiles (id),
  storage_path text not null,
  created_at timestamptz not null default now()
);

create index trip_photos_trip_id_idx on public.trip_photos (trip_id);
create index trip_photos_uploaded_by_idx on public.trip_photos (uploaded_by);

alter table public.trip_photos enable row level security;
alter table public.trip_photos force row level security;

create policy trip_photos_select_member on public.trip_photos
  for select to authenticated
  using ((select private.is_trip_member(trip_id)));

create policy trip_photos_insert_member on public.trip_photos
  for insert to authenticated
  with check ((select private.is_trip_member(trip_id)) and uploaded_by = (select auth.uid()));

create policy trip_photos_delete_owner_or_admin on public.trip_photos
  for delete to authenticated
  using (uploaded_by = (select auth.uid()) or (select private.is_trip_admin(trip_id)));

insert into storage.buckets (id, name, public)
values ('trip-photos', 'trip-photos', false)
on conflict (id) do nothing;

create policy trip_photos_storage_select_member
  on storage.objects for select to authenticated
  using (
    bucket_id = 'trip-photos'
    and (select private.is_trip_member((storage.foldername(name))[1]::bigint))
  );

create policy trip_photos_storage_insert_member
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'trip-photos'
    and (select private.is_trip_member((storage.foldername(name))[1]::bigint))
  );

create policy trip_photos_storage_delete_owner_or_admin
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'trip-photos'
    and (
      owner = (select auth.uid())
      or (select private.is_trip_admin((storage.foldername(name))[1]::bigint))
    )
  );
