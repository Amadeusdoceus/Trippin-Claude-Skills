-- Bucket privado para os documentos anexados (E8 — Docs com inteligência; UI
-- ainda não construída, mas H2.2 pede Storage provisionado desde a Fase A).
-- Convenção de caminho: {trip_id}/{arquivo} — permite checar posse por prefixo
-- sem precisar de tabela auxiliar.

insert into storage.buckets (id, name, public)
values ('trip-documents', 'trip-documents', false)
on conflict (id) do nothing;

create policy trip_documents_select_member
  on storage.objects for select to authenticated
  using (
    bucket_id = 'trip-documents'
    and (select private.is_trip_member((storage.foldername(name))[1]::bigint))
  );

create policy trip_documents_insert_member
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'trip-documents'
    and (select private.is_trip_member((storage.foldername(name))[1]::bigint))
  );

create policy trip_documents_delete_owner_or_admin
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'trip-documents'
    and (
      owner = (select auth.uid())
      or (select private.is_trip_admin((storage.foldername(name))[1]::bigint))
    )
  );
