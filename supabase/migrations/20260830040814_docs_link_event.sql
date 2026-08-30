-- E8 / H8.3 — falta uma policy de UPDATE em documents para gravar
-- extracted_event_id depois que o usuário confirma a extração e o evento é
-- criado. Faltava desde a migração inicial (só existiam select/insert/delete).
-- Segue o padrão de privilégio mínimo já usado no resto do schema: só a
-- coluna necessária, só quem subiu o documento ou é Admin da viagem.
create policy documents_update_link_event on public.documents
  for update to authenticated
  using (uploaded_by = (select auth.uid()) or (select private.is_trip_admin(trip_id)))
  with check (uploaded_by = (select auth.uid()) or (select private.is_trip_admin(trip_id)));

revoke update on public.documents from authenticated;
grant update (extracted_event_id) on public.documents to authenticated;
