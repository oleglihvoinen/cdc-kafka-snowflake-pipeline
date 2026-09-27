create table customers (
  customer_id bigserial primary key,
  customer_name text not null,
  email text,
  updated_at timestamptz default now()
);
create table orders (
  order_id bigserial primary key,
  customer_id bigint references customers(customer_id),
  status text not null,
  net_revenue numeric(12,2) not null,
  updated_at timestamptz default now()
);
insert into customers(customer_name,email) values
  ('Acme Oy','info@acme.fi'),('Nordic Parts','nina@nordicparts.fi');
insert into orders(customer_id,status,net_revenue) values
  (1,'COMPLETED',149.90),(2,'OPEN',89.00);
