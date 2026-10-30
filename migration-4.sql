-- Canonix, mise à jour 4 : alertes e-mail par triggers SQL (remplace les « Database Webhooks » du tableau de bord).
-- 1) Remplacez REMPLACEZ_PAR_VOTRE_WEBHOOK_SECRET par la valeur du secret WEBHOOK_SECRET de la fonction notify.
-- 2) Exécutez le tout dans Supabase > SQL Editor.
create extension if not exists pg_net with schema extensions;

create or replace function public.notify_canonix() returns trigger
language plpgsql security definer set search_path = public, extensions as $$
begin
  begin
    perform net.http_post(
      url := 'https://pcqvtyxhhnmziwlvvkxe.supabase.co/functions/v1/notify',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBjcXZ0eXhoaG5teml3bHZ2a3hlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMyNjk4NDYsImV4cCI6MjEwODg0NTg0Nn0.06hOg8xRN2xddWAQJFC28KUggRhm2KU5AqSlIddzoOk',
        'x-webhook-secret', 'REMPLACEZ_PAR_VOTRE_WEBHOOK_SECRET'),
      body := jsonb_build_object('type', 'INSERT', 'table', TG_TABLE_NAME, 'record', to_jsonb(NEW))
    );
  exception when others then null; -- un échec d'e-mail ne doit jamais bloquer un commentaire ou un message
  end;
  return NEW;
end $$;

drop trigger if exists comments_notify on public.comments;
create trigger comments_notify after insert on public.comments for each row execute function public.notify_canonix();
drop trigger if exists messages_notify on public.messages;
create trigger messages_notify after insert on public.messages for each row execute function public.notify_canonix();

-- Pour vérifier les envois : select id, status_code, content, created from net._http_response order by created desc limit 5;
