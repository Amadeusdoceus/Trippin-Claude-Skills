-- E12 / H12.3 — sincronização offline com last-write-wins: para decidir se
-- uma edição feita offline ainda "vence" ao reconectar, o cliente precisa
-- comparar o timestamp local da edição contra a última alteração real no
-- servidor. schedule_events só tinha created_at (nunca muda); falta um
-- updated_at que reflita toda edição, atualizado automaticamente por
-- trigger (não pelo cliente, que poderia esquecer de setá-lo).
alter table public.schedule_events
  add column updated_at timestamptz not null default now();

create or replace function private.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger schedule_events_set_updated_at
  before update on public.schedule_events
  for each row execute function private.set_updated_at();
