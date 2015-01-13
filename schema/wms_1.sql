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
-- Name: wms_1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE wms_1 IS 'Store specific (note the store_id suffix). Inbound and outbound purchase orders, inventory for a store, bins, pick carts, etc. information about suppliers, finance information. Also contains pick tasks, employee schedules and stations.';


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


SET search_path = public, pg_catalog;

--
-- Name: customer_order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE customer_order_status AS ENUM (
    'Processing',
    'Queued for Picking',
    'Picking',
    'On Hold',
    'Ready for Pickup',
    'Completed',
    'Cancelled',
    'Abandoned'
);


ALTER TYPE customer_order_status OWNER TO postgres;

--
-- Name: TYPE customer_order_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE customer_order_status IS 'Possible statuses for a customer order:
Processing - just received from website, must be processed before queued for picking
Queued for Picking - in the pick queue
Picking - currently being picked
On Hold - placed on hold due to some issue that must be resolved before proceeding
Ready for Pickup - picking completed, awaiting customer pickup
Completed - picked up by the customer
Cancelled - cancelled';


--
-- Name: expiration_class; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE expiration_class AS ENUM (
    'A',
    'B',
    'C'
);


ALTER TYPE expiration_class OWNER TO postgres;

--
-- Name: TYPE expiration_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE expiration_class IS 'Level of rigor needed in checking expiration dates.
Class A products have short shelf lives (<2 weeks) and must be checked immediately when stocking.
Class B products have shelf lives measured in months and are checked only if they remain on hand for weeks.
Class C products have shelf lives measured in years and are checked only if they remain on hand for months.';


--
-- Name: measurement_unit; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE measurement_unit AS ENUM (
    'fl oz',
    'oz',
    'sq ft',
    'lbs',
    'count',
    'L',
    'qt',
    'pt',
    'gal',
    'pack'
);


ALTER TYPE measurement_unit OWNER TO postgres;

--
-- Name: TYPE measurement_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE measurement_unit IS 'Units of measure for product sizes';


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
-- Name: outbound_inventory_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE outbound_inventory_type AS ENUM (
    'Customer Order',
    'Return to Vendor',
    'Donation',
    'Promotion'
);


ALTER TYPE outbound_inventory_type OWNER TO postgres;

--
-- Name: TYPE outbound_inventory_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE outbound_inventory_type IS 'Reasons for inventory to leave the warehouse:
Customer Order - purchased products
Return to Vendor - products we return to the vendor
Donation - products we donate
Promotion - products we give away for promotional/marketing purposes';


--
-- Name: outbound_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE outbound_status AS ENUM (
    'Queued for Picking',
    'Picking',
    'Ready for Pickup',
    'Completed Pickup',
    'Cancelled Pickup'
);


ALTER TYPE outbound_status OWNER TO postgres;

--
-- Name: TYPE outbound_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE outbound_status IS 'Possible states for outbound_inventory products';


--
-- Name: pick_container_location_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE pick_container_location_type AS ENUM (
    'Finished Goods Buffer',
    'Pick Cart Parking'
);


ALTER TYPE pick_container_location_type OWNER TO postgres;

--
-- Name: TYPE pick_container_location_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE pick_container_location_type IS 'Denotes the type of locations that pick_containers can be stored in';


--
-- Name: pick_container_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE pick_container_type AS ENUM (
    'Pick Cart',
    'Bin'
);


ALTER TYPE pick_container_type OWNER TO postgres;

--
-- Name: TYPE pick_container_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE pick_container_type IS 'Types of containers for products used during picking';


--
-- Name: pickup_location_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE pickup_location_type AS ENUM (
    'Parking Spot',
    'Indoor Pickup Location'
);


ALTER TYPE pickup_location_type OWNER TO postgres;

--
-- Name: TYPE pickup_location_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE pickup_location_type IS 'Types of pickup locations - indoor or outdoor parking spots';


--
-- Name: product_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE product_status AS ENUM (
    'Active',
    'Being Added',
    'Temporarily Unavailable',
    'Discontinued',
    'Dummy'
);


ALTER TYPE product_status OWNER TO postgres;

--
-- Name: TYPE product_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE product_status IS 'Stages of product lifecycle. Only active products are listed on site';


--
-- Name: receiving_location_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE receiving_location_type AS ENUM (
    'Pallet Receiving',
    'DSD Receiving Bay',
    'General Receiving Bay'
);


ALTER TYPE receiving_location_type OWNER TO postgres;

--
-- Name: TYPE receiving_location_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE receiving_location_type IS 'Types of places where goods can be stored during receiving -
Pallet Receiving for entire pallets in any temperature zone
DSD Receiving Bay for direct store deliveries - no barcode, one per store
General Receiving Bay for sub-pallet deliveries, returns or emergency products (with barcodes)';


--
-- Name: station_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE station_type AS ENUM (
    'Receiving',
    'Stocking',
    'Picking',
    'Pickup',
    'Quality Control',
    'Kiosk Checkin',
    'Other'
);


ALTER TYPE station_type OWNER TO postgres;

--
-- Name: TYPE station_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE station_type IS 'Stations that associates can be staffed to';


--
-- Name: stocking_location_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE stocking_location_type AS ENUM (
    'Pallet Storage',
    'Shelf Storage',
    'Produce Storage'
);


ALTER TYPE stocking_location_type OWNER TO postgres;

--
-- Name: TYPE stocking_location_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE stocking_location_type IS 'Types of stocking_locations';


--
-- Name: stocking_purchase_order_product_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE stocking_purchase_order_product_status AS ENUM (
    'Unsent',
    'Requested',
    'Confirmed',
    'Shipped',
    'Received',
    'Stocked',
    'Unfulfilled',
    'Unavailable',
    'Received - Qty Mismatch'
);


ALTER TYPE stocking_purchase_order_product_status OWNER TO postgres;

--
-- Name: TYPE stocking_purchase_order_product_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE stocking_purchase_order_product_status IS 'Possible states for SPO products. Should go from Ordered to Received to Stocked in the general case. Unfulfilled means the item was not in the shipment that arrived.';


--
-- Name: stocking_purchase_order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE stocking_purchase_order_status AS ENUM (
    'Unsent',
    'Requested',
    'Confirmed',
    'Shipped',
    'Partially Delivered',
    'Delivered',
    'Cancelled'
);


ALTER TYPE stocking_purchase_order_status OWNER TO postgres;

--
-- Name: TYPE stocking_purchase_order_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE stocking_purchase_order_status IS 'Possible statuses of stocking_purchase_orders:
Unsent: has not been sent to supplier yet
Requested: has been sent to supplier, no confirmation received
Confirmed: has been confirmed by supplier
Shipped: has been shipped by supplier
Partially Delivered: some products have arrived, but not all
Delivered: all products delivered
Cancelled: self explanatory';


--
-- Name: task_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE task_status AS ENUM (
    'Queued',
    'In Progress',
    'Paused',
    'Completed'
);


ALTER TYPE task_status OWNER TO postgres;

--
-- Name: TYPE task_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE task_status IS 'States a pick/pickup task can be in:
Queued - not yet started
In Progress - currently being worked on
Paused - was in progress, but paused (i.e. due to emergency)
Completed - done';


--
-- Name: temperature_zone; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE temperature_zone AS ENUM (
    'frozen',
    'cold',
    'fresh',
    'dry'
);


ALTER TYPE temperature_zone OWNER TO postgres;

--
-- Name: TYPE temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE temperature_zone IS 'Physical storage areas in the warehouse for each product';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: associate_stations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE associate_stations (
    associate_id integer NOT NULL,
    station_type station_type NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone
);


ALTER TABLE associate_stations OWNER TO postgres;

--
-- Name: TABLE associate_stations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE associate_stations IS 'Current and historical stations associates are staffed to';


--
-- Name: COLUMN associate_stations.associate_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associate_stations.associate_id IS 'Foreign key to associates table';


--
-- Name: COLUMN associate_stations.station_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associate_stations.station_type IS 'The station they are staffed to';


--
-- Name: COLUMN associate_stations.start_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associate_stations.start_time IS 'When this employee started working at this station';


--
-- Name: associates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE associates (
    associate_id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    login_pin character varying(6),
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE associates OWNER TO postgres;

--
-- Name: TABLE associates; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE associates IS 'Employees working at the store';


--
-- Name: COLUMN associates.associate_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associates.associate_id IS 'Unique identifier to the associate record';


--
-- Name: COLUMN associates.last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associates.last_name IS 'The associate''s last name';


--
-- Name: COLUMN associates.login_pin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associates.login_pin IS 'PIN the associate uses to log in via app';


--
-- Name: associates_associate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE associates_associate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE associates_associate_id_seq OWNER TO postgres;

--
-- Name: associates_associate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE associates_associate_id_seq OWNED BY associates.associate_id;


--
-- Name: customer_order_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE customer_order_products (
    customer_order_product_id integer NOT NULL,
    customer_order_id integer NOT NULL,
    sku ean13 NOT NULL,
    quantity integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE customer_order_products OWNER TO postgres;

--
-- Name: TABLE customer_order_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE customer_order_products IS 'Line items on customer orders';


--
-- Name: COLUMN customer_order_products.customer_order_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_order_products.customer_order_product_id IS 'Unique id generated on the web site';


--
-- Name: COLUMN customer_order_products.customer_order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_order_products.customer_order_id IS 'Foreign key to customer_orders';


--
-- Name: COLUMN customer_order_products.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_order_products.sku IS 'Foreign key to products';


--
-- Name: COLUMN customer_order_products.quantity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_order_products.quantity IS 'Quantity ordered';


--
-- Name: customer_orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE customer_orders (
    customer_order_id integer NOT NULL,
    customer_id integer NOT NULL,
    status customer_order_status NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    email character varying(255),
    phone character varying(30),
    notification_type notification_type,
    submitted_at timestamp without time zone,
    scheduled_pickup timestamp without time zone,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE customer_orders OWNER TO postgres;

--
-- Name: TABLE customer_orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE customer_orders IS 'Orders received from customers';


--
-- Name: COLUMN customer_orders.customer_order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.customer_order_id IS 'Unique id generated on the web site';


--
-- Name: COLUMN customer_orders.customer_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.customer_id IS 'Foreign key to the customers table';


--
-- Name: COLUMN customer_orders.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.status IS 'Current status of this customer order';


--
-- Name: COLUMN customer_orders.first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.first_name IS 'Customer first name';


--
-- Name: COLUMN customer_orders.last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.last_name IS 'Customer last name';


--
-- Name: COLUMN customer_orders.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.email IS 'Customer email address';


--
-- Name: COLUMN customer_orders.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.phone IS 'Customer phone number';


--
-- Name: COLUMN customer_orders.notification_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.notification_type IS 'How the customer wants to receive order status notifications (text, email, push)';


--
-- Name: COLUMN customer_orders.submitted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.submitted_at IS 'Date the order was submitted on the web site';


--
-- Name: COLUMN customer_orders.scheduled_pickup; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.scheduled_pickup IS 'Scheduled pickup date';


--
-- Name: inventory_errors; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventory_errors (
    inventory_error_id integer NOT NULL,
    associate_id integer NOT NULL,
    sku ean13 NOT NULL,
    qty_adjustment integer,
    static_inventory_id integer,
    stocking_purchase_order_product_id integer,
    outbound_inventory_id integer,
    notes text,
    error_date timestamp without time zone,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE inventory_errors OWNER TO postgres;

--
-- Name: TABLE inventory_errors; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE inventory_errors IS 'A place to log any inventory errors or adjustments to inventory';


--
-- Name: COLUMN inventory_errors.inventory_error_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.inventory_error_id IS 'Surrogate primary key';


--
-- Name: COLUMN inventory_errors.associate_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.associate_id IS 'The person logging the error';


--
-- Name: COLUMN inventory_errors.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.sku IS 'The sku the error pertains to';


--
-- Name: COLUMN inventory_errors.qty_adjustment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.qty_adjustment IS 'Amount adjusted (negative if removed qty, positive if added)';


--
-- Name: COLUMN inventory_errors.static_inventory_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.static_inventory_id IS 'The static_inventory record this pertains to, if applicable';


--
-- Name: COLUMN inventory_errors.stocking_purchase_order_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.stocking_purchase_order_product_id IS 'The stocking_purchase_order_products record this pertains to, if applicable';


--
-- Name: COLUMN inventory_errors.outbound_inventory_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.outbound_inventory_id IS 'The outbound_inventory record this pertains to, if applicable';


--
-- Name: COLUMN inventory_errors.notes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.notes IS 'Associate-entered description of what happened';


--
-- Name: COLUMN inventory_errors.error_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.error_date IS 'Date when the error was logged';


--
-- Name: inventory_errors_inventory_error_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventory_errors_inventory_error_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE inventory_errors_inventory_error_id_seq OWNER TO postgres;

--
-- Name: inventory_errors_inventory_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventory_errors_inventory_error_id_seq OWNED BY inventory_errors.inventory_error_id;


--
-- Name: inventory_holds; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventory_holds (
    inventory_hold_id integer NOT NULL,
    static_inventory_id integer NOT NULL,
    customer_order_product_id integer NOT NULL,
    qty integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE inventory_holds OWNER TO postgres;

--
-- Name: TABLE inventory_holds; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE inventory_holds IS 'Products that are on hold for unprocessed orders (tied to static_inventory)';


--
-- Name: COLUMN inventory_holds.inventory_hold_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_holds.inventory_hold_id IS 'Surrogate primary key';


--
-- Name: COLUMN inventory_holds.static_inventory_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_holds.static_inventory_id IS 'Foreign key to static_inventory table';


--
-- Name: COLUMN inventory_holds.customer_order_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_holds.customer_order_product_id IS 'Foreign key to inventory_holds table';


--
-- Name: COLUMN inventory_holds.qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_holds.qty IS 'Quantity held by this hold';


--
-- Name: inventory_holds_inventory_hold_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventory_holds_inventory_hold_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE inventory_holds_inventory_hold_id_seq OWNER TO postgres;

--
-- Name: inventory_holds_inventory_hold_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventory_holds_inventory_hold_id_seq OWNED BY inventory_holds.inventory_hold_id;


--
-- Name: kiosks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE kiosks (
    kiosk_id integer NOT NULL,
    preferred_pickup_locations integer[],
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE kiosks OWNER TO postgres;

--
-- Name: TABLE kiosks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE kiosks IS 'Outdoor kiosks customers use to check in.';


--
-- Name: COLUMN kiosks.kiosk_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN kiosks.kiosk_id IS 'Unique identifier to the kiosk';


--
-- Name: COLUMN kiosks.preferred_pickup_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN kiosks.preferred_pickup_locations IS 'Ordered array of preferred pickup_location_ids';


--
-- Name: kiosks_kiosk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE kiosks_kiosk_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kiosks_kiosk_id_seq OWNER TO postgres;

--
-- Name: kiosks_kiosk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE kiosks_kiosk_id_seq OWNED BY kiosks.kiosk_id;


--
-- Name: outbound_inventory; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE outbound_inventory (
    outbound_inventory_id integer NOT NULL,
    customer_order_product_id integer NOT NULL,
    sku ean13 NOT NULL,
    pick_container_id ean13 NOT NULL,
    stocking_location_id ean13 NOT NULL,
    static_inventory_id integer NOT NULL,
    qty integer NOT NULL,
    outbound_inventory_type outbound_inventory_type NOT NULL,
    status outbound_status NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE outbound_inventory OWNER TO postgres;

--
-- Name: TABLE outbound_inventory; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE outbound_inventory IS 'Tracks locations for products that have been picked and are awaiting pickup';


--
-- Name: COLUMN outbound_inventory.outbound_inventory_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.outbound_inventory_id IS 'Surrogate primary key';


--
-- Name: COLUMN outbound_inventory.customer_order_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.customer_order_product_id IS 'Foreign key to customer_order_products table';


--
-- Name: COLUMN outbound_inventory.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.sku IS 'Foreign key to products table';


--
-- Name: COLUMN outbound_inventory.pick_container_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.pick_container_id IS 'Finished goods storage location for the product. Part of the primary key because a single product could take up multiple locations.';


--
-- Name: COLUMN outbound_inventory.stocking_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.stocking_location_id IS 'The storage slot in static_inventory that the product came from. Part of the primary key because a single product could come from multiple locations.';


--
-- Name: COLUMN outbound_inventory.static_inventory_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.static_inventory_id IS 'The static inventory record this outbound inventory is coming from';


--
-- Name: COLUMN outbound_inventory.qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.qty IS 'Quantity of this product stored in this finished goods location';


--
-- Name: COLUMN outbound_inventory.outbound_inventory_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.outbound_inventory_type IS 'Reason why this inventory is outbound (i.e. customer order vs donation)';


--
-- Name: COLUMN outbound_inventory.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN outbound_inventory.status IS 'Current state of this product on this order';


--
-- Name: outbound_inventory_outbound_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE outbound_inventory_outbound_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE outbound_inventory_outbound_inventory_id_seq OWNER TO postgres;

--
-- Name: outbound_inventory_outbound_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE outbound_inventory_outbound_inventory_id_seq OWNED BY outbound_inventory.outbound_inventory_id;


--
-- Name: pick_container_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pick_container_locations (
    pick_container_location_id ean13 NOT NULL,
    pick_container_location_type pick_container_location_type NOT NULL,
    temperature_zone temperature_zone,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE pick_container_locations OWNER TO postgres;

--
-- Name: TABLE pick_container_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pick_container_locations IS 'Locations that pick_containers can be stored in';


--
-- Name: COLUMN pick_container_locations.pick_container_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pick_container_location_id IS 'Unique barcode on each pick container';


--
-- Name: COLUMN pick_container_locations.pick_container_location_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pick_container_location_type IS 'The type of location - i.e. finished goods buffer vs. pick cart parking';


--
-- Name: COLUMN pick_container_locations.temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.temperature_zone IS 'The temperature zone the location is to be used in';


--
-- Name: pick_containers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pick_containers (
    pick_container_id ean13 NOT NULL,
    temperature_zone temperature_zone NOT NULL,
    pick_container_type pick_container_type NOT NULL,
    pick_container_location_id integer,
    height double precision,
    width double precision NOT NULL,
    depth double precision NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE pick_containers OWNER TO postgres;

--
-- Name: TABLE pick_containers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pick_containers IS 'Containers for products used during picking';


--
-- Name: COLUMN pick_containers.pick_container_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pick_container_id IS 'Unique barcode on each pick container';


--
-- Name: COLUMN pick_containers.temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.temperature_zone IS 'The temperature zone the container is to be used in';


--
-- Name: COLUMN pick_containers.pick_container_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pick_container_type IS 'The type of pick container, such as pick cart or bin';


--
-- Name: COLUMN pick_containers.pick_container_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pick_container_location_id IS 'Current pick_container_location this is stored in, if any';


--
-- Name: COLUMN pick_containers.height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.height IS 'Height of the container in inches (null for carts which are flat)';


--
-- Name: COLUMN pick_containers.width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.width IS 'Width of the container in inches';


--
-- Name: COLUMN pick_containers.depth; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.depth IS 'Depth of the container in inches';


--
-- Name: pick_task_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pick_task_products (
    pick_task_product_id integer NOT NULL,
    pick_task_id integer NOT NULL,
    customer_order_product_id integer NOT NULL,
    sku ean13 NOT NULL,
    qty integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE pick_task_products OWNER TO postgres;

--
-- Name: TABLE pick_task_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pick_task_products IS 'Products that make up a pickup task, each tied to a customer_order_product';


--
-- Name: COLUMN pick_task_products.pick_task_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.pick_task_product_id IS 'Surrogate primary key';


--
-- Name: COLUMN pick_task_products.pick_task_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.pick_task_id IS 'Foreign key to pick_tasks';


--
-- Name: COLUMN pick_task_products.customer_order_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.customer_order_product_id IS 'Foreign key to customer_order_products';


--
-- Name: COLUMN pick_task_products.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.sku IS 'Foreign key to products';


--
-- Name: COLUMN pick_task_products.qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.qty IS 'Qty of this sku on this pick task (can be subset of customer_order_product qty if many are ordered)';


--
-- Name: pick_task_products_pick_task_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pick_task_products_pick_task_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pick_task_products_pick_task_product_id_seq OWNER TO postgres;

--
-- Name: pick_task_products_pick_task_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pick_task_products_pick_task_product_id_seq OWNED BY pick_task_products.pick_task_product_id;


--
-- Name: pick_tasks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pick_tasks (
    pick_task_id integer NOT NULL,
    pick_container_id ean13 NOT NULL,
    customer_order_id integer NOT NULL,
    status task_status NOT NULL,
    temperature_zone temperature_zone NOT NULL,
    order_promised_time timestamp without time zone NOT NULL,
    associate_id integer,
    est_duration integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE pick_tasks OWNER TO postgres;

--
-- Name: TABLE pick_tasks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pick_tasks IS 'Represents work assigned to one associate in one temperature zone for one order';


--
-- Name: COLUMN pick_tasks.pick_task_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pick_task_id IS 'Unique identifier to the pick task';


--
-- Name: COLUMN pick_tasks.pick_container_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pick_container_id IS 'The container being used to pick the products';


--
-- Name: COLUMN pick_tasks.customer_order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.customer_order_id IS 'Foreign key to customer_orders';


--
-- Name: COLUMN pick_tasks.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.status IS 'Current status of this pick task, i.e. queued/in progress/complete';


--
-- Name: COLUMN pick_tasks.temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.temperature_zone IS 'Temperature zone the pick task takes place in';


--
-- Name: COLUMN pick_tasks.order_promised_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.order_promised_time IS 'Time by which the pick task must be completed';


--
-- Name: COLUMN pick_tasks.associate_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.associate_id IS 'Associate assigned to the task';


--
-- Name: COLUMN pick_tasks.est_duration; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.est_duration IS 'Duration estimate, if applicable';


--
-- Name: COLUMN pick_tasks.start_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.start_time IS 'When the task was started';


--
-- Name: COLUMN pick_tasks.end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.end_time IS 'When the task was completed';


--
-- Name: pick_tasks_pick_task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pick_tasks_pick_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pick_tasks_pick_task_id_seq OWNER TO postgres;

--
-- Name: pick_tasks_pick_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pick_tasks_pick_task_id_seq OWNED BY pick_tasks.pick_task_id;


--
-- Name: pickup_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pickup_locations (
    pickup_location_id integer NOT NULL,
    pickup_location_type pickup_location_type NOT NULL,
    display_name character varying(50) NOT NULL,
    current_cars integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE pickup_locations OWNER TO postgres;

--
-- Name: TABLE pickup_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pickup_locations IS 'Places customers will be waiting when picking up their orders';


--
-- Name: COLUMN pickup_locations.pickup_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_locations.pickup_location_id IS 'Unique identifier to the location';


--
-- Name: COLUMN pickup_locations.pickup_location_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_locations.pickup_location_type IS 'Type of location - parking spot or indoor';


--
-- Name: COLUMN pickup_locations.display_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_locations.display_name IS 'Name shown to associates in app for the location';


--
-- Name: COLUMN pickup_locations.current_cars; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_locations.current_cars IS 'Current number of cars in the location (always 0 for indoor)';


--
-- Name: pickup_locations_pickup_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pickup_locations_pickup_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pickup_locations_pickup_location_id_seq OWNER TO postgres;

--
-- Name: pickup_locations_pickup_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pickup_locations_pickup_location_id_seq OWNED BY pickup_locations.pickup_location_id;


--
-- Name: pickup_task_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pickup_task_products (
    pickup_task_product_id integer NOT NULL,
    pickup_task_id integer NOT NULL,
    customer_order_product_id integer NOT NULL,
    sku ean13 NOT NULL,
    qty integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE pickup_task_products OWNER TO postgres;

--
-- Name: COLUMN pickup_task_products.pickup_task_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_task_products.pickup_task_product_id IS 'Surrogate primary key';


--
-- Name: COLUMN pickup_task_products.pickup_task_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_task_products.pickup_task_id IS 'Foreign key to pickup_tasks';


--
-- Name: COLUMN pickup_task_products.customer_order_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_task_products.customer_order_product_id IS 'Foreign key to customer_order_products';


--
-- Name: COLUMN pickup_task_products.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_task_products.sku IS 'Foreign key to products';


--
-- Name: COLUMN pickup_task_products.qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_task_products.qty IS 'Qty of this sku on this pick task (can be subset of customer_order_product qty if many are ordered)';


--
-- Name: pickup_task_products_pickup_task_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pickup_task_products_pickup_task_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pickup_task_products_pickup_task_product_id_seq OWNER TO postgres;

--
-- Name: pickup_task_products_pickup_task_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pickup_task_products_pickup_task_product_id_seq OWNED BY pickup_task_products.pickup_task_product_id;


--
-- Name: pickup_tasks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pickup_tasks (
    pickup_task_id integer NOT NULL,
    customer_order_id integer NOT NULL,
    status task_status NOT NULL,
    customer_checkin_time timestamp without time zone NOT NULL,
    pickup_location_id integer NOT NULL,
    associate_id integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE pickup_tasks OWNER TO postgres;

--
-- Name: TABLE pickup_tasks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pickup_tasks IS 'Group of products that one associate gathers as part (or all) of a customer order across multiple temperature zones';


--
-- Name: COLUMN pickup_tasks.pickup_task_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.pickup_task_id IS 'Surrogate primary key';


--
-- Name: COLUMN pickup_tasks.customer_order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.customer_order_id IS 'Foreign key to customer_orders';


--
-- Name: COLUMN pickup_tasks.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.status IS 'Current status of this pickup task, i.e. queued/in progress/complete';


--
-- Name: COLUMN pickup_tasks.customer_checkin_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.customer_checkin_time IS 'Time when the customer checked in as awaiting pickup';


--
-- Name: COLUMN pickup_tasks.pickup_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.pickup_location_id IS 'Location where the customer is waiting for pickup';


--
-- Name: COLUMN pickup_tasks.associate_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.associate_id IS 'Associate assigned to the pickup task';


--
-- Name: COLUMN pickup_tasks.start_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.start_time IS 'When the task was started';


--
-- Name: COLUMN pickup_tasks.end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.end_time IS 'When the task was completed';


--
-- Name: pickup_tasks_pickup_task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pickup_tasks_pickup_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pickup_tasks_pickup_task_id_seq OWNER TO postgres;

--
-- Name: pickup_tasks_pickup_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pickup_tasks_pickup_task_id_seq OWNED BY pickup_tasks.pickup_task_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products (
    sku ean13 NOT NULL,
    sku_is_real_upc boolean NOT NULL,
    status product_status NOT NULL,
    default_image_id integer,
    case_upc ean13,
    units_per_case smallint,
    measurement_unit measurement_unit,
    measurement_value integer,
    upc_commodity integer,
    upc_vendor integer,
    upc_case integer,
    upc_item integer,
    length double precision,
    width double precision,
    height double precision,
    cubic_volume double precision,
    weight double precision,
    gtin character varying(14),
    temperature_zone temperature_zone,
    manufacturer_id integer,
    category_id integer,
    description text,
    shelf_life_days integer,
    qc_check_interval_days integer,
    brand_id integer,
    name character varying(255),
    product_family_id integer,
    case_length double precision,
    case_width double precision,
    case_height double precision,
    case_weight double precision,
    expiration_class expiration_class,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE products OWNER TO postgres;

--
-- Name: TABLE products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE products IS 'Information about a product that is size-specific, such as UPC, measurements and prices. Must be tied to a product_id for base product information even if there is only one size.';


--
-- Name: COLUMN products.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.sku IS 'The unique UPC for this item, as scanned if the item has a barcode on it. For other items like produce, this is an number determine.';


--
-- Name: COLUMN products.sku_is_real_upc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.sku_is_real_upc IS 'True if the item has a barcode on it and our sku is an actual UPC.';


--
-- Name: COLUMN products.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.status IS 'Whether the product can be displayed and sold on site';


--
-- Name: COLUMN products.default_image_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.default_image_id IS 'Default image to be displayed on browse and product pages';


--
-- Name: COLUMN products.case_upc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.case_upc IS 'The UPC of the case the item comes in, if applicable';


--
-- Name: COLUMN products.units_per_case; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.units_per_case IS 'The quantity of this item contained in the case_upc';


--
-- Name: COLUMN products.measurement_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.measurement_unit IS 'The unit of measure for this product if applicable';


--
-- Name: COLUMN products.measurement_value; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.measurement_value IS 'The value in units of measurement_unit';


--
-- Name: COLUMN products.upc_commodity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.upc_commodity IS 'This data comes from C&S and we may not need it. Drop?';


--
-- Name: COLUMN products.upc_vendor; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.upc_vendor IS 'This data comes from C&S and we may not need it. Drop?';


--
-- Name: COLUMN products.upc_case; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.upc_case IS 'This data comes from C&S and we may not need it. Drop?';


--
-- Name: COLUMN products.upc_item; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.upc_item IS 'This data comes from C&S and we may not need it. Drop?';


--
-- Name: COLUMN products.length; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.length IS 'The length of the product in inches in packaging as stored in the warehouse';


--
-- Name: COLUMN products.width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.width IS 'The width of the product in inches in packaging as stored in the warehouse';


--
-- Name: COLUMN products.height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.height IS 'The height of the product in inches in packaging as stored in the warehouse';


--
-- Name: COLUMN products.cubic_volume; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.cubic_volume IS 'The length*width*depth. This is redundant. Drop?';


--
-- Name: COLUMN products.weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.weight IS 'The weight of the product in packaging in lbs';


--
-- Name: COLUMN products.gtin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.gtin IS 'Global Trade Item Number';


--
-- Name: COLUMN products.temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.temperature_zone IS 'Temperature zone where the product is stored in the warehouse';


--
-- Name: COLUMN products.manufacturer_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.manufacturer_id IS 'The manufacturer that produces the product';


--
-- Name: COLUMN products.category_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.category_id IS 'The category the product is tied to for revenue allocation and merchandising purposes';


--
-- Name: COLUMN products.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.description IS 'The detailed product description as displayed to customers on site';


--
-- Name: COLUMN products.shelf_life_days; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.shelf_life_days IS 'Estimated shelf life in days after a product is received. We will need to populate this based on our experience if we can''t get data from the manufacturer.';


--
-- Name: COLUMN products.qc_check_interval_days; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.qc_check_interval_days IS 'Frequency at which we should check quality on a product, especially produce';


--
-- Name: COLUMN products.brand_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.brand_id IS 'Foreign key to brand.id';


--
-- Name: COLUMN products.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.name IS 'Product name as shown to customers on site';


--
-- Name: COLUMN products.product_family_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.product_family_id IS 'Foreign key to product_families table if the product is part of a family.';


--
-- Name: COLUMN products.expiration_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.expiration_class IS 'Level of rigor needed in checking expirations - based on shelf life';


--
-- Name: products_suppliers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products_suppliers (
    sku ean13 NOT NULL,
    supplier_id integer NOT NULL,
    status product_status NOT NULL,
    wholesale_cost integer,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE products_suppliers OWNER TO postgres;

--
-- Name: TABLE products_suppliers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE products_suppliers IS 'Which product instances are carried by which suppliers and at what wholesale price';


--
-- Name: COLUMN products_suppliers.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products_suppliers.status IS 'Whether we can currently buy this product from this supplier';


--
-- Name: COLUMN products_suppliers.wholesale_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products_suppliers.wholesale_cost IS 'The price in CENTS we would pay to buy this product from the supplier';


--
-- Name: receiving_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE receiving_locations (
    receiving_location_id ean13 NOT NULL,
    receiving_location_type receiving_location_type NOT NULL,
    temperature_zone temperature_zone NOT NULL,
    supplier_shipment_id integer,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE receiving_locations OWNER TO postgres;

--
-- Name: TABLE receiving_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE receiving_locations IS 'Locations where goods can be stored during receiving. A location is empty if stocking_purchase_order_id is null, and non-empty otherwise.';


--
-- Name: COLUMN receiving_locations.receiving_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN receiving_locations.receiving_location_id IS 'Barcode identifier for the location (or just the word DSD Bay for the singleton DSD bay)';


--
-- Name: COLUMN receiving_locations.temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN receiving_locations.temperature_zone IS 'Temperature zone the receiving location is located in';


--
-- Name: COLUMN receiving_locations.supplier_shipment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN receiving_locations.supplier_shipment_id IS 'Current supplier shipment in this location, if the location is not empty';


--
-- Name: static_inventory; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE static_inventory (
    static_inventory_id integer NOT NULL,
    stocking_location_id ean13 NOT NULL,
    sku ean13 NOT NULL,
    stocking_purchase_order_product_id integer NOT NULL,
    expiration_class expiration_class,
    expiration_date timestamp without time zone,
    total_qty integer NOT NULL,
    available_qty integer NOT NULL,
    arrival_date timestamp without time zone,
    emptied_date timestamp without time zone,
    manufacturer_id integer,
    name character varying(255),
    length double precision,
    width double precision,
    height double precision,
    weight double precision,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE static_inventory OWNER TO postgres;

--
-- Name: TABLE static_inventory; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE static_inventory IS 'Representation of inventory on hand in the warehouse.';


--
-- Name: COLUMN static_inventory.static_inventory_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.static_inventory_id IS 'Surrogate primary key';


--
-- Name: COLUMN static_inventory.stocking_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.stocking_location_id IS 'Storage slot for the inventory.';


--
-- Name: COLUMN static_inventory.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.sku IS 'The sku from the products table of the inventory';


--
-- Name: COLUMN static_inventory.stocking_purchase_order_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.stocking_purchase_order_product_id IS 'Foreign key to stocking_purchase_order_products - denotes where the product came from';


--
-- Name: COLUMN static_inventory.expiration_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.expiration_class IS 'Indicates level of rigor required around expiration date checking';


--
-- Name: COLUMN static_inventory.expiration_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.expiration_date IS 'Date the items in this slot will expire. Should be recorded at time of receipt (and estimated if not provided on packaging)';


--
-- Name: COLUMN static_inventory.total_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.total_qty IS 'The total quantity of product when the slot was first stocked';


--
-- Name: COLUMN static_inventory.available_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.available_qty IS 'Currently available quantity (total less sold products)';


--
-- Name: COLUMN static_inventory.arrival_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.arrival_date IS 'Date the slot was stocked';


--
-- Name: COLUMN static_inventory.emptied_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.emptied_date IS 'Date the slot was emptied - if not null this means the slot is free';


--
-- Name: COLUMN static_inventory.manufacturer_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.manufacturer_id IS 'Manufacturer ID (used to pull and display images in pick app)';


--
-- Name: COLUMN static_inventory.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.name IS 'Display name of the product';


--
-- Name: COLUMN static_inventory.length; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.length IS 'Length of a single product in inches';


--
-- Name: COLUMN static_inventory.width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.width IS 'Width of a single product in inches';


--
-- Name: COLUMN static_inventory.height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.height IS 'Height of a single product in inches';


--
-- Name: COLUMN static_inventory.weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.weight IS 'Weight of a single product in pounds';


--
-- Name: static_inventory_static_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE static_inventory_static_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE static_inventory_static_inventory_id_seq OWNER TO postgres;

--
-- Name: static_inventory_static_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE static_inventory_static_inventory_id_seq OWNED BY static_inventory.static_inventory_id;


--
-- Name: stocking_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stocking_locations (
    stocking_location_id ean13 NOT NULL,
    temperature_zone temperature_zone NOT NULL,
    stocking_location_type stocking_location_type NOT NULL,
    pick_segment integer NOT NULL,
    aisle integer NOT NULL,
    bay integer NOT NULL,
    shelf integer NOT NULL,
    shelf_slot integer NOT NULL,
    height double precision,
    width double precision,
    depth double precision,
    assigned_sku ean13,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE stocking_locations OWNER TO postgres;

--
-- Name: TABLE stocking_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE stocking_locations IS 'Represents locations that items are stored for picking, pallets or on shelves.
Associates will most often refer to a storage slot by its "location_code", which is computed
as {temperature_zone}-{aisle}-{bay}-{shelf}-{shelf_slot}, with zeroes for the last 3 elements if not on shelving.';


--
-- Name: COLUMN stocking_locations.stocking_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stocking_location_id IS 'Barcode identifier to a storage slot';


--
-- Name: COLUMN stocking_locations.temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.temperature_zone IS 'Temperature zone the storage slot is located in';


--
-- Name: COLUMN stocking_locations.stocking_location_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stocking_location_type IS 'The type of stocking location such as pallet or shelf storage';


--
-- Name: COLUMN stocking_locations.pick_segment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.pick_segment IS 'Numerical pick segment the slot is part of';


--
-- Name: COLUMN stocking_locations.aisle; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.aisle IS 'Aisle number within a temperature zone (visible within store to associates)';


--
-- Name: COLUMN stocking_locations.bay; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.bay IS 'Shelving bay within an aisle (will be null for pallets)';


--
-- Name: COLUMN stocking_locations.shelf; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.shelf IS 'Shelf number within a shelving bay (counting from bottom, starting at 1)';


--
-- Name: COLUMN stocking_locations.shelf_slot; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.shelf_slot IS 'Slot within a shelf (counting from left, starting at 1)';


--
-- Name: COLUMN stocking_locations.height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.height IS 'Height in inches of the slot';


--
-- Name: COLUMN stocking_locations.width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.width IS 'Width in inches of the slot';


--
-- Name: COLUMN stocking_locations.depth; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.depth IS 'Depth in inches of the slot';


--
-- Name: COLUMN stocking_locations.assigned_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.assigned_sku IS 'sku that should be placed in this slot (only for directed put-away, i.e. produce)';


--
-- Name: stocking_purchase_order_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stocking_purchase_order_products (
    stocking_purchase_order_product_id integer NOT NULL,
    stocking_purchase_order_id integer NOT NULL,
    sku ean13 NOT NULL,
    status stocking_purchase_order_product_status NOT NULL,
    requested_qty integer NOT NULL,
    confirmed_qty integer,
    received_qty integer,
    case_upc ean13,
    units_per_case integer,
    requested_case_qty integer,
    confirmed_case_qty integer,
    received_case_qty integer,
    case_length double precision,
    case_width double precision,
    case_height double precision,
    case_weight double precision,
    expected_arrival timestamp without time zone,
    actual_arrival timestamp without time zone,
    wholesale_cost integer,
    expiration_class expiration_class,
    receiving_location_id ean13,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE stocking_purchase_order_products OWNER TO postgres;

--
-- Name: TABLE stocking_purchase_order_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE stocking_purchase_order_products IS 'Products requested on stocking purchase orders. This tracks products from purchasing up through receiving.';


--
-- Name: COLUMN stocking_purchase_order_products.stocking_purchase_order_product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.stocking_purchase_order_product_id IS 'Surrogate key to uniquely identify a row';


--
-- Name: COLUMN stocking_purchase_order_products.stocking_purchase_order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.stocking_purchase_order_id IS 'Foreign key to stocking_purchase_orders';


--
-- Name: COLUMN stocking_purchase_order_products.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.sku IS 'Foreign key to products';


--
-- Name: COLUMN stocking_purchase_order_products.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.status IS 'Current state of this product on this order';


--
-- Name: COLUMN stocking_purchase_order_products.requested_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.requested_qty IS 'Quantity requested to the supplier';


--
-- Name: COLUMN stocking_purchase_order_products.confirmed_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.confirmed_qty IS 'Quantity the supplier confirmed they can send us';


--
-- Name: COLUMN stocking_purchase_order_products.received_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.received_qty IS 'Actual quantity of this product that we received on this purchase order';


--
-- Name: COLUMN stocking_purchase_order_products.case_upc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.case_upc IS 'Barcode on the case of products if shipped by case';


--
-- Name: COLUMN stocking_purchase_order_products.units_per_case; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.units_per_case IS 'Quantity of products per case';


--
-- Name: COLUMN stocking_purchase_order_products.requested_case_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.requested_case_qty IS 'Number of cases requested';


--
-- Name: COLUMN stocking_purchase_order_products.confirmed_case_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.confirmed_case_qty IS 'Number of cases confirmed';


--
-- Name: COLUMN stocking_purchase_order_products.received_case_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.received_case_qty IS 'Number of cases received';


--
-- Name: COLUMN stocking_purchase_order_products.case_length; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.case_length IS 'Length of the case in inches';


--
-- Name: COLUMN stocking_purchase_order_products.case_width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.case_width IS 'Width of the case in inches';


--
-- Name: COLUMN stocking_purchase_order_products.case_height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.case_height IS 'Height of the case in inches';


--
-- Name: COLUMN stocking_purchase_order_products.case_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.case_weight IS 'Weight of the case in pounds';


--
-- Name: COLUMN stocking_purchase_order_products.expected_arrival; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.expected_arrival IS 'Expected arrival date of this product';


--
-- Name: COLUMN stocking_purchase_order_products.actual_arrival; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.actual_arrival IS 'Actual arrival date of this product';


--
-- Name: COLUMN stocking_purchase_order_products.wholesale_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.wholesale_cost IS 'Wholesale cost per unit in CENTS we will to pay the supplier';


--
-- Name: COLUMN stocking_purchase_order_products.expiration_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.expiration_class IS 'Indicates level of rigor required around expiration date checking';


--
-- Name: COLUMN stocking_purchase_order_products.receiving_location_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.receiving_location_id IS 'Location the product is/was in when received and waiting to be stocked';


--
-- Name: stocking_purchase_order_produ_stocking_purchase_order_produ_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE stocking_purchase_order_produ_stocking_purchase_order_produ_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stocking_purchase_order_produ_stocking_purchase_order_produ_seq OWNER TO postgres;

--
-- Name: stocking_purchase_order_produ_stocking_purchase_order_produ_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stocking_purchase_order_produ_stocking_purchase_order_produ_seq OWNED BY stocking_purchase_order_products.stocking_purchase_order_product_id;


--
-- Name: stocking_purchase_orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stocking_purchase_orders (
    stocking_purchase_order_id integer NOT NULL,
    status stocking_purchase_order_status NOT NULL,
    supplier_id integer NOT NULL,
    date_ordered timestamp without time zone NOT NULL,
    date_confirmed timestamp without time zone,
    date_shipped timestamp without time zone,
    date_arrived timestamp without time zone,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE stocking_purchase_orders OWNER TO postgres;

--
-- Name: TABLE stocking_purchase_orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE stocking_purchase_orders IS 'Representation of orders to suppliers to stock our warehouse';


--
-- Name: COLUMN stocking_purchase_orders.stocking_purchase_order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.stocking_purchase_order_id IS 'Unique identifier to a stocking purchase order';


--
-- Name: COLUMN stocking_purchase_orders.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.status IS 'Current status of this stocking purchase order';


--
-- Name: COLUMN stocking_purchase_orders.supplier_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.supplier_id IS 'Supplier the order is placed with';


--
-- Name: COLUMN stocking_purchase_orders.date_ordered; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.date_ordered IS 'Date order sent to supplier';


--
-- Name: COLUMN stocking_purchase_orders.date_confirmed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.date_confirmed IS 'Date the supplier confirmed the products on the order';


--
-- Name: COLUMN stocking_purchase_orders.date_shipped; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.date_shipped IS 'Date the supplier sent us an advanced shipping notification';


--
-- Name: COLUMN stocking_purchase_orders.date_arrived; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.date_arrived IS 'Date the order arrived - note individual item arrival times tracked in stocking_purchase_order_products in case of multiple shipments';


--
-- Name: stocking_purchase_orders_stocking_purchase_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE stocking_purchase_orders_stocking_purchase_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stocking_purchase_orders_stocking_purchase_order_id_seq OWNER TO postgres;

--
-- Name: stocking_purchase_orders_stocking_purchase_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stocking_purchase_orders_stocking_purchase_order_id_seq OWNED BY stocking_purchase_orders.stocking_purchase_order_id;


--
-- Name: supplier_shipments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE supplier_shipments (
    supplier_shipment_id integer NOT NULL,
    shipment_id character varying(255) NOT NULL,
    stocking_purchase_order_id integer NOT NULL,
    supplier_id integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE supplier_shipments OWNER TO postgres;

--
-- Name: TABLE supplier_shipments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE supplier_shipments IS 'Represents many:many relationship between supplier shipment IDs and our SPOs';


--
-- Name: COLUMN supplier_shipments.supplier_shipment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.supplier_shipment_id IS 'Surrogate primary key';


--
-- Name: COLUMN supplier_shipments.shipment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.shipment_id IS 'Supplier-specified ID to a shipment of products';


--
-- Name: COLUMN supplier_shipments.stocking_purchase_order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.stocking_purchase_order_id IS 'Foreign key to stocking_purchase_orders';


--
-- Name: COLUMN supplier_shipments.supplier_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.supplier_id IS 'The supplier the shipment is tied to';


--
-- Name: supplier_shipments_supplier_shipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE supplier_shipments_supplier_shipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE supplier_shipments_supplier_shipment_id_seq OWNER TO postgres;

--
-- Name: supplier_shipments_supplier_shipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE supplier_shipments_supplier_shipment_id_seq OWNED BY supplier_shipments.supplier_shipment_id;


--
-- Name: associate_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY associates ALTER COLUMN associate_id SET DEFAULT nextval('associates_associate_id_seq'::regclass);


--
-- Name: inventory_error_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_errors ALTER COLUMN inventory_error_id SET DEFAULT nextval('inventory_errors_inventory_error_id_seq'::regclass);


--
-- Name: inventory_hold_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_holds ALTER COLUMN inventory_hold_id SET DEFAULT nextval('inventory_holds_inventory_hold_id_seq'::regclass);


--
-- Name: kiosk_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY kiosks ALTER COLUMN kiosk_id SET DEFAULT nextval('kiosks_kiosk_id_seq'::regclass);


--
-- Name: outbound_inventory_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY outbound_inventory ALTER COLUMN outbound_inventory_id SET DEFAULT nextval('outbound_inventory_outbound_inventory_id_seq'::regclass);


--
-- Name: pick_task_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pick_task_products ALTER COLUMN pick_task_product_id SET DEFAULT nextval('pick_task_products_pick_task_product_id_seq'::regclass);


--
-- Name: pick_task_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pick_tasks ALTER COLUMN pick_task_id SET DEFAULT nextval('pick_tasks_pick_task_id_seq'::regclass);


--
-- Name: pickup_location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pickup_locations ALTER COLUMN pickup_location_id SET DEFAULT nextval('pickup_locations_pickup_location_id_seq'::regclass);


--
-- Name: pickup_task_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pickup_task_products ALTER COLUMN pickup_task_product_id SET DEFAULT nextval('pickup_task_products_pickup_task_product_id_seq'::regclass);


--
-- Name: pickup_task_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pickup_tasks ALTER COLUMN pickup_task_id SET DEFAULT nextval('pickup_tasks_pickup_task_id_seq'::regclass);


--
-- Name: static_inventory_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY static_inventory ALTER COLUMN static_inventory_id SET DEFAULT nextval('static_inventory_static_inventory_id_seq'::regclass);


--
-- Name: stocking_purchase_order_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stocking_purchase_order_products ALTER COLUMN stocking_purchase_order_product_id SET DEFAULT nextval('stocking_purchase_order_produ_stocking_purchase_order_produ_seq'::regclass);


--
-- Name: stocking_purchase_order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stocking_purchase_orders ALTER COLUMN stocking_purchase_order_id SET DEFAULT nextval('stocking_purchase_orders_stocking_purchase_order_id_seq'::regclass);


--
-- Name: supplier_shipment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supplier_shipments ALTER COLUMN supplier_shipment_id SET DEFAULT nextval('supplier_shipments_supplier_shipment_id_seq'::regclass);


--
-- Name: associates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY associates
    ADD CONSTRAINT associates_pkey PRIMARY KEY (associate_id);


--
-- Name: customer_order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY customer_order_products
    ADD CONSTRAINT customer_order_products_pkey PRIMARY KEY (customer_order_product_id);


--
-- Name: customer_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY customer_orders
    ADD CONSTRAINT customer_orders_pkey PRIMARY KEY (customer_order_id);


--
-- Name: inventory_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventory_errors
    ADD CONSTRAINT inventory_errors_pkey PRIMARY KEY (inventory_error_id);


--
-- Name: inventory_holds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventory_holds
    ADD CONSTRAINT inventory_holds_pkey PRIMARY KEY (inventory_hold_id);


--
-- Name: kiosks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY kiosks
    ADD CONSTRAINT kiosks_pkey PRIMARY KEY (kiosk_id);


--
-- Name: outbound_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY outbound_inventory
    ADD CONSTRAINT outbound_inventory_pkey PRIMARY KEY (outbound_inventory_id);


--
-- Name: pick_container_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pick_container_locations
    ADD CONSTRAINT pick_container_locations_pkey PRIMARY KEY (pick_container_location_id);


--
-- Name: pick_containers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pick_containers
    ADD CONSTRAINT pick_containers_pkey PRIMARY KEY (pick_container_id);


--
-- Name: pick_task_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pick_task_products
    ADD CONSTRAINT pick_task_products_pkey PRIMARY KEY (pick_task_product_id);


--
-- Name: pick_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pick_tasks
    ADD CONSTRAINT pick_tasks_pkey PRIMARY KEY (pick_task_id);


--
-- Name: pickup_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pickup_locations
    ADD CONSTRAINT pickup_locations_pkey PRIMARY KEY (pickup_location_id);


--
-- Name: pickup_task_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pickup_task_products
    ADD CONSTRAINT pickup_task_products_pkey PRIMARY KEY (pickup_task_product_id);


--
-- Name: pickup_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pickup_tasks
    ADD CONSTRAINT pickup_tasks_pkey PRIMARY KEY (pickup_task_id);


--
-- Name: products_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey1 PRIMARY KEY (sku);


--
-- Name: products_suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products_suppliers
    ADD CONSTRAINT products_suppliers_pkey PRIMARY KEY (sku, supplier_id);


--
-- Name: receiving_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY receiving_locations
    ADD CONSTRAINT receiving_locations_pkey PRIMARY KEY (receiving_location_id);


--
-- Name: static_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY static_inventory
    ADD CONSTRAINT static_inventory_pkey PRIMARY KEY (static_inventory_id);


--
-- Name: stocking_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocking_locations
    ADD CONSTRAINT stocking_locations_pkey PRIMARY KEY (stocking_location_id);


--
-- Name: stocking_purchase_order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocking_purchase_order_products
    ADD CONSTRAINT stocking_purchase_order_products_pkey PRIMARY KEY (stocking_purchase_order_product_id);


--
-- Name: stocking_purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocking_purchase_orders
    ADD CONSTRAINT stocking_purchase_orders_pkey PRIMARY KEY (stocking_purchase_order_id);


--
-- Name: supplier_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supplier_shipments
    ADD CONSTRAINT supplier_shipments_pkey PRIMARY KEY (supplier_shipment_id);


--
-- Name: unique_hold_sku_location; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventory_holds
    ADD CONSTRAINT unique_hold_sku_location UNIQUE (static_inventory_id, customer_order_product_id);


--
-- Name: unique_opid_sku_container_location; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY outbound_inventory
    ADD CONSTRAINT unique_opid_sku_container_location UNIQUE (customer_order_product_id, sku, pick_container_id, stocking_location_id);


--
-- Name: unique_sn_spo; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supplier_shipments
    ADD CONSTRAINT unique_sn_spo UNIQUE (shipment_id, stocking_purchase_order_id);


--
-- Name: unique_spo_sku; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocking_purchase_order_products
    ADD CONSTRAINT unique_spo_sku UNIQUE (stocking_purchase_order_id, sku);


--
-- Name: associate_stations_associate_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX associate_stations_associate_id_idx ON associate_stations USING btree (associate_id);


--
-- Name: associate_stations_end_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX associate_stations_end_time_idx ON associate_stations USING btree (end_time) WHERE (end_time IS NULL);


--
-- Name: associate_stations_start_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX associate_stations_start_time_idx ON associate_stations USING btree (start_time);


--
-- Name: customer_order_products_customer_order_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX customer_order_products_customer_order_id_idx ON customer_order_products USING btree (customer_order_id);


--
-- Name: customer_order_products_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX customer_order_products_sku_idx ON customer_order_products USING btree (sku);


--
-- Name: customer_orders_status_scheduled_pickup_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX customer_orders_status_scheduled_pickup_idx ON customer_orders USING btree (status, scheduled_pickup) WHERE ((status <> 'Completed'::customer_order_status) AND (status <> 'Cancelled'::customer_order_status));


--
-- Name: customer_orders_submitted_at_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX customer_orders_submitted_at_idx ON customer_orders USING btree (submitted_at);


--
-- Name: inventory_errors_error_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_errors_error_date_idx ON inventory_errors USING btree (error_date);


--
-- Name: inventory_errors_outbound_inventory_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_errors_outbound_inventory_id_idx ON inventory_errors USING btree (outbound_inventory_id);


--
-- Name: inventory_errors_static_inventory_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_errors_static_inventory_id_idx ON inventory_errors USING btree (static_inventory_id);


--
-- Name: inventory_errors_stocking_purchase_order_product_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_errors_stocking_purchase_order_product_id_idx ON inventory_errors USING btree (stocking_purchase_order_product_id);


--
-- Name: inventory_holds_customer_order_product_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_holds_customer_order_product_id_idx ON inventory_holds USING btree (customer_order_product_id);


--
-- Name: outbound_inventory_pick_container_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX outbound_inventory_pick_container_id_idx ON outbound_inventory USING btree (pick_container_id);


--
-- Name: outbound_inventory_stocking_location_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX outbound_inventory_stocking_location_id_idx ON outbound_inventory USING btree (stocking_location_id);


--
-- Name: pick_containers_pick_container_location_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_containers_pick_container_location_id_idx ON pick_containers USING btree (pick_container_location_id);


--
-- Name: pick_task_products_customer_order_product_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_task_products_customer_order_product_id_idx ON pick_task_products USING btree (customer_order_product_id);


--
-- Name: pick_task_products_pick_task_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_task_products_pick_task_id_idx ON pick_task_products USING btree (pick_task_id);


--
-- Name: pick_tasks_customer_order_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_tasks_customer_order_id_idx ON pick_tasks USING btree (customer_order_id);


--
-- Name: pick_tasks_pick_container_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_tasks_pick_container_id_idx ON pick_tasks USING btree (pick_container_id);


--
-- Name: pick_tasks_status_order_promised_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_tasks_status_order_promised_time_idx ON pick_tasks USING btree (status, order_promised_time) WHERE (status <> 'Completed'::task_status);


--
-- Name: pickup_task_products_customer_order_product_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_task_products_customer_order_product_id_idx ON pickup_task_products USING btree (customer_order_product_id);


--
-- Name: pickup_task_products_pickup_task_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_task_products_pickup_task_id_idx ON pickup_task_products USING btree (pickup_task_id);


--
-- Name: pickup_tasks_associate_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_tasks_associate_id_idx ON pickup_tasks USING btree (associate_id);


--
-- Name: pickup_tasks_customer_checkin_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_tasks_customer_checkin_time_idx ON pickup_tasks USING btree (customer_checkin_time);


--
-- Name: pickup_tasks_customer_order_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_tasks_customer_order_id_idx ON pickup_tasks USING btree (customer_order_id);


--
-- Name: pickup_tasks_status_customer_checkin_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_tasks_status_customer_checkin_time_idx ON pickup_tasks USING btree (status, customer_checkin_time) WHERE (status <> 'Completed'::task_status);


--
-- Name: receiving_locations_temperature_zone_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX receiving_locations_temperature_zone_idx ON receiving_locations USING btree (temperature_zone) WHERE (supplier_shipment_id IS NOT NULL);


--
-- Name: static_inventory_expiration_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX static_inventory_expiration_date_idx ON static_inventory USING btree (expiration_date);


--
-- Name: static_inventory_last_updated_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX static_inventory_last_updated_idx ON static_inventory USING btree (last_updated);


--
-- Name: static_inventory_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX static_inventory_sku_idx ON static_inventory USING btree (sku);


--
-- Name: static_inventory_stocking_purchase_order_product_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX static_inventory_stocking_purchase_order_product_id_idx ON static_inventory USING btree (stocking_purchase_order_product_id);


--
-- Name: stocking_purchase_order_products_actual_arrival_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_actual_arrival_idx ON stocking_purchase_order_products USING btree (actual_arrival);


--
-- Name: stocking_purchase_order_products_expected_arrival_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_expected_arrival_idx ON stocking_purchase_order_products USING btree (expected_arrival);


--
-- Name: stocking_purchase_order_products_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_sku_idx ON stocking_purchase_order_products USING btree (sku);


--
-- Name: stocking_purchase_order_products_status_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_status_idx ON stocking_purchase_order_products USING btree (status) WHERE (status <> 'Stocked'::stocking_purchase_order_product_status);


--
-- Name: stocking_purchase_orders_date_arrived_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_orders_date_arrived_idx ON stocking_purchase_orders USING btree (date_arrived);


--
-- Name: stocking_purchase_orders_date_confirmed_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_orders_date_confirmed_idx ON stocking_purchase_orders USING btree (date_confirmed);


--
-- Name: stocking_purchase_orders_date_ordered_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_orders_date_ordered_idx ON stocking_purchase_orders USING btree (date_ordered);


--
-- Name: stocking_purchase_orders_date_shipped_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_orders_date_shipped_idx ON stocking_purchase_orders USING btree (date_shipped);


--
-- Name: supplier_shipments_shipment_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX supplier_shipments_shipment_id_idx ON supplier_shipments USING btree (shipment_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: products; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE products FROM PUBLIC;
REVOKE ALL ON TABLE products FROM postgres;
GRANT ALL ON TABLE products TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE products TO jp_readwrite;


--
-- Name: products_suppliers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE products_suppliers FROM PUBLIC;
REVOKE ALL ON TABLE products_suppliers FROM postgres;
GRANT ALL ON TABLE products_suppliers TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE products_suppliers TO jp_readwrite;


--
-- PostgreSQL database dump complete
--

