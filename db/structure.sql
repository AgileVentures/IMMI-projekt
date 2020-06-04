SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id bigint NOT NULL,
    street_address character varying,
    post_code character varying,
    city character varying,
    country character varying DEFAULT 'Sverige'::character varying NOT NULL,
    region_id bigint,
    addressable_type character varying,
    addressable_id bigint,
    kommun_id bigint,
    latitude double precision,
    longitude double precision,
    visibility character varying DEFAULT 'street_address'::character varying,
    mail boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: app_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_configurations (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    chair_signature_file_name character varying,
    chair_signature_content_type character varying,
    chair_signature_file_size integer,
    chair_signature_updated_at timestamp without time zone,
    shf_logo_file_name character varying,
    shf_logo_content_type character varying,
    shf_logo_file_size integer,
    shf_logo_updated_at timestamp without time zone,
    h_brand_logo_file_name character varying,
    h_brand_logo_content_type character varying,
    h_brand_logo_file_size integer,
    h_brand_logo_updated_at timestamp without time zone,
    sweden_dog_trainers_file_name character varying,
    sweden_dog_trainers_content_type character varying,
    sweden_dog_trainers_file_size integer,
    sweden_dog_trainers_updated_at timestamp without time zone,
    email_admin_new_app_received_enabled boolean DEFAULT true,
    site_name character varying DEFAULT 'Sveriges Hundföretagare'::character varying NOT NULL,
    site_meta_title character varying DEFAULT 'Hitta H-märkt hundföretag, hundinstruktör'::character varying NOT NULL,
    site_meta_description character varying DEFAULT 'Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera.'::character varying NOT NULL,
    site_meta_keywords character varying DEFAULT 'hund, hundägare, hundinstruktör, hundentreprenör, Sveriges Hundföretagare, svenskt hundföretag, etisk, H-märkt, hundkurs'::character varying NOT NULL,
    site_meta_image_width integer DEFAULT 0 NOT NULL,
    site_meta_image_height integer DEFAULT 0 NOT NULL,
    og_type character varying DEFAULT 'website'::character varying NOT NULL,
    twitter_card_type character varying DEFAULT 'summary'::character varying NOT NULL,
    facebook_app_id bigint DEFAULT 0 NOT NULL,
    site_meta_image_file_name character varying,
    site_meta_image_content_type character varying,
    site_meta_image_file_size integer,
    site_meta_image_updated_at timestamp without time zone,
    singleton_guard integer DEFAULT 0 NOT NULL,
    payment_too_soon_days integer DEFAULT 60 NOT NULL,
    membership_guideline_list_id bigint
);


--
-- Name: COLUMN app_configurations.payment_too_soon_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.app_configurations.payment_too_soon_days IS 'Warn user that they are paying too soon if payment is due more than this many days away.';


--
-- Name: app_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_configurations_id_seq OWNED BY public.app_configurations.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: business_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business_categories (
    id bigint NOT NULL,
    name character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ancestry character varying
);


--
-- Name: business_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.business_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: business_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.business_categories_id_seq OWNED BY public.business_categories.id;


--
-- Name: business_categories_shf_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business_categories_shf_applications (
    id bigint NOT NULL,
    shf_application_id bigint,
    business_category_id bigint
);


--
-- Name: business_categories_shf_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.business_categories_shf_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: business_categories_shf_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.business_categories_shf_applications_id_seq OWNED BY public.business_categories_shf_applications.id;


--
-- Name: ckeditor_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ckeditor_assets (
    id bigint NOT NULL,
    data_file_name character varying NOT NULL,
    data_content_type character varying,
    data_file_size integer,
    data_fingerprint character varying,
    type character varying(30),
    width integer,
    height integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    company_id bigint
);


--
-- Name: ckeditor_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ckeditor_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ckeditor_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ckeditor_assets_id_seq OWNED BY public.ckeditor_assets.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    name character varying,
    company_number character varying,
    phone_number character varying,
    email character varying,
    website character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    dinkurs_company_id character varying,
    show_dinkurs_events boolean,
    short_h_brand_url character varying,
    facebook_url character varying,
    instagram_url character varying,
    youtube_url character varying
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: company_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.company_applications (
    id bigint NOT NULL,
    company_id bigint NOT NULL,
    shf_application_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: company_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.company_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: company_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.company_applications_id_seq OWNED BY public.company_applications.id;


--
-- Name: conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conditions (
    id bigint NOT NULL,
    class_name character varying NOT NULL,
    timing character varying,
    config text DEFAULT '--- {}'::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: COLUMN conditions.class_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.conditions.class_name IS 'name of the Condition class of this condition (required)';


--
-- Name: COLUMN conditions.timing; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.conditions.timing IS '(optional) specific timing about the Condition';


--
-- Name: COLUMN conditions.config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.conditions.config IS 'a serialize Hash with configuration information (required; must be a Hash)';


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conditions_id_seq OWNED BY public.conditions.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    fee numeric(8,2),
    start_date date,
    location text,
    description text,
    dinkurs_id character varying,
    name character varying,
    sign_up_url character varying,
    place character varying,
    latitude double precision,
    longitude double precision,
    company_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: file_delivery_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_delivery_methods (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description_sv character varying,
    description_en character varying,
    default_option boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE file_delivery_methods; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.file_delivery_methods IS 'User choices for how files for SHF application will be delivered';


--
-- Name: file_delivery_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_delivery_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_delivery_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_delivery_methods_id_seq OWNED BY public.file_delivery_methods.id;


--
-- Name: kommuns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kommuns (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: kommuns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kommuns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kommuns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kommuns_id_seq OWNED BY public.kommuns.id;


--
-- Name: master_checklist_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_checklist_types (
    id bigint NOT NULL,
    name character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: master_checklist_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_checklist_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_checklist_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_checklist_types_id_seq OWNED BY public.master_checklist_types.id;


--
-- Name: master_checklists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_checklists (
    id bigint NOT NULL,
    name character varying NOT NULL,
    displayed_text character varying NOT NULL,
    description character varying,
    list_position integer DEFAULT 0 NOT NULL,
    ancestry character varying,
    notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_in_use boolean DEFAULT true NOT NULL,
    is_in_use_changed_at timestamp without time zone,
    master_checklist_type_id bigint NOT NULL
);


--
-- Name: COLUMN master_checklists.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.master_checklists.name IS 'This is a shortened way to refer to the item.';


--
-- Name: COLUMN master_checklists.displayed_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.master_checklists.displayed_text IS 'This is what users see';


--
-- Name: COLUMN master_checklists.list_position; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.master_checklists.list_position IS 'This is zero-based. It is the order (position) that this item should appear in its checklist';


--
-- Name: COLUMN master_checklists.notes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.master_checklists.notes IS 'Notes about this item.';


--
-- Name: master_checklists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_checklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_checklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_checklists_id_seq OWNED BY public.master_checklists.id;


--
-- Name: member_app_waiting_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.member_app_waiting_reasons (
    id bigint NOT NULL,
    name_sv character varying,
    description_sv character varying,
    name_en character varying,
    description_en character varying,
    is_custom boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE member_app_waiting_reasons; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.member_app_waiting_reasons IS 'reasons why SHF is waiting for more info from applicant. Add more columns when more locales needed.';


--
-- Name: COLUMN member_app_waiting_reasons.name_sv; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.member_app_waiting_reasons.name_sv IS 'name of the reason in svenska/Swedish';


--
-- Name: COLUMN member_app_waiting_reasons.description_sv; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.member_app_waiting_reasons.description_sv IS 'description for the reason in svenska/Swedish';


--
-- Name: COLUMN member_app_waiting_reasons.name_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.member_app_waiting_reasons.name_en IS 'name of the reason in engelsk/English';


--
-- Name: COLUMN member_app_waiting_reasons.description_en; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.member_app_waiting_reasons.description_en IS 'description for the reason in engelsk/English';


--
-- Name: COLUMN member_app_waiting_reasons.is_custom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.member_app_waiting_reasons.is_custom IS 'was this entered as a new ''custom'' reason?';


--
-- Name: member_app_waiting_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.member_app_waiting_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_app_waiting_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.member_app_waiting_reasons_id_seq OWNED BY public.member_app_waiting_reasons.id;


--
-- Name: member_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.member_pages (
    id bigint NOT NULL,
    filename character varying NOT NULL,
    title character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: member_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.member_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.member_pages_id_seq OWNED BY public.member_pages.id;


--
-- Name: membership_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.membership_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: one_time_tasker_task_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.one_time_tasker_task_attempts (
    id bigint NOT NULL,
    task_name character varying NOT NULL,
    task_source character varying,
    attempted_on timestamp without time zone NOT NULL,
    was_successful boolean DEFAULT false NOT NULL,
    notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: one_time_tasker_task_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.one_time_tasker_task_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: one_time_tasker_task_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.one_time_tasker_task_attempts_id_seq OWNED BY public.one_time_tasker_task_attempts.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    payment_type character varying,
    status character varying,
    hips_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    start_date date,
    expire_date date,
    notes text
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regions (
    id bigint NOT NULL,
    name character varying,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shf_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shf_applications (
    id bigint NOT NULL,
    phone_number character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint,
    contact_email character varying,
    state character varying DEFAULT 'new'::character varying,
    member_app_waiting_reasons_id integer,
    custom_reason_text character varying,
    when_approved timestamp without time zone,
    file_delivery_method_id bigint,
    file_delivery_selection_date date,
    uploaded_files_count integer DEFAULT 0 NOT NULL
);


--
-- Name: shf_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shf_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shf_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shf_applications_id_seq OWNED BY public.shf_applications.id;


--
-- Name: shf_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shf_documents (
    id bigint NOT NULL,
    uploader_id bigint NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    actual_file_file_name character varying,
    actual_file_content_type character varying,
    actual_file_file_size integer,
    actual_file_updated_at timestamp without time zone
);


--
-- Name: shf_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shf_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shf_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shf_documents_id_seq OWNED BY public.shf_documents.id;


--
-- Name: uploaded_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploaded_files (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    actual_file_file_name character varying,
    actual_file_content_type character varying,
    actual_file_file_size integer,
    actual_file_updated_at timestamp without time zone,
    shf_application_id bigint
);


--
-- Name: uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploaded_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploaded_files_id_seq OWNED BY public.uploaded_files.id;


--
-- Name: user_checklists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_checklists (
    id bigint NOT NULL,
    user_id bigint,
    master_checklist_id bigint,
    name character varying NOT NULL,
    description character varying,
    date_completed timestamp without time zone,
    ancestry character varying,
    list_position integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: COLUMN user_checklists.list_position; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_checklists.list_position IS 'This is zero-based. It is the order (position) that this item should appear in its checklist';


--
-- Name: user_checklists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_checklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_checklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_checklists_id_seq OWNED BY public.user_checklists.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    admin boolean DEFAULT false,
    first_name character varying,
    last_name character varying,
    membership_number character varying,
    member boolean DEFAULT false,
    member_photo_file_name character varying,
    member_photo_content_type character varying,
    member_photo_file_size integer,
    member_photo_updated_at timestamp without time zone,
    short_proof_of_membership_url character varying,
    date_membership_packet_sent timestamp without time zone
);


--
-- Name: COLUMN users.date_membership_packet_sent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.date_membership_packet_sent IS 'When the user was sent a membership welcome packet';


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: app_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_configurations ALTER COLUMN id SET DEFAULT nextval('public.app_configurations_id_seq'::regclass);


--
-- Name: business_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_categories ALTER COLUMN id SET DEFAULT nextval('public.business_categories_id_seq'::regclass);


--
-- Name: business_categories_shf_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_categories_shf_applications ALTER COLUMN id SET DEFAULT nextval('public.business_categories_shf_applications_id_seq'::regclass);


--
-- Name: ckeditor_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ckeditor_assets ALTER COLUMN id SET DEFAULT nextval('public.ckeditor_assets_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: company_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_applications ALTER COLUMN id SET DEFAULT nextval('public.company_applications_id_seq'::regclass);


--
-- Name: conditions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions ALTER COLUMN id SET DEFAULT nextval('public.conditions_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: file_delivery_methods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_delivery_methods ALTER COLUMN id SET DEFAULT nextval('public.file_delivery_methods_id_seq'::regclass);


--
-- Name: kommuns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kommuns ALTER COLUMN id SET DEFAULT nextval('public.kommuns_id_seq'::regclass);


--
-- Name: master_checklist_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_checklist_types ALTER COLUMN id SET DEFAULT nextval('public.master_checklist_types_id_seq'::regclass);


--
-- Name: master_checklists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_checklists ALTER COLUMN id SET DEFAULT nextval('public.master_checklists_id_seq'::regclass);


--
-- Name: member_app_waiting_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_app_waiting_reasons ALTER COLUMN id SET DEFAULT nextval('public.member_app_waiting_reasons_id_seq'::regclass);


--
-- Name: member_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_pages ALTER COLUMN id SET DEFAULT nextval('public.member_pages_id_seq'::regclass);


--
-- Name: one_time_tasker_task_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.one_time_tasker_task_attempts ALTER COLUMN id SET DEFAULT nextval('public.one_time_tasker_task_attempts_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: regions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions ALTER COLUMN id SET DEFAULT nextval('public.regions_id_seq'::regclass);


--
-- Name: shf_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shf_applications ALTER COLUMN id SET DEFAULT nextval('public.shf_applications_id_seq'::regclass);


--
-- Name: shf_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shf_documents ALTER COLUMN id SET DEFAULT nextval('public.shf_documents_id_seq'::regclass);


--
-- Name: uploaded_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_files ALTER COLUMN id SET DEFAULT nextval('public.uploaded_files_id_seq'::regclass);


--
-- Name: user_checklists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_checklists ALTER COLUMN id SET DEFAULT nextval('public.user_checklists_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: app_configurations app_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_configurations
    ADD CONSTRAINT app_configurations_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: business_categories business_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_categories
    ADD CONSTRAINT business_categories_pkey PRIMARY KEY (id);


--
-- Name: business_categories_shf_applications business_categories_shf_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_categories_shf_applications
    ADD CONSTRAINT business_categories_shf_applications_pkey PRIMARY KEY (id);


--
-- Name: ckeditor_assets ckeditor_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ckeditor_assets
    ADD CONSTRAINT ckeditor_assets_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: company_applications company_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_applications
    ADD CONSTRAINT company_applications_pkey PRIMARY KEY (id);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: file_delivery_methods file_delivery_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_delivery_methods
    ADD CONSTRAINT file_delivery_methods_pkey PRIMARY KEY (id);


--
-- Name: kommuns kommuns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kommuns
    ADD CONSTRAINT kommuns_pkey PRIMARY KEY (id);


--
-- Name: master_checklist_types master_checklist_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_checklist_types
    ADD CONSTRAINT master_checklist_types_pkey PRIMARY KEY (id);


--
-- Name: master_checklists master_checklists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_checklists
    ADD CONSTRAINT master_checklists_pkey PRIMARY KEY (id);


--
-- Name: member_app_waiting_reasons member_app_waiting_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_app_waiting_reasons
    ADD CONSTRAINT member_app_waiting_reasons_pkey PRIMARY KEY (id);


--
-- Name: member_pages member_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_pages
    ADD CONSTRAINT member_pages_pkey PRIMARY KEY (id);


--
-- Name: one_time_tasker_task_attempts one_time_tasker_task_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.one_time_tasker_task_attempts
    ADD CONSTRAINT one_time_tasker_task_attempts_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shf_applications shf_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shf_applications
    ADD CONSTRAINT shf_applications_pkey PRIMARY KEY (id);


--
-- Name: shf_documents shf_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shf_documents
    ADD CONSTRAINT shf_documents_pkey PRIMARY KEY (id);


--
-- Name: uploaded_files uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_files
    ADD CONSTRAINT uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: user_checklists user_checklists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_checklists
    ADD CONSTRAINT user_checklists_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_addresses_on_addressable_type_and_addressable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_addressable_type_and_addressable_id ON public.addresses USING btree (addressable_type, addressable_id);


--
-- Name: index_addresses_on_kommun_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_kommun_id ON public.addresses USING btree (kommun_id);


--
-- Name: index_addresses_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_latitude_and_longitude ON public.addresses USING btree (latitude, longitude);


--
-- Name: index_addresses_on_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_region_id ON public.addresses USING btree (region_id);


--
-- Name: index_app_configurations_on_membership_guideline_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_app_configurations_on_membership_guideline_list_id ON public.app_configurations USING btree (membership_guideline_list_id);


--
-- Name: index_app_configurations_on_singleton_guard; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_app_configurations_on_singleton_guard ON public.app_configurations USING btree (singleton_guard);


--
-- Name: index_business_categories_on_ancestry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_business_categories_on_ancestry ON public.business_categories USING btree (ancestry);


--
-- Name: index_ckeditor_assets_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ckeditor_assets_on_company_id ON public.ckeditor_assets USING btree (company_id);


--
-- Name: index_ckeditor_assets_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ckeditor_assets_on_type ON public.ckeditor_assets USING btree (type);


--
-- Name: index_companies_on_company_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_company_number ON public.companies USING btree (company_number);


--
-- Name: index_company_applications_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_company_applications_on_company_id ON public.company_applications USING btree (company_id);


--
-- Name: index_company_applications_on_shf_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_company_applications_on_shf_application_id ON public.company_applications USING btree (shf_application_id);


--
-- Name: index_events_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_company_id ON public.events USING btree (company_id);


--
-- Name: index_events_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_latitude_and_longitude ON public.events USING btree (latitude, longitude);


--
-- Name: index_events_on_start_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_start_date ON public.events USING btree (start_date);


--
-- Name: index_file_delivery_methods_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_delivery_methods_on_name ON public.file_delivery_methods USING btree (name);


--
-- Name: index_master_checklists_on_ancestry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_master_checklists_on_ancestry ON public.master_checklists USING btree (ancestry);


--
-- Name: index_master_checklists_on_master_checklist_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_master_checklists_on_master_checklist_type_id ON public.master_checklists USING btree (master_checklist_type_id);


--
-- Name: index_master_checklists_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_master_checklists_on_name ON public.master_checklists USING btree (name);


--
-- Name: index_on_applications; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_applications ON public.business_categories_shf_applications USING btree (shf_application_id);


--
-- Name: index_on_categories; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_categories ON public.business_categories_shf_applications USING btree (business_category_id);


--
-- Name: index_payments_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_company_id ON public.payments USING btree (company_id);


--
-- Name: index_payments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_user_id ON public.payments USING btree (user_id);


--
-- Name: index_shf_applications_on_file_delivery_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shf_applications_on_file_delivery_method_id ON public.shf_applications USING btree (file_delivery_method_id);


--
-- Name: index_shf_applications_on_member_app_waiting_reasons_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shf_applications_on_member_app_waiting_reasons_id ON public.shf_applications USING btree (member_app_waiting_reasons_id);


--
-- Name: index_shf_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shf_applications_on_user_id ON public.shf_applications USING btree (user_id);


--
-- Name: index_shf_documents_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shf_documents_on_uploader_id ON public.shf_documents USING btree (uploader_id);


--
-- Name: index_uploaded_files_on_shf_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploaded_files_on_shf_application_id ON public.uploaded_files USING btree (shf_application_id);


--
-- Name: index_user_checklists_on_ancestry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_checklists_on_ancestry ON public.user_checklists USING btree (ancestry);


--
-- Name: index_user_checklists_on_master_checklist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_checklists_on_master_checklist_id ON public.user_checklists USING btree (master_checklist_id);


--
-- Name: index_user_checklists_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_checklists_on_user_id ON public.user_checklists USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_membership_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_membership_number ON public.users USING btree (membership_number);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: payments fk_rails_081dc04a02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_rails_081dc04a02 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payments fk_rails_0fc68a9316; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_rails_0fc68a9316 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: ckeditor_assets fk_rails_1b8d2a3863; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ckeditor_assets
    ADD CONSTRAINT fk_rails_1b8d2a3863 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: uploaded_files fk_rails_2224289299; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_files
    ADD CONSTRAINT fk_rails_2224289299 FOREIGN KEY (shf_application_id) REFERENCES public.shf_applications(id);


--
-- Name: shf_applications fk_rails_3ee395b045; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shf_applications
    ADD CONSTRAINT fk_rails_3ee395b045 FOREIGN KEY (member_app_waiting_reasons_id) REFERENCES public.member_app_waiting_reasons(id);


--
-- Name: app_configurations fk_rails_488f5a5802; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_configurations
    ADD CONSTRAINT fk_rails_488f5a5802 FOREIGN KEY (membership_guideline_list_id) REFERENCES public.master_checklists(id);


--
-- Name: user_checklists fk_rails_4ff2e06edf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_checklists
    ADD CONSTRAINT fk_rails_4ff2e06edf FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: addresses fk_rails_76a66052a5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT fk_rails_76a66052a5 FOREIGN KEY (kommun_id) REFERENCES public.kommuns(id);


--
-- Name: events fk_rails_88786fdf2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT fk_rails_88786fdf2d FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: shf_documents fk_rails_bb6df17516; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shf_documents
    ADD CONSTRAINT fk_rails_bb6df17516 FOREIGN KEY (uploader_id) REFERENCES public.users(id);


--
-- Name: shf_applications fk_rails_be394644c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shf_applications
    ADD CONSTRAINT fk_rails_be394644c4 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: shf_applications fk_rails_c591d9a2b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shf_applications
    ADD CONSTRAINT fk_rails_c591d9a2b0 FOREIGN KEY (file_delivery_method_id) REFERENCES public.file_delivery_methods(id);


--
-- Name: company_applications fk_rails_cf393e2864; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_applications
    ADD CONSTRAINT fk_rails_cf393e2864 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: company_applications fk_rails_cfd957fb2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_applications
    ADD CONSTRAINT fk_rails_cfd957fb2a FOREIGN KEY (shf_application_id) REFERENCES public.shf_applications(id);


--
-- Name: user_checklists fk_rails_e1e5ab0568; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_checklists
    ADD CONSTRAINT fk_rails_e1e5ab0568 FOREIGN KEY (master_checklist_id) REFERENCES public.master_checklists(id);


--
-- Name: master_checklists fk_rails_eeb183e3fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_checklists
    ADD CONSTRAINT fk_rails_eeb183e3fb FOREIGN KEY (master_checklist_type_id) REFERENCES public.master_checklist_types(id);


--
-- Name: addresses fk_rails_f7aa0f06a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT fk_rails_f7aa0f06a9 FOREIGN KEY (region_id) REFERENCES public.regions(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20161110203212'),
('20161111183945'),
('20161111185238'),
('20161112171216'),
('20161113110952'),
('20161119045729'),
('20161119050754'),
('20161119074645'),
('20161128080706'),
('20161129012732'),
('20161129022533'),
('20161130012213'),
('20161130042130'),
('20161130122729'),
('20161201022139'),
('20161201061301'),
('20161202101242'),
('20161206020021'),
('20161218040617'),
('20161228160416'),
('20161228160857'),
('20161228161607'),
('20161228185350'),
('20170104233630'),
('20170207183100'),
('20170207191717'),
('20170220223441'),
('20170222090742'),
('20170305120412'),
('20170305130437'),
('20170305190917'),
('20170310102947'),
('20170310224421'),
('20170312125058'),
('20170316182702'),
('20170323202941'),
('20170324015417'),
('20170418213009'),
('20170507103334'),
('20170525201944'),
('20170615091313'),
('20170704095534'),
('20170918123414'),
('20170919120008'),
('20170920153643'),
('20170922144510'),
('20171005113112'),
('20171013141538'),
('20171025191957'),
('20171026103648'),
('20171109142139'),
('20171120170441'),
('20171213174816'),
('20180103171241'),
('20180110215208'),
('20180116141245'),
('20180219132317'),
('20180326103433'),
('20180328105100'),
('20180428103625'),
('20180624155644'),
('20180717043851'),
('20180719021503'),
('20181203121315'),
('20181214011549'),
('20181228073947'),
('20181229015347'),
('20190123143128'),
('20190123144623'),
('20190128210825'),
('20190312204251'),
('20190326120854'),
('20190514172102'),
('20190601004310'),
('20190616183023'),
('20190815215041'),
('20190830212208'),
('20191030162238'),
('20191130225826'),
('20191204203416'),
('20200108194625'),
('20200119054308'),
('20200122200839'),
('20200122215813'),
('20200205213528');


