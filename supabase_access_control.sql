-- IPHW Rate Calculator: per-user access control
-- Run this once in Supabase Dashboard -> SQL Editor.
-- Admin status continues to come from public.profiles.is_admin.

create table if not exists public.user_access (
  user_id uuid primary key references auth.users(id) on delete cascade,
  normal_rate boolean not null default false,
  rate_a boolean not null default false,
  rate_b boolean not null default false,
  rate_chart boolean not null default false,
  zone boolean not null default false,
  oda boolean not null default false,
  calculation_logs boolean not null default false,
  updated_at timestamptz not null default now()
);

create or replace function public.touch_user_access_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_user_access_updated_at on public.user_access;
create trigger trg_user_access_updated_at
before update on public.user_access
for each row execute function public.touch_user_access_updated_at();

-- Creates an empty permission row for each newly registered account.
create or replace function public.create_default_user_access()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_access(user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_create_default_user_access on auth.users;
create trigger trg_create_default_user_access
after insert on auth.users
for each row execute function public.create_default_user_access();

-- Helper used by RLS. It reads the existing profiles.is_admin flag.
create or replace function public.ip_hw_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.is_admin from public.profiles p where p.id = auth.uid()),
    false
  );
$$;

alter table public.user_access enable row level security;

drop policy if exists "user_access_select_own_or_admin" on public.user_access;
create policy "user_access_select_own_or_admin"
on public.user_access for select
to authenticated
using (user_id = auth.uid() or public.ip_hw_is_admin());

drop policy if exists "user_access_insert_admin" on public.user_access;
create policy "user_access_insert_admin"
on public.user_access for insert
to authenticated
with check (public.ip_hw_is_admin());

drop policy if exists "user_access_update_admin" on public.user_access;
create policy "user_access_update_admin"
on public.user_access for update
to authenticated
using (public.ip_hw_is_admin())
with check (public.ip_hw_is_admin());

drop policy if exists "user_access_delete_admin" on public.user_access;
create policy "user_access_delete_admin"
on public.user_access for delete
to authenticated
using (public.ip_hw_is_admin());

-- The Admin User Access panel needs to read all profiles.
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select
to authenticated
using (id = auth.uid());

drop policy if exists "profiles_select_admin" on public.profiles;
create policy "profiles_select_admin"
on public.profiles for select
to authenticated
using (public.ip_hw_is_admin());

grant select on public.user_access to authenticated;
grant insert, update, delete on public.user_access to authenticated;
grant select on public.profiles to authenticated;

-- IMPORTANT:
-- 1) Make your own account Admin by setting public.profiles.is_admin = true.
-- 2) Then login and open Sidebar -> Users.
-- 3) Assign Normal Rate / Rate A / Rate B / Rate Chart / Zone / ODA / Calculation Logs.
-- Example:
-- update public.profiles set is_admin = true where email = 'YOUR-ADMIN-EMAIL';
