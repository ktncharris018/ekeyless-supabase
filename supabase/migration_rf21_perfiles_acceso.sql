-- Migración incremental para proyectos eKeyLess que ya ejecutaron schema.sql.
-- Ejecutar una sola vez en Supabase SQL Editor.

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
for select to authenticated using (propietario_id = auth.uid());

drop policy if exists perfiles_acceso_insert_owner on public.perfiles_acceso;
create policy perfiles_acceso_insert_owner on public.perfiles_acceso
for insert to authenticated with check (propietario_id = auth.uid());

drop policy if exists perfiles_acceso_update_owner on public.perfiles_acceso;
create policy perfiles_acceso_update_owner on public.perfiles_acceso
for update to authenticated
using (propietario_id = auth.uid())
with check (propietario_id = auth.uid());

drop policy if exists perfiles_acceso_delete_owner on public.perfiles_acceso;
create policy perfiles_acceso_delete_owner on public.perfiles_acceso
for delete to authenticated using (propietario_id = auth.uid());

drop policy if exists perfiles_historial_select_owner on public.perfiles_acceso_historial;
create policy perfiles_historial_select_owner on public.perfiles_acceso_historial
for select to authenticated using (propietario_id = auth.uid());

drop policy if exists perfiles_historial_insert_owner on public.perfiles_acceso_historial;
create policy perfiles_historial_insert_owner on public.perfiles_acceso_historial
for insert to authenticated with check (propietario_id = auth.uid());

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
      and (item->>'fechaFin' is null or (item->>'fechaFin')::timestamptz >= now())
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
      and (now() + make_interval(
        mins => coalesce((item->>'zonaHorariaOffsetMinutos')::integer, 0)
      ))::time >= (item->>'horaInicio')::time
      and (now() + make_interval(
        mins => coalesce((item->>'zonaHorariaOffsetMinutos')::integer, 0)
      ))::time <= (item->>'horaFin')::time
  )
);
