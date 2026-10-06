-- eKeyLess - Supabase/PostgreSQL schema
-- This schema intentionally preserves the data shape used by the original
-- Firebase app so UI and candado workflows remain unchanged during migration.

create extension if not exists pgcrypto;

create table if not exists public.usuarios (
  id uuid primary key references auth.users(id) on delete cascade,
  "imagenPerfil" text not null default '',
  "nombreUsuario" text not null unique,
  email text not null unique,
  "authGoogle" boolean not null default false,
  amigos jsonb not null default '[]'::jsonb,
  "solicitudesRecibidas" jsonb not null default '[]'::jsonb,
  "solicitudesEnviadas" jsonb not null default '[]'::jsonb,
  "fechaCreacion" timestamptz not null default now()
);

create table if not exists public.candados (
  key text primary key,
  nombre text not null,
  dueno uuid not null references public.usuarios(id) on delete cascade,
  "invitadosPermanentes" jsonb not null default '[]'::jsonb,
  "invitadosTemporales" jsonb not null default '[]'::jsonb,
  "fechaCreacion" timestamptz not null default now()
);

create table if not exists public.notificaciones (
  id uuid primary key default gen_random_uuid(),
  "emisorId" uuid references public.usuarios(id) on delete set null,
  "receptorId" uuid not null references public.usuarios(id) on delete cascade,
  titulo text not null,
  cuerpo text not null,
  leido boolean not null default false,
  tipo text not null default 'sistema',
  "fechaCreacion" timestamptz not null default now()
);

create index if not exists idx_notificaciones_receptor_fecha
  on public.notificaciones("receptorId", "fechaCreacion" desc);
create index if not exists idx_candados_dueno on public.candados(dueno);
create index if not exists idx_usuarios_nombre on public.usuarios("nombreUsuario");

-- Keep profile row in sync for users created through auth providers.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.usuarios (
    id, "imagenPerfil", "nombreUsuario", email, "authGoogle"
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture', ''),
    coalesce(new.raw_user_meta_data->>'nombreUsuario', new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    coalesce(new.email, ''),
    coalesce(new.raw_app_meta_data->>'provider', '') = 'google'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_auth_user();

-- Supabase Storage for profile images.
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

drop policy if exists avatars_insert_authenticated on storage.objects;

create policy avatars_insert_authenticated
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and owner_id = (select auth.uid()::text)
);

-- RLS
alter table public.usuarios enable row level security;
alter table public.candados enable row level security;
alter table public.notificaciones enable row level security;

drop policy if exists usuarios_select_authenticated on public.usuarios;
create policy usuarios_select_authenticated on public.usuarios
for select to authenticated using (true);

drop policy if exists usuarios_insert_own on public.usuarios;
create policy usuarios_insert_own on public.usuarios
for insert to authenticated with check (id = auth.uid());

drop policy if exists usuarios_update_own on public.usuarios;
create policy usuarios_update_own on public.usuarios
for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists candados_select_access on public.candados;
create policy candados_select_access on public.candados
for select to authenticated using (
  dueno = auth.uid()
  or "invitadosPermanentes" ? auth.uid()::text
  or exists (
    select 1
    from jsonb_array_elements(coalesce("invitadosTemporales", '[]'::jsonb)) as item
    where item->>'usuarioId' = auth.uid()::text
      and (item->>'fechaExpiracion')::timestamptz > now()
      and (
        item->>'fechaInicio' is null
        or (item->>'fechaInicio')::timestamptz <= now()
      )
  )
);

drop policy if exists candados_insert_own on public.candados;
create policy candados_insert_own on public.candados
for insert to authenticated with check (dueno = auth.uid());

drop policy if exists candados_update_owner on public.candados;
create policy candados_update_owner on public.candados
for update to authenticated using (dueno = auth.uid()) with check (dueno = auth.uid());

drop policy if exists notificaciones_select_own on public.notificaciones;
create policy notificaciones_select_own on public.notificaciones
for select to authenticated using ("receptorId" = auth.uid());

drop policy if exists notificaciones_insert_authenticated on public.notificaciones;
create policy notificaciones_insert_authenticated on public.notificaciones
for insert to authenticated with check ("emisorId" = auth.uid() or "emisorId" is null);

drop policy if exists notificaciones_update_own on public.notificaciones;
create policy notificaciones_update_own on public.notificaciones
for update to authenticated using ("receptorId" = auth.uid()) with check ("receptorId" = auth.uid());

drop policy if exists notificaciones_delete_own on public.notificaciones;
create policy notificaciones_delete_own on public.notificaciones
for delete to authenticated using ("receptorId" = auth.uid());

-- Atomic friendship operations. The client only calls these RPCs.
create or replace function public.enviar_solicitud_amistad(p_receptor_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  sender_id uuid := auth.uid();
  sender_name text;
  already_sent boolean;
  already_received boolean;
begin
  if sender_id is null then raise exception 'Usuario no autenticado'; end if;
  if sender_id = p_receptor_id then raise exception 'No puedes enviarte una solicitud a ti mismo'; end if;
  if not exists (select 1 from usuarios where id = p_receptor_id) then raise exception 'Uno de los usuarios no existe'; end if;

  select "nombreUsuario" into sender_name from usuarios where id = sender_id;
  select ("solicitudesEnviadas" ? p_receptor_id::text), ("solicitudesRecibidas" ? sender_id::text)
    into already_sent, already_received
    from usuarios where id = sender_id;

  if coalesce(already_sent, false) or exists (
    select 1 from usuarios where id = p_receptor_id and "solicitudesRecibidas" ? sender_id::text
  ) then raise exception 'Solicitud ya enviada'; end if;

  update usuarios
    set "solicitudesEnviadas" = "solicitudesEnviadas" || to_jsonb(array[p_receptor_id::text])
    where id = sender_id;

  update usuarios
    set "solicitudesRecibidas" = "solicitudesRecibidas" || to_jsonb(array[sender_id::text])
    where id = p_receptor_id;

  insert into notificaciones("emisorId", "receptorId", titulo, cuerpo, leido, tipo)
  values (
    sender_id,
    p_receptor_id,
    'Nueva solicitud de amistad',
    coalesce(sender_name, 'Un usuario') || ' te ha enviado una solicitud de amistad. ¡Revisa tu lista de solicitudes pendientes!',
    false,
    'amigo'
  );
end;
$$;

grant execute on function public.enviar_solicitud_amistad(uuid) to authenticated;

create or replace function public.aceptar_solicitud_amistad(p_emisor_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  receptor_id uuid := auth.uid();
begin
  if receptor_id is null then raise exception 'Usuario no autenticado'; end if;

  update usuarios
    set "solicitudesRecibidas" = (
      select coalesce(jsonb_agg(value), '[]'::jsonb)
      from jsonb_array_elements(coalesce("solicitudesRecibidas", '[]'::jsonb)) x(value)
      where value #>> '{}' <> p_emisor_id::text
    ),
    amigos = case when amigos ? p_emisor_id::text then amigos else amigos || to_jsonb(array[p_emisor_id::text]) end
  where id = receptor_id;

  update usuarios
    set "solicitudesEnviadas" = (
      select coalesce(jsonb_agg(value), '[]'::jsonb)
      from jsonb_array_elements(coalesce("solicitudesEnviadas", '[]'::jsonb)) x(value)
      where value #>> '{}' <> receptor_id::text
    ),
    amigos = case when amigos ? receptor_id::text then amigos else amigos || to_jsonb(array[receptor_id::text]) end
  where id = p_emisor_id;
end;
$$;

grant execute on function public.aceptar_solicitud_amistad(uuid) to authenticated;

create or replace function public.cancelar_solicitud_amistad(p_receptor_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  sender_id uuid := auth.uid();
begin
  if sender_id is null then raise exception 'Usuario no autenticado'; end if;

  update usuarios
    set "solicitudesEnviadas" = (
      select coalesce(jsonb_agg(value), '[]'::jsonb)
      from jsonb_array_elements(coalesce("solicitudesEnviadas", '[]'::jsonb)) x(value)
      where value #>> '{}' <> p_receptor_id::text
    )
  where id = sender_id;

  update usuarios
    set "solicitudesRecibidas" = (
      select coalesce(jsonb_agg(value), '[]'::jsonb)
      from jsonb_array_elements(coalesce("solicitudesRecibidas", '[]'::jsonb)) x(value)
      where value #>> '{}' <> sender_id::text
    )
  where id = p_receptor_id;
end;
$$;

grant execute on function public.cancelar_solicitud_amistad(uuid) to authenticated;

-- Enable realtime for notifications while preserving the original live UX.
do $$
begin
  alter publication supabase_realtime add table public.notificaciones;
exception when duplicate_object then
  null;
end $$;

-- ==========================================================
-- RF-21: Perfiles de acceso reutilizables y trazabilidad
-- ==========================================================

alter table public.candados
  add column if not exists "invitadosRecurrentes" jsonb not null default '[]'::jsonb;

create table if not exists public.perfiles_acceso (
  id uuid primary key default gen_random_uuid(),
  propietario_id uuid not null references public.usuarios(id) on delete cascade,
  nombre text not null,
  candado_key text not null references public.candados(key) on delete cascade,
  usuario_id uuid not null references public.usuarios(id) on delete cascade,
  dispositivo_id text,
  tipo_acceso text not null check (tipo_acceso in ('permanente', 'recurrente', 'temporal')),
  fecha_inicio timestamptz not null,
  fecha_fin timestamptz,
  dias_permitidos integer[] not null default '{}',
  hora_inicio time,
  hora_fin time,
  canal_comunicacion text not null default 'bluetooth'
    check (canal_comunicacion in ('bluetooth', 'nfc')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_perfiles_acceso_candado
  on public.perfiles_acceso(candado_key, nombre);
create index if not exists idx_perfiles_acceso_propietario
  on public.perfiles_acceso(propietario_id);

create table if not exists public.perfiles_acceso_historial (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid references public.perfiles_acceso(id) on delete set null,
  propietario_id uuid not null references public.usuarios(id) on delete cascade,
  operacion text not null,
  detalles jsonb not null default '{}'::jsonb,
  fecha_creacion timestamptz not null default now()
);

create index if not exists idx_perfiles_historial_perfil_fecha
  on public.perfiles_acceso_historial(perfil_id, fecha_creacion desc);

alter table public.perfiles_acceso enable row level security;
alter table public.perfiles_acceso_historial enable row level security;

drop policy if exists perfiles_acceso_select_owner on public.perfiles_acceso;
create policy perfiles_acceso_select_owner on public.perfiles_acceso
for select to authenticated
using (propietario_id = auth.uid());

drop policy if exists perfiles_acceso_insert_owner on public.perfiles_acceso;
create policy perfiles_acceso_insert_owner on public.perfiles_acceso
for insert to authenticated
with check (propietario_id = auth.uid());

drop policy if exists perfiles_acceso_update_owner on public.perfiles_acceso;
create policy perfiles_acceso_update_owner on public.perfiles_acceso
for update to authenticated
using (propietario_id = auth.uid())
with check (propietario_id = auth.uid());

drop policy if exists perfiles_acceso_delete_owner on public.perfiles_acceso;
create policy perfiles_acceso_delete_owner on public.perfiles_acceso
for delete to authenticated
using (propietario_id = auth.uid());

drop policy if exists perfiles_historial_select_owner on public.perfiles_acceso_historial;
create policy perfiles_historial_select_owner on public.perfiles_acceso_historial
for select to authenticated
using (propietario_id = auth.uid());

drop policy if exists perfiles_historial_insert_owner on public.perfiles_acceso_historial;
create policy perfiles_historial_insert_owner on public.perfiles_acceso_historial
for insert to authenticated
with check (propietario_id = auth.uid());

-- Actualizar la política de lectura de candados para reconocer acceso recurrente.
drop policy if exists candados_select_access on public.candados;
create policy candados_select_access on public.candados
for select to authenticated using (
  dueno = auth.uid()
  or "invitadosPermanentes" ? auth.uid()::text
  or exists (
    select 1
    from jsonb_array_elements(coalesce("invitadosTemporales", '[]'::jsonb)) as item
    where item->>'usuarioId' = auth.uid()::text
      and (item->>'fechaExpiracion')::timestamptz > now()
      and (
        item->>'fechaInicio' is null
        or (item->>'fechaInicio')::timestamptz <= now()
      )
  )
  or exists (
    select 1
    from jsonb_array_elements(coalesce("invitadosRecurrentes", '[]'::jsonb)) as item
    where item->>'usuarioId' = auth.uid()::text
      and (item->>'fechaInicio')::timestamptz <= now()
      and (
        item->>'fechaFin' is null
        or (item->>'fechaFin')::timestamptz >= now()
      )
      and exists (
        select 1
        from jsonb_array_elements_text(coalesce(item->'diasPermitidos', '[]'::jsonb)) as day(value)
        where day.value = extract(
          isodow from (
            now() + make_interval(
              mins => coalesce((item->>'zonaHorariaOffsetMinutos')::integer, 0)
            )
          )
        )::integer::text
      )
      and (
        (now() + make_interval(
          mins => coalesce((item->>'zonaHorariaOffsetMinutos')::integer, 0)
        ))::time >= (item->>'horaInicio')::time
      )
      and (
        (now() + make_interval(
          mins => coalesce((item->>'zonaHorariaOffsetMinutos')::integer, 0)
        ))::time <= (item->>'horaFin')::time
      )
  )
);
