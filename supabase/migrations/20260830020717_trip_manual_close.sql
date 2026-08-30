-- E5 / H5.2 — permite ao organizador encerrar a viagem manualmente antes do
-- prazo automático (N dias após end_date, calculado no cliente). trips ainda
-- não tinha nenhuma policy de UPDATE (nenhuma feature editava a viagem até
-- agora) — segue o mesmo padrão de privilégio mínimo já usado no restante do
-- schema: só a coluna necessária, só quem é Admin.
alter table public.trips add column closed_at timestamptz;

create policy trips_update_by_admin on public.trips
  for update to authenticated
  using ((select private.is_trip_admin(id)))
  with check ((select private.is_trip_admin(id)));

revoke update on public.trips from authenticated;
grant update (closed_at) on public.trips to authenticated;
