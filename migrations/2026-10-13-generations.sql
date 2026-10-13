-- Tableau de garde — migration 2026-10-13 : horaires générés conservés (brouillons et publiés)
-- À coller tel quel dans Supabase > SQL Editor > New query > Run.

create table if not exists public.generations (
  id uuid primary key default gen_random_uuid(),
  trimestre text not null,
  cree_a timestamptz not null default now(),
  par text,
  statut text not null default 'brouillon' check (statut in ('brouillon','publiee','annulee')),
  publiee_a timestamptz, publiee_par text,
  note text,
  data jsonb not null,
  maj timestamptz not null default now());
create index if not exists generations_cree_idx on public.generations(cree_a desc);

alter table public.generations enable row level security;
-- lecture et écriture réservées aux responsables : un brouillon n'est jamais visible des membres
drop policy if exists lecture_responsables on public.generations;
create policy lecture_responsables on public.generations for select to authenticated using (public.est_responsable());
drop policy if exists ecriture_responsables on public.generations;
create policy ecriture_responsables on public.generations for all to authenticated using (public.est_responsable()) with check (public.est_responsable());

do $$ begin
  begin alter publication supabase_realtime add table public.generations;
  exception when others then null; end;
end $$;

select count(*) as generations from public.generations;
