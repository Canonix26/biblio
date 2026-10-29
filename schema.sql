-- Canonix : à exécuter dans Supabase > SQL Editor
create table profiles(id uuid primary key references auth.users on delete cascade, name text, role text default 'reader');
create table documents(id uuid primary key default gen_random_uuid(), title text not null, author text, category text, year int, description text, file_url text, created_at timestamptz default now());
create table posts(id uuid primary key default gen_random_uuid(), title text not null, body text, author_name text, created_at timestamptz default now());
create table comments(id uuid primary key default gen_random_uuid(), post_id uuid references posts on delete cascade, user_id uuid, author_name text, body text, created_at timestamptz default now());
create table history(id uuid primary key default gen_random_uuid(), user_id uuid not null, doc_id uuid references documents on delete cascade, kind text, q text, created_at timestamptz default now());
create function is_admin() returns boolean language sql security definer as $$ select exists(select 1 from profiles where id=auth.uid() and role='admin') $$;
create function new_user() returns trigger language plpgsql security definer as $$ begin insert into public.profiles(id,name) values(new.id,new.raw_user_meta_data->>'name'); return new; end $$;
create trigger on_signup after insert on auth.users for each row execute function new_user();
alter table profiles enable row level security; alter table documents enable row level security; alter table posts enable row level security; alter table comments enable row level security; alter table history enable row level security;
create policy "profil lisible" on profiles for select using (id=auth.uid());
create policy "docs lisibles" on documents for select using (true);
create policy "docs admin" on documents for all using (is_admin()) with check (is_admin());
create policy "posts lisibles" on posts for select using (true);
create policy "posts admin" on posts for all using (is_admin()) with check (is_admin());
create policy "comm lisibles" on comments for select using (true);
create policy "comm ajout" on comments for insert with check (user_id=auth.uid());
create policy "comm suppression" on comments for delete using (user_id=auth.uid() or is_admin());
create policy "histo perso" on history for all using (user_id=auth.uid()) with check (user_id=auth.uid());
-- Stockage des fichiers (bucket public en lecture)
insert into storage.buckets(id,name,public) values('documents','documents',true);
create policy "fichiers lisibles" on storage.objects for select using (bucket_id='documents');
create policy "fichiers admin" on storage.objects for insert with check (bucket_id='documents' and is_admin());
-- Pour nommer un administrateur : update profiles set role='admin' where id='<UUID de l’utilisateur>';
