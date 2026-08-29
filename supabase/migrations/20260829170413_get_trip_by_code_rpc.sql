-- Bug real encontrado via smoke test: quem ainda não é integrante de uma
-- viagem não consegue fazer SELECT em `trips` (correto — a policy protege
-- dados de viagens de terceiros) mas isso também bloqueia a própria busca da
-- viagem pelo código antes de entrar nela (H4.2), tornando "Participar de
-- viagem" impossível para um convidado de verdade.
--
-- O código de 12 dígitos já funciona como um token de convite (só quem o
-- recebeu consegue usá-lo) — por isso uma função security definer que só
-- retorna a viagem em caso de match exato de código é uma exceção segura,
-- sem abrir SELECT geral na tabela.
create or replace function public.get_trip_by_code(p_code text)
returns setof public.trips
language sql
security definer
set search_path = ''
stable
as $$
  select * from public.trips where code = p_code;
$$;

grant execute on function public.get_trip_by_code(text) to authenticated;
