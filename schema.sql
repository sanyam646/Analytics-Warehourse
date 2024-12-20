-- schema.sql : Minimal star-ish schema for analytics
-- Compatible with SQLite and Postgres (avoid serials, use INTEGER PK)

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id   INTEGER PRIMARY KEY,
  created_at    TEXT NOT NULL
);

CREATE TABLE sellers (
  seller_id     INTEGER PRIMARY KEY,
  created_at    TEXT NOT NULL
);

CREATE TABLE orders (
  order_id      INTEGER PRIMARY KEY,
  customer_id   INTEGER NOT NULL REFERENCES customers(customer_id),
  order_date    TEXT NOT NULL,
  status        TEXT NOT NULL, -- created, paid, cancelled, refunded
  total_amount  NUMERIC NOT NULL,
  channel       TEXT NOT NULL  -- web, app, store
);

CREATE TABLE order_items (
  order_item_id INTEGER PRIMARY KEY,
  order_id      INTEGER NOT NULL REFERENCES orders(order_id),
  seller_id     INTEGER NOT NULL REFERENCES sellers(seller_id),
  qty           INTEGER NOT NULL,
  price         NUMERIC NOT NULL,
  discount      NUMERIC NOT NULL DEFAULT 0,
  category      TEXT
);

CREATE TABLE deliveries (
  delivery_id    INTEGER PRIMARY KEY,
  order_id       INTEGER NOT NULL REFERENCES orders(order_id),
  shipped_at     TEXT,
  delivered_at   TEXT,
  city           TEXT,
  logistics_cost NUMERIC DEFAULT 0
);

-- Indexes for typical analytics patterns
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);
CREATE INDEX idx_items_order ON order_items (order_id);
CREATE INDEX idx_items_seller ON order_items (seller_id);
CREATE INDEX idx_deliveries_order ON deliveries (order_id);
