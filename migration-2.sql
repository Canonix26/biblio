-- Canonix, mise à jour 2 : catégories gérables + badge « Auteur » sur les commentaires.
-- À exécuter UNE FOIS dans Supabase > SQL Editor, AVANT de publier le nouveau app.js.
create table categories(id uuid primary key default gen_random_uuid(), name text unique not null, color text default '#4a4a4a', created_at timestamptz default now());
alter table categories enable row level security;
create policy "cat lisibles" on categories for select using (true);
create policy "cat admin" on categories for all using (is_admin()) with check (is_admin());
insert into categories(name,color) values ('Droit canonique','#c2490d'),('Philosophie','#2c2c2c'),('Littérature','#7a2a1a'),('Sciences','#2f3f52'),('Histoire','#8a6420'),('Droit','#4a4a4a'),('Arts','#6b4f3a');
alter table comments add column by_author boolean not null default false;
drop policy "comm ajout" on comments;
create policy "comm ajout" on comments for insert with check (user_id=auth.uid() and (by_author=false or is_admin()));
