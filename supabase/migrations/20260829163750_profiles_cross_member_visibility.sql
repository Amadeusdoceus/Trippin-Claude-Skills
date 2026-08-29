-- A policy original (profiles_select_own) só deixa um usuário ler o próprio
-- perfil, o que impede a tela de Integrantes de mostrar o nome de quem mais
-- está na viagem. Adiciona visibilidade entre integrantes da mesma viagem,
-- sem abrir leitura geral de perfis (continua restrito a quem compartilha
-- pelo menos uma viagem).

create policy profiles_select_trip_co_member on public.profiles
  for select to authenticated
  using (
    exists (
      select 1
      from public.trip_members tm1
      join public.trip_members tm2 on tm1.trip_id = tm2.trip_id
      where tm1.user_id = (select auth.uid())
        and tm2.user_id = profiles.id
    )
  );
