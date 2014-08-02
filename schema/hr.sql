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
-- Name: hr; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE hr IS 'Data related to employees and the org chart';


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
-- Name: employee_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE employee_type AS ENUM (
    'Full Time',
    'Part Time',
    'Intern'
);


ALTER TYPE public.employee_type OWNER TO postgres;

--
-- Name: TYPE employee_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE employee_type IS 'Type of employee, such as full time or part time';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE departments (
    department_id integer NOT NULL,
    department_name character varying(255) NOT NULL,
    parent_department_id integer,
    owner_employee_id integer,
    mailing_list character varying(255)
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: TABLE departments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE departments IS 'Departments within the organization. The parent column creates an org chart tree. Each employee is in exactly one department';


--
-- Name: COLUMN departments.department_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN departments.department_name IS 'Display name for the department on the org chart';


--
-- Name: COLUMN departments.parent_department_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN departments.parent_department_id IS 'Parent ID allows creation of a directory tree';


--
-- Name: COLUMN departments.owner_employee_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN departments.owner_employee_id IS 'Each department can have one manager or owner employee. A single employee could own multiple departments';


--
-- Name: COLUMN departments.mailing_list; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN departments.mailing_list IS 'An email distribution list containing members of the department and sub-departments, if one exists';


--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE departments_department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departments_department_id_seq OWNER TO postgres;

--
-- Name: departments_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE departments_department_id_seq OWNED BY departments.department_id;


--
-- Name: employee_permissions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE employee_permissions (
    permissions_id integer NOT NULL,
    employee_id integer NOT NULL
);


ALTER TABLE public.employee_permissions OWNER TO postgres;

--
-- Name: TABLE employee_permissions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE employee_permissions IS 'Grants a permission set in the permissions table to an employee_id. Any permissions granted to an entire department should be handled by the application creating one row here per employee to keep querying fast and simple';


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE employees (
    employee_id integer NOT NULL,
    department_id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255),
    last_name character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255),
    email character varying(255) NOT NULL,
    active boolean NOT NULL,
    start_date timestamp with time zone DEFAULT now() NOT NULL,
    term_date timestamp with time zone,
    rank integer,
    title character varying(255),
    type employee_type,
    customer_id integer,
    store_id integer,
    birthday date
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: TABLE employees; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE employees IS 'Contains all past and previous employees';


--
-- Name: COLUMN employees.department_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.department_id IS 'The department the employee works for. Foreign key to departments.department_id';


--
-- Name: COLUMN employees.username; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.username IS 'Username the employee uses to log in to company tools';


--
-- Name: COLUMN employees.password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.password IS 'Hashed password for login to company tools';


--
-- Name: COLUMN employees.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.active IS 'Is this person currently working for us?';


--
-- Name: COLUMN employees.start_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.start_date IS 'The first (or upcoming) date the employee was/will be active';


--
-- Name: COLUMN employees.term_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.term_date IS 'The date the employee became/will become inactive';


--
-- Name: COLUMN employees.rank; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.rank IS 'Numerical rank for level within the organization (titles vary across teams but ranks do not)';


--
-- Name: COLUMN employees.title; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.title IS 'Current or latest job title';


--
-- Name: COLUMN employees.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.type IS 'The type of employee, such as full time or part time';


--
-- Name: COLUMN employees.customer_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.customer_id IS 'The customer account this employee uses when logging into the site';


--
-- Name: COLUMN employees.store_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.store_id IS 'The primary physical store where the employee works';


--
-- Name: COLUMN employees.birthday; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.birthday IS 'The day and month portion of the birthday only. The year should always be set to 2000.';


--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employees_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employees_employee_id_seq OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE employees_employee_id_seq OWNED BY employees.employee_id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE permissions (
    permissions_id integer NOT NULL,
    permissions_name character varying(255) NOT NULL
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: TABLE permissions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE permissions IS 'Permission sets for various admin forms. ability to view reports, edit base_products, etc.';


--
-- Name: permissions_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE permissions_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permissions_permissions_id_seq OWNER TO postgres;

--
-- Name: permissions_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE permissions_permissions_id_seq OWNED BY permissions.permissions_id;


--
-- Name: department_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY departments ALTER COLUMN department_id SET DEFAULT nextval('departments_department_id_seq'::regclass);


--
-- Name: employee_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY employees ALTER COLUMN employee_id SET DEFAULT nextval('employees_employee_id_seq'::regclass);


--
-- Name: permissions_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY permissions ALTER COLUMN permissions_id SET DEFAULT nextval('permissions_permissions_id_seq'::regclass);


--
-- Name: departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: employee_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY employee_permissions
    ADD CONSTRAINT employee_permissions_pkey PRIMARY KEY (permissions_id, employee_id);


--
-- Name: employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (permissions_id);


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

