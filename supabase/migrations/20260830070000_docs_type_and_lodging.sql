-- Backlog v2 (docs/04-backlog-v2.md) / H16.3-H16.4 — documentos passam a ter
-- um tipo (passagem/hospedagem/evento/extra, H16.4) e, quando o tipo é
-- hospedagem, os campos que alimentam o cartão fixado no Cronograma entre
-- check-in e check-out (H16.3) e a âncora de localização (E17/H17.1). Sem
-- esses campos na própria linha de documents, não dá para calcular "em que
-- dias esse documento cobre" sem reabrir o arquivo original a cada consulta.
--
-- doc_type nasce 'extra' por padrão porque H8.1 exige que o documento seja
-- gravado no upload, antes de a extração terminar (o tipo real só é conhecido
-- depois da confirmação humana, H8.3/H16.3) — mesmo motivo pelo qual não há
-- constraint NOT NULL nos campos de hospedagem.

alter table public.documents
  add column doc_type text not null default 'extra'
    check (doc_type in ('ticket', 'lodging', 'event', 'extra')),
  add column lodging_check_in date,
  add column lodging_check_out date,
  add column lodging_address text,
  add column lodging_confirmation_code text,
  add constraint documents_lodging_dates_order
    check (lodging_check_in is null or lodging_check_out is null or lodging_check_out >= lodging_check_in);

comment on column public.documents.doc_type is 'H16.4 — categoria usada para agrupar a aba Docs em sub-abas; hospedagem também alimenta H16.3/H17.1.';
comment on column public.documents.lodging_check_in is 'H16.3 — só preenchido quando doc_type = lodging; primeiro dia em que o cartão de hospedagem aparece no Cronograma.';
comment on column public.documents.lodging_check_out is 'H16.3 — último dia (inclusive) em que o cartão de hospedagem aparece no Cronograma.';

create index documents_trip_lodging_idx on public.documents (trip_id, lodging_check_in, lodging_check_out)
  where doc_type = 'lodging';

-- mesmo padrão de privilégio mínimo de 20260830040814_docs_link_event.sql
-- (a policy documents_update_link_event já cobre quem pode fazer update:
-- só quem subiu o documento ou é Admin da viagem) — aqui só ampliamos as
-- colunas liberadas para esse mesmo update.
grant update (doc_type, lodging_check_in, lodging_check_out, lodging_address, lodging_confirmation_code)
  on public.documents to authenticated;
