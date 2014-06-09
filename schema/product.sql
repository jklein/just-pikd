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


SET search_path = public, pg_catalog;

--
-- Name: measurement_unit; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE measurement_unit AS ENUM (
    'fl oz',
    'oz',
    'sq ft',
    'lbs',
    'count'
);


ALTER TYPE public.measurement_unit OWNER TO postgres;

--
-- Name: temperature_zone; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE temperature_zone AS ENUM (
    'frozen',
    'cold',
    'fresh',
    'dry'
);


ALTER TYPE public.temperature_zone OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: candstop500; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE candstop500 (
    rank integer,
    item_code integer,
    description character varying(500),
    pack integer,
    size_number double precision,
    unit_of_measure character varying(10),
    list_cost money,
    upc_commodity integer,
    upc_vendor integer,
    upc_case integer,
    upc_item integer,
    destination character varying(500),
    gl character varying(500),
    category character varying(500),
    vendor_name character varying(500),
    length double precision,
    width double precision,
    height double precision,
    cube double precision,
    weight double precision,
    qc_spec integer,
    type_of_qc character varying(500),
    rank_by_category integer,
    total_rank integer,
    case_upc character varying(50),
    item_upc character varying(50),
    found_in_itemmaster integer,
    gl_category character varying(500)
);


ALTER TABLE public.candstop500 OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE categories (
    category_id integer NOT NULL,
    category_name character varying(500) NOT NULL,
    category_number integer,
    category_top_level character varying(500),
    third_party_identifier character varying(500),
    parent_category_id integer,
    active boolean
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_category_id_seq OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE categories_category_id_seq OWNED BY categories.category_id;


--
-- Name: im500items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE im500items (
    item_upc character varying(50),
    rank integer,
    id integer,
    upc character varying(50),
    description character varying(500),
    manufacturer character varying(500),
    brand character varying(500),
    distributor character varying(500),
    gs1_category character varying(500),
    pkg_manufacturer character varying(500),
    pkg_manufacturer_address character varying(500),
    pkg_manufacturer_phone character varying(500),
    pkg_manufacturer_email character varying(500),
    pkg_manufacturer_url character varying(500),
    pkg_distributor character varying(500),
    pkg_distributor_address character varying(500),
    pkg_distributor_phone character varying(500),
    pkg_distributor_email character varying(500),
    pkg_distributor_url character varying(500),
    marketing_description character varying(8000),
    other_description character varying(8000),
    units_in_package integer,
    packaging_type character varying(500),
    packaging_size character varying(500),
    package_information character varying(500),
    created timestamp without time zone,
    last_updated timestamp without time zone
);


ALTER TABLE public.im500items OWNER TO postgres;

--
-- Name: im500media; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE im500media (
    item_upc character varying(50),
    rank integer,
    image_count integer,
    id integer,
    upc character varying(50),
    gs1_view character varying(50),
    image_1_mime_type character varying(50),
    image_1_date_added timestamp without time zone,
    image_1_source character varying(500),
    image_1_description character varying(500),
    image_1_path character varying(500),
    image_2_mime_type character varying(50),
    image_2_date_added timestamp without time zone,
    image_2_source character varying(500),
    image_2_description character varying(500),
    image_2_path character varying(500),
    image_3_mime_type character varying(50),
    image_3_date_added timestamp without time zone,
    image_3_source character varying(500),
    image_3_description character varying(500),
    image_3_path character varying(500),
    image_4_mime_type character varying(50),
    image_4_date_added timestamp without time zone,
    image_4_source character varying(500),
    image_4_description character varying(500),
    image_4_path character varying(500),
    image_5_mime_type character varying(50),
    image_5_date_added timestamp without time zone,
    image_5_source character varying(500),
    image_5_description character varying(500),
    image_5_path character varying(500),
    image_6_mime_type character varying(50),
    image_6_date_added timestamp without time zone,
    image_6_source character varying(500),
    image_6_description character varying(500),
    image_6_path character varying(500),
    image_7_mime_type character varying(50),
    image_7_date_added timestamp without time zone,
    image_7_source character varying(500),
    image_7_description character varying(500),
    image_7_path character varying(500),
    image_8_mime_type character varying(50),
    image_8_date_added timestamp without time zone,
    image_8_source character varying(500),
    image_8_description character varying(500),
    image_8_path character varying(500),
    image_9_mime_type character varying(50),
    image_9_date_added timestamp without time zone,
    image_9_source character varying(500),
    image_9_description character varying(500),
    image_9_path character varying(500)
);


ALTER TABLE public.im500media OWNER TO postgres;

--
-- Name: im500productdata; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE im500productdata (
    item_upc character varying(50),
    rank integer,
    id integer,
    upc character varying(50),
    product_id character varying(100),
    sequence integer,
    manufacturer character varying(500),
    distributor character varying(500),
    brand character varying(500),
    product_description character varying(8000),
    product_size character varying(500),
    drug_interactions character varying(500),
    directions character varying(8000),
    indications character varying(8000),
    ingredients character varying(8000),
    vitamin_and_minerals character varying(8000),
    low_fat boolean,
    low_sodium boolean,
    fat_free boolean,
    sugar_free boolean,
    good_source_of_fiber boolean,
    vegan boolean,
    vegetarian boolean,
    lactose_free boolean,
    flavor boolean,
    antibiotic_free boolean,
    temperature_indicator character varying(500),
    wheat_free boolean,
    gluten_free boolean,
    hormone_free boolean,
    is_natural boolean,
    nitrates_free boolean,
    nitrites_free boolean,
    organic boolean,
    peanut_free boolean,
    ready_to_cook boolean,
    ready_to_heat boolean,
    dairy_free boolean,
    egg_free boolean,
    kosher_codes character varying(50),
    recycle_codes character varying(50),
    ndc_code character varying(50),
    country_of_origin character varying(50)
);


ALTER TABLE public.im500productdata OWNER TO postgres;

--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE manufacturers (
    manufacturer_id integer NOT NULL,
    manufacturer_name character varying(500) NOT NULL
);


ALTER TABLE public.manufacturers OWNER TO postgres;

--
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE manufacturers_manufacturer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.manufacturers_manufacturer_id_seq OWNER TO postgres;

--
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE manufacturers_manufacturer_id_seq OWNED BY manufacturers.manufacturer_id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_images (
    image_id integer NOT NULL,
    product_id integer NOT NULL,
    image_rank integer NOT NULL,
    mime_type character varying(255),
    source character varying(500),
    description character varying(4000),
    path character varying(500),
    date_added timestamp without time zone DEFAULT now()
);


ALTER TABLE public.product_images OWNER TO postgres;

--
-- Name: product_images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE product_images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_images_image_id_seq OWNER TO postgres;

--
-- Name: product_images_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE product_images_image_id_seq OWNED BY product_images.image_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products (
    product_id integer NOT NULL,
    name character varying(255) NOT NULL,
    temperature_zone temperature_zone NOT NULL,
    manufacturer_id integer NOT NULL,
    list_cost money NOT NULL,
    category_id integer NOT NULL,
    description text,
    units_per_case smallint,
    measurement_unit measurement_unit,
    measurement_value integer,
    upc_commodity integer,
    upc_vendor integer,
    upc_case integer,
    upc_item integer,
    source_warehouse_id integer,
    vendor_name character varying(500),
    length double precision,
    width double precision,
    height double precision,
    cubic_volume double precision,
    weight double precision,
    shelf_life_days integer,
    case_upc character varying(64),
    item_upc character varying(64)
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_product_id_seq OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE products_product_id_seq OWNED BY products.product_id;


--
-- Name: category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categories ALTER COLUMN category_id SET DEFAULT nextval('categories_category_id_seq'::regclass);


--
-- Name: manufacturer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY manufacturers ALTER COLUMN manufacturer_id SET DEFAULT nextval('manufacturers_manufacturer_id_seq'::regclass);


--
-- Name: image_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_images ALTER COLUMN image_id SET DEFAULT nextval('product_images_image_id_seq'::regclass);


--
-- Name: product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY products ALTER COLUMN product_id SET DEFAULT nextval('products_product_id_seq'::regclass);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: candstop500; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE candstop500 FROM PUBLIC;
REVOKE ALL ON TABLE candstop500 FROM postgres;
GRANT ALL ON TABLE candstop500 TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE candstop500 TO jp_readwrite;


--
-- Name: categories; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE categories FROM PUBLIC;
REVOKE ALL ON TABLE categories FROM postgres;
GRANT ALL ON TABLE categories TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE categories TO jp_readwrite;


--
-- Name: im500items; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE im500items FROM PUBLIC;
REVOKE ALL ON TABLE im500items FROM postgres;
GRANT ALL ON TABLE im500items TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE im500items TO jp_readwrite;


--
-- Name: im500media; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE im500media FROM PUBLIC;
REVOKE ALL ON TABLE im500media FROM postgres;
GRANT ALL ON TABLE im500media TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE im500media TO jp_readwrite;


--
-- Name: im500productdata; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE im500productdata FROM PUBLIC;
REVOKE ALL ON TABLE im500productdata FROM postgres;
GRANT ALL ON TABLE im500productdata TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE im500productdata TO jp_readwrite;


--
-- Name: manufacturers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE manufacturers FROM PUBLIC;
REVOKE ALL ON TABLE manufacturers FROM postgres;
GRANT ALL ON TABLE manufacturers TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE manufacturers TO jp_readwrite;


--
-- Name: products; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE products FROM PUBLIC;
REVOKE ALL ON TABLE products FROM postgres;
GRANT ALL ON TABLE products TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE products TO jp_readwrite;


--
-- PostgreSQL database dump complete
--

