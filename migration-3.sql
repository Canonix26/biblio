-- Canonix, mise à jour 3 : messages du formulaire Contact (stockés + alerte e-mail via Resend).
-- À exécuter UNE FOIS dans Supabase > SQL Editor, AVANT de publier le nouveau app.js.
create table messages(id uuid primary key default gen_random_uuid(), name text not null check (char_length(name) between 1 and 100), email text check (email is null or char_length(email)<=200), body text not null check (char_length(body) between 1 and 3000), created_at timestamptz default now());
alter table messages enable row level security;
create policy "msg envoi" on messages for insert with check (true);
create policy "msg admin lecture" on messages for select using (is_admin());
create policy "msg admin suppression" on messages for delete using (is_admin());
