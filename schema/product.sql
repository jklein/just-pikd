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

COMMENT ON DATABASE product IS 'Stores information to display product content on the website including the products themselves, categorization, attributes/tags, brand/manufacturer information, images. Merchandising and editing of products happens against this database, and the product data must flow to the WMS.';


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
-- Name: attribute_values; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE attribute_values (
    atv_id integer NOT NULL,
    atv_pr_sku integer NOT NULL,
    atv_at_id integer NOT NULL,
    atv_value boolean NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE attribute_values OWNER TO postgres;

--
-- Name: TABLE attribute_values; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE attribute_values IS 'Contains yes/no values for each product we have values for. Stored at the product level, not product_instance level';


--
-- Name: COLUMN attribute_values.atv_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN attribute_values.atv_id IS 'Surrogate primary key';


--
-- Name: COLUMN attribute_values.atv_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN attribute_values.atv_pr_sku IS 'Foreign key to products';


--
-- Name: COLUMN attribute_values.atv_at_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN attribute_values.atv_at_id IS 'Foreign key to attributes';


--
-- Name: COLUMN attribute_values.atv_value; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN attribute_values.atv_value IS 'The yes/no value for this attribute for this product';


--
-- Name: attribute_values_atv_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE attribute_values_atv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE attribute_values_atv_id_seq OWNER TO postgres;

--
-- Name: attribute_values_atv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE attribute_values_atv_id_seq OWNED BY attribute_values.atv_id;


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE attributes (
    at_id integer NOT NULL,
    at_name character varying(255) NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE attributes OWNER TO postgres;

--
-- Name: TABLE attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE attributes IS 'Description of various product attributes which are yes/no values like contains gluten';


--
-- Name: attributes_at_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE attributes_at_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE attributes_at_id_seq OWNER TO postgres;

--
-- Name: attributes_at_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE attributes_at_id_seq OWNED BY attributes.at_id;


--
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE brands (
    bnd_id integer NOT NULL,
    bnd_name character varying(500) NOT NULL,
    bnd_logo_image_url character varying(500),
    bnd_marketing_description character varying(500),
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE brands OWNER TO postgres;

--
-- Name: TABLE brands; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE brands IS 'Contains brand name and ID. Expand to include other fields that we can track about who makes a product.';


--
-- Name: COLUMN brands.bnd_logo_image_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN brands.bnd_logo_image_url IS 'URL to an image containing the brand logo for display on site';


--
-- Name: COLUMN brands.bnd_marketing_description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN brands.bnd_marketing_description IS 'A story or description about this brand for display to customers';


--
-- Name: brands_bnd_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE brands_bnd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE brands_bnd_id_seq OWNER TO postgres;

--
-- Name: brands_bnd_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE brands_bnd_id_seq OWNED BY brands.bnd_id;


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


ALTER TABLE candsproducts OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE categories (
    cat_id integer NOT NULL,
    cat_name character varying(500) NOT NULL,
    cat_third_party_identifier character varying(500),
    cat_parent_cat_id integer,
    cat_active boolean,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE categories OWNER TO postgres;

--
-- Name: TABLE categories; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE categories IS 'Product categorization - a category tree is maintained by the fact that a category can have a parent.';


--
-- Name: COLUMN categories.cat_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.cat_name IS 'Display name on site for the category';


--
-- Name: COLUMN categories.cat_third_party_identifier; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.cat_third_party_identifier IS 'Full third party identifier to the category from which name, number and top_level are extracted';


--
-- Name: COLUMN categories.cat_parent_cat_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.cat_parent_cat_id IS 'Each category can have a single parent, creating a tree of categories';


--
-- Name: COLUMN categories.cat_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.cat_active IS 'Should this category be displayed and browsable on site?';


--
-- Name: COLUMN categories.last_updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN categories.last_updated IS 'The last time any of the data in this row was changed';


--
-- Name: categories_cat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE categories_cat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories_cat_id_seq OWNER TO postgres;

--
-- Name: categories_cat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE categories_cat_id_seq OWNED BY categories.cat_id;


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


ALTER TABLE im_items OWNER TO postgres;

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


ALTER TABLE im_media OWNER TO postgres;

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


ALTER TABLE im_productdata OWNER TO postgres;

--
-- Name: images; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE images (
    img_id integer NOT NULL,
    img_ma_id integer NOT NULL,
    img_pr_sku ean13,
    img_mime_type character varying(255),
    img_rank integer NOT NULL,
    img_show_on_site boolean DEFAULT true NOT NULL,
    img_width integer,
    img_height integer,
    img_file_size integer,
    img_alt_text character varying(255),
    img_description character varying(4000),
    img_source character varying(500),
    img_date_added timestamp with time zone DEFAULT now() NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT images_rank_check CHECK ((img_rank > 0))
);


ALTER TABLE images OWNER TO postgres;

--
-- Name: TABLE images; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE images IS 'Any image resource. Either a picture of a product, a manufacturer logo, or some other image for the site';


--
-- Name: COLUMN images.img_ma_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_ma_id IS 'The manufacturer associated with either the product the image is a picture of, or the manufacturer logo. Used to determine the image path.';


--
-- Name: COLUMN images.img_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_pr_sku IS 'The sku for the product the image is a picture of, if it is a product image. Null otherwise.';


--
-- Name: COLUMN images.img_mime_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_mime_type IS 'The mime-type to be displayed to the client for the image. Usually image/jpeg';


--
-- Name: COLUMN images.img_rank; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_rank IS 'Sort order on the product page (the default_image_id in products is always shown first though). Must be greater than zero, and must be unique to the sku+image combo';


--
-- Name: COLUMN images.img_show_on_site; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_show_on_site IS 'Whether to display the image on site.';


--
-- Name: COLUMN images.img_width; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_width IS 'The width in pixels';


--
-- Name: COLUMN images.img_height; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_height IS 'The height in pixels';


--
-- Name: COLUMN images.img_file_size; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_file_size IS 'Size on disk';


--
-- Name: COLUMN images.img_alt_text; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_alt_text IS 'Alt text to display on site';


--
-- Name: COLUMN images.img_description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_description IS 'Internal-only description of the image. Not shown to customers';


--
-- Name: COLUMN images.img_source; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN images.img_source IS 'Brief description of who or where we got the image from';


--
-- Name: images_img_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE images_img_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE images_img_id_seq OWNER TO postgres;

--
-- Name: images_img_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE images_img_id_seq OWNED BY images.img_id;


--
-- Name: kwikee_external_codes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE kwikee_external_codes (
    gtin character varying(14),
    external_code character varying(500),
    external_code_value character varying(500)
);


ALTER TABLE kwikee_external_codes OWNER TO postgres;

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


ALTER TABLE kwikee_nutrition OWNER TO postgres;

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


ALTER TABLE kwikee_pog OWNER TO postgres;

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


ALTER TABLE kwikee_products OWNER TO postgres;

--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE manufacturers (
    ma_id integer NOT NULL,
    ma_name character varying(500) NOT NULL,
    ma_logo_image_url character varying(500),
    ma_marketing_description character varying(500),
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE manufacturers OWNER TO postgres;

--
-- Name: TABLE manufacturers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE manufacturers IS 'Contains manufacturer name and ID. Expand to include other fields that we can track about who makes a product.';


--
-- Name: COLUMN manufacturers.ma_logo_image_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.ma_logo_image_url IS 'URL to an image containing the manufacturer logo for display on site';


--
-- Name: COLUMN manufacturers.ma_marketing_description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.ma_marketing_description IS 'A story or description about this manufacturer for display to customers';


--
-- Name: manufacturers_ma_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE manufacturers_ma_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE manufacturers_ma_id_seq OWNER TO postgres;

--
-- Name: manufacturers_ma_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE manufacturers_ma_id_seq OWNED BY manufacturers.ma_id;


--
-- Name: product_families; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_families (
    ma_id integer NOT NULL,
    ma_name character varying(255) NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE product_families OWNER TO postgres;

--
-- Name: product_families_pfl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE product_families_pfl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE product_families_pfl_id_seq OWNER TO postgres;

--
-- Name: product_families_pfl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE product_families_pfl_id_seq OWNED BY product_families.ma_id;


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
-- Name: products_stores; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products_stores (
    sku ean13 NOT NULL,
    store_id integer NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL,
    list_cost integer NOT NULL
);


ALTER TABLE products_stores OWNER TO postgres;

--
-- Name: TABLE products_stores; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE products_stores IS 'Which products are available on which stores, as well as any store specific info such as prices (and potentially merchandising overrides)';


--
-- Name: COLUMN products_stores.list_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products_stores.list_cost IS 'The price in CENTS as listed to the customer';


--
-- Name: products_suppliers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products_suppliers (
    psl_id integer NOT NULL,
    psl_pr_sku ean13 NOT NULL,
    psl_su_id integer NOT NULL,
    psl_status product_status NOT NULL,
    psl_wholesale_cost integer,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE products_suppliers OWNER TO postgres;

--
-- Name: TABLE products_suppliers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE products_suppliers IS 'Which product instances are carried by which suppliers and at what wholesale price';


--
-- Name: COLUMN products_suppliers.psl_pr_sku; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products_suppliers.psl_pr_sku IS 'Foreign key to products';


--
-- Name: COLUMN products_suppliers.psl_su_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products_suppliers.psl_su_id IS 'Foreign key to suppliers';


--
-- Name: COLUMN products_suppliers.psl_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products_suppliers.psl_status IS 'Whether we can currently buy this product from this supplier';


--
-- Name: COLUMN products_suppliers.psl_wholesale_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN products_suppliers.psl_wholesale_cost IS 'The price in CENTS we would pay to buy this product from the supplier';


--
-- Name: products_suppliers_psl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE products_suppliers_psl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products_suppliers_psl_id_seq OWNER TO postgres;

--
-- Name: products_suppliers_psl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE products_suppliers_psl_id_seq OWNED BY products_suppliers.psl_id;


--
-- Name: stores; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stores (
    so_id integer NOT NULL,
    so_name character varying(255) NOT NULL,
    so_active boolean DEFAULT true NOT NULL,
    so_date_active timestamp with time zone,
    so_address1 character varying(255),
    so_address2 character varying(255),
    so_city character varying(255),
    so_state character(2),
    so_zip_code character varying(12),
    so_phone character varying(30)
);


ALTER TABLE stores OWNER TO postgres;

--
-- Name: TABLE stores; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE stores IS 'Physical store locations. Active stores are selectable by customers on site';


--
-- Name: COLUMN stores.so_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stores.so_name IS 'Display name for the store, a brief description of the location';


--
-- Name: COLUMN stores.so_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stores.so_active IS 'Should the store be selectable and (can it take orders?)';


--
-- Name: COLUMN stores.so_date_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN stores.so_date_active IS 'When the store was/will be activated';


--
-- Name: stores_so_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE stores_so_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stores_so_id_seq OWNER TO postgres;

--
-- Name: stores_so_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stores_so_id_seq OWNED BY stores.so_id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE suppliers (
    supplier_id integer NOT NULL,
    supplier_name character varying(500) NOT NULL
);


ALTER TABLE suppliers OWNER TO postgres;

--
-- Name: TABLE suppliers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE suppliers IS 'Information about companies we directly source products from.';


--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE suppliers_supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE suppliers_supplier_id_seq OWNER TO postgres;

--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE suppliers_supplier_id_seq OWNED BY suppliers.supplier_id;


--
-- Name: atv_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attribute_values ALTER COLUMN atv_id SET DEFAULT nextval('attribute_values_atv_id_seq'::regclass);


--
-- Name: at_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attributes ALTER COLUMN at_id SET DEFAULT nextval('attributes_at_id_seq'::regclass);


--
-- Name: bnd_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY brands ALTER COLUMN bnd_id SET DEFAULT nextval('brands_bnd_id_seq'::regclass);


--
-- Name: cat_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categories ALTER COLUMN cat_id SET DEFAULT nextval('categories_cat_id_seq'::regclass);


--
-- Name: img_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY images ALTER COLUMN img_id SET DEFAULT nextval('images_img_id_seq'::regclass);


--
-- Name: ma_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY manufacturers ALTER COLUMN ma_id SET DEFAULT nextval('manufacturers_ma_id_seq'::regclass);


--
-- Name: ma_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_families ALTER COLUMN ma_id SET DEFAULT nextval('product_families_pfl_id_seq'::regclass);


--
-- Name: psl_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY products_suppliers ALTER COLUMN psl_id SET DEFAULT nextval('products_suppliers_psl_id_seq'::regclass);


--
-- Name: so_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stores ALTER COLUMN so_id SET DEFAULT nextval('stores_so_id_seq'::regclass);


--
-- Name: supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('suppliers_supplier_id_seq'::regclass);


--
-- Name: attribute_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attribute_values
    ADD CONSTRAINT attribute_values_pkey PRIMARY KEY (atv_id);


--
-- Name: attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (at_id);


--
-- Name: brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (bnd_id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (cat_id);


--
-- Name: images_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey1 PRIMARY KEY (img_id);


--
-- Name: manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (ma_id);


--
-- Name: product_families_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_families
    ADD CONSTRAINT product_families_pkey PRIMARY KEY (ma_id);


--
-- Name: products_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey1 PRIMARY KEY (pr_sku);


--
-- Name: products_stores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products_stores
    ADD CONSTRAINT products_stores_pkey PRIMARY KEY (sku, store_id);


--
-- Name: products_suppliers_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products_suppliers
    ADD CONSTRAINT products_suppliers_pkey1 PRIMARY KEY (psl_id);


--
-- Name: stores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (so_id);


--
-- Name: suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- Name: uniq_sku_image_ranks; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY images
    ADD CONSTRAINT uniq_sku_image_ranks UNIQUE (img_pr_sku, img_rank);


--
-- Name: attribute_values_atv_at_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX attribute_values_atv_at_id_idx ON attribute_values USING btree (atv_at_id);


--
-- Name: attribute_values_atv_pr_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX attribute_values_atv_pr_sku_idx ON attribute_values USING btree (atv_pr_sku);


--
-- Name: products_suppliers_psl_pr_sku_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX products_suppliers_psl_pr_sku_idx ON products_suppliers USING btree (psl_pr_sku);


--
-- Name: products_suppliers_psl_su_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX products_suppliers_psl_su_id_idx ON products_suppliers USING btree (psl_su_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: brands; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE brands FROM PUBLIC;
REVOKE ALL ON TABLE brands FROM postgres;
GRANT ALL ON TABLE brands TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE brands TO jp_readwrite;


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
-- Name: kwikee_external_codes; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE kwikee_external_codes FROM PUBLIC;
REVOKE ALL ON TABLE kwikee_external_codes FROM postgres;
GRANT ALL ON TABLE kwikee_external_codes TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE kwikee_external_codes TO jp_readwrite;


--
-- Name: kwikee_nutrition; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE kwikee_nutrition FROM PUBLIC;
REVOKE ALL ON TABLE kwikee_nutrition FROM postgres;
GRANT ALL ON TABLE kwikee_nutrition TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE kwikee_nutrition TO jp_readwrite;


--
-- Name: kwikee_pog; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE kwikee_pog FROM PUBLIC;
REVOKE ALL ON TABLE kwikee_pog FROM postgres;
GRANT ALL ON TABLE kwikee_pog TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE kwikee_pog TO jp_readwrite;


--
-- Name: kwikee_products; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE kwikee_products FROM PUBLIC;
REVOKE ALL ON TABLE kwikee_products FROM postgres;
GRANT ALL ON TABLE kwikee_products TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE kwikee_products TO jp_readwrite;


--
-- Name: manufacturers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE manufacturers FROM PUBLIC;
REVOKE ALL ON TABLE manufacturers FROM postgres;
GRANT ALL ON TABLE manufacturers TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE manufacturers TO jp_readwrite;


--
-- Name: product_families; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE product_families FROM PUBLIC;
REVOKE ALL ON TABLE product_families FROM postgres;
GRANT ALL ON TABLE product_families TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE product_families TO jp_readwrite;


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
-- Name: suppliers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE suppliers FROM PUBLIC;
REVOKE ALL ON TABLE suppliers FROM postgres;
GRANT ALL ON TABLE suppliers TO postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE suppliers TO jp_readwrite;


--
-- PostgreSQL database dump complete
--

