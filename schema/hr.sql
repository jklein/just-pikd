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


ALTER TYPE employee_type OWNER TO postgres;

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
    dpt_id integer NOT NULL,
    dpt_parent_dpt_id integer,
    dpt_owner_emp_id integer,
    dpt_name character varying(255) NOT NULL,
    dpt_mailing_list character varying(255)
);


ALTER TABLE departments OWNER TO postgres;

--
-- Name: TABLE departments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE departments IS 'Departments within the organization. The parent column creates an org chart tree. Each employee is in exactly one department';


--
-- Name: COLUMN departments.dpt_parent_dpt_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN departments.dpt_parent_dpt_id IS 'Parent ID allows creation of a directory tree';


--
-- Name: COLUMN departments.dpt_owner_emp_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN departments.dpt_owner_emp_id IS 'Each department can have one manager or owner employee. A single employee could own multiple departments';


--
-- Name: COLUMN departments.dpt_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN departments.dpt_name IS 'Display name for the department on the org chart';


--
-- Name: COLUMN departments.dpt_mailing_list; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN departments.dpt_mailing_list IS 'An email distribution list containing members of the department and sub-departments, if one exists';


--
-- Name: departments_dpt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE departments_dpt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE departments_dpt_id_seq OWNER TO postgres;

--
-- Name: departments_dpt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE departments_dpt_id_seq OWNED BY departments.dpt_id;


--
-- Name: employee_permissions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE employee_permissions (
    epr_id integer NOT NULL,
    epr_prm_id integer NOT NULL,
    epr_emp_id integer NOT NULL
);


ALTER TABLE employee_permissions OWNER TO postgres;

--
-- Name: TABLE employee_permissions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE employee_permissions IS 'Grants a permission set in the permissions table to an emp_id. Any permissions granted to an entire department should be handled by the application creating one row here per employee to keep querying fast and simple';


--
-- Name: employee_permissions_epr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_permissions_epr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employee_permissions_epr_id_seq OWNER TO postgres;

--
-- Name: employee_permissions_epr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE employee_permissions_epr_id_seq OWNED BY employee_permissions.epr_id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE employees (
    emp_id integer NOT NULL,
    emp_dpt_id integer NOT NULL,
    emp_cu_id integer,
    emp_so_id integer,
    emp_first_name character varying(255) NOT NULL,
    emp_middle_name character varying(255),
    emp_last_name character varying(255) NOT NULL,
    emp_username character varying(255) NOT NULL,
    emp_password character varying(255),
    emp_salt character varying(32),
    emp_email character varying(255) NOT NULL,
    emp_active boolean NOT NULL,
    emp_start_date timestamp with time zone DEFAULT now() NOT NULL,
    emp_term_date timestamp with time zone,
    emp_rank integer,
    emp_title character varying(255),
    emp_type employee_type
);


ALTER TABLE employees OWNER TO postgres;

--
-- Name: TABLE employees; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE employees IS 'Contains all past and previous employees';


--
-- Name: COLUMN employees.emp_dpt_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_dpt_id IS 'The department the employee works for. Foreign key to departments.department_id';


--
-- Name: COLUMN employees.emp_cu_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_cu_id IS 'The customer account this employee uses when logging into the site';


--
-- Name: COLUMN employees.emp_so_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_so_id IS 'The primary physical store where the employee works';


--
-- Name: COLUMN employees.emp_username; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_username IS 'Username the employee uses to log in to company tools';


--
-- Name: COLUMN employees.emp_password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_password IS 'Hashed password for login to company tools';


--
-- Name: COLUMN employees.emp_salt; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_salt IS 'The unique user salt for the hashed password';


--
-- Name: COLUMN employees.emp_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_active IS 'Is this person currently working for us?';


--
-- Name: COLUMN employees.emp_start_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_start_date IS 'The first (or upcoming) date the employee was/will be active';


--
-- Name: COLUMN employees.emp_term_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_term_date IS 'The date the employee became/will become inactive';


--
-- Name: COLUMN employees.emp_rank; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_rank IS 'Numerical rank for level within the organization (titles vary across teams but ranks do not)';


--
-- Name: COLUMN employees.emp_title; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_title IS 'Current or latest job title';


--
-- Name: COLUMN employees.emp_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN employees.emp_type IS 'The type of employee, such as full time or part time';


--
-- Name: employees_emp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employees_emp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employees_emp_id_seq OWNER TO postgres;

--
-- Name: employees_emp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE employees_emp_id_seq OWNED BY employees.emp_id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE permissions (
    prm_id integer NOT NULL,
    prm_name character varying(255) NOT NULL
);


ALTER TABLE permissions OWNER TO postgres;

--
-- Name: TABLE permissions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE permissions IS 'Permission sets for various admin forms. ability to view reports, edit products, etc.';


--
-- Name: COLUMN permissions.prm_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN permissions.prm_name IS 'String used in the app to identify a permission set';


--
-- Name: permissions_prm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE permissions_prm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE permissions_prm_id_seq OWNER TO postgres;

--
-- Name: permissions_prm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE permissions_prm_id_seq OWNED BY permissions.prm_id;


--
-- Name: dpt_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY departments ALTER COLUMN dpt_id SET DEFAULT nextval('departments_dpt_id_seq'::regclass);


--
-- Name: epr_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY employee_permissions ALTER COLUMN epr_id SET DEFAULT nextval('employee_permissions_epr_id_seq'::regclass);


--
-- Name: emp_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY employees ALTER COLUMN emp_id SET DEFAULT nextval('employees_emp_id_seq'::regclass);


--
-- Name: prm_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY permissions ALTER COLUMN prm_id SET DEFAULT nextval('permissions_prm_id_seq'::regclass);


--
-- Name: departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (dpt_id);


--
-- Name: employee_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY employee_permissions
    ADD CONSTRAINT employee_permissions_pkey PRIMARY KEY (epr_id);


--
-- Name: employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (emp_id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (prm_id);


--
-- Name: unique_employee_permissions; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY employee_permissions
    ADD CONSTRAINT unique_employee_permissions UNIQUE (epr_prm_id, epr_emp_id);


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

