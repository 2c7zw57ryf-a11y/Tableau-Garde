-- Tableau de garde — Anesthésiologie — schéma Supabase (v1, 2026-10-07)
-- À coller tel quel dans SQL Editor > New query > Run.

create extension if not exists pgcrypto;

create table if not exists public.membres (
  id text primary key, nom text not null, ini text not null unique, courriel text unique,
  mode text not null default '24h' check (mode in ('24h','12h')),
  mode_fds text not null default '24h' check (mode_fds in ('24h','12h')),
  ven_sep boolean not null default false, actif boolean not null default true,
  responsable boolean not null default false, ordre int not null default 99,
  maj timestamptz not null default now());

create table if not exists public.gardes (
  jour date primary key,
  g1 text references public.membres(id), g1j text references public.membres(id),
  g1n text references public.membres(id), g2 text references public.membres(id),
  prov jsonb, maj timestamptz not null default now(), maj_par text);

create table if not exists public.choix (
  jour date primary key, ordre text[] not null, nuit text,
  post_garde text[] not null default '{}', absents text[] not null default '{}',
  hb int, maj timestamptz not null default now());

create table if not exists public.absences (
  id uuid primary key default gen_random_uuid(),
  membre text not null references public.membres(id),
  debut date not null, fin date not null, motif text, echange text,
  maj timestamptz not null default now());
create index if not exists absences_membre_idx on public.absences(membre, debut, fin);

create table if not exists public.feries (jour date primary key);
create table if not exists public.verrous (jour date primary key, par text, t timestamptz not null default now());

create table if not exists public.echanges (
  id text primary key, type text not null, statut text not null,
  par text not null references public.membres(id), cible text references public.membres(id),
  preneur text references public.membres(id), data jsonb not null,
  cree_a timestamptz not null default now(), maj timestamptz not null default now());

create table if not exists public.journal (id bigserial primary key, t timestamptz not null default now(), par text, txt text not null);
create table if not exists public.reglages (cle text primary key, valeur jsonb not null, maj timestamptz not null default now());

-- autorisation
create or replace function public.mon_membre() returns text
language sql stable security definer set search_path = public as $$
  select id from public.membres where actif and courriel is not null and lower(courriel) = lower(coalesce(auth.jwt()->>'email','')) limit 1
$$;
create or replace function public.est_membre() returns boolean
language sql stable security definer set search_path = public as $$ select public.mon_membre() is not null $$;
create or replace function public.est_responsable() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select responsable from public.membres where id = public.mon_membre()), false)
$$;

alter table public.membres enable row level security;
alter table public.gardes enable row level security;
alter table public.choix enable row level security;
alter table public.absences enable row level security;
alter table public.feries enable row level security;
alter table public.verrous enable row level security;
alter table public.echanges enable row level security;
alter table public.journal enable row level security;
alter table public.reglages enable row level security;

do $$ declare t text; begin
  foreach t in array array['membres','gardes','choix','absences','feries','verrous','echanges','journal','reglages'] loop
    execute format('drop policy if exists lecture_membres on public.%I', t);
    execute format('create policy lecture_membres on public.%I for select to authenticated using (public.est_membre())', t);
    execute format('drop policy if exists ecriture_responsables on public.%I', t);
    execute format('create policy ecriture_responsables on public.%I for all to authenticated using (public.est_responsable()) with check (public.est_responsable())', t);
  end loop; end $$;

-- échanges : chaque membre crée ses demandes et peut agir sur celles qui le concernent
drop policy if exists echanges_creer on public.echanges;
create policy echanges_creer on public.echanges for insert to authenticated with check (public.est_membre() and par = public.mon_membre());
drop policy if exists echanges_modifier on public.echanges;
create policy echanges_modifier on public.echanges for update to authenticated
  using (public.est_membre() and (par = public.mon_membre() or cible = public.mon_membre() or type = 'encan'))
  with check (public.est_membre());
-- conclure un échange écrit dans gardes / choix / absences / journal
drop policy if exists gardes_echange on public.gardes;
create policy gardes_echange on public.gardes for all to authenticated using (public.est_membre()) with check (public.est_membre());
drop policy if exists choix_echange on public.choix;
create policy choix_echange on public.choix for all to authenticated using (public.est_membre()) with check (public.est_membre());
drop policy if exists absences_echange on public.absences;
create policy absences_echange on public.absences for all to authenticated using (public.est_membre()) with check (public.est_membre());
drop policy if exists journal_ecrire on public.journal;
create policy journal_ecrire on public.journal for insert to authenticated with check (public.est_membre());

-- données de départ (fériés et réglages seulement)
-- Les membres et les absences sont des données personnelles : à saisir dans l'application
-- (Gestion > Membres, Gestion > Vacances) ou dans Supabase, jamais dans le dépôt public.
insert into public.feries (jour) values ('2026-01-01'),('2026-04-03'),('2026-05-18'),('2026-06-24'),('2026-07-01'),('2026-09-07'),('2026-10-12'),('2026-11-09'),('2026-12-25'),('2027-01-01'),('2027-03-26'),('2027-05-24'),('2027-06-24'),('2027-07-01'),('2027-09-06'),('2027-10-11'),('2027-12-25') on conflict do nothing;

insert into public.reglages (cle,valeur) values
  ('blocs', '[7, 12]'::jsonb), ('hbDefaut', '1'::jsonb), ('delaiEncan', '24'::jsonb), ('capacites', '{"2026-08-31": 5, "2026-09-07": 4, "2026-09-14": 4, "2026-09-21": 2, "2026-09-28": 3, "2026-10-05": 2, "2026-10-12": 4, "2026-10-19": 2, "2026-10-26": 2, "2026-11-02": 6, "2026-11-09": 2, "2026-11-16": 2, "2026-11-23": 2, "2026-11-30": 1, "2026-12-07": 2, "2026-12-14": 1}'::jsonb)
on conflict (cle) do nothing;

-- temps réel
do $$ begin
  begin alter publication supabase_realtime add table public.gardes, public.choix, public.absences, public.echanges, public.membres, public.verrous, public.feries, public.reglages, public.journal;
  exception when others then null; end;
end $$;

select count(*) as membres from public.membres;
