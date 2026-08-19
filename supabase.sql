create extension if not exists pgcrypto;

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  description text default '',
  price numeric(12,2) not null default 0,
  features jsonb not null default '[]'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  order_number text unique not null,
  customer_name text not null,
  customer_email text,
  customer_phone text not null,
  product_id uuid references products(id) on delete set null,
  quantity integer not null default 1 check (quantity > 0),
  payment_method text not null,
  transaction_id text not null,
  note text,
  status text not null default 'Pending' check (status in ('Pending','Confirmed','Completed','Cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists admin_users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  created_at timestamptz not null default now()
);

alter table products enable row level security;
alter table orders enable row level security;
alter table admin_users enable row level security;

drop policy if exists "public read active products" on products;
create policy "public read active products" on products
for select using (is_active = true);

drop policy if exists "admins manage products" on products;
create policy "admins manage products" on products
for all to authenticated
using (exists (select 1 from admin_users a where a.id = auth.uid()))
with check (exists (select 1 from admin_users a where a.id = auth.uid()));

drop policy if exists "public create orders" on orders;
create policy "public create orders" on orders
for insert to anon, authenticated
with check (true);

drop policy if exists "admins read orders" on orders;
create policy "admins read orders" on orders
for select to authenticated
using (exists (select 1 from admin_users a where a.id = auth.uid()));

drop policy if exists "admins update orders" on orders;
create policy "admins update orders" on orders
for update to authenticated
using (exists (select 1 from admin_users a where a.id = auth.uid()))
with check (exists (select 1 from admin_users a where a.id = auth.uid()));

drop policy if exists "admins delete orders" on orders;
create policy "admins delete orders" on orders
for delete to authenticated
using (exists (select 1 from admin_users a where a.id = auth.uid()));

drop policy if exists "admins read admin users" on admin_users;
create policy "admins read admin users" on admin_users
for select to authenticated
using (id = auth.uid());

insert into products (name, slug, description, price, features)
values
('Canva Pro Account','canva-pro','Premium Canva account.',500,'["Premium features","Easy ordering","Fast delivery"]'::jsonb),
('Canva Owner Account','canva-owner','Canva owner account.',1500,'["Owner access","Easy ordering","Fast delivery"]'::jsonb)
on conflict (slug) do nothing;


-- Secure customer order-status lookup without exposing the orders table.
create or replace function public.get_order_status(p_order_number text, p_phone text)
returns table (
  order_number text,
  customer_name text,
  customer_phone text,
  status text,
  created_at timestamptz,
  product_name text
)
language sql
security definer
set search_path = public
as $$
  select o.order_number, o.customer_name, o.customer_phone, o.status, o.created_at, p.name
  from orders o
  left join products p on p.id = o.product_id
  where o.order_number = p_order_number
    and o.customer_phone = p_phone
  limit 1;
$$;

revoke all on function public.get_order_status(text,text) from public;
grant execute on function public.get_order_status(text,text) to anon, authenticated;
