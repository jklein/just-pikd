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
-- Name: product; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE product IS 'Stores information to display product content on the website including the base_products themselves, categorization, attributes/tags, brand/manufacturer information, images. Merchandising and editing of base_products happens against this database, and the product data must flow to the WMS. There should be one master product database replicated to store specific product_<storeid> databases which have override tables so that merchandising, pricing etc. can be overridden by store';


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
-- Name: TYPE measurement_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE measurement_unit IS 'Units of measure for product sizes';


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


ALTER TYPE public.product_status OWNER TO postgres;

--
-- Name: TYPE product_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE product_status IS 'Stages of product lifecycle. Only active base_products are listed on site';


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

--
-- Name: TYPE temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE temperature_zone IS 'Physical storage areas in the warehouse for each product';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attribute_values; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE attribute_values (
    product_id integer NOT NULL,
    attribute_id integer NOT NULL,
    value boolean NOT NULL
);


ALTER TABLE public.attribute_values OWNER TO postgres;

--
-- Name: TABLE attribute_values; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE attribute_values IS 'Contains yes/no values for each product we have values for. Stored at the product level, not product_instance level';


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE attributes (
    attribute_id integer NOT NULL,
    attribute_name character varying(255) NOT NULL
);


ALTER TABLE public.attributes OWNER TO postgres;

--
-- Name: TABLE attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE attributes IS 'Description of various product attributes which are yes/no values like contains gluten';


--
-- Name: attributes_attribute_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE attributes_attribute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attributes_attribute_id_seq OWNER TO postgres;

--
-- Name: attributes_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE attributes_attribute_id_seq OWNED BY attributes.attribute_id;


--
-- Name: base_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE base_products (
    product_id integer NOT NULL,
    name character varying(255) NOT NULL,
    temperature_zone temperature_zone NOT NULL,
    manufacturer_id integer NOT NULL,
    category_id integer NOT NULL,
    description text,
    shelf_life_days integer,
    qc_check_interval_days integer,
    brand_id integer
);


ALTER TABLE public.base_products OWNER TO postgres;

--
-- Name: TABLE base_products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE base_products IS 'Base level product information. Anything that is not option/size specific. Assumption: description is not size specific. Assumption: a product lives in a single category';


--
-- Name: COLUMN base_products.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN base_products.name IS 'Product name as shown to customers on site';


--
-- Name: COLUMN base_products.temperature_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN base_products.temperature_zone IS 'Temperature zone where the product is stored in the warehouse';


--
-- Name: COLUMN base_products.manufacturer_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN base_products.manufacturer_id IS 'The manufacturer that produces the product';


--
-- Name: COLUMN base_products.category_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN base_products.category_id IS 'The category the product is tied to for revenue allocation and merchandising purposes';


--
-- Name: COLUMN base_products.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN base_products.description IS 'The detailed product description as displayed to customers on site';


--
-- Name: COLUMN base_products.shelf_life_days; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN base_products.shelf_life_days IS 'Estimated shelf life in days after a product is received. We will need to populate this based on our experience if we can''t get data from the manufacturer.';


--
-- Name: COLUMN base_products.qc_check_interval_days; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN base_products.qc_check_interval_days IS 'Frequency at which we should check quality on a product, especially produce';


--
-- Name: COLUMN base_products.brand_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN base_products.brand_id IS 'Foreign key to brand.id';


--
-- Name: base_products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE base_products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.base_products_product_id_seq OWNER TO postgres;

--
-- Name: base_products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE base_products_product_id_seq OWNED BY base_products.product_id;


--
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE brands (
    brand_id integer NOT NULL,
    brand_name character varying(500) NOT NULL,
    logo_image_url character varying(500),
    marketing_description character varying(500)
);


ALTER TABLE public.brands OWNER TO postgres;

--
-- Name: TABLE brands; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE brands IS 'Contains brand name and ID. Expand to include other fields that we can track about who makes a product.';


--
-- Name: COLUMN brands.logo_image_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN brands.logo_image_url IS 'URL to an image containing the brand logo for display on site';


--
-- Name: COLUMN brands.marketing_description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN brands.marketing_description IS 'A story or description about this brand for display to customers';


--
-- Name: brands_brand_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE brands_brand_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.brands_brand_id_seq OWNER TO postgres;

--
-- Name: brands_brand_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE brands_brand_id_seq OWNED BY brands.brand_id;


--
-- Name: candsproducts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE candsproducts (
    item_code integer,
    item_upc character varying(50),
    database character varying(100),
    description character varying(500),
    pack integer,
    size_number double precision,
    unit_of_measure character varying(10),
    list_cost money,
    upc_commodity integer,
    upc_vendor integer,
    upc_case integer,
    upc_item integer,
    case_full_upc character varying(50),
    item_full_upc character varying(50),
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
    total_rank money,
    retail_mult integer,
    assumed_case_volume double precision,
    assumed_item_volume money,
    assumed_cogs money,
    valid_item_upc boolean,
    jp_category character varying(500),
    jp_subcategory character varying(500)
);


ALTER TABLE public.candsproducts OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE categories (
    category_id integer NOT NULL,
    category_name character varying(500) NOT NULL,
    third_party_identifier character varying(500),
    parent_category_id integer,
    active boolean,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: TABLE categories; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE categories IS 'Product categorization - a category tree is maintained by the fact that a category can have a parent.';


--
-- Name: COLUMN categories.category_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.category_name IS 'Display name on site for the category';


--
-- Name: COLUMN categories.third_party_identifier; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.third_party_identifier IS 'Full third party identifier to the category from which name, number and top_level are extracted';


--
-- Name: COLUMN categories.parent_category_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.parent_category_id IS 'Each category can have a single parent, creating a tree of categories';


--
-- Name: COLUMN categories.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.active IS 'Should this category be displayed and browsable on site?';


--
-- Name: COLUMN categories.last_updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.last_updated IS 'The last time any of the data in this row was changed';


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
-- Name: im_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE im_items (
    item_upc character varying(50),
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
    other_description text,
    units_in_package integer,
    packaging_type character varying(500),
    packaging_size character varying(500),
    package_information character varying(500),
    created timestamp without time zone,
    last_updated timestamp without time zone
);


ALTER TABLE public.im_items OWNER TO postgres;

--
-- Name: im_media; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE im_media (
    id integer,
    item_upc character varying(50),
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


ALTER TABLE public.im_media OWNER TO postgres;

--
-- Name: im_productdata; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE im_productdata (
    item_upc character varying(50),
    id integer,
    upc character varying(50),
    product_id character varying(100),
    sequence integer,
    manufacturer character varying(500),
    distributor character varying(500),
    brand character varying(500),
    product_description character varying(8000),
    product_size character varying(500),
    drug_interactions character varying(8000),
    directions text,
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
    country_of_origin character varying(500)
);


ALTER TABLE public.im_productdata OWNER TO postgres;

--
-- Name: images; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE images (
    image_id integer NOT NULL,
    manufacturer_id integer NOT NULL,
    sku character varying(12),
    mime_type character varying(255),
    rank integer NOT NULL,
    show_on_site boolean DEFAULT true NOT NULL,
    width integer,
    height integer,
    file_size integer,
    alt_text character varying(255),
    description character varying(4000),
    source character varying(500),
    date_added timestamp with time zone DEFAULT now() NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT images_rank_check CHECK ((rank > 0))
);


ALTER TABLE public.images OWNER TO postgres;

--
-- Name: TABLE images; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE images IS 'Any image resource. Either a picture of a product, a manufacturer logo, or some other image for the site';


--
-- Name: COLUMN images.manufacturer_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.manufacturer_id IS 'The manufacturer associated with either the product the image is a picture of, or the manufacturer logo. Used to determine the image path.';


--
-- Name: COLUMN images.sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.sku IS 'The sku for the product the image is a picture of, if it is a product image. Null otherwise.';


--
-- Name: COLUMN images.mime_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.mime_type IS 'The mime-type to be displayed to the client for the image. Usually image/jpeg';


--
-- Name: COLUMN images.rank; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.rank IS 'Sort order on the product page (the default_image_id in products is always shown first though). Must be greater than zero, and must be unique to the sku+image combo';


--
-- Name: COLUMN images.show_on_site; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.show_on_site IS 'Whether to display the image on site.';


--
-- Name: COLUMN images.width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.width IS 'The width in pixels';


--
-- Name: COLUMN images.height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.height IS 'The height in pixels';


--
-- Name: COLUMN images.file_size; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.file_size IS 'Size on disk';


--
-- Name: COLUMN images.alt_text; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.alt_text IS 'Alt text to display on site';


--
-- Name: COLUMN images.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.description IS 'Internal-only description of the image. Not shown to customers';


--
-- Name: COLUMN images.source; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.source IS 'Brief description of who or where we got the image from';


--
-- Name: images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.images_image_id_seq OWNER TO postgres;

--
-- Name: images_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE images_image_id_seq OWNED BY images.image_id;


--
-- Name: kwikee_external_codes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE kwikee_external_codes (
    gtin character varying(14),
    external_code character varying(500),
    external_code_value character varying(500)
);


ALTER TABLE public.kwikee_external_codes OWNER TO postgres;

--
-- Name: kwikee_nutrition; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE kwikee_nutrition (
    upc character varying(10),
    gtin character varying(14),
    promotion character varying(800),
    cal_from_sat_tran_fat character varying(15),
    calories_per_serving character varying(15),
    carbo_per_serving character varying(15),
    carbo_uom character varying(15),
    cholesterol_per_serving character varying(15),
    cholesterol_uom character varying(15),
    dvp_biotin character varying(15),
    dvp_calcium character varying(15),
    dvp_carbo character varying(15),
    dvp_chloride character varying(15),
    dvp_cholesterol character varying(15),
    dvp_chromium character varying(15),
    dvp_copper character varying(15),
    dvp_fiber character varying(15),
    dvp_folic_acid character varying(15),
    dvp_iodide character varying(15),
    dvp_iodine character varying(15),
    dvp_iron character varying(15),
    dvp_magnesium character varying(15),
    dvp_manganese character varying(15),
    dvp_molybdenum character varying(15),
    dvp_niacin character varying(15),
    dvp_panthothenate character varying(15),
    dvp_phosphorus character varying(15),
    dvp_potassium character varying(15),
    dvp_protein character varying(15),
    dvp_riboflavin character varying(15),
    dvp_sat_tran_fat character varying(15),
    dvp_saturated_fat character varying(15),
    dvp_selenium character varying(15),
    dvp_sodium character varying(15),
    dvp_sugar character varying(15),
    dvp_thiamin character varying(15),
    dvp_total_fat character varying(15),
    dvp_vitamin_a character varying(15),
    dvp_vitamin_b12 character varying(15),
    dvp_vitamin_b6 character varying(15),
    dvp_vitamin_c character varying(15),
    dvp_vitamin_d character varying(15),
    dvp_vitamin_e character varying(15),
    dvp_vitamin_k character varying(15),
    dvp_zinc character varying(15),
    fat_calories_per_serving character varying(15),
    fiber_per_serving character varying(15),
    fiber_uom character varying(15),
    insol_fiber_per_serving character varying(15),
    insol_fiber_per_serving_uom character varying(15),
    mono_unsat_fat character varying(15),
    mono_unsat_fat_uom character varying(15),
    nutrient_disclaimer_1 character varying(800),
    nutrient_disclaimer_2 character varying(800),
    nutrient_disclaimer_3 character varying(800),
    nutrient_disclaimer_4 character varying(800),
    nutrition_label character varying(800),
    omega_3_polyunsat character varying(15),
    omega_3_polyunsat_uom character varying(15),
    omega_6_polyunsat character varying(15),
    omega_6_polyunsat_uom character varying(15),
    omega_9_polyunsat character varying(15),
    omega_9_polyunsat_uom character varying(15),
    poly_unsat_fat character varying(15),
    poly_unsat_fat_uom character varying(15),
    potassium_per_serving character varying(15),
    potassium_uom character varying(15),
    protein_per_serving character varying(15),
    protein_uom character varying(15),
    sat_fat_per_serving character varying(15),
    sat_fat_uom character varying(15),
    serving_size character varying(15),
    serving_size_uom character varying(15),
    servings_per_container character varying(15),
    sodium_per_serving character varying(15),
    sodium_uom character varying(15),
    sol_fiber_per_serving character varying(15),
    sol_fiber_per_serving_uom character varying(15),
    starch_per_serving character varying(15),
    starch_per_serving_uom character varying(15),
    sub_number integer,
    sugar_per_serving character varying(15),
    sugar_uom character varying(15),
    suger_alc_per_serving character varying(15),
    suger_alc_per_serving_uom character varying(15),
    total_calories_per_serving character varying(15),
    total_fat_per_serving character varying(15),
    total_fat_uom character varying(15),
    trans_fat_per_serving character varying(15),
    trans_fat_uom character varying(15)
);


ALTER TABLE public.kwikee_nutrition OWNER TO postgres;

--
-- Name: kwikee_pog; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE kwikee_pog (
    gtin character varying(14),
    upc_10 character varying(10),
    upc_12 character varying(12),
    gpc_brick_id integer,
    gpc_brick_name character varying(8000),
    section_id character varying(15),
    section_name character varying(800),
    manufacturer_name character varying(800),
    brand_name character varying(800),
    custom_product_name character varying(8000),
    product_name character varying(8000),
    description character varying(8000),
    product_size double precision,
    uom character varying(50),
    container_type character varying(800),
    height double precision,
    height_count double precision,
    width double precision,
    width_count double precision,
    depth double precision,
    depth_count double precision,
    depth_nesting double precision,
    dual_nesting integer,
    vertical_nesting double precision,
    peg_down double precision,
    peg_right double precision,
    tray_count character varying(15),
    tray_depth double precision,
    tray_height double precision,
    tray_width double precision,
    case_count double precision,
    case_depth double precision,
    case_height double precision,
    case_width double precision,
    display_depth double precision,
    display_height double precision,
    display_width double precision,
    unique_id character varying(800),
    physical_weight_lb double precision,
    physical_weight_oz double precision,
    date_created timestamp without time zone,
    product_count character varying(500),
    unit_size double precision,
    unit_uom character varying(50),
    unit_container character varying(800),
    source_zip character varying(50)
);


ALTER TABLE public.kwikee_pog OWNER TO postgres;

--
-- Name: kwikee_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE kwikee_products (
    upc character varying(10),
    whole_upc character varying(12),
    gtin character varying(14),
    case_gtin character varying(100),
    manufacturer_name character varying(800),
    brand_name character varying(800),
    product_name character varying(800),
    description character varying(8000),
    product_size double precision,
    uom character varying(50),
    container_type character varying(500),
    product_count character varying(500),
    unit_size double precision,
    unit_uom character varying(50),
    unit_container character varying(500),
    custom_product_name character varying(800),
    promotion character varying(800),
    gpc_brick_id integer,
    section_id character varying(15),
    section_name character varying(800),
    consumable character varying(5),
    low_fat character varying(5),
    fat_free character varying(5),
    gluten_free character varying(5),
    kosher character varying(5),
    organic character varying(5),
    model character varying(50),
    ingredient_code character varying(8000),
    ingredients character varying(8000),
    allergens character varying(8000),
    indications_copy character varying(8000),
    interactions_copy character varying(8000),
    why_buy_1 character varying(8000),
    why_buy_2 character varying(8000),
    why_buy_3 character varying(8000),
    why_buy_4 character varying(8000),
    why_buy_5 character varying(8000),
    why_buy_6 character varying(8000),
    why_buy_7 character varying(8000),
    romance_copy_1 character varying(8000),
    romance_copy_2 character varying(8000),
    romance_copy_3 character varying(8000),
    romance_copy_4 character varying(8000),
    warnings_copy character varying(8000),
    instructions_copy_1 character varying(8000),
    instructions_copy_2 character varying(8000),
    instructions_copy_3 character varying(8000),
    instructions_copy_4 character varying(8000),
    instructions_copy_5 character varying(8000),
    guarantees character varying(8000),
    guarantee_analysis character varying(8000),
    legal character varying(8000),
    post_consumer character varying(8000),
    keywords character varying(8000),
    height double precision,
    width double precision,
    depth double precision,
    peg_right double precision,
    peg_down double precision,
    physical_weight_lb double precision,
    physical_weight_oz double precision,
    case_count integer,
    case_depth double precision,
    case_height double precision,
    case_width double precision,
    depth_count integer,
    display_depth double precision,
    display_height double precision,
    display_width double precision,
    height_count integer,
    tray_count character varying(15),
    tray_depth double precision,
    tray_height double precision,
    tray_width double precision,
    width_count double precision,
    multiple_shelf_facings integer,
    dual_nesting integer,
    depth_nesting double precision,
    vertical_nesting double precision,
    product_created_date timestamp without time zone,
    product_last_modified_date timestamp without time zone,
    division_name character varying(800),
    division_name_2 character varying(800),
    last_publish_date timestamp without time zone,
    image_indicator integer,
    seasonal_flag integer,
    country_id integer,
    language_id integer,
    mfr_approved_date timestamp without time zone,
    product_base_id integer,
    product_varietal character varying(800),
    variant_name_1 character varying(800),
    variant_name_2 character varying(800),
    variant_value_1 double precision,
    variant_value_2 double precision,
    alt_brand_name character varying(800),
    alt_container_type character varying(500),
    alt_product_description character varying(8000),
    alt_product_name character varying(800),
    alt_product_size double precision,
    alt_uom character varying(15),
    nutrient_claim_1 character varying(100),
    nutrient_claim_2 character varying(100),
    nutrient_claim_3 character varying(100),
    nutrient_claim_4 character varying(100),
    nutrient_claim_5 character varying(100),
    nutrient_claim_6 character varying(100),
    nutrient_claim_7 character varying(100),
    nutrient_claim_8 character varying(100),
    nutrition_footnotes_1 character varying(800),
    nutrition_footnotes_2 character varying(800),
    nutrition_head_1 character varying(800),
    nutrition_head_2 character varying(800),
    other_nutrient_statement character varying(8000),
    extra_text_2 character varying(800),
    extra_text_3 character varying(800),
    extra_text_4 character varying(800),
    diabetes_fc_values character varying(800),
    disease_claim character varying(800),
    romance_copy_category character varying(800),
    sensible_solutions character varying(800),
    size_description_1 character varying(800),
    size_description_2 character varying(800),
    ss_claim_1 character varying(800),
    ss_claim_2 character varying(800),
    ss_claim_3 character varying(800),
    ss_claim_4 character varying(800),
    hexcode character varying(800),
    identifier_1 character varying(800),
    identifier_2 character varying(800),
    vm_claim_1 character varying(800),
    vm_claim_2 character varying(800),
    vm_claim_3 character varying(800),
    vm_claim_4 character varying(800),
    vm_type_1 character varying(800),
    vm_type_2 character varying(800),
    vm_type_3 character varying(800),
    vm_type_4 character varying(800),
    bdm_account_base_id integer,
    client_base_id integer,
    container_type_uc character varying(800),
    csm_account_base_id integer,
    custom_product_name_uc character varying(800),
    ethnic_copy character varying(8000),
    flavor character varying(800),
    national_billing_flag integer,
    product_form character varying(800),
    product_name_uc character varying(8000),
    product_size_uc character varying(800),
    product_type character varying(800),
    supplied_brand_name character varying(800),
    supplied_manufacturer_name character varying(800),
    uom_uc character varying(15),
    walmart_long_desc_header character varying(8000),
    walmart_search_description character varying(8000),
    source_zip character varying(50)
);


ALTER TABLE public.kwikee_products OWNER TO postgres;

--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE manufacturers (
    manufacturer_id integer NOT NULL,
    manufacturer_name character varying(500) NOT NULL,
    logo_image_url character varying(500),
    marketing_description character varying(500)
);


ALTER TABLE public.manufacturers OWNER TO postgres;

--
-- Name: TABLE manufacturers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE manufacturers IS 'Contains manufacturer name and ID. Expand to include other fields that we can track about who makes a product.';


--
-- Name: COLUMN manufacturers.logo_image_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.logo_image_url IS 'URL to an image containing the manufacturer logo for display on site';


--
-- Name: COLUMN manufacturers.marketing_description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.marketing_description IS 'A story or description about this manufacturer for display to customers';


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
-- Name: products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products (
    sku character varying(14) NOT NULL,
    product_id integer NOT NULL,
    sku_is_real_upc boolean NOT NULL,
    list_cost money NOT NULL,
    status product_status NOT NULL,
    default_image_id integer,
    instance_description character varying(255),
    case_upc character varying(64),
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
    wholesale_cost money,
    gtin character varying(14)
);


ALTER TABLE public.products OWNER TO postgres;

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
-- Name: COLUMN products.list_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.list_cost IS 'The price as listed to the customer';


--
-- Name: COLUMN products.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.status IS 'Whether the product can be displayed and sold on site';


--
-- Name: COLUMN products.default_image_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.default_image_id IS 'Default image to be displayed on browse and product pages';


--
-- Name: COLUMN products.instance_description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.instance_description IS 'Instance-specific description if applicable. Otherwise base product description will be displayed along with sizing information';


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
-- Name: COLUMN products.wholesale_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.wholesale_cost IS 'The price we pay to the supplier';


--
-- Name: COLUMN products.gtin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products.gtin IS 'Global Trade Item Number';


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
-- Name: products_stores; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products_stores (
    sku integer NOT NULL,
    store_id integer NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.products_stores OWNER TO postgres;

--
-- Name: TABLE products_stores; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE products_stores IS 'Which base_products are available on which stores';


--
-- Name: products_suppliers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products_suppliers (
    sku integer NOT NULL,
    supplier_id integer NOT NULL,
    status product_status NOT NULL,
    wholesale_cost money,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.products_suppliers OWNER TO postgres;

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

COMMENT ON COLUMN products_suppliers.wholesale_cost IS 'The price we would pay to buy this product from the supplier';


--
-- Name: stores; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stores (
    store_id integer NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    date_active timestamp with time zone,
    address1 character varying(255),
    address2 character varying(255),
    city character varying(255),
    state character(2),
    zip_code character varying(12),
    phone character varying(30)
);


ALTER TABLE public.stores OWNER TO postgres;

--
-- Name: TABLE stores; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE stores IS 'Physical store locations. Active stores are selectable by customers on site';


--
-- Name: COLUMN stores.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stores.name IS 'Display name for the store, a brief description of the location';


--
-- Name: COLUMN stores.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stores.active IS 'Should the store be selectable and (can it take orders?)';


--
-- Name: COLUMN stores.date_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stores.date_active IS 'When the store was/will be activated';


--
-- Name: stores_store_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE stores_store_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stores_store_id_seq OWNER TO postgres;

--
-- Name: stores_store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stores_store_id_seq OWNED BY stores.store_id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE suppliers (
    supplier_id integer NOT NULL,
    supplier_name character varying(500) NOT NULL
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: TABLE suppliers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE suppliers IS 'Information about companies we directly source base_products from.';


--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE suppliers_supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.suppliers_supplier_id_seq OWNER TO postgres;

--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE suppliers_supplier_id_seq OWNED BY suppliers.supplier_id;


--
-- Name: attribute_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attributes ALTER COLUMN attribute_id SET DEFAULT nextval('attributes_attribute_id_seq'::regclass);


--
-- Name: product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY base_products ALTER COLUMN product_id SET DEFAULT nextval('base_products_product_id_seq'::regclass);


--
-- Name: brand_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY brands ALTER COLUMN brand_id SET DEFAULT nextval('brands_brand_id_seq'::regclass);


--
-- Name: category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categories ALTER COLUMN category_id SET DEFAULT nextval('categories_category_id_seq'::regclass);


--
-- Name: image_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY images ALTER COLUMN image_id SET DEFAULT nextval('images_image_id_seq'::regclass);


--
-- Name: manufacturer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY manufacturers ALTER COLUMN manufacturer_id SET DEFAULT nextval('manufacturers_manufacturer_id_seq'::regclass);


--
-- Name: product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY products ALTER COLUMN product_id SET DEFAULT nextval('products_product_id_seq'::regclass);


--
-- Name: store_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stores ALTER COLUMN store_id SET DEFAULT nextval('stores_store_id_seq'::regclass);


--
-- Name: supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('suppliers_supplier_id_seq'::regclass);


--
-- Name: attribute_values_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attribute_values
    ADD CONSTRAINT attribute_values_pkey1 PRIMARY KEY (product_id, attribute_id);


--
-- Name: attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (attribute_id);


--
-- Name: base_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY base_products
    ADD CONSTRAINT base_products_pkey PRIMARY KEY (product_id);


--
-- Name: brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (brand_id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: images_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey1 PRIMARY KEY (image_id);


--
-- Name: manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (manufacturer_id);


--
-- Name: products_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey1 PRIMARY KEY (sku);


--
-- Name: products_stores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products_stores
    ADD CONSTRAINT products_stores_pkey PRIMARY KEY (sku, store_id);


--
-- Name: products_suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products_suppliers
    ADD CONSTRAINT products_suppliers_pkey PRIMARY KEY (sku, supplier_id);


--
-- Name: stores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (store_id);


--
-- Name: suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- Name: uniq_sku_image_ranks; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY images
    ADD CONSTRAINT uniq_sku_image_ranks UNIQUE (sku, rank);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: attribute_values; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE attribute_values FROM PUBLIC;
REVOKE ALL ON TABLE attribute_values FROM postgres;
GRANT ALL ON TABLE attribute_values TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE attribute_values TO jp_readwrite;


--
-- Name: attributes; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE attributes FROM PUBLIC;
REVOKE ALL ON TABLE attributes FROM postgres;
GRANT ALL ON TABLE attributes TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE attributes TO jp_readwrite;


--
-- Name: base_products; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE base_products FROM PUBLIC;
REVOKE ALL ON TABLE base_products FROM postgres;
GRANT ALL ON TABLE base_products TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE base_products TO jp_readwrite;


--
-- Name: candsproducts; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE candsproducts FROM PUBLIC;
REVOKE ALL ON TABLE candsproducts FROM postgres;
GRANT ALL ON TABLE candsproducts TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE candsproducts TO jp_readwrite;


--
-- Name: categories; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE categories FROM PUBLIC;
REVOKE ALL ON TABLE categories FROM postgres;
GRANT ALL ON TABLE categories TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE categories TO jp_readwrite;


--
-- Name: im_items; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE im_items FROM PUBLIC;
REVOKE ALL ON TABLE im_items FROM postgres;
GRANT ALL ON TABLE im_items TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE im_items TO jp_readwrite;


--
-- Name: im_media; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE im_media FROM PUBLIC;
REVOKE ALL ON TABLE im_media FROM postgres;
GRANT ALL ON TABLE im_media TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE im_media TO jp_readwrite;


--
-- Name: im_productdata; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE im_productdata FROM PUBLIC;
REVOKE ALL ON TABLE im_productdata FROM postgres;
GRANT ALL ON TABLE im_productdata TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE im_productdata TO jp_readwrite;


--
-- Name: images; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE images FROM PUBLIC;
REVOKE ALL ON TABLE images FROM postgres;
GRANT ALL ON TABLE images TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE images TO jp_readwrite;


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
-- Name: products_stores; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE products_stores FROM PUBLIC;
REVOKE ALL ON TABLE products_stores FROM postgres;
GRANT ALL ON TABLE products_stores TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE products_stores TO jp_readwrite;


--
-- Name: products_suppliers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE products_suppliers FROM PUBLIC;
REVOKE ALL ON TABLE products_suppliers FROM postgres;
GRANT ALL ON TABLE products_suppliers TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE products_suppliers TO jp_readwrite;


--
-- Name: stores; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE stores FROM PUBLIC;
REVOKE ALL ON TABLE stores FROM postgres;
GRANT ALL ON TABLE stores TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE stores TO jp_readwrite;


--
-- Name: suppliers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE suppliers FROM PUBLIC;
REVOKE ALL ON TABLE suppliers FROM postgres;
GRANT ALL ON TABLE suppliers TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE suppliers TO jp_readwrite;


--
-- PostgreSQL database dump complete
--

