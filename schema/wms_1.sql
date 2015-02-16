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
-- Name: pick_task_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE pick_task_type AS ENUM (
    'Customer Order',
    'Return to Vendor',
    'Donation',
    'Promotion'
);


ALTER TYPE pick_task_type OWNER TO postgres;

--
-- Name: TYPE pick_task_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE pick_task_type IS 'Reasons for inventory to leave the warehouse:
Customer Order - purchased products
Return to Vendor - products we return to the vendor
Donation - products we donate
Promotion - products we give away for promotional/marketing purposes';


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
-- Name: receiving_location_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE receiving_location_type AS ENUM (
    'Pallet Receiving',
    'DSD Receiving Bay',
    'General Receiving Bay',
    'Exception Handling',
    'Return to Vendor'
);


ALTER TYPE receiving_location_type OWNER TO postgres;

--
-- Name: TYPE receiving_location_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE receiving_location_type IS 'Types of places where goods can be stored during receiving -
Pallet Receiving for entire pallets in any temperature zone
DSD Receiving Bay for direct store deliveries - no barcode, one per store
General Receiving Bay for sub-pallet deliveries, returns or emergency products (with barcodes)
Exception Handling - used for returns, uncollected orders and found products
Return to Vendor - locations within each temperature zone for unknown/unordered products to be returned to the vendor';


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
    'Produce Storage',
    'Stocking Cart'
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
    'Stocked',
    'Unfulfilled',
    'Unavailable',
    'Received - Qty Mismatch'
);


ALTER TYPE stocking_purchase_order_product_status OWNER TO postgres;

--
-- Name: TYPE stocking_purchase_order_product_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE stocking_purchase_order_product_status IS 'Possible states for SPO products. Should go from Ordered to Shipped to Stocked in the general case. Unfulfilled means the item was not in the shipment that arrived.';


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
    'Ready for Pickup',
    'Completed Pickup',
    'Cancelled'
);


ALTER TYPE task_status OWNER TO postgres;

--
-- Name: TYPE task_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE task_status IS 'States a pick/pickup task can be in:
Queued - not yet started
In Progress - currently being worked on
Paused - was in progress, but paused (i.e. due to emergency)
Completed - done
Cancelled - cancelled';


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
    ast_id integer NOT NULL,
    ast_as_id integer NOT NULL,
    ast_station_type station_type NOT NULL,
    ast_start_time timestamp with time zone NOT NULL,
    ast_end_time timestamp with time zone
);


ALTER TABLE associate_stations OWNER TO postgres;

--
-- Name: TABLE associate_stations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE associate_stations IS 'Current and historical stations associates are staffed to';


--
-- Name: COLUMN associate_stations.ast_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associate_stations.ast_id IS 'Surrogate primary key';


--
-- Name: COLUMN associate_stations.ast_as_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associate_stations.ast_as_id IS 'Foreign key to associates table';


--
-- Name: COLUMN associate_stations.ast_station_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associate_stations.ast_station_type IS 'The station they are staffed to';


--
-- Name: COLUMN associate_stations.ast_start_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associate_stations.ast_start_time IS 'When this employee started working at this station';


--
-- Name: COLUMN associate_stations.ast_end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associate_stations.ast_end_time IS 'When this employee finished working at this station';


--
-- Name: associate_stations_ast_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE associate_stations_ast_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE associate_stations_ast_id_seq OWNER TO postgres;

--
-- Name: associate_stations_ast_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE associate_stations_ast_id_seq OWNED BY associate_stations.ast_id;


--
-- Name: associates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE associates (
    as_id integer NOT NULL,
    as_first_name character varying(255) NOT NULL,
    as_last_name character varying(255) NOT NULL,
    as_login_pin character varying(6),
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE associates OWNER TO postgres;

--
-- Name: TABLE associates; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE associates IS 'Employees working at the store';


--
-- Name: COLUMN associates.as_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associates.as_id IS 'Unique identifier to the associate record';


--
-- Name: COLUMN associates.as_first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associates.as_first_name IS 'The associate''s first name';


--
-- Name: COLUMN associates.as_last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associates.as_last_name IS 'The associate''s last name';


--
-- Name: COLUMN associates.as_login_pin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN associates.as_login_pin IS 'PIN the associate uses to log in via app';


--
-- Name: associates_as_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE associates_as_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE associates_as_id_seq OWNER TO postgres;

--
-- Name: associates_as_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE associates_as_id_seq OWNED BY associates.as_id;


--
-- Name: customer_order_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE customer_order_products (
    cop_id integer NOT NULL,
    cop_cor_id integer NOT NULL,
    cop_pr_sku ean13 NOT NULL,
    cop_quantity integer NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE customer_order_products OWNER TO postgres;

--
-- Name: TABLE customer_order_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE customer_order_products IS 'Line items on customer orders';


--
-- Name: COLUMN customer_order_products.cop_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_order_products.cop_id IS 'Unique id generated on the web site';


--
-- Name: COLUMN customer_order_products.cop_cor_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_order_products.cop_cor_id IS 'Foreign key to customer_orders';


--
-- Name: COLUMN customer_order_products.cop_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_order_products.cop_pr_sku IS 'Foreign key to products';


--
-- Name: COLUMN customer_order_products.cop_quantity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_order_products.cop_quantity IS 'Quantity ordered';


--
-- Name: customer_orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE customer_orders (
    cor_id integer NOT NULL,
    cor_cu_id integer NOT NULL,
    cor_status customer_order_status NOT NULL,
    cor_first_name character varying(255),
    cor_last_name character varying(255),
    cor_email character varying(255),
    cor_phone character varying(30),
    cor_notification_type notification_type,
    cor_submitted_at timestamp with time zone,
    cor_scheduled_pickup timestamp with time zone,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE customer_orders OWNER TO postgres;

--
-- Name: TABLE customer_orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE customer_orders IS 'Orders received from customers';


--
-- Name: COLUMN customer_orders.cor_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_id IS 'Unique id generated on the web site';


--
-- Name: COLUMN customer_orders.cor_cu_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_cu_id IS 'Foreign key to the customers table';


--
-- Name: COLUMN customer_orders.cor_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_status IS 'Current status of this customer order';


--
-- Name: COLUMN customer_orders.cor_first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_first_name IS 'Customer first name';


--
-- Name: COLUMN customer_orders.cor_last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_last_name IS 'Customer last name';


--
-- Name: COLUMN customer_orders.cor_email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_email IS 'Customer email address';


--
-- Name: COLUMN customer_orders.cor_phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_phone IS 'Customer phone number';


--
-- Name: COLUMN customer_orders.cor_notification_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_notification_type IS 'How the customer wants to receive order status notifications (text, email, push)';


--
-- Name: COLUMN customer_orders.cor_submitted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_submitted_at IS 'Date the order was submitted on the web site';


--
-- Name: COLUMN customer_orders.cor_scheduled_pickup; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN customer_orders.cor_scheduled_pickup IS 'Scheduled pickup date';


--
-- Name: inventory_errors; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventory_errors (
    ier_id integer NOT NULL,
    ier_as_id integer NOT NULL,
    ier_pr_sku ean13 NOT NULL,
    ier_si_id integer,
    ier_spop_id integer,
    ier_ptp_id integer,
    ier_stl_id integer,
    ier_qty_adjustment integer,
    ier_notes text,
    ier_error_date timestamp with time zone,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE inventory_errors OWNER TO postgres;

--
-- Name: TABLE inventory_errors; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE inventory_errors IS 'A place to log any inventory errors or adjustments to inventory';


--
-- Name: COLUMN inventory_errors.ier_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_id IS 'Surrogate primary key';


--
-- Name: COLUMN inventory_errors.ier_as_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_as_id IS 'The person logging the error';


--
-- Name: COLUMN inventory_errors.ier_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_pr_sku IS 'The sku the error pertains to';


--
-- Name: COLUMN inventory_errors.ier_si_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_si_id IS 'The static_inventory record this pertains to, if applicable';


--
-- Name: COLUMN inventory_errors.ier_spop_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_spop_id IS 'The stocking_purchase_order_products record this pertains to, if applicable';


--
-- Name: COLUMN inventory_errors.ier_ptp_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_ptp_id IS 'The pick_task_product record this pertains to, if applicable';


--
-- Name: COLUMN inventory_errors.ier_stl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_stl_id IS 'The stocking_location record this pertains to, if applicable';


--
-- Name: COLUMN inventory_errors.ier_qty_adjustment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_qty_adjustment IS 'Amount adjusted (negative if removed qty, positive if added)';


--
-- Name: COLUMN inventory_errors.ier_notes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_notes IS 'Associate-entered description of what happened';


--
-- Name: COLUMN inventory_errors.ier_error_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_errors.ier_error_date IS 'Date when the error was logged';


--
-- Name: inventory_errors_ier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventory_errors_ier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE inventory_errors_ier_id_seq OWNER TO postgres;

--
-- Name: inventory_errors_ier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventory_errors_ier_id_seq OWNED BY inventory_errors.ier_id;


--
-- Name: inventory_holds; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventory_holds (
    ihd_id integer NOT NULL,
    ihd_si_id integer NOT NULL,
    ihd_cop_id integer NOT NULL,
    ihd_qty integer NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE inventory_holds OWNER TO postgres;

--
-- Name: TABLE inventory_holds; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE inventory_holds IS 'Products that are on hold for unprocessed orders (tied to static_inventory)';


--
-- Name: COLUMN inventory_holds.ihd_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_holds.ihd_id IS 'Surrogate primary key';


--
-- Name: COLUMN inventory_holds.ihd_si_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_holds.ihd_si_id IS 'Foreign key to static_inventory table';


--
-- Name: COLUMN inventory_holds.ihd_cop_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_holds.ihd_cop_id IS 'Foreign key to inventory_holds table';


--
-- Name: COLUMN inventory_holds.ihd_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_holds.ihd_qty IS 'Quantity held by this hold';


--
-- Name: inventory_holds_ihd_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventory_holds_ihd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE inventory_holds_ihd_id_seq OWNER TO postgres;

--
-- Name: inventory_holds_ihd_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventory_holds_ihd_id_seq OWNED BY inventory_holds.ihd_id;


--
-- Name: kiosks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE kiosks (
    kio_id integer NOT NULL,
    kio_preferred_pickup_locations integer[],
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE kiosks OWNER TO postgres;

--
-- Name: TABLE kiosks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE kiosks IS 'Outdoor kiosks customers use to check in.';


--
-- Name: COLUMN kiosks.kio_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN kiosks.kio_id IS 'Unique identifier to the kiosk';


--
-- Name: COLUMN kiosks.kio_preferred_pickup_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN kiosks.kio_preferred_pickup_locations IS 'Ordered array of preferred pickup_location_ids';


--
-- Name: kiosks_kio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE kiosks_kio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kiosks_kio_id_seq OWNER TO postgres;

--
-- Name: kiosks_kio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE kiosks_kio_id_seq OWNED BY kiosks.kio_id;


--
-- Name: pick_container_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pick_container_locations (
    pcl_id ean13 NOT NULL,
    pcl_type pick_container_location_type NOT NULL,
    pcl_temperature_zone temperature_zone,
    pcl_aisle integer NOT NULL,
    pcl_bay integer NOT NULL,
    pcl_shelf integer DEFAULT 1 NOT NULL,
    pcl_shelf_slot integer DEFAULT 1 NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pick_container_locations OWNER TO postgres;

--
-- Name: TABLE pick_container_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pick_container_locations IS 'Locations that pick_containers can be stored in';


--
-- Name: COLUMN pick_container_locations.pcl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pcl_id IS 'Unique barcode on each pick container';


--
-- Name: COLUMN pick_container_locations.pcl_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pcl_type IS 'The type of location - i.e. finished goods buffer vs. pick cart parking';


--
-- Name: COLUMN pick_container_locations.pcl_temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pcl_temperature_zone IS 'The temperature zone the location is to be used in';


--
-- Name: COLUMN pick_container_locations.pcl_aisle; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pcl_aisle IS 'Aisle number within a temperature zone (visible within store to associates)';


--
-- Name: COLUMN pick_container_locations.pcl_bay; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pcl_bay IS 'Shelving bay within an aisle';


--
-- Name: COLUMN pick_container_locations.pcl_shelf; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pcl_shelf IS 'Shelf number within a shelving bay (counting from bottom, starting at 1)';


--
-- Name: COLUMN pick_container_locations.pcl_shelf_slot; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_container_locations.pcl_shelf_slot IS 'Slot within a shelf (counting from left, starting at 1)';


--
-- Name: pick_containers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pick_containers (
    pc_id ean13 NOT NULL,
    pc_pcl_id ean13,
    pc_temperature_zone temperature_zone NOT NULL,
    pc_type pick_container_type NOT NULL,
    pc_height double precision,
    pc_width double precision NOT NULL,
    pc_depth double precision NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pick_containers OWNER TO postgres;

--
-- Name: TABLE pick_containers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pick_containers IS 'Containers for products used during picking';


--
-- Name: COLUMN pick_containers.pc_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pc_id IS 'Unique barcode on each pick container';


--
-- Name: COLUMN pick_containers.pc_pcl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pc_pcl_id IS 'Foreign key to pick_container_locations - current location this is stored in, if any';


--
-- Name: COLUMN pick_containers.pc_temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pc_temperature_zone IS 'The temperature zone the container is to be used in';


--
-- Name: COLUMN pick_containers.pc_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pc_type IS 'The type of pick container, such as pick cart or bin';


--
-- Name: COLUMN pick_containers.pc_height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pc_height IS 'Height of the container in inches (null for carts which are flat)';


--
-- Name: COLUMN pick_containers.pc_width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pc_width IS 'Width of the container in inches';


--
-- Name: COLUMN pick_containers.pc_depth; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_containers.pc_depth IS 'Depth of the container in inches';


--
-- Name: pick_task_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pick_task_products (
    ptp_id integer NOT NULL,
    ptp_pt_id integer NOT NULL,
    ptp_cop_id integer,
    ptp_pr_sku ean13 NOT NULL,
    ptp_pc_id ean13,
    ptp_stl_id ean13 NOT NULL,
    ptp_si_id integer NOT NULL,
    ptp_status task_status NOT NULL,
    ptp_allocated_qty integer NOT NULL,
    ptp_fulfilled_qty integer,
    ptp_ma_id integer NOT NULL,
    ptp_pick_order integer,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pick_task_products OWNER TO postgres;

--
-- Name: TABLE pick_task_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pick_task_products IS 'Tracks products to be picked as split into pick tasks';


--
-- Name: COLUMN pick_task_products.ptp_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_id IS 'Surrogate primary key';


--
-- Name: COLUMN pick_task_products.ptp_pt_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_pt_id IS 'Foreign key to pick_tasks - the task this is tied to';


--
-- Name: COLUMN pick_task_products.ptp_cop_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_cop_id IS 'Foreign key to customer_order_products - null if not picking for an order';


--
-- Name: COLUMN pick_task_products.ptp_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_pr_sku IS 'Foreign key to products table';


--
-- Name: COLUMN pick_task_products.ptp_pc_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_pc_id IS 'Foreign key to pick_containers - container the product is currently on.';


--
-- Name: COLUMN pick_task_products.ptp_stl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_stl_id IS 'Foreign key to stocking_locations - the location the product came from';


--
-- Name: COLUMN pick_task_products.ptp_si_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_si_id IS 'Foreign key to static_inventory_id - the static inventory record the product came from';


--
-- Name: COLUMN pick_task_products.ptp_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_status IS 'Current status of this product, i.e. queued/in progress/complete';


--
-- Name: COLUMN pick_task_products.ptp_allocated_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_allocated_qty IS 'Quantity of this product stored in this finished goods location';


--
-- Name: COLUMN pick_task_products.ptp_fulfilled_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_fulfilled_qty IS 'Quantity of this product able to be fulfilled - if not same as allocated, this is an exception';


--
-- Name: COLUMN pick_task_products.ptp_ma_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_ma_id IS 'Foreign key to manufacturers - used to display image';


--
-- Name: COLUMN pick_task_products.ptp_pick_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_task_products.ptp_pick_order IS 'Calculated pick order relative to other products on the pick task';


--
-- Name: pick_task_products_ptp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pick_task_products_ptp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pick_task_products_ptp_id_seq OWNER TO postgres;

--
-- Name: pick_task_products_ptp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pick_task_products_ptp_id_seq OWNED BY pick_task_products.ptp_id;


--
-- Name: pick_tasks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pick_tasks (
    pt_id integer NOT NULL,
    pt_as_id integer,
    pt_type pick_task_type NOT NULL,
    pt_status task_status NOT NULL,
    pt_temperature_zone temperature_zone NOT NULL,
    pt_order_promised_time timestamp with time zone,
    pt_est_duration integer,
    pt_start_time timestamp with time zone,
    pt_end_time timestamp with time zone,
    pt_bin_qty_est integer NOT NULL,
    pt_bin_size_est double precision,
    pt_multi_order boolean DEFAULT false NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pick_tasks OWNER TO postgres;

--
-- Name: TABLE pick_tasks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pick_tasks IS 'Represents work assigned to one associate in one temperature zone for one or more orders';


--
-- Name: COLUMN pick_tasks.pt_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_id IS 'Unique identifier to the pick task';


--
-- Name: COLUMN pick_tasks.pt_as_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_as_id IS 'Foreign key to associates - person assigned to the task';


--
-- Name: COLUMN pick_tasks.pt_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_type IS 'Reason why the inventory is outbound (i.e. customer order vs donation)';


--
-- Name: COLUMN pick_tasks.pt_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_status IS 'Current status of this pick task, i.e. queued/in progress/complete';


--
-- Name: COLUMN pick_tasks.pt_temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_temperature_zone IS 'Temperature zone the pick task takes place in';


--
-- Name: COLUMN pick_tasks.pt_order_promised_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_order_promised_time IS 'Time by which the pick task must be completed (earliest order promised time)';


--
-- Name: COLUMN pick_tasks.pt_est_duration; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_est_duration IS 'Duration estimate, if applicable';


--
-- Name: COLUMN pick_tasks.pt_start_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_start_time IS 'When the task was started';


--
-- Name: COLUMN pick_tasks.pt_end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_end_time IS 'When the task was completed';


--
-- Name: COLUMN pick_tasks.pt_bin_qty_est; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_bin_qty_est IS 'Estimated number of bins required on the pick cart based on product sizes';


--
-- Name: COLUMN pick_tasks.pt_bin_size_est; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_bin_size_est IS 'Estimated bin size in cubic volume (relevant only if using just one bin, otherwise use largest bins)';


--
-- Name: COLUMN pick_tasks.pt_multi_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pick_tasks.pt_multi_order IS 'Does this task contain products from multiple orders?';


--
-- Name: pick_tasks_pt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pick_tasks_pt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pick_tasks_pt_id_seq OWNER TO postgres;

--
-- Name: pick_tasks_pt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pick_tasks_pt_id_seq OWNED BY pick_tasks.pt_id;


--
-- Name: pickup_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pickup_locations (
    pul_id integer NOT NULL,
    pul_type pickup_location_type NOT NULL,
    pul_display_name character varying(50) NOT NULL,
    pul_current_cars integer NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pickup_locations OWNER TO postgres;

--
-- Name: TABLE pickup_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pickup_locations IS 'Places customers will be waiting when picking up their orders';


--
-- Name: COLUMN pickup_locations.pul_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_locations.pul_id IS 'Unique identifier to the location';


--
-- Name: COLUMN pickup_locations.pul_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_locations.pul_type IS 'Type of location - parking spot or indoor';


--
-- Name: COLUMN pickup_locations.pul_display_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_locations.pul_display_name IS 'Name shown to associates in app for the location';


--
-- Name: COLUMN pickup_locations.pul_current_cars; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_locations.pul_current_cars IS 'Current number of cars in the location (always 0 for indoor)';


--
-- Name: pickup_locations_pul_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pickup_locations_pul_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pickup_locations_pul_id_seq OWNER TO postgres;

--
-- Name: pickup_locations_pul_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pickup_locations_pul_id_seq OWNED BY pickup_locations.pul_id;


--
-- Name: pickup_sub_tasks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pickup_sub_tasks (
    pst_id integer NOT NULL,
    pst_temperature_zone temperature_zone NOT NULL,
    pst_put_id integer NOT NULL,
    pst_pcl_id ean13 NOT NULL,
    pst_pt_id integer NOT NULL,
    pst_status task_status NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pickup_sub_tasks OWNER TO postgres;

--
-- Name: TABLE pickup_sub_tasks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pickup_sub_tasks IS 'Sub tasks that make up a pickup task - represents one finished goods location in one temperature zone as part of pickup';


--
-- Name: COLUMN pickup_sub_tasks.pst_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_sub_tasks.pst_id IS 'Surrogate primary key';


--
-- Name: COLUMN pickup_sub_tasks.pst_temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_sub_tasks.pst_temperature_zone IS 'Temperature zone where the subtask takes place';


--
-- Name: COLUMN pickup_sub_tasks.pst_put_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_sub_tasks.pst_put_id IS 'Foreign key to pickup_tasks - the pickup task this is part of';


--
-- Name: COLUMN pickup_sub_tasks.pst_pcl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_sub_tasks.pst_pcl_id IS 'Foreign key to pick_container_locations - the finished goods location containing products for this task';


--
-- Name: COLUMN pickup_sub_tasks.pst_pt_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_sub_tasks.pst_pt_id IS 'Foreign key to pick_tasks - the pick task that preceded this';


--
-- Name: COLUMN pickup_sub_tasks.pst_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_sub_tasks.pst_status IS 'Current status of this subtask, i.e. queued/in progress/complete';


--
-- Name: pickup_sub_tasks_pst_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pickup_sub_tasks_pst_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pickup_sub_tasks_pst_id_seq OWNER TO postgres;

--
-- Name: pickup_sub_tasks_pst_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pickup_sub_tasks_pst_id_seq OWNED BY pickup_sub_tasks.pst_id;


--
-- Name: pickup_tasks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pickup_tasks (
    put_id integer NOT NULL,
    put_cor_id integer NOT NULL,
    put_pul_id integer NOT NULL,
    put_as_id integer,
    put_status task_status NOT NULL,
    put_customer_checkin_time timestamp with time zone NOT NULL,
    put_start_time timestamp with time zone,
    put_end_time timestamp with time zone,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pickup_tasks OWNER TO postgres;

--
-- Name: TABLE pickup_tasks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE pickup_tasks IS 'Group of products that one associate gathers as part (or all) of a customer order across multiple temperature zones';


--
-- Name: COLUMN pickup_tasks.put_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.put_id IS 'Surrogate primary key';


--
-- Name: COLUMN pickup_tasks.put_cor_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.put_cor_id IS 'Foreign key to customer_orders';


--
-- Name: COLUMN pickup_tasks.put_pul_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.put_pul_id IS 'Location where the customer is waiting for pickup';


--
-- Name: COLUMN pickup_tasks.put_as_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.put_as_id IS 'Associate assigned to the pickup task';


--
-- Name: COLUMN pickup_tasks.put_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.put_status IS 'Current status of this pickup task, i.e. queued/in progress/complete';


--
-- Name: COLUMN pickup_tasks.put_customer_checkin_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.put_customer_checkin_time IS 'Time when the customer checked in as awaiting pickup';


--
-- Name: COLUMN pickup_tasks.put_start_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.put_start_time IS 'When the task was started';


--
-- Name: COLUMN pickup_tasks.put_end_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN pickup_tasks.put_end_time IS 'When the task was completed';


--
-- Name: pickup_tasks_put_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pickup_tasks_put_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pickup_tasks_put_id_seq OWNER TO postgres;

--
-- Name: pickup_tasks_put_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pickup_tasks_put_id_seq OWNED BY pickup_tasks.put_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products (
    pr_sku ean13 NOT NULL,
    pr_sku_is_real_upc boolean NOT NULL,
    pr_status product_status NOT NULL,
    pr_default_img_id integer,
    pr_case_upc ean13,
    pr_units_per_case smallint,
    pr_measurement_unit measurement_unit,
    pr_measurement_value integer,
    pr_upc_commodity integer,
    pr_upc_vendor integer,
    pr_upc_case integer,
    pr_upc_item integer,
    pr_length double precision,
    pr_width double precision,
    pr_height double precision,
    pr_cubic_volume double precision,
    pr_weight double precision,
    pr_gtin character varying(14),
    pr_temperature_zone temperature_zone,
    pr_ma_id integer,
    pr_cat_id integer,
    pr_description text,
    pr_shelf_life_days integer,
    pr_qc_check_interval_days integer,
    pr_bnd_id integer,
    pr_name character varying(255),
    pr_pfl_id integer,
    pr_case_length double precision,
    pr_case_width double precision,
    pr_case_height double precision,
    pr_case_weight double precision,
    pr_expiration_class expiration_class,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE products OWNER TO postgres;

--
-- Name: TABLE products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE products IS 'Information about a product that is size-specific, such as UPC, measurements and prices. Must be tied to a product_id for base product information even if there is only one size.';


--
-- Name: COLUMN products.pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_sku IS 'Unique sku to a product - stored as ean13. All UPCs will have 0 for leading digit, our internally generated ones will have 2 as a leading digit';


--
-- Name: COLUMN products.pr_sku_is_real_upc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_sku_is_real_upc IS 'True if the item has a barcode on it and our sku is an actual UPC.';


--
-- Name: COLUMN products.pr_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_status IS 'Whether the product can be displayed and sold on site';


--
-- Name: COLUMN products.pr_default_img_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_default_img_id IS 'Default image to be displayed on browse and product pages';


--
-- Name: COLUMN products.pr_case_upc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_case_upc IS 'The UPC of the case the item comes in, if applicable';


--
-- Name: COLUMN products.pr_units_per_case; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_units_per_case IS 'The quantity of this item contained in the case_upc';


--
-- Name: COLUMN products.pr_measurement_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_measurement_unit IS 'The unit of measure for this product if applicable';


--
-- Name: COLUMN products.pr_measurement_value; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_measurement_value IS 'The value in units of measurement_unit';


--
-- Name: COLUMN products.pr_upc_commodity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_upc_commodity IS 'This data comes from C&S and we may not need it. Drop?';


--
-- Name: COLUMN products.pr_upc_vendor; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_upc_vendor IS 'This data comes from C&S and we may not need it. Drop?';


--
-- Name: COLUMN products.pr_upc_case; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_upc_case IS 'This data comes from C&S and we may not need it. Drop?';


--
-- Name: COLUMN products.pr_upc_item; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_upc_item IS 'This data comes from C&S and we may not need it. Drop?';


--
-- Name: COLUMN products.pr_length; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_length IS 'The length of the product in inches in packaging as stored in the warehouse';


--
-- Name: COLUMN products.pr_width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_width IS 'The width of the product in inches in packaging as stored in the warehouse';


--
-- Name: COLUMN products.pr_height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_height IS 'The height of the product in inches in packaging as stored in the warehouse';


--
-- Name: COLUMN products.pr_cubic_volume; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_cubic_volume IS 'The length*width*depth. This is redundant. Drop?';


--
-- Name: COLUMN products.pr_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_weight IS 'The weight of the product in packaging in lbs';


--
-- Name: COLUMN products.pr_gtin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_gtin IS 'Global Trade Item Number';


--
-- Name: COLUMN products.pr_temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_temperature_zone IS 'Temperature zone where the product is stored in the warehouse';


--
-- Name: COLUMN products.pr_ma_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_ma_id IS 'The manufacturer that produces the product';


--
-- Name: COLUMN products.pr_cat_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_cat_id IS 'The category the product is tied to for revenue allocation and merchandising purposes';


--
-- Name: COLUMN products.pr_description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_description IS 'The detailed product description as displayed to customers on site';


--
-- Name: COLUMN products.pr_shelf_life_days; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_shelf_life_days IS 'Estimated shelf life in days after a product is received. We will need to populate this based on our experience if we can''t get data from the manufacturer.';


--
-- Name: COLUMN products.pr_qc_check_interval_days; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_qc_check_interval_days IS 'Frequency at which we should check quality on a product, especially produce';


--
-- Name: COLUMN products.pr_bnd_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_bnd_id IS 'Foreign key to brand.id';


--
-- Name: COLUMN products.pr_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_name IS 'Product name as shown to customers on site';


--
-- Name: COLUMN products.pr_pfl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_pfl_id IS 'Foreign key to product_families table if the product is part of a family.';


--
-- Name: COLUMN products.pr_case_length; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_case_length IS 'Length of the case in inches';


--
-- Name: COLUMN products.pr_case_width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_case_width IS 'Width of the case in inches';


--
-- Name: COLUMN products.pr_case_height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_case_height IS 'Height of the case in inches';


--
-- Name: COLUMN products.pr_case_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_case_weight IS 'Weight of the case in pounds';


--
-- Name: COLUMN products.pr_expiration_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.pr_expiration_class IS 'Level of rigor needed in checking expirations - based on shelf life';


--
-- Name: receiving_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE receiving_locations (
    rcl_id ean13 NOT NULL,
    rcl_type receiving_location_type NOT NULL,
    rcl_temperature_zone temperature_zone NOT NULL,
    rcl_shi_shipment_code integer,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE receiving_locations OWNER TO postgres;

--
-- Name: TABLE receiving_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE receiving_locations IS 'Locations where goods can be stored during receiving. A location is empty if stocking_purchase_order_id is null, and non-empty otherwise.';


--
-- Name: COLUMN receiving_locations.rcl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN receiving_locations.rcl_id IS 'Barcode identifier for the location (or just the word DSD Bay for the singleton DSD bay)';


--
-- Name: COLUMN receiving_locations.rcl_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN receiving_locations.rcl_type IS 'receiving_location_type which denotes whether the location is for pallet deliveries, sub-pallet, exception, DSDs, etc.';


--
-- Name: COLUMN receiving_locations.rcl_temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN receiving_locations.rcl_temperature_zone IS 'Temperature zone the receiving location is located in';


--
-- Name: COLUMN receiving_locations.rcl_shi_shipment_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN receiving_locations.rcl_shi_shipment_code IS 'Current supplier shipment in this location, if the location is not empty - if -1, location is nonempty but contains unknown shipment';


--
-- Name: static_inventory; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE static_inventory (
    si_id integer NOT NULL,
    si_stl_id ean13 NOT NULL,
    si_pr_sku ean13 NOT NULL,
    si_spop_id integer NOT NULL,
    si_ma_id integer NOT NULL,
    si_expiration_class expiration_class,
    si_expiration_date timestamp with time zone,
    si_total_qty integer NOT NULL,
    si_available_qty integer NOT NULL,
    si_qty_on_hand integer NOT NULL,
    si_arrival_date timestamp with time zone,
    si_emptied_date timestamp with time zone,
    si_product_name character varying(255),
    si_product_length double precision,
    si_product_width double precision,
    si_product_height double precision,
    si_product_weight double precision,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE static_inventory OWNER TO postgres;

--
-- Name: TABLE static_inventory; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE static_inventory IS 'Representation of inventory on hand in the warehouse.';


--
-- Name: COLUMN static_inventory.si_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_id IS 'Surrogate primary key';


--
-- Name: COLUMN static_inventory.si_stl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_stl_id IS 'Storage slot for the inventory. Foreign key to stocking_locations';


--
-- Name: COLUMN static_inventory.si_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_pr_sku IS 'Foreign key to products - the product stored in this slot';


--
-- Name: COLUMN static_inventory.si_spop_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_spop_id IS 'Foreign key to stocking_purchase_order_products - denotes where the product came from';


--
-- Name: COLUMN static_inventory.si_ma_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_ma_id IS 'Manufacturer ID (used to pull and display images in pick app)';


--
-- Name: COLUMN static_inventory.si_expiration_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_expiration_class IS 'Indicates level of rigor required around expiration date checking';


--
-- Name: COLUMN static_inventory.si_expiration_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_expiration_date IS 'Date the items in this slot will expire. Should be recorded at time of receipt (and estimated if not provided on packaging)';


--
-- Name: COLUMN static_inventory.si_total_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_total_qty IS 'The total quantity of product when the slot was first stocked';


--
-- Name: COLUMN static_inventory.si_available_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_available_qty IS 'Currently available quantity for purchase (total less sold products)';


--
-- Name: COLUMN static_inventory.si_qty_on_hand; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_qty_on_hand IS 'Current quantity in the actual storage slot in the warehouse';


--
-- Name: COLUMN static_inventory.si_arrival_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_arrival_date IS 'Date the slot was stocked';


--
-- Name: COLUMN static_inventory.si_emptied_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_emptied_date IS 'Date the slot was emptied - if not null this means the slot is free';


--
-- Name: COLUMN static_inventory.si_product_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_product_name IS 'Display name of the product';


--
-- Name: COLUMN static_inventory.si_product_length; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_product_length IS 'Length of a single product in inches';


--
-- Name: COLUMN static_inventory.si_product_width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_product_width IS 'Width of a single product in inches';


--
-- Name: COLUMN static_inventory.si_product_height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_product_height IS 'Height of a single product in inches';


--
-- Name: COLUMN static_inventory.si_product_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN static_inventory.si_product_weight IS 'Weight of a single product in pounds';


--
-- Name: static_inventory_si_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE static_inventory_si_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE static_inventory_si_id_seq OWNER TO postgres;

--
-- Name: static_inventory_si_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE static_inventory_si_id_seq OWNED BY static_inventory.si_id;


--
-- Name: stocking_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stocking_locations (
    stl_id ean13 NOT NULL,
    stl_temperature_zone temperature_zone NOT NULL,
    stl_type stocking_location_type NOT NULL,
    stl_pick_segment integer NOT NULL,
    stl_aisle integer NOT NULL,
    stl_bay integer NOT NULL,
    stl_shelf integer DEFAULT 1 NOT NULL,
    stl_shelf_slot integer DEFAULT 1 NOT NULL,
    stl_height double precision,
    stl_width double precision,
    stl_depth double precision,
    stl_assigned_sku ean13,
    stl_needs_qc boolean DEFAULT false NOT NULL,
    stl_last_qc_date timestamp with time zone,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE stocking_locations OWNER TO postgres;

--
-- Name: TABLE stocking_locations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE stocking_locations IS 'Represents locations that items are stored for picking, pallets or on shelves.
Associates will most often refer to a storage slot by its "location_code", which is computed
as {temperature_zone}-{aisle}-{bay}-{shelf}-{shelf_slot}, with zeroes for the last 3 elements if not on shelving.';


--
-- Name: COLUMN stocking_locations.stl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_id IS 'Barcode identifier to a storage slot';


--
-- Name: COLUMN stocking_locations.stl_temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_temperature_zone IS 'Temperature zone the storage slot is located in';


--
-- Name: COLUMN stocking_locations.stl_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_type IS 'The type of stocking location such as pallet or shelf storage';


--
-- Name: COLUMN stocking_locations.stl_pick_segment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_pick_segment IS 'Numerical pick segment the slot is part of';


--
-- Name: COLUMN stocking_locations.stl_aisle; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_aisle IS 'Aisle number within a temperature zone (visible within store to associates)';


--
-- Name: COLUMN stocking_locations.stl_bay; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_bay IS 'Shelving bay within an aisle';


--
-- Name: COLUMN stocking_locations.stl_shelf; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_shelf IS 'Shelf number within a shelving bay (counting from bottom, starting at 1)';


--
-- Name: COLUMN stocking_locations.stl_shelf_slot; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_shelf_slot IS 'Slot within a shelf (counting from left, starting at 1)';


--
-- Name: COLUMN stocking_locations.stl_height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_height IS 'Height in inches of the slot';


--
-- Name: COLUMN stocking_locations.stl_width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_width IS 'Width in inches of the slot';


--
-- Name: COLUMN stocking_locations.stl_depth; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_depth IS 'Depth in inches of the slot';


--
-- Name: COLUMN stocking_locations.stl_assigned_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_assigned_sku IS 'sku that should be placed in this slot (only for directed put-away, i.e. produce)';


--
-- Name: COLUMN stocking_locations.stl_needs_qc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_needs_qc IS 'Whether this location is flagged for needing qc';


--
-- Name: COLUMN stocking_locations.stl_last_qc_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_locations.stl_last_qc_date IS 'Last time this location was manually checked';


--
-- Name: stocking_purchase_order_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stocking_purchase_order_products (
    spop_id integer NOT NULL,
    spop_spo_id integer NOT NULL,
    spop_pr_sku ean13 NOT NULL,
    spop_rcl_id ean13,
    spop_status stocking_purchase_order_product_status NOT NULL,
    spop_requested_qty integer NOT NULL,
    spop_confirmed_qty integer,
    spop_received_qty integer,
    spop_case_upc ean13,
    spop_units_per_case integer,
    spop_requested_case_qty integer,
    spop_confirmed_case_qty integer,
    spop_received_case_qty integer,
    spop_case_length double precision,
    spop_case_width double precision,
    spop_case_height double precision,
    spop_case_weight double precision,
    spop_expected_arrival timestamp with time zone,
    spop_actual_arrival timestamp with time zone,
    spop_wholesale_cost integer,
    spop_expiration_class expiration_class,
    spop_ma_id integer NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE stocking_purchase_order_products OWNER TO postgres;

--
-- Name: TABLE stocking_purchase_order_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE stocking_purchase_order_products IS 'Products requested on stocking purchase orders. This tracks products from purchasing up through receiving.';


--
-- Name: COLUMN stocking_purchase_order_products.spop_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_id IS 'Surrogate key to uniquely identify a row';


--
-- Name: COLUMN stocking_purchase_order_products.spop_spo_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_spo_id IS 'Foreign key to stocking_purchase_orders';


--
-- Name: COLUMN stocking_purchase_order_products.spop_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_pr_sku IS 'Foreign key to products';


--
-- Name: COLUMN stocking_purchase_order_products.spop_rcl_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_rcl_id IS 'Foreign key to receiving_locations - location the product is/was in when received and waiting to be stocked';


--
-- Name: COLUMN stocking_purchase_order_products.spop_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_status IS 'Current state of this product on this order';


--
-- Name: COLUMN stocking_purchase_order_products.spop_requested_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_requested_qty IS 'Quantity requested to the supplier';


--
-- Name: COLUMN stocking_purchase_order_products.spop_confirmed_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_confirmed_qty IS 'Quantity the supplier confirmed they can send us';


--
-- Name: COLUMN stocking_purchase_order_products.spop_received_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_received_qty IS 'Actual quantity of this product that we received on this purchase order';


--
-- Name: COLUMN stocking_purchase_order_products.spop_case_upc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_case_upc IS 'Barcode on the case of products if shipped by case';


--
-- Name: COLUMN stocking_purchase_order_products.spop_units_per_case; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_units_per_case IS 'Quantity of products per case';


--
-- Name: COLUMN stocking_purchase_order_products.spop_requested_case_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_requested_case_qty IS 'Number of cases requested';


--
-- Name: COLUMN stocking_purchase_order_products.spop_confirmed_case_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_confirmed_case_qty IS 'Number of cases confirmed';


--
-- Name: COLUMN stocking_purchase_order_products.spop_received_case_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_received_case_qty IS 'Number of cases received';


--
-- Name: COLUMN stocking_purchase_order_products.spop_case_length; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_case_length IS 'Length of the case in inches';


--
-- Name: COLUMN stocking_purchase_order_products.spop_case_width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_case_width IS 'Width of the case in inches';


--
-- Name: COLUMN stocking_purchase_order_products.spop_case_height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_case_height IS 'Height of the case in inches';


--
-- Name: COLUMN stocking_purchase_order_products.spop_case_weight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_case_weight IS 'Weight of the case in pounds';


--
-- Name: COLUMN stocking_purchase_order_products.spop_expected_arrival; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_expected_arrival IS 'Expected arrival date of this product';


--
-- Name: COLUMN stocking_purchase_order_products.spop_actual_arrival; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_actual_arrival IS 'Actual arrival date of this product';


--
-- Name: COLUMN stocking_purchase_order_products.spop_wholesale_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_wholesale_cost IS 'Wholesale cost per unit in CENTS we will to pay the supplier';


--
-- Name: COLUMN stocking_purchase_order_products.spop_expiration_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_expiration_class IS 'Indicates level of rigor required around expiration date checking';


--
-- Name: COLUMN stocking_purchase_order_products.spop_ma_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_order_products.spop_ma_id IS 'Foreign key to manufacturers, used to display image link';


--
-- Name: stocking_purchase_order_products_spop_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE stocking_purchase_order_products_spop_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stocking_purchase_order_products_spop_id_seq OWNER TO postgres;

--
-- Name: stocking_purchase_order_products_spop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stocking_purchase_order_products_spop_id_seq OWNED BY stocking_purchase_order_products.spop_id;


--
-- Name: stocking_purchase_orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stocking_purchase_orders (
    spo_id integer NOT NULL,
    spo_status stocking_purchase_order_status NOT NULL,
    spo_su_id integer NOT NULL,
    spo_date_ordered timestamp with time zone NOT NULL,
    spo_date_confirmed timestamp with time zone,
    spo_date_shipped timestamp with time zone,
    spo_date_arrived timestamp with time zone,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE stocking_purchase_orders OWNER TO postgres;

--
-- Name: TABLE stocking_purchase_orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE stocking_purchase_orders IS 'Representation of orders to suppliers to stock our warehouse';


--
-- Name: COLUMN stocking_purchase_orders.spo_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.spo_id IS 'Unique identifier to a stocking purchase order';


--
-- Name: COLUMN stocking_purchase_orders.spo_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.spo_status IS 'Current status of this stocking purchase order';


--
-- Name: COLUMN stocking_purchase_orders.spo_su_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.spo_su_id IS 'Supplier the order is placed with';


--
-- Name: COLUMN stocking_purchase_orders.spo_date_ordered; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.spo_date_ordered IS 'Date order sent to supplier';


--
-- Name: COLUMN stocking_purchase_orders.spo_date_confirmed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.spo_date_confirmed IS 'Date the supplier confirmed the products on the order';


--
-- Name: COLUMN stocking_purchase_orders.spo_date_shipped; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.spo_date_shipped IS 'Date the supplier sent us an advanced shipping notification';


--
-- Name: COLUMN stocking_purchase_orders.spo_date_arrived; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stocking_purchase_orders.spo_date_arrived IS 'Date the order arrived - note individual item arrival times tracked in stocking_purchase_order_products in case of multiple shipments';


--
-- Name: stocking_purchase_orders_spo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE stocking_purchase_orders_spo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stocking_purchase_orders_spo_id_seq OWNER TO postgres;

--
-- Name: stocking_purchase_orders_spo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stocking_purchase_orders_spo_id_seq OWNED BY stocking_purchase_orders.spo_id;


--
-- Name: supplier_shipments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE supplier_shipments (
    shi_id integer NOT NULL,
    shi_shipment_code character varying(255) NOT NULL,
    shi_spo_id integer NOT NULL,
    shi_su_id integer NOT NULL,
    shi_promised_delivery timestamp with time zone,
    shi_actual_delivery timestamp with time zone,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE supplier_shipments OWNER TO postgres;

--
-- Name: TABLE supplier_shipments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE supplier_shipments IS 'Represents many:many relationship between supplier shipment IDs and our SPOs';


--
-- Name: COLUMN supplier_shipments.shi_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.shi_id IS 'Surrogate primary key';


--
-- Name: COLUMN supplier_shipments.shi_shipment_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.shi_shipment_code IS 'Supplier-specified code to a shipment of products (can be a string in any format)';


--
-- Name: COLUMN supplier_shipments.shi_spo_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.shi_spo_id IS 'Foreign key to stocking_purchase_orders';


--
-- Name: COLUMN supplier_shipments.shi_su_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.shi_su_id IS 'The supplier the shipment is tied to';


--
-- Name: COLUMN supplier_shipments.shi_promised_delivery; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.shi_promised_delivery IS 'Date supplier promised the shipment would be delivered by';


--
-- Name: COLUMN supplier_shipments.shi_actual_delivery; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN supplier_shipments.shi_actual_delivery IS 'Actual date shipment was received';


--
-- Name: supplier_shipments_shi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE supplier_shipments_shi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE supplier_shipments_shi_id_seq OWNER TO postgres;

--
-- Name: supplier_shipments_shi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE supplier_shipments_shi_id_seq OWNED BY supplier_shipments.shi_id;


--
-- Name: ast_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY associate_stations ALTER COLUMN ast_id SET DEFAULT nextval('associate_stations_ast_id_seq'::regclass);


--
-- Name: as_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY associates ALTER COLUMN as_id SET DEFAULT nextval('associates_as_id_seq'::regclass);


--
-- Name: ier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_errors ALTER COLUMN ier_id SET DEFAULT nextval('inventory_errors_ier_id_seq'::regclass);


--
-- Name: ihd_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_holds ALTER COLUMN ihd_id SET DEFAULT nextval('inventory_holds_ihd_id_seq'::regclass);


--
-- Name: kio_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY kiosks ALTER COLUMN kio_id SET DEFAULT nextval('kiosks_kio_id_seq'::regclass);


--
-- Name: ptp_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pick_task_products ALTER COLUMN ptp_id SET DEFAULT nextval('pick_task_products_ptp_id_seq'::regclass);


--
-- Name: pt_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pick_tasks ALTER COLUMN pt_id SET DEFAULT nextval('pick_tasks_pt_id_seq'::regclass);


--
-- Name: pul_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pickup_locations ALTER COLUMN pul_id SET DEFAULT nextval('pickup_locations_pul_id_seq'::regclass);


--
-- Name: pst_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pickup_sub_tasks ALTER COLUMN pst_id SET DEFAULT nextval('pickup_sub_tasks_pst_id_seq'::regclass);


--
-- Name: put_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pickup_tasks ALTER COLUMN put_id SET DEFAULT nextval('pickup_tasks_put_id_seq'::regclass);


--
-- Name: si_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY static_inventory ALTER COLUMN si_id SET DEFAULT nextval('static_inventory_si_id_seq'::regclass);


--
-- Name: spop_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stocking_purchase_order_products ALTER COLUMN spop_id SET DEFAULT nextval('stocking_purchase_order_products_spop_id_seq'::regclass);


--
-- Name: spo_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stocking_purchase_orders ALTER COLUMN spo_id SET DEFAULT nextval('stocking_purchase_orders_spo_id_seq'::regclass);


--
-- Name: shi_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supplier_shipments ALTER COLUMN shi_id SET DEFAULT nextval('supplier_shipments_shi_id_seq'::regclass);


--
-- Name: associate_stations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY associate_stations
    ADD CONSTRAINT associate_stations_pkey PRIMARY KEY (ast_id);


--
-- Name: associates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY associates
    ADD CONSTRAINT associates_pkey PRIMARY KEY (as_id);


--
-- Name: customer_order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY customer_order_products
    ADD CONSTRAINT customer_order_products_pkey PRIMARY KEY (cop_id);


--
-- Name: customer_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY customer_orders
    ADD CONSTRAINT customer_orders_pkey PRIMARY KEY (cor_id);


--
-- Name: inventory_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventory_errors
    ADD CONSTRAINT inventory_errors_pkey PRIMARY KEY (ier_id);


--
-- Name: inventory_holds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventory_holds
    ADD CONSTRAINT inventory_holds_pkey PRIMARY KEY (ihd_id);


--
-- Name: kiosks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY kiosks
    ADD CONSTRAINT kiosks_pkey PRIMARY KEY (kio_id);


--
-- Name: pick_container_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pick_container_locations
    ADD CONSTRAINT pick_container_locations_pkey PRIMARY KEY (pcl_id);


--
-- Name: pick_containers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pick_containers
    ADD CONSTRAINT pick_containers_pkey PRIMARY KEY (pc_id);


--
-- Name: pick_task_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pick_task_products
    ADD CONSTRAINT pick_task_products_pkey PRIMARY KEY (ptp_id);


--
-- Name: pick_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pick_tasks
    ADD CONSTRAINT pick_tasks_pkey PRIMARY KEY (pt_id);


--
-- Name: pickup_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pickup_locations
    ADD CONSTRAINT pickup_locations_pkey PRIMARY KEY (pul_id);


--
-- Name: pickup_sub_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pickup_sub_tasks
    ADD CONSTRAINT pickup_sub_tasks_pkey PRIMARY KEY (pst_id);


--
-- Name: pickup_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pickup_tasks
    ADD CONSTRAINT pickup_tasks_pkey PRIMARY KEY (put_id);


--
-- Name: products_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey1 PRIMARY KEY (pr_sku);


--
-- Name: receiving_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY receiving_locations
    ADD CONSTRAINT receiving_locations_pkey PRIMARY KEY (rcl_id);


--
-- Name: static_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY static_inventory
    ADD CONSTRAINT static_inventory_pkey PRIMARY KEY (si_id);


--
-- Name: stocking_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocking_locations
    ADD CONSTRAINT stocking_locations_pkey PRIMARY KEY (stl_id);


--
-- Name: stocking_purchase_order_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocking_purchase_order_products
    ADD CONSTRAINT stocking_purchase_order_products_pkey PRIMARY KEY (spop_id);


--
-- Name: stocking_purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocking_purchase_orders
    ADD CONSTRAINT stocking_purchase_orders_pkey PRIMARY KEY (spo_id);


--
-- Name: supplier_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supplier_shipments
    ADD CONSTRAINT supplier_shipments_pkey PRIMARY KEY (shi_id);


--
-- Name: unique_hold_sku_location; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventory_holds
    ADD CONSTRAINT unique_hold_sku_location UNIQUE (ihd_si_id, ihd_cop_id);


--
-- Name: unique_sn_spo; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supplier_shipments
    ADD CONSTRAINT unique_sn_spo UNIQUE (shi_shipment_code, shi_spo_id);


--
-- Name: unique_spo_sku; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocking_purchase_order_products
    ADD CONSTRAINT unique_spo_sku UNIQUE (spop_spo_id, spop_pr_sku);


--
-- Name: associate_stations_ast_as_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX associate_stations_ast_as_id_idx ON associate_stations USING btree (ast_as_id);


--
-- Name: associate_stations_ast_end_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX associate_stations_ast_end_time_idx ON associate_stations USING btree (ast_end_time) WHERE (ast_end_time IS NULL);


--
-- Name: associate_stations_ast_start_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX associate_stations_ast_start_time_idx ON associate_stations USING btree (ast_start_time);


--
-- Name: customer_order_products_cop_cor_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX customer_order_products_cop_cor_id_idx ON customer_order_products USING btree (cop_cor_id);


--
-- Name: customer_order_products_cop_pr_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX customer_order_products_cop_pr_sku_idx ON customer_order_products USING btree (cop_pr_sku);


--
-- Name: customer_orders_cor_submitted_at_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX customer_orders_cor_submitted_at_idx ON customer_orders USING btree (cor_submitted_at);


--
-- Name: inventory_errors_ier_ptp_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_errors_ier_ptp_id_idx ON inventory_errors USING btree (ier_ptp_id);


--
-- Name: inventory_errors_ier_si_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_errors_ier_si_id_idx ON inventory_errors USING btree (ier_si_id);


--
-- Name: inventory_errors_ier_spop_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_errors_ier_spop_id_idx ON inventory_errors USING btree (ier_spop_id);


--
-- Name: inventory_holds_ihd_cop_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_holds_ihd_cop_id_idx ON inventory_holds USING btree (ihd_cop_id);


--
-- Name: inventory_holds_ihd_si_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX inventory_holds_ihd_si_id_idx ON inventory_holds USING btree (ihd_si_id);


--
-- Name: pick_containers_pc_pcl_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_containers_pc_pcl_id_idx ON pick_containers USING btree (pc_pcl_id);


--
-- Name: pick_task_products_ptp_cop_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_task_products_ptp_cop_id_idx ON pick_task_products USING btree (ptp_cop_id);


--
-- Name: pick_task_products_ptp_pc_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_task_products_ptp_pc_id_idx ON pick_task_products USING btree (ptp_pc_id);


--
-- Name: pick_task_products_ptp_pt_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_task_products_ptp_pt_id_idx ON pick_task_products USING btree (ptp_pt_id);


--
-- Name: pick_task_products_ptp_stl_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_task_products_ptp_stl_id_idx ON pick_task_products USING btree (ptp_stl_id);


--
-- Name: pick_tasks_pt_status_pt_order_promised_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pick_tasks_pt_status_pt_order_promised_time_idx ON pick_tasks USING btree (pt_status, pt_order_promised_time) WHERE (pt_status <> ALL (ARRAY['Completed Pickup'::task_status, 'Cancelled'::task_status]));


--
-- Name: pickup_sub_tasks_pst_put_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_sub_tasks_pst_put_id_idx ON pickup_sub_tasks USING btree (pst_put_id);


--
-- Name: pickup_tasks_put_as_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_tasks_put_as_id_idx ON pickup_tasks USING btree (put_as_id);


--
-- Name: pickup_tasks_put_cor_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_tasks_put_cor_id_idx ON pickup_tasks USING btree (put_cor_id);


--
-- Name: pickup_tasks_put_customer_checkin_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_tasks_put_customer_checkin_time_idx ON pickup_tasks USING btree (put_customer_checkin_time);


--
-- Name: pickup_tasks_put_status_put_customer_checkin_time_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX pickup_tasks_put_status_put_customer_checkin_time_idx ON pickup_tasks USING btree (put_status, put_customer_checkin_time) WHERE (put_status <> ALL (ARRAY['Completed Pickup'::task_status, 'Cancelled'::task_status]));


--
-- Name: static_inventory_si_expiration_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX static_inventory_si_expiration_date_idx ON static_inventory USING btree (si_expiration_date);


--
-- Name: static_inventory_si_pr_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX static_inventory_si_pr_sku_idx ON static_inventory USING btree (si_pr_sku);


--
-- Name: static_inventory_si_spop_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX static_inventory_si_spop_id_idx ON static_inventory USING btree (si_spop_id);


--
-- Name: static_inventory_si_stl_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX static_inventory_si_stl_id_idx ON static_inventory USING btree (si_stl_id) WHERE (si_emptied_date IS NOT NULL);


--
-- Name: stocking_locations_stl_assigned_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_locations_stl_assigned_sku_idx ON stocking_locations USING btree (stl_assigned_sku);


--
-- Name: stocking_locations_stl_needs_qc_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_locations_stl_needs_qc_idx ON stocking_locations USING btree (stl_needs_qc) WHERE (stl_needs_qc = true);


--
-- Name: stocking_purchase_order_products_spop_actual_arrival_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_spop_actual_arrival_idx ON stocking_purchase_order_products USING btree (spop_actual_arrival);


--
-- Name: stocking_purchase_order_products_spop_expected_arrival_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_spop_expected_arrival_idx ON stocking_purchase_order_products USING btree (spop_expected_arrival);


--
-- Name: stocking_purchase_order_products_spop_pr_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_spop_pr_sku_idx ON stocking_purchase_order_products USING btree (spop_pr_sku);


--
-- Name: stocking_purchase_order_products_spop_spo_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_spop_spo_id_idx ON stocking_purchase_order_products USING btree (spop_spo_id);


--
-- Name: stocking_purchase_order_products_spop_status_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_order_products_spop_status_idx ON stocking_purchase_order_products USING btree (spop_status) WHERE (spop_status <> 'Stocked'::stocking_purchase_order_product_status);


--
-- Name: stocking_purchase_orders_spo_date_arrived_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_orders_spo_date_arrived_idx ON stocking_purchase_orders USING btree (spo_date_arrived);


--
-- Name: stocking_purchase_orders_spo_date_confirmed_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_orders_spo_date_confirmed_idx ON stocking_purchase_orders USING btree (spo_date_confirmed);


--
-- Name: stocking_purchase_orders_spo_date_ordered_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_orders_spo_date_ordered_idx ON stocking_purchase_orders USING btree (spo_date_ordered);


--
-- Name: stocking_purchase_orders_spo_date_shipped_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocking_purchase_orders_spo_date_shipped_idx ON stocking_purchase_orders USING btree (spo_date_shipped);


--
-- Name: supplier_shipments_shi_shipment_code_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX supplier_shipments_shi_shipment_code_idx ON supplier_shipments USING btree (shi_shipment_code);


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

