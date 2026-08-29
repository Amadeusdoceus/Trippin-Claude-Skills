-- TEMPORÁRIO — diagnóstico de uma falha de RLS em trips_insert_own; removido
-- por uma migration de limpeza assim que a causa for confirmada.
create or replace function public.debug_whoami()
returns jsonb
language sql
security invoker
stable
as $$
  select jsonb_build_object(
    'auth_uid', auth.uid(),
    'jwt_claims', auth.jwt()
  );
$$;

grant execute on function public.debug_whoami() to authenticated;
