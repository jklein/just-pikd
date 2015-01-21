--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: customer; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE customer IS 'Customer accounts, billing and shipping address book, saved shopping lists, purchase history, shopping carts. This must be completely decoupled from the product database, the only interaction is on add to cart where the application puts the necessary data into the order tables.';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: isn; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS isn WITH SCHEMA public;


--
-- Name: EXTENSION isn; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION isn IS 'data types for international product numbering standards';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: address_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE address_type AS ENUM (
    'Billing',
    'Shipping'
);


ALTER TYPE address_type OWNER TO postgres;

--
-- Name: order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE order_status AS ENUM (
    'Basket',
    'Shopping List',
    'Pending Pickup',
    'Complete',
    'Cancelled'
);


ALTER TYPE order_status OWNER TO postgres;

--
-- Name: TYPE order_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE order_status IS 'States that an order can be in from the customer perspective (not the WMS perspective)';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: address_books; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address_books (
    adr_id integer NOT NULL,
    adr_cu_id integer NOT NULL,
    adr_type address_type NOT NULL,
    adr_first_name character varying(255) NOT NULL,
    adr_middle_name character varying(255),
    adr_last_name character varying(255),
    adr_email character varying(255),
    adr_address1 character varying(255) NOT NULL,
    adr_address2 character varying(255),
    adr_city character varying(255) NOT NULL,
    adr_state character(2) NOT NULL,
    adr_zip_code character varying(12) NOT NULL,
    adr_phone character varying(30)
);


ALTER TABLE address_books OWNER TO postgres;

--
-- Name: TABLE address_books; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE address_books IS 'Saved billing or shipping addresses tied to a customer account';


--
-- Name: COLUMN address_books.adr_state; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN address_books.adr_state IS 'Two letter state code such as "MA"';


--
-- Name: address_books_adr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE address_books_adr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE address_books_adr_id_seq OWNER TO postgres;

--
-- Name: address_books_adr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE address_books_adr_id_seq OWNED BY address_books.adr_id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE customers (
    cu_id integer NOT NULL,
    cu_email character varying(255) NOT NULL,
    cu_password character varying(255),
    cu_last_login timestamp with time zone,
    cu_persist_code character varying(255) DEFAULT NULL::character varying,
    cu_reset_password_code character varying(255) DEFAULT NULL::character varying,
    cu_first_name character varying(255) DEFAULT NULL::character varying,
    cu_stripe_id character varying(255) DEFAULT NULL::character varying,
    cu_created_at timestamp with time zone DEFAULT now() NOT NULL,
    cu_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    cu_default_billing_address_id integer,
    cu_default_shipping_address_id integer
);


ALTER TABLE customers OWNER TO postgres;

--
-- Name: TABLE customers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE customers IS 'Basic login information for a customer account';


--
-- Name: COLUMN customers.cu_password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customers.cu_password IS 'Hashed password for this customer account';


--
-- Name: COLUMN customers.cu_persist_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customers.cu_persist_code IS 'Session identifier';


--
-- Name: COLUMN customers.cu_reset_password_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customers.cu_reset_password_code IS 'One time code to reset password, should be nulled out upon use';


--
-- Name: COLUMN customers.cu_stripe_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customers.cu_stripe_id IS 'Customer ID from Stripe API for credit card authentication';


--
-- Name: customers_cu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE customers_cu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE customers_cu_id_seq OWNER TO postgres;

--
-- Name: customers_cu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE customers_cu_id_seq OWNED BY customers.cu_id;


--
-- Name: order_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE order_products (
    op_id integer NOT NULL,
    op_or_id integer NOT NULL,
    op_pr_sku ean13 NOT NULL,
    op_qty integer NOT NULL,
    op_product_name character varying(255) NOT NULL,
    op_manufacturer_name character varying(255),
    op_list_cost integer,
    op_date_added timestamp with time zone DEFAULT now() NOT NULL,
    op_date_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE order_products OWNER TO postgres;

--
-- Name: TABLE order_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE order_products IS 'base_products in the order, including all point in time product data necessary to display it in cart and view it in order history without needing to query product tables again.';


--
-- Name: COLUMN order_products.op_or_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.op_or_id IS 'Foreign key to orders table, the order this item is part of';


--
-- Name: COLUMN order_products.op_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.op_pr_sku IS 'Foreign key to the products table';


--
-- Name: COLUMN order_products.op_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.op_qty IS 'The number of this sku being purchased';


--
-- Name: COLUMN order_products.op_product_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.op_product_name IS 'Display name at time of addition';


--
-- Name: COLUMN order_products.op_manufacturer_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.op_manufacturer_name IS 'Manufacturer display name at time of addition';


--
-- Name: COLUMN order_products.op_list_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.op_list_cost IS 'products list_cost in CENTS at time of addition to cart. For a shopping list, this should stay NULL until it becomes a cart';


--
-- Name: COLUMN order_products.op_date_added; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.op_date_added IS 'Date the item was added';


--
-- Name: COLUMN order_products.op_date_updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.op_date_updated IS 'Date the quantity or cost was last changed';


--
-- Name: order_products_op_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE order_products_op_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE order_products_op_id_seq OWNER TO postgres;

--
-- Name: order_products_op_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE order_products_op_id_seq OWNED BY order_products.op_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE orders (
    or_id integer NOT NULL,
    or_so_id integer NOT NULL,
    or_cu_id integer NOT NULL,
    or_status order_status NOT NULL,
    or_created_at timestamp with time zone DEFAULT now() NOT NULL,
    or_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    or_submitted_at timestamp with time zone,
    or_total_cost integer,
    or_first_name character varying(255),
    or_middle_name character varying(255),
    or_last_name character varying(255),
    or_email character varying(255),
    or_address1 character varying(255),
    or_address2 character varying(255),
    or_city character varying(255),
    or_state character(2),
    or_zip_code character varying(12),
    or_phone character varying(30)
);


ALTER TABLE orders OWNER TO postgres;

--
-- Name: TABLE orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE orders IS 'Order level information, including status and point in time billing address information';


--
-- Name: COLUMN orders.or_so_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.or_so_id IS 'The store that fulfills the order - fk to stores';


--
-- Name: COLUMN orders.or_cu_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.or_cu_id IS 'The customer that placed the order - fk to customers';


--
-- Name: COLUMN orders.or_created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.or_created_at IS 'The time when the basket is initially created';


--
-- Name: COLUMN orders.or_updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.or_updated_at IS 'The last time any data on the order was changed';


--
-- Name: COLUMN orders.or_submitted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.or_submitted_at IS 'The time when the customer submitted the order upon completion of checkout';


--
-- Name: COLUMN orders.or_total_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.or_total_cost IS 'The total price in CENTS paid by the customer for all base_products on the order';


--
-- Name: orders_or_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE orders_or_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE orders_or_id_seq OWNER TO postgres;

--
-- Name: orders_or_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE orders_or_id_seq OWNED BY orders.or_id;


--
-- Name: adr_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_books ALTER COLUMN adr_id SET DEFAULT nextval('address_books_adr_id_seq'::regclass);


--
-- Name: cu_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY customers ALTER COLUMN cu_id SET DEFAULT nextval('customers_cu_id_seq'::regclass);


--
-- Name: op_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY order_products ALTER COLUMN op_id SET DEFAULT nextval('order_products_op_id_seq'::regclass);


--
-- Name: or_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN or_id SET DEFAULT nextval('orders_or_id_seq'::regclass);


--
-- Name: address_books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_books
    ADD CONSTRAINT address_books_pkey PRIMARY KEY (adr_id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (cu_id);


--
-- Name: order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY order_products
    ADD CONSTRAINT order_products_pkey PRIMARY KEY (op_id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (or_id);


--
-- Name: address_books_adr_cu_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX address_books_adr_cu_id_idx ON address_books USING btree (adr_cu_id);


--
-- Name: customers_cu_email_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX customers_cu_email_idx ON customers USING btree (cu_email);


--
-- Name: order_products_op_or_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX order_products_op_or_id_idx ON order_products USING btree (op_or_id);


--
-- Name: orders_or_cu_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX orders_or_cu_id_idx ON orders USING btree (or_cu_id);


--
-- Name: orders_or_so_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX orders_or_so_id_idx ON orders USING btree (or_so_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

