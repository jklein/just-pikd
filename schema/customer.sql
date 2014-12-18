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
-- Name: notification_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE notification_type AS ENUM (
    'Email',
    'Text',
    'Push'
);


ALTER TYPE notification_type OWNER TO postgres;

--
-- Name: TYPE notification_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE notification_type IS 'Customer selected contact preference types for order status notifications';


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
    address_id integer NOT NULL,
    customer_id integer NOT NULL,
    type address_type NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255),
    last_name character varying(255),
    email character varying(255),
    address1 character varying(255) NOT NULL,
    address2 character varying(255),
    city character varying(255) NOT NULL,
    state character(2) NOT NULL,
    zip_code character varying(12) NOT NULL,
    phone character varying(30)
);


ALTER TABLE address_books OWNER TO postgres;

--
-- Name: TABLE address_books; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE address_books IS 'Saved billing or shipping addresses tied to a customer account';


--
-- Name: COLUMN address_books.state; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN address_books.state IS 'Two letter state code such as "MA"';


--
-- Name: address_books_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE address_books_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE address_books_address_id_seq OWNER TO postgres;

--
-- Name: address_books_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE address_books_address_id_seq OWNED BY address_books.address_id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE customers (
    customer_id integer NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255),
    last_login timestamp with time zone,
    persist_code character varying(255) DEFAULT NULL::character varying,
    reset_password_code character varying(255) DEFAULT NULL::character varying,
    first_name character varying(255) DEFAULT NULL::character varying,
    stripe_id character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    default_billing_address_id integer,
    default_shipping_address_id integer
);


ALTER TABLE customers OWNER TO postgres;

--
-- Name: TABLE customers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE customers IS 'Basic login information for a customer account';


--
-- Name: COLUMN customers.password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customers.password IS 'Hashed password for this customer account';


--
-- Name: COLUMN customers.persist_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customers.persist_code IS 'Session identifier';


--
-- Name: COLUMN customers.reset_password_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customers.reset_password_code IS 'One time code to reset password, should be nulled out upon use';


--
-- Name: COLUMN customers.stripe_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customers.stripe_id IS 'Customer ID from Stripe API for credit card authentication';


--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE customers_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE customers_customer_id_seq OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE customers_customer_id_seq OWNED BY customers.customer_id;


--
-- Name: order_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE order_products (
    order_product_id integer NOT NULL,
    order_id integer NOT NULL,
    sku character varying(14) NOT NULL,
    quantity integer NOT NULL,
    name character varying(255) NOT NULL,
    manufacturer_name character varying(255),
    list_cost money,
    date_added timestamp with time zone DEFAULT now() NOT NULL,
    date_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE order_products OWNER TO postgres;

--
-- Name: TABLE order_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE order_products IS 'base_products in the order, including all point in time product data necessary to display it in cart and view it in order history without needing to query product tables again.';


--
-- Name: COLUMN order_products.order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.order_id IS 'Foreign key to orders table, the order this item is part of';


--
-- Name: COLUMN order_products.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.sku IS 'Foreign key to the products table';


--
-- Name: COLUMN order_products.quantity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.quantity IS 'The number of this sku being purchased';


--
-- Name: COLUMN order_products.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.name IS 'Display name at time of addition';


--
-- Name: COLUMN order_products.manufacturer_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.manufacturer_name IS 'Manufacturer display name at time of addition';


--
-- Name: COLUMN order_products.list_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.list_cost IS 'products list_cost at time of addition to cart. For a shopping list, this should stay NULL until it becomes a cart';


--
-- Name: COLUMN order_products.date_added; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.date_added IS 'Date the item was added';


--
-- Name: COLUMN order_products.date_updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN order_products.date_updated IS 'Date the quantity or cost was last changed';


--
-- Name: order_products_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE order_products_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE order_products_item_id_seq OWNER TO postgres;

--
-- Name: order_products_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE order_products_item_id_seq OWNED BY order_products.order_product_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE orders (
    order_id integer NOT NULL,
    store_id integer NOT NULL,
    customer_id integer NOT NULL,
    status order_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    submitted_at timestamp with time zone,
    total_cost money,
    first_name character varying(255),
    middle_name character varying(255),
    last_name character varying(255),
    email character varying(255),
    address1 character varying(255),
    address2 character varying(255),
    city character varying(255),
    state character(2),
    zip_code character varying(12),
    phone character varying(30),
    notification_type notification_type,
    scheduled_pickup timestamp without time zone
);


ALTER TABLE orders OWNER TO postgres;

--
-- Name: TABLE orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE orders IS 'Order level information, including status and point in time billing address information';


--
-- Name: COLUMN orders.store_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.store_id IS 'The store that fulfills the order';


--
-- Name: COLUMN orders.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.created_at IS 'The time when the basket is initially created';


--
-- Name: COLUMN orders.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.updated_at IS 'The last time any data on the order was changed';


--
-- Name: COLUMN orders.submitted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.submitted_at IS 'The time when the customer submitted the order upon completion of checkout';


--
-- Name: COLUMN orders.total_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.total_cost IS 'The total price paid by the customer for all base_products on the order';


--
-- Name: COLUMN orders.notification_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.notification_type IS 'Customer selected contact preference types for order status notifications';


--
-- Name: COLUMN orders.scheduled_pickup; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.scheduled_pickup IS 'Scheduled pickup time chosen when placing order';


--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE orders_order_id_seq OWNED BY orders.order_id;


--
-- Name: address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address_books ALTER COLUMN address_id SET DEFAULT nextval('address_books_address_id_seq'::regclass);


--
-- Name: customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY customers ALTER COLUMN customer_id SET DEFAULT nextval('customers_customer_id_seq'::regclass);


--
-- Name: order_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY order_products ALTER COLUMN order_product_id SET DEFAULT nextval('order_products_item_id_seq'::regclass);


--
-- Name: order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN order_id SET DEFAULT nextval('orders_order_id_seq'::regclass);


--
-- Name: address_books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address_books
    ADD CONSTRAINT address_books_pkey PRIMARY KEY (address_id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY order_products
    ADD CONSTRAINT order_products_pkey PRIMARY KEY (order_product_id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: address_books; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE address_books FROM PUBLIC;
REVOKE ALL ON TABLE address_books FROM postgres;
GRANT ALL ON TABLE address_books TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE address_books TO jp_readwrite;


--
-- Name: customers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE customers FROM PUBLIC;
REVOKE ALL ON TABLE customers FROM postgres;
GRANT ALL ON TABLE customers TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE customers TO jp_readwrite;


--
-- Name: order_products; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE order_products FROM PUBLIC;
REVOKE ALL ON TABLE order_products FROM postgres;
GRANT ALL ON TABLE order_products TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE order_products TO jp_readwrite;


--
-- Name: orders; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE orders FROM PUBLIC;
REVOKE ALL ON TABLE orders FROM postgres;
GRANT ALL ON TABLE orders TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE orders TO jp_readwrite;


--
-- PostgreSQL database dump complete
--

