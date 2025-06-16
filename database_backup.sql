--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

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
-- Name: claim_reason_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.claim_reason_enum AS ENUM (
    'missing_item',
    'wrong_item',
    'production_failure',
    'other'
);


ALTER TYPE public.claim_reason_enum OWNER TO postgres;

--
-- Name: order_claim_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_claim_type_enum AS ENUM (
    'refund',
    'replace'
);


ALTER TYPE public.order_claim_type_enum OWNER TO postgres;

--
-- Name: order_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status_enum AS ENUM (
    'pending',
    'completed',
    'draft',
    'archived',
    'canceled',
    'requires_action'
);


ALTER TYPE public.order_status_enum OWNER TO postgres;

--
-- Name: return_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.return_status_enum AS ENUM (
    'open',
    'requested',
    'received',
    'partially_received',
    'canceled'
);


ALTER TYPE public.return_status_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_holder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_holder (
    id text NOT NULL,
    provider_id text NOT NULL,
    external_id text NOT NULL,
    email text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.account_holder OWNER TO postgres;

--
-- Name: api_key; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_key (
    id text NOT NULL,
    token text NOT NULL,
    salt text NOT NULL,
    redacted text NOT NULL,
    title text NOT NULL,
    type text NOT NULL,
    last_used_at timestamp with time zone,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_by text,
    revoked_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT api_key_type_check CHECK ((type = ANY (ARRAY['publishable'::text, 'secret'::text])))
);


ALTER TABLE public.api_key OWNER TO postgres;

--
-- Name: application_method_buy_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.application_method_buy_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.application_method_buy_rules OWNER TO postgres;

--
-- Name: application_method_target_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.application_method_target_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.application_method_target_rules OWNER TO postgres;

--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_identity (
    id text NOT NULL,
    app_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.auth_identity OWNER TO postgres;

--
-- Name: capture; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.capture (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb
);


ALTER TABLE public.capture OWNER TO postgres;

--
-- Name: cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart (
    id text NOT NULL,
    region_id text,
    customer_id text,
    sales_channel_id text,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone
);


ALTER TABLE public.cart OWNER TO postgres;

--
-- Name: cart_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_address OWNER TO postgres;

--
-- Name: cart_line_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_line_item (
    id text NOT NULL,
    cart_id text NOT NULL,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    quantity integer NOT NULL,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    product_type_id text,
    is_custom_price boolean DEFAULT false NOT NULL,
    is_giftcard boolean DEFAULT false NOT NULL,
    CONSTRAINT cart_line_item_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.cart_line_item OWNER TO postgres;

--
-- Name: cart_line_item_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text,
    CONSTRAINT cart_line_item_adjustment_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.cart_line_item_adjustment OWNER TO postgres;

--
-- Name: cart_line_item_tax_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text
);


ALTER TABLE public.cart_line_item_tax_line OWNER TO postgres;

--
-- Name: cart_payment_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_payment_collection (
    cart_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_payment_collection OWNER TO postgres;

--
-- Name: cart_promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_promotion (
    cart_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_promotion OWNER TO postgres;

--
-- Name: cart_shipping_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_shipping_method (
    id text NOT NULL,
    cart_id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT cart_shipping_method_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.cart_shipping_method OWNER TO postgres;

--
-- Name: cart_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


ALTER TABLE public.cart_shipping_method_adjustment OWNER TO postgres;

--
-- Name: cart_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


ALTER TABLE public.cart_shipping_method_tax_line OWNER TO postgres;

--
-- Name: credit_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credit_line (
    id text NOT NULL,
    cart_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.credit_line OWNER TO postgres;

--
-- Name: currency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.currency (
    code text NOT NULL,
    symbol text NOT NULL,
    symbol_native text NOT NULL,
    decimal_digits integer DEFAULT 0 NOT NULL,
    rounding numeric DEFAULT 0 NOT NULL,
    raw_rounding jsonb NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.currency OWNER TO postgres;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    id text NOT NULL,
    company_name text,
    first_name text,
    last_name text,
    email text,
    phone text,
    has_account boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- Name: customer_account_holder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_account_holder (
    customer_id character varying(255) NOT NULL,
    account_holder_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_account_holder OWNER TO postgres;

--
-- Name: customer_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_address (
    id text NOT NULL,
    customer_id text NOT NULL,
    address_name text,
    is_default_shipping boolean DEFAULT false NOT NULL,
    is_default_billing boolean DEFAULT false NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_address OWNER TO postgres;

--
-- Name: customer_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_group (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    created_by text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_group OWNER TO postgres;

--
-- Name: customer_group_customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_group_customer (
    id text NOT NULL,
    customer_id text NOT NULL,
    customer_group_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_group_customer OWNER TO postgres;

--
-- Name: fulfillment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment (
    id text NOT NULL,
    location_id text NOT NULL,
    packed_at timestamp with time zone,
    shipped_at timestamp with time zone,
    delivered_at timestamp with time zone,
    canceled_at timestamp with time zone,
    data jsonb,
    provider_id text,
    shipping_option_id text,
    metadata jsonb,
    delivery_address_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    marked_shipped_by text,
    created_by text,
    requires_shipping boolean DEFAULT true NOT NULL
);


ALTER TABLE public.fulfillment OWNER TO postgres;

--
-- Name: fulfillment_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_address (
    id text NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_address OWNER TO postgres;

--
-- Name: fulfillment_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_item (
    id text NOT NULL,
    title text NOT NULL,
    sku text NOT NULL,
    barcode text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    line_item_id text,
    inventory_item_id text,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_item OWNER TO postgres;

--
-- Name: fulfillment_label; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_label (
    id text NOT NULL,
    tracking_number text NOT NULL,
    tracking_url text NOT NULL,
    label_url text NOT NULL,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_label OWNER TO postgres;

--
-- Name: fulfillment_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_provider OWNER TO postgres;

--
-- Name: fulfillment_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_set (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_set OWNER TO postgres;

--
-- Name: geo_zone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.geo_zone (
    id text NOT NULL,
    type text DEFAULT 'country'::text NOT NULL,
    country_code text NOT NULL,
    province_code text,
    city text,
    service_zone_id text NOT NULL,
    postal_expression jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT geo_zone_type_check CHECK ((type = ANY (ARRAY['country'::text, 'province'::text, 'city'::text, 'zip'::text])))
);


ALTER TABLE public.geo_zone OWNER TO postgres;

--
-- Name: image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image (
    id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    rank integer DEFAULT 0 NOT NULL,
    product_id text NOT NULL
);


ALTER TABLE public.image OWNER TO postgres;

--
-- Name: inventory_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    sku text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    requires_shipping boolean DEFAULT true NOT NULL,
    description text,
    title text,
    thumbnail text,
    metadata jsonb
);


ALTER TABLE public.inventory_item OWNER TO postgres;

--
-- Name: inventory_level; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_level (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    inventory_item_id text NOT NULL,
    location_id text NOT NULL,
    stocked_quantity numeric DEFAULT 0 NOT NULL,
    reserved_quantity numeric DEFAULT 0 NOT NULL,
    incoming_quantity numeric DEFAULT 0 NOT NULL,
    metadata jsonb,
    raw_stocked_quantity jsonb,
    raw_reserved_quantity jsonb,
    raw_incoming_quantity jsonb
);


ALTER TABLE public.inventory_level OWNER TO postgres;

--
-- Name: invite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invite (
    id text NOT NULL,
    email text NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.invite OWNER TO postgres;

--
-- Name: link_module_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.link_module_migrations (
    id integer NOT NULL,
    table_name character varying(255) NOT NULL,
    link_descriptor jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.link_module_migrations OWNER TO postgres;

--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.link_module_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.link_module_migrations_id_seq OWNER TO postgres;

--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.link_module_migrations_id_seq OWNED BY public.link_module_migrations.id;


--
-- Name: location_fulfillment_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location_fulfillment_provider (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.location_fulfillment_provider OWNER TO postgres;

--
-- Name: location_fulfillment_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location_fulfillment_set (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.location_fulfillment_set OWNER TO postgres;

--
-- Name: mikro_orm_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mikro_orm_migrations (
    id integer NOT NULL,
    name character varying(255),
    executed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.mikro_orm_migrations OWNER TO postgres;

--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mikro_orm_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mikro_orm_migrations_id_seq OWNER TO postgres;

--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mikro_orm_migrations_id_seq OWNED BY public.mikro_orm_migrations.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id text NOT NULL,
    "to" text NOT NULL,
    channel text NOT NULL,
    template text NOT NULL,
    data jsonb,
    trigger_type text,
    resource_id text,
    resource_type text,
    receiver_id text,
    original_notification_id text,
    idempotency_key text,
    external_id text,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'pending'::text NOT NULL,
    CONSTRAINT notification_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'success'::text, 'failure'::text])))
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: notification_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_provider (
    id text NOT NULL,
    handle text NOT NULL,
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    channels text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.notification_provider OWNER TO postgres;

--
-- Name: order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."order" (
    id text NOT NULL,
    region_id text,
    display_id integer,
    customer_id text,
    version integer DEFAULT 1 NOT NULL,
    sales_channel_id text,
    status public.order_status_enum DEFAULT 'pending'::public.order_status_enum NOT NULL,
    is_draft_order boolean DEFAULT false NOT NULL,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    no_notification boolean,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone
);


ALTER TABLE public."order" OWNER TO postgres;

--
-- Name: order_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_address OWNER TO postgres;

--
-- Name: order_cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_cart (
    order_id character varying(255) NOT NULL,
    cart_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_cart OWNER TO postgres;

--
-- Name: order_change; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_change (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    description text,
    status text DEFAULT 'pending'::text NOT NULL,
    internal_note text,
    created_by text,
    requested_by text,
    requested_at timestamp with time zone,
    confirmed_by text,
    confirmed_at timestamp with time zone,
    declined_by text,
    declined_reason text,
    metadata jsonb,
    declined_at timestamp with time zone,
    canceled_by text,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    change_type text,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text,
    CONSTRAINT order_change_status_check CHECK ((status = ANY (ARRAY['confirmed'::text, 'declined'::text, 'requested'::text, 'pending'::text, 'canceled'::text])))
);


ALTER TABLE public.order_change OWNER TO postgres;

--
-- Name: order_change_action; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_change_action (
    id text NOT NULL,
    order_id text,
    version integer,
    ordering bigint NOT NULL,
    order_change_id text,
    reference text,
    reference_id text,
    action text NOT NULL,
    details jsonb,
    amount numeric,
    raw_amount jsonb,
    internal_note text,
    applied boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_change_action OWNER TO postgres;

--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_change_action_ordering_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_change_action_ordering_seq OWNER TO postgres;

--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_change_action_ordering_seq OWNED BY public.order_change_action.ordering;


--
-- Name: order_claim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_claim (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    type public.order_claim_type_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.order_claim OWNER TO postgres;

--
-- Name: order_claim_display_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_claim_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_claim_display_id_seq OWNER TO postgres;

--
-- Name: order_claim_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_claim_display_id_seq OWNED BY public.order_claim.display_id;


--
-- Name: order_claim_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_claim_item (
    id text NOT NULL,
    claim_id text NOT NULL,
    item_id text NOT NULL,
    is_additional_item boolean DEFAULT false NOT NULL,
    reason public.claim_reason_enum,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_claim_item OWNER TO postgres;

--
-- Name: order_claim_item_image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_claim_item_image (
    id text NOT NULL,
    claim_item_id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_claim_item_image OWNER TO postgres;

--
-- Name: order_credit_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_credit_line (
    id text NOT NULL,
    order_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_credit_line OWNER TO postgres;

--
-- Name: order_display_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_display_id_seq OWNER TO postgres;

--
-- Name: order_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_display_id_seq OWNED BY public."order".display_id;


--
-- Name: order_exchange; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_exchange (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    no_notification boolean,
    allow_backorder boolean DEFAULT false NOT NULL,
    difference_due numeric,
    raw_difference_due jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.order_exchange OWNER TO postgres;

--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_exchange_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_exchange_display_id_seq OWNER TO postgres;

--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_exchange_display_id_seq OWNED BY public.order_exchange.display_id;


--
-- Name: order_exchange_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_exchange_item (
    id text NOT NULL,
    exchange_id text NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_exchange_item OWNER TO postgres;

--
-- Name: order_fulfillment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_fulfillment (
    order_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_fulfillment OWNER TO postgres;

--
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    fulfilled_quantity numeric NOT NULL,
    raw_fulfilled_quantity jsonb NOT NULL,
    shipped_quantity numeric NOT NULL,
    raw_shipped_quantity jsonb NOT NULL,
    return_requested_quantity numeric NOT NULL,
    raw_return_requested_quantity jsonb NOT NULL,
    return_received_quantity numeric NOT NULL,
    raw_return_received_quantity jsonb NOT NULL,
    return_dismissed_quantity numeric NOT NULL,
    raw_return_dismissed_quantity jsonb NOT NULL,
    written_off_quantity numeric NOT NULL,
    raw_written_off_quantity jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    delivered_quantity numeric DEFAULT 0 NOT NULL,
    raw_delivered_quantity jsonb NOT NULL,
    unit_price numeric,
    raw_unit_price jsonb,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- Name: order_line_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_line_item (
    id text NOT NULL,
    totals_id text,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_price boolean DEFAULT false NOT NULL,
    product_type_id text,
    is_giftcard boolean DEFAULT false NOT NULL
);


ALTER TABLE public.order_line_item OWNER TO postgres;

--
-- Name: order_line_item_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_line_item_adjustment OWNER TO postgres;

--
-- Name: order_line_item_tax_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_line_item_tax_line OWNER TO postgres;

--
-- Name: order_payment_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_payment_collection (
    order_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_payment_collection OWNER TO postgres;

--
-- Name: order_promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_promotion (
    order_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_promotion OWNER TO postgres;

--
-- Name: order_shipping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_shipping (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    shipping_method_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_shipping OWNER TO postgres;

--
-- Name: order_shipping_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_shipping_method (
    id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_amount boolean DEFAULT false NOT NULL
);


ALTER TABLE public.order_shipping_method OWNER TO postgres;

--
-- Name: order_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_shipping_method_adjustment OWNER TO postgres;

--
-- Name: order_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_shipping_method_tax_line OWNER TO postgres;

--
-- Name: order_summary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_summary (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    totals jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_summary OWNER TO postgres;

--
-- Name: order_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_transaction (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    reference text,
    reference_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_transaction OWNER TO postgres;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    provider_id text NOT NULL,
    data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    captured_at timestamp with time zone,
    canceled_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    payment_session_id text NOT NULL,
    metadata jsonb
);


ALTER TABLE public.payment OWNER TO postgres;

--
-- Name: payment_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_collection (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    authorized_amount numeric,
    raw_authorized_amount jsonb,
    captured_amount numeric,
    raw_captured_amount jsonb,
    refunded_amount numeric,
    raw_refunded_amount jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone,
    status text DEFAULT 'not_paid'::text NOT NULL,
    metadata jsonb,
    CONSTRAINT payment_collection_status_check CHECK ((status = ANY (ARRAY['not_paid'::text, 'awaiting'::text, 'authorized'::text, 'partially_authorized'::text, 'canceled'::text, 'failed'::text, 'completed'::text])))
);


ALTER TABLE public.payment_collection OWNER TO postgres;

--
-- Name: payment_collection_payment_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_collection_payment_providers (
    payment_collection_id text NOT NULL,
    payment_provider_id text NOT NULL
);


ALTER TABLE public.payment_collection_payment_providers OWNER TO postgres;

--
-- Name: payment_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.payment_provider OWNER TO postgres;

--
-- Name: payment_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_session (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    context jsonb,
    status text DEFAULT 'pending'::text NOT NULL,
    authorized_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT payment_session_status_check CHECK ((status = ANY (ARRAY['authorized'::text, 'captured'::text, 'pending'::text, 'requires_more'::text, 'error'::text, 'canceled'::text])))
);


ALTER TABLE public.payment_session OWNER TO postgres;

--
-- Name: price; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price (
    id text NOT NULL,
    title text,
    price_set_id text NOT NULL,
    currency_code text NOT NULL,
    raw_amount jsonb NOT NULL,
    rules_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    price_list_id text,
    amount numeric NOT NULL,
    min_quantity integer,
    max_quantity integer
);


ALTER TABLE public.price OWNER TO postgres;

--
-- Name: price_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_list (
    id text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    rules_count integer DEFAULT 0,
    title text NOT NULL,
    description text NOT NULL,
    type text DEFAULT 'sale'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT price_list_status_check CHECK ((status = ANY (ARRAY['active'::text, 'draft'::text]))),
    CONSTRAINT price_list_type_check CHECK ((type = ANY (ARRAY['sale'::text, 'override'::text])))
);


ALTER TABLE public.price_list OWNER TO postgres;

--
-- Name: price_list_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_list_rule (
    id text NOT NULL,
    price_list_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    value jsonb,
    attribute text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.price_list_rule OWNER TO postgres;

--
-- Name: price_preference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_preference (
    id text NOT NULL,
    attribute text NOT NULL,
    value text,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.price_preference OWNER TO postgres;

--
-- Name: price_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_rule (
    id text NOT NULL,
    value text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    price_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    attribute text DEFAULT ''::text NOT NULL,
    operator text DEFAULT 'eq'::text NOT NULL,
    CONSTRAINT price_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text])))
);


ALTER TABLE public.price_rule OWNER TO postgres;

--
-- Name: price_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_set (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.price_set OWNER TO postgres;

--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    subtitle text,
    description text,
    is_giftcard boolean DEFAULT false NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    thumbnail text,
    weight text,
    length text,
    height text,
    width text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    collection_id text,
    type_id text,
    discountable boolean DEFAULT true NOT NULL,
    external_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    CONSTRAINT product_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'proposed'::text, 'published'::text, 'rejected'::text])))
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_category (
    id text NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    handle text NOT NULL,
    mpath text NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    is_internal boolean DEFAULT false NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    parent_category_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);


ALTER TABLE public.product_category OWNER TO postgres;

--
-- Name: product_category_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_category_product (
    product_id text NOT NULL,
    product_category_id text NOT NULL
);


ALTER TABLE public.product_category_product OWNER TO postgres;

--
-- Name: product_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_collection (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_collection OWNER TO postgres;

--
-- Name: product_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_option (
    id text NOT NULL,
    title text NOT NULL,
    product_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_option OWNER TO postgres;

--
-- Name: product_option_value; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_option_value (
    id text NOT NULL,
    value text NOT NULL,
    option_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_option_value OWNER TO postgres;

--
-- Name: product_sales_channel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_sales_channel (
    product_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_sales_channel OWNER TO postgres;

--
-- Name: product_shipping_profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_shipping_profile (
    product_id character varying(255) NOT NULL,
    shipping_profile_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_shipping_profile OWNER TO postgres;

--
-- Name: product_tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_tag (
    id text NOT NULL,
    value text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_tag OWNER TO postgres;

--
-- Name: product_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_tags (
    product_id text NOT NULL,
    product_tag_id text NOT NULL
);


ALTER TABLE public.product_tags OWNER TO postgres;

--
-- Name: product_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_type (
    id text NOT NULL,
    value text NOT NULL,
    metadata json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_type OWNER TO postgres;

--
-- Name: product_variant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variant (
    id text NOT NULL,
    title text NOT NULL,
    sku text,
    barcode text,
    ean text,
    upc text,
    allow_backorder boolean DEFAULT false NOT NULL,
    manage_inventory boolean DEFAULT true NOT NULL,
    hs_code text,
    origin_country text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    metadata jsonb,
    variant_rank integer DEFAULT 0,
    product_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant OWNER TO postgres;

--
-- Name: product_variant_inventory_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variant_inventory_item (
    variant_id character varying(255) NOT NULL,
    inventory_item_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    required_quantity integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_inventory_item OWNER TO postgres;

--
-- Name: product_variant_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variant_option (
    variant_id text NOT NULL,
    option_value_id text NOT NULL
);


ALTER TABLE public.product_variant_option OWNER TO postgres;

--
-- Name: product_variant_price_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variant_price_set (
    variant_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_price_set OWNER TO postgres;

--
-- Name: promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion (
    id text NOT NULL,
    code text NOT NULL,
    campaign_id text,
    is_automatic boolean DEFAULT false NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'draft'::text NOT NULL,
    CONSTRAINT promotion_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'inactive'::text]))),
    CONSTRAINT promotion_type_check CHECK ((type = ANY (ARRAY['standard'::text, 'buyget'::text])))
);


ALTER TABLE public.promotion OWNER TO postgres;

--
-- Name: promotion_application_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_application_method (
    id text NOT NULL,
    value numeric,
    raw_value jsonb,
    max_quantity integer,
    apply_to_quantity integer,
    buy_rules_min_quantity integer,
    type text NOT NULL,
    target_type text NOT NULL,
    allocation text,
    promotion_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    CONSTRAINT promotion_application_method_allocation_check CHECK ((allocation = ANY (ARRAY['each'::text, 'across'::text]))),
    CONSTRAINT promotion_application_method_target_type_check CHECK ((target_type = ANY (ARRAY['order'::text, 'shipping_methods'::text, 'items'::text]))),
    CONSTRAINT promotion_application_method_type_check CHECK ((type = ANY (ARRAY['fixed'::text, 'percentage'::text])))
);


ALTER TABLE public.promotion_application_method OWNER TO postgres;

--
-- Name: promotion_campaign; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_campaign (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    campaign_identifier text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.promotion_campaign OWNER TO postgres;

--
-- Name: promotion_campaign_budget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_campaign_budget (
    id text NOT NULL,
    type text NOT NULL,
    campaign_id text NOT NULL,
    "limit" numeric,
    raw_limit jsonb,
    used numeric DEFAULT 0 NOT NULL,
    raw_used jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    CONSTRAINT promotion_campaign_budget_type_check CHECK ((type = ANY (ARRAY['spend'::text, 'usage'::text])))
);


ALTER TABLE public.promotion_campaign_budget OWNER TO postgres;

--
-- Name: promotion_promotion_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_promotion_rule (
    promotion_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.promotion_promotion_rule OWNER TO postgres;

--
-- Name: promotion_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_rule (
    id text NOT NULL,
    description text,
    attribute text NOT NULL,
    operator text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT promotion_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text, 'ne'::text, 'in'::text])))
);


ALTER TABLE public.promotion_rule OWNER TO postgres;

--
-- Name: promotion_rule_value; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_rule_value (
    id text NOT NULL,
    promotion_rule_id text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.promotion_rule_value OWNER TO postgres;

--
-- Name: provider_identity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provider_identity (
    id text NOT NULL,
    entity_id text NOT NULL,
    provider text NOT NULL,
    auth_identity_id text NOT NULL,
    user_metadata jsonb,
    provider_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.provider_identity OWNER TO postgres;

--
-- Name: publishable_api_key_sales_channel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publishable_api_key_sales_channel (
    publishable_key_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.publishable_api_key_sales_channel OWNER TO postgres;

--
-- Name: refund; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refund (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb,
    refund_reason_id text,
    note text
);


ALTER TABLE public.refund OWNER TO postgres;

--
-- Name: refund_reason; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refund_reason (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.refund_reason OWNER TO postgres;

--
-- Name: region; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.region (
    id text NOT NULL,
    name text NOT NULL,
    currency_code text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    automatic_taxes boolean DEFAULT true NOT NULL
);


ALTER TABLE public.region OWNER TO postgres;

--
-- Name: region_country; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.region_country (
    iso_2 text NOT NULL,
    iso_3 text NOT NULL,
    num_code text NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    region_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.region_country OWNER TO postgres;

--
-- Name: region_payment_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.region_payment_provider (
    region_id character varying(255) NOT NULL,
    payment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.region_payment_provider OWNER TO postgres;

--
-- Name: reservation_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    line_item_id text,
    location_id text NOT NULL,
    quantity numeric NOT NULL,
    external_id text,
    description text,
    created_by text,
    metadata jsonb,
    inventory_item_id text NOT NULL,
    allow_backorder boolean DEFAULT false,
    raw_quantity jsonb
);


ALTER TABLE public.reservation_item OWNER TO postgres;

--
-- Name: return; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return (
    id text NOT NULL,
    order_id text NOT NULL,
    claim_id text,
    exchange_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    status public.return_status_enum DEFAULT 'open'::public.return_status_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    received_at timestamp with time zone,
    canceled_at timestamp with time zone,
    location_id text,
    requested_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.return OWNER TO postgres;

--
-- Name: return_display_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.return_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.return_display_id_seq OWNER TO postgres;

--
-- Name: return_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.return_display_id_seq OWNED BY public.return.display_id;


--
-- Name: return_fulfillment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return_fulfillment (
    return_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.return_fulfillment OWNER TO postgres;

--
-- Name: return_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return_item (
    id text NOT NULL,
    return_id text NOT NULL,
    reason_id text,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    received_quantity numeric DEFAULT 0 NOT NULL,
    raw_received_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    damaged_quantity numeric DEFAULT 0 NOT NULL,
    raw_damaged_quantity jsonb NOT NULL
);


ALTER TABLE public.return_item OWNER TO postgres;

--
-- Name: return_reason; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return_reason (
    id character varying NOT NULL,
    value character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    metadata jsonb,
    parent_return_reason_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.return_reason OWNER TO postgres;

--
-- Name: sales_channel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_channel (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    is_disabled boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.sales_channel OWNER TO postgres;

--
-- Name: sales_channel_stock_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_channel_stock_location (
    sales_channel_id character varying(255) NOT NULL,
    stock_location_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.sales_channel_stock_location OWNER TO postgres;

--
-- Name: script_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.script_migrations (
    id integer NOT NULL,
    script_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    finished_at timestamp with time zone
);


ALTER TABLE public.script_migrations OWNER TO postgres;

--
-- Name: script_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.script_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.script_migrations_id_seq OWNER TO postgres;

--
-- Name: script_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.script_migrations_id_seq OWNED BY public.script_migrations.id;


--
-- Name: service_zone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_zone (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    fulfillment_set_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.service_zone OWNER TO postgres;

--
-- Name: shipping_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_option (
    id text NOT NULL,
    name text NOT NULL,
    price_type text DEFAULT 'flat'::text NOT NULL,
    service_zone_id text NOT NULL,
    shipping_profile_id text,
    provider_id text,
    data jsonb,
    metadata jsonb,
    shipping_option_type_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_price_type_check CHECK ((price_type = ANY (ARRAY['calculated'::text, 'flat'::text])))
);


ALTER TABLE public.shipping_option OWNER TO postgres;

--
-- Name: shipping_option_price_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_option_price_set (
    shipping_option_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_option_price_set OWNER TO postgres;

--
-- Name: shipping_option_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_option_rule (
    id text NOT NULL,
    attribute text NOT NULL,
    operator text NOT NULL,
    value jsonb,
    shipping_option_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_rule_operator_check CHECK ((operator = ANY (ARRAY['in'::text, 'eq'::text, 'ne'::text, 'gt'::text, 'gte'::text, 'lt'::text, 'lte'::text, 'nin'::text])))
);


ALTER TABLE public.shipping_option_rule OWNER TO postgres;

--
-- Name: shipping_option_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_option_type (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_option_type OWNER TO postgres;

--
-- Name: shipping_profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_profile (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_profile OWNER TO postgres;

--
-- Name: stock_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_location (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    address_id text,
    metadata jsonb
);


ALTER TABLE public.stock_location OWNER TO postgres;

--
-- Name: stock_location_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_location_address (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    address_1 text NOT NULL,
    address_2 text,
    company text,
    city text,
    country_code text NOT NULL,
    phone text,
    province text,
    postal_code text,
    metadata jsonb
);


ALTER TABLE public.stock_location_address OWNER TO postgres;

--
-- Name: store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store (
    id text NOT NULL,
    name text DEFAULT 'Medusa Store'::text NOT NULL,
    default_sales_channel_id text,
    default_region_id text,
    default_location_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.store OWNER TO postgres;

--
-- Name: store_currency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store_currency (
    id text NOT NULL,
    currency_code text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.store_currency OWNER TO postgres;

--
-- Name: tax_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_provider OWNER TO postgres;

--
-- Name: tax_rate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_rate (
    id text NOT NULL,
    rate real,
    code text NOT NULL,
    name text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_combinable boolean DEFAULT false NOT NULL,
    tax_region_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_rate OWNER TO postgres;

--
-- Name: tax_rate_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_rate_rule (
    id text NOT NULL,
    tax_rate_id text NOT NULL,
    reference_id text NOT NULL,
    reference text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_rate_rule OWNER TO postgres;

--
-- Name: tax_region; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_region (
    id text NOT NULL,
    provider_id text,
    country_code text NOT NULL,
    province_code text,
    parent_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone,
    CONSTRAINT "CK_tax_region_country_top_level" CHECK (((parent_id IS NULL) OR (province_code IS NOT NULL))),
    CONSTRAINT "CK_tax_region_provider_top_level" CHECK (((parent_id IS NULL) OR (provider_id IS NULL)))
);


ALTER TABLE public.tax_region OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id text NOT NULL,
    first_name text,
    last_name text,
    email text NOT NULL,
    avatar_url text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: workflow_execution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_execution (
    id character varying NOT NULL,
    workflow_id character varying NOT NULL,
    transaction_id character varying NOT NULL,
    execution jsonb,
    context jsonb,
    state character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone,
    retention_time integer,
    run_id text DEFAULT '01JX92C6DS5YDHZXZ83QZWTX4P'::text NOT NULL
);


ALTER TABLE public.workflow_execution OWNER TO postgres;

--
-- Name: link_module_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.link_module_migrations ALTER COLUMN id SET DEFAULT nextval('public.link_module_migrations_id_seq'::regclass);


--
-- Name: mikro_orm_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mikro_orm_migrations ALTER COLUMN id SET DEFAULT nextval('public.mikro_orm_migrations_id_seq'::regclass);


--
-- Name: order display_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order" ALTER COLUMN display_id SET DEFAULT nextval('public.order_display_id_seq'::regclass);


--
-- Name: order_change_action ordering; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change_action ALTER COLUMN ordering SET DEFAULT nextval('public.order_change_action_ordering_seq'::regclass);


--
-- Name: order_claim display_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_claim ALTER COLUMN display_id SET DEFAULT nextval('public.order_claim_display_id_seq'::regclass);


--
-- Name: order_exchange display_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_exchange ALTER COLUMN display_id SET DEFAULT nextval('public.order_exchange_display_id_seq'::regclass);


--
-- Name: return display_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return ALTER COLUMN display_id SET DEFAULT nextval('public.return_display_id_seq'::regclass);


--
-- Name: script_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.script_migrations ALTER COLUMN id SET DEFAULT nextval('public.script_migrations_id_seq'::regclass);


--
-- Data for Name: account_holder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_holder (id, provider_id, external_id, email, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: api_key; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_key (id, token, salt, redacted, title, type, last_used_at, created_by, created_at, revoked_by, revoked_at, updated_at, deleted_at) FROM stdin;
apk_01JX92CPSBNQ861PZSH11P3N6B	pk_5fff5295898482c5a71702783c5d8d3d7f3799d1b8863d6ac48517cd077a9250		pk_5ff***250	Webshop	publishable	\N		2025-06-08 20:45:34.891-04	\N	\N	2025-06-08 20:45:34.891-04	\N
apk_01JXTJQ4320VMV73M6V9D1VGQ0	pk_bdbccff38f68c730c59a87ec343a0a1d8a14c02d8e273e81fdcfc14061335596		pk_bdb***596	administrador 	publishable	\N	user_01JX92DTT9EE5ADVH465X383R4	2025-06-15 15:57:58.754-04	\N	\N	2025-06-15 15:57:58.754-04	\N
\.


--
-- Data for Name: application_method_buy_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.application_method_buy_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: application_method_target_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.application_method_target_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_identity (id, app_metadata, created_at, updated_at, deleted_at) FROM stdin;
authid_01JX92DTS06QT5NF3GXDGT2HAD	{"user_id": "user_01JX92DTT9EE5ADVH465X383R4"}	2025-06-08 20:46:11.744-04	2025-06-08 20:46:11.8-04	\N
authid_01JXAPHBZJ6BT751M77619ZK46	{"customer_id": "cus_01JXAPHC14T2P60QN2X5EAEN2R"}	2025-06-09 11:56:53.619-04	2025-06-09 11:56:53.692-04	\N
\.


--
-- Data for Name: capture; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.capture (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata) FROM stdin;
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart (id, region_id, customer_id, sales_channel_id, email, currency_code, shipping_address_id, billing_address_id, metadata, created_at, updated_at, deleted_at, completed_at) FROM stdin;
cart_01JX953RZT46DHZ4CFMZK5NGYE	reg_01JX92CPJV4PY6T452C0KP8M4V	\N	sc_01JX92CH43K6G3YZSHBR6WXNYP	\N	eur	\N	\N	\N	2025-06-08 21:33:07.962-04	2025-06-08 21:33:07.962-04	\N	\N
cart_01JX97BWPMAKBVZQ655QH2S5FY	reg_01JX96W5CAFG1XZM8E72ARJY8Z	cus_01JXAPHC14T2P60QN2X5EAEN2R	sc_01JX92CH43K6G3YZSHBR6WXNYP	cmutinelli@gmail.com	clp	caaddr_01JX97W6R5CQ7N9YXZR2DY6KH2	caaddr_01JX97W6R58KR192F87TFQ0PWR	\N	2025-06-08 22:12:31.061-04	2025-06-09 11:56:53.995-04	\N	\N
cart_01JXTJE90AFY3FH7PBS3ZTVEJE	reg_01JX96W5CAFG1XZM8E72ARJY8Z	cus_01JXTJG4QF9RKH3E6YY7GF918K	sc_01JX92CH43K6G3YZSHBR6WXNYP	crt@tdcom.cl	clp	caaddr_01JXTJG4QS8W7BWDW2T8QN8A0F	caaddr_01JXTJG4QSCK9RY0FDJQCR1W0J	\N	2025-06-15 15:53:08.875-04	2025-06-15 15:54:10.041-04	\N	\N
\.


--
-- Data for Name: cart_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
caaddr_01JX97CA54F179PB2JDBMRSQ53	\N	\N	\N	\N	\N	\N	\N	cl	\N	\N	\N	\N	2025-06-08 22:12:44.837-04	2025-06-08 22:12:44.837-04	\N
caaddr_01JX97W6R58KR192F87TFQ0PWR	\N	TD	Cristian	Ruiz-Tagle	ewrrwr		wrwrr	cl		werwerwere		\N	2025-06-08 22:21:25.637-04	2025-06-08 22:21:25.637-04	\N
caaddr_01JX97W6R5CQ7N9YXZR2DY6KH2	\N	TD	Cristian	Ruiz-Tagle	ewrrwr		wrwrr	cl		werwerwere		\N	2025-06-08 22:21:25.637-04	2025-06-08 22:21:25.637-04	\N
caaddr_01JXTJE90AXHMA30NQ5G7TYW6D	\N	\N	\N	\N	\N	\N	\N	cl	\N	\N	\N	\N	2025-06-15 15:53:08.875-04	2025-06-15 15:53:08.875-04	\N
caaddr_01JXTJG4QSCK9RY0FDJQCR1W0J	\N		Cristian	Ruiz-Tagle	Algo por así 		Santiago	cl	Santiago	11111		\N	2025-06-15 15:54:10.041-04	2025-06-15 15:54:10.041-04	\N
caaddr_01JXTJG4QS8W7BWDW2T8QN8A0F	\N		Cristian	Ruiz-Tagle	Algo por así 		Santiago	cl	Santiago	11111		\N	2025-06-15 15:54:10.041-04	2025-06-15 15:54:10.041-04	\N
\.


--
-- Data for Name: cart_line_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_line_item (id, cart_id, title, subtitle, thumbnail, quantity, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, product_type_id, is_custom_price, is_giftcard) FROM stdin;
cali_01JX953SE483X8FKQ4J53B29NT	cart_01JX953RZT46DHZ4CFMZK5NGYE	Medusa Sweatpants	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	1	variant_01JX92CPYD7KM69SZFHB5CEDX5	prod_01JX92CPTN3EQ8DBW9PR5BWTY6	Medusa Sweatpants	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	\N	\N	\N	sweatpants	SWEATPANTS-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2025-06-08 21:33:08.421-04	2025-06-08 21:33:08.421-04	\N	\N	f	f
cali_01JX97TK3VQJQYQEG2V5GMZ6AS	cart_01JX97BWPMAKBVZQ655QH2S5FY	Ventilador de techo Flight 52" (132 cm)	Default variant	http://localhost:9000/static/1749434914057-w=1500,h=1500,fit=pad-13.webp	1	variant_01JX974NA6C3EH827GXE39F966	prod_01JX974N8STXW6ACEYYRTBB1QD	Ventilador de techo Flight 52" (132 cm)	⚡ EL PAPITA CRISTIAN LO HIZO DE NUEVO\nRetail: $134.990 (auch)\nLa Papita: $49.990 (¡aaaah!)\nAhorraste $84.000 para más papas fritas 🍟		\N	\N	ventilador-de-techo-flight-52-132-cm	\N	\N	Default variant	\N	t	t	t	\N	\N	49900	{"value": "49900", "precision": 20}	{}	2025-06-08 22:20:32.764-04	2025-06-09 09:53:55.664-04	\N	\N	f	f
cali_01JXTJE960WBT0KZSTQF0MG60N	cart_01JXTJE90AFY3FH7PBS3ZTVEJE	Ventilador de techo Flight 52" (132 cm)	Default variant	http://localhost:9000/static/1749434914057-w=1500,h=1500,fit=pad-13.webp	1	variant_01JX974NA6C3EH827GXE39F966	prod_01JX974N8STXW6ACEYYRTBB1QD	Ventilador de techo Flight 52" (132 cm)	⚡ EL PAPITA CRISTIAN LO HIZO DE NUEVO\nRetail: $134.990 (auch)\nLa Papita: $49.990 (¡aaaah!)\nAhorraste $84.000 para más papas fritas 🍟		\N	\N	ventilador-de-techo-flight-52-132-cm	\N	\N	Default variant	\N	t	t	t	\N	\N	49900	{"value": "49900", "precision": 20}	{}	2025-06-15 15:53:09.057-04	2025-06-15 15:53:09.057-04	\N	\N	f	f
\.


--
-- Data for Name: cart_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, item_id) FROM stdin;
\.


--
-- Data for Name: cart_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_line_item_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, item_id) FROM stdin;
\.


--
-- Data for Name: cart_payment_collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_payment_collection (cart_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_promotion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_promotion (cart_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_shipping_method (id, cart_id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_shipping_method_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: credit_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit_line (id, cart_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: currency; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.currency (code, symbol, symbol_native, decimal_digits, rounding, raw_rounding, name, created_at, updated_at, deleted_at) FROM stdin;
usd	$	$	2	0	{"value": "0", "precision": 20}	US Dollar	2025-06-08 20:45:21.331-04	2025-06-08 20:45:21.331-04	\N
cad	CA$	$	2	0	{"value": "0", "precision": 20}	Canadian Dollar	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
eur	€	€	2	0	{"value": "0", "precision": 20}	Euro	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
aed	AED	د.إ.‏	2	0	{"value": "0", "precision": 20}	United Arab Emirates Dirham	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
afn	Af	؋	0	0	{"value": "0", "precision": 20}	Afghan Afghani	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
all	ALL	Lek	0	0	{"value": "0", "precision": 20}	Albanian Lek	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
amd	AMD	դր.	0	0	{"value": "0", "precision": 20}	Armenian Dram	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
ars	AR$	$	2	0	{"value": "0", "precision": 20}	Argentine Peso	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
aud	AU$	$	2	0	{"value": "0", "precision": 20}	Australian Dollar	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
azn	man.	ман.	2	0	{"value": "0", "precision": 20}	Azerbaijani Manat	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bam	KM	KM	2	0	{"value": "0", "precision": 20}	Bosnia-Herzegovina Convertible Mark	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bdt	Tk	৳	2	0	{"value": "0", "precision": 20}	Bangladeshi Taka	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bgn	BGN	лв.	2	0	{"value": "0", "precision": 20}	Bulgarian Lev	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bhd	BD	د.ب.‏	3	0	{"value": "0", "precision": 20}	Bahraini Dinar	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bif	FBu	FBu	0	0	{"value": "0", "precision": 20}	Burundian Franc	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bnd	BN$	$	2	0	{"value": "0", "precision": 20}	Brunei Dollar	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bob	Bs	Bs	2	0	{"value": "0", "precision": 20}	Bolivian Boliviano	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
brl	R$	R$	2	0	{"value": "0", "precision": 20}	Brazilian Real	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bwp	BWP	P	2	0	{"value": "0", "precision": 20}	Botswanan Pula	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
byn	Br	руб.	2	0	{"value": "0", "precision": 20}	Belarusian Ruble	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
bzd	BZ$	$	2	0	{"value": "0", "precision": 20}	Belize Dollar	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
cdf	CDF	FrCD	2	0	{"value": "0", "precision": 20}	Congolese Franc	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
chf	CHF	CHF	2	0.05	{"value": "0.05", "precision": 20}	Swiss Franc	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
clp	CL$	$	0	0	{"value": "0", "precision": 20}	Chilean Peso	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
cny	CN¥	CN¥	2	0	{"value": "0", "precision": 20}	Chinese Yuan	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
cop	CO$	$	0	0	{"value": "0", "precision": 20}	Colombian Peso	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
crc	₡	₡	0	0	{"value": "0", "precision": 20}	Costa Rican Colón	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
cve	CV$	CV$	2	0	{"value": "0", "precision": 20}	Cape Verdean Escudo	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
czk	Kč	Kč	2	0	{"value": "0", "precision": 20}	Czech Republic Koruna	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
djf	Fdj	Fdj	0	0	{"value": "0", "precision": 20}	Djiboutian Franc	2025-06-08 20:45:21.332-04	2025-06-08 20:45:21.332-04	\N
dkk	Dkr	kr	2	0	{"value": "0", "precision": 20}	Danish Krone	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
dop	RD$	RD$	2	0	{"value": "0", "precision": 20}	Dominican Peso	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
dzd	DA	د.ج.‏	2	0	{"value": "0", "precision": 20}	Algerian Dinar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
eek	Ekr	kr	2	0	{"value": "0", "precision": 20}	Estonian Kroon	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
egp	EGP	ج.م.‏	2	0	{"value": "0", "precision": 20}	Egyptian Pound	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
ern	Nfk	Nfk	2	0	{"value": "0", "precision": 20}	Eritrean Nakfa	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
etb	Br	Br	2	0	{"value": "0", "precision": 20}	Ethiopian Birr	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
gbp	£	£	2	0	{"value": "0", "precision": 20}	British Pound Sterling	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
gel	GEL	GEL	2	0	{"value": "0", "precision": 20}	Georgian Lari	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
ghs	GH₵	GH₵	2	0	{"value": "0", "precision": 20}	Ghanaian Cedi	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
gnf	FG	FG	0	0	{"value": "0", "precision": 20}	Guinean Franc	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
gtq	GTQ	Q	2	0	{"value": "0", "precision": 20}	Guatemalan Quetzal	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
hkd	HK$	$	2	0	{"value": "0", "precision": 20}	Hong Kong Dollar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
hnl	HNL	L	2	0	{"value": "0", "precision": 20}	Honduran Lempira	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
hrk	kn	kn	2	0	{"value": "0", "precision": 20}	Croatian Kuna	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
huf	Ft	Ft	0	0	{"value": "0", "precision": 20}	Hungarian Forint	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
idr	Rp	Rp	0	0	{"value": "0", "precision": 20}	Indonesian Rupiah	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
ils	₪	₪	2	0	{"value": "0", "precision": 20}	Israeli New Sheqel	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
inr	Rs	₹	2	0	{"value": "0", "precision": 20}	Indian Rupee	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
iqd	IQD	د.ع.‏	0	0	{"value": "0", "precision": 20}	Iraqi Dinar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
irr	IRR	﷼	0	0	{"value": "0", "precision": 20}	Iranian Rial	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
isk	Ikr	kr	0	0	{"value": "0", "precision": 20}	Icelandic Króna	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
jmd	J$	$	2	0	{"value": "0", "precision": 20}	Jamaican Dollar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
jod	JD	د.أ.‏	3	0	{"value": "0", "precision": 20}	Jordanian Dinar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
jpy	¥	￥	0	0	{"value": "0", "precision": 20}	Japanese Yen	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
kes	Ksh	Ksh	2	0	{"value": "0", "precision": 20}	Kenyan Shilling	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
khr	KHR	៛	2	0	{"value": "0", "precision": 20}	Cambodian Riel	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
kmf	CF	FC	0	0	{"value": "0", "precision": 20}	Comorian Franc	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
krw	₩	₩	0	0	{"value": "0", "precision": 20}	South Korean Won	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
kwd	KD	د.ك.‏	3	0	{"value": "0", "precision": 20}	Kuwaiti Dinar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
kzt	KZT	тңг.	2	0	{"value": "0", "precision": 20}	Kazakhstani Tenge	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
lbp	LB£	ل.ل.‏	0	0	{"value": "0", "precision": 20}	Lebanese Pound	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
lkr	SLRs	SL Re	2	0	{"value": "0", "precision": 20}	Sri Lankan Rupee	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
ltl	Lt	Lt	2	0	{"value": "0", "precision": 20}	Lithuanian Litas	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
lvl	Ls	Ls	2	0	{"value": "0", "precision": 20}	Latvian Lats	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
lyd	LD	د.ل.‏	3	0	{"value": "0", "precision": 20}	Libyan Dinar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mad	MAD	د.م.‏	2	0	{"value": "0", "precision": 20}	Moroccan Dirham	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mdl	MDL	MDL	2	0	{"value": "0", "precision": 20}	Moldovan Leu	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mga	MGA	MGA	0	0	{"value": "0", "precision": 20}	Malagasy Ariary	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mkd	MKD	MKD	2	0	{"value": "0", "precision": 20}	Macedonian Denar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mmk	MMK	K	0	0	{"value": "0", "precision": 20}	Myanma Kyat	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mnt	MNT	₮	0	0	{"value": "0", "precision": 20}	Mongolian Tugrig	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mop	MOP$	MOP$	2	0	{"value": "0", "precision": 20}	Macanese Pataca	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mur	MURs	MURs	0	0	{"value": "0", "precision": 20}	Mauritian Rupee	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mxn	MX$	$	2	0	{"value": "0", "precision": 20}	Mexican Peso	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
myr	RM	RM	2	0	{"value": "0", "precision": 20}	Malaysian Ringgit	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
mzn	MTn	MTn	2	0	{"value": "0", "precision": 20}	Mozambican Metical	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
nad	N$	N$	2	0	{"value": "0", "precision": 20}	Namibian Dollar	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
ngn	₦	₦	2	0	{"value": "0", "precision": 20}	Nigerian Naira	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
nio	C$	C$	2	0	{"value": "0", "precision": 20}	Nicaraguan Córdoba	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
nok	Nkr	kr	2	0	{"value": "0", "precision": 20}	Norwegian Krone	2025-06-08 20:45:21.333-04	2025-06-08 20:45:21.333-04	\N
npr	NPRs	नेरू	2	0	{"value": "0", "precision": 20}	Nepalese Rupee	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
nzd	NZ$	$	2	0	{"value": "0", "precision": 20}	New Zealand Dollar	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
omr	OMR	ر.ع.‏	3	0	{"value": "0", "precision": 20}	Omani Rial	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
pab	B/.	B/.	2	0	{"value": "0", "precision": 20}	Panamanian Balboa	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
pen	S/.	S/.	2	0	{"value": "0", "precision": 20}	Peruvian Nuevo Sol	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
php	₱	₱	2	0	{"value": "0", "precision": 20}	Philippine Peso	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
pkr	PKRs	₨	0	0	{"value": "0", "precision": 20}	Pakistani Rupee	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
pln	zł	zł	2	0	{"value": "0", "precision": 20}	Polish Zloty	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
pyg	₲	₲	0	0	{"value": "0", "precision": 20}	Paraguayan Guarani	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
qar	QR	ر.ق.‏	2	0	{"value": "0", "precision": 20}	Qatari Rial	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
ron	RON	RON	2	0	{"value": "0", "precision": 20}	Romanian Leu	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
rsd	din.	дин.	0	0	{"value": "0", "precision": 20}	Serbian Dinar	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
rub	RUB	₽.	2	0	{"value": "0", "precision": 20}	Russian Ruble	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
rwf	RWF	FR	0	0	{"value": "0", "precision": 20}	Rwandan Franc	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
sar	SR	ر.س.‏	2	0	{"value": "0", "precision": 20}	Saudi Riyal	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
sdg	SDG	SDG	2	0	{"value": "0", "precision": 20}	Sudanese Pound	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
sek	Skr	kr	2	0	{"value": "0", "precision": 20}	Swedish Krona	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
sgd	S$	$	2	0	{"value": "0", "precision": 20}	Singapore Dollar	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
sos	Ssh	Ssh	0	0	{"value": "0", "precision": 20}	Somali Shilling	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
syp	SY£	ل.س.‏	0	0	{"value": "0", "precision": 20}	Syrian Pound	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
thb	฿	฿	2	0	{"value": "0", "precision": 20}	Thai Baht	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
tnd	DT	د.ت.‏	3	0	{"value": "0", "precision": 20}	Tunisian Dinar	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
top	T$	T$	2	0	{"value": "0", "precision": 20}	Tongan Paʻanga	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
try	₺	₺	2	0	{"value": "0", "precision": 20}	Turkish Lira	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
ttd	TT$	$	2	0	{"value": "0", "precision": 20}	Trinidad and Tobago Dollar	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
twd	NT$	NT$	2	0	{"value": "0", "precision": 20}	New Taiwan Dollar	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
tzs	TSh	TSh	0	0	{"value": "0", "precision": 20}	Tanzanian Shilling	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
uah	₴	₴	2	0	{"value": "0", "precision": 20}	Ukrainian Hryvnia	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
ugx	USh	USh	0	0	{"value": "0", "precision": 20}	Ugandan Shilling	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
uyu	$U	$	2	0	{"value": "0", "precision": 20}	Uruguayan Peso	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
uzs	UZS	UZS	0	0	{"value": "0", "precision": 20}	Uzbekistan Som	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
vef	Bs.F.	Bs.F.	2	0	{"value": "0", "precision": 20}	Venezuelan Bolívar	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
vnd	₫	₫	0	0	{"value": "0", "precision": 20}	Vietnamese Dong	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
xaf	FCFA	FCFA	0	0	{"value": "0", "precision": 20}	CFA Franc BEAC	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
xof	CFA	CFA	0	0	{"value": "0", "precision": 20}	CFA Franc BCEAO	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
yer	YR	ر.ي.‏	0	0	{"value": "0", "precision": 20}	Yemeni Rial	2025-06-08 20:45:21.334-04	2025-06-08 20:45:21.334-04	\N
zar	R	R	2	0	{"value": "0", "precision": 20}	South African Rand	2025-06-08 20:45:21.335-04	2025-06-08 20:45:21.335-04	\N
zmk	ZK	ZK	0	0	{"value": "0", "precision": 20}	Zambian Kwacha	2025-06-08 20:45:21.335-04	2025-06-08 20:45:21.335-04	\N
zwl	ZWL$	ZWL$	0	0	{"value": "0", "precision": 20}	Zimbabwean Dollar	2025-06-08 20:45:21.335-04	2025-06-08 20:45:21.335-04	\N
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (id, company_name, first_name, last_name, email, phone, has_account, metadata, created_at, updated_at, deleted_at, created_by) FROM stdin;
cus_01JX97W6QF6KXXPJRHCASZMXDY	\N	\N	\N	cmutinelli@gmail.com	\N	f	\N	2025-06-08 22:21:25.615-04	2025-06-08 22:21:25.615-04	\N	\N
cus_01JXAPHC14T2P60QN2X5EAEN2R	\N	demo	demo	cmutinelli@gmail.com		t	\N	2025-06-09 11:56:53.668-04	2025-06-09 11:56:53.668-04	\N	\N
cus_01JXTJG4QF9RKH3E6YY7GF918K	\N	\N	\N	crt@tdcom.cl	\N	f	\N	2025-06-15 15:54:10.031-04	2025-06-15 15:54:10.031-04	\N	\N
\.


--
-- Data for Name: customer_account_holder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_account_holder (customer_id, account_holder_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_address (id, customer_id, address_name, is_default_shipping, is_default_billing, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_group (id, name, metadata, created_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group_customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_group_customer (id, customer_id, customer_group_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment (id, location_id, packed_at, shipped_at, delivered_at, canceled_at, data, provider_id, shipping_option_id, metadata, delivery_address_id, created_at, updated_at, deleted_at, marked_shipped_by, created_by, requires_shipping) FROM stdin;
\.


--
-- Data for Name: fulfillment_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_address (id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_item (id, title, sku, barcode, quantity, raw_quantity, line_item_id, inventory_item_id, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_label; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_label (id, tracking_number, tracking_url, label_url, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
manual_manual	t	2025-06-08 20:45:21.693-04	2025-06-08 20:45:21.693-04	\N
\.


--
-- Data for Name: fulfillment_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_set (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuset_01JX92CPNH64CNS7A776NMFWXQ	European Warehouse delivery	shipping	\N	2025-06-08 20:45:34.769-04	2025-06-08 22:05:25.359-04	2025-06-08 22:05:25.357-04
fuset_01JX96YZ86A2S68JBMYHF5GBRW	La bodega de la papita pick up	pickup	\N	2025-06-08 22:05:27.687-04	2025-06-08 22:05:27.687-04	\N
fuset_01JXTHF7ZJG371GDYRN7WD7WS0	La bodega de la papita shipping	shipping	\N	2025-06-15 15:36:12.019-04	2025-06-15 15:36:12.019-04	\N
\.


--
-- Data for Name: geo_zone; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.geo_zone (id, type, country_code, province_code, city, service_zone_id, postal_expression, metadata, created_at, updated_at, deleted_at) FROM stdin;
fgz_01JX92CPNG6MMBV5CTYK6X019G	country	gb	\N	\N	serzo_01JX92CPNGDNHM6B968JAM0PDS	\N	\N	2025-06-08 20:45:34.769-04	2025-06-08 22:05:25.389-04	2025-06-08 22:05:25.357-04
fgz_01JX92CPNGEMBJQ9WRVCCDCN9C	country	de	\N	\N	serzo_01JX92CPNGDNHM6B968JAM0PDS	\N	\N	2025-06-08 20:45:34.769-04	2025-06-08 22:05:25.389-04	2025-06-08 22:05:25.357-04
fgz_01JX92CPNGC2TTZ2CADTPZ4768	country	dk	\N	\N	serzo_01JX92CPNGDNHM6B968JAM0PDS	\N	\N	2025-06-08 20:45:34.77-04	2025-06-08 22:05:25.389-04	2025-06-08 22:05:25.357-04
fgz_01JX92CPNG9QQEQF07CKJA251Y	country	se	\N	\N	serzo_01JX92CPNGDNHM6B968JAM0PDS	\N	\N	2025-06-08 20:45:34.77-04	2025-06-08 22:05:25.39-04	2025-06-08 22:05:25.357-04
fgz_01JX92CPNGE0HR30R2YC5MRFAV	country	fr	\N	\N	serzo_01JX92CPNGDNHM6B968JAM0PDS	\N	\N	2025-06-08 20:45:34.77-04	2025-06-08 22:05:25.39-04	2025-06-08 22:05:25.357-04
fgz_01JX92CPNGH8A9QD8H7D54V6B5	country	es	\N	\N	serzo_01JX92CPNGDNHM6B968JAM0PDS	\N	\N	2025-06-08 20:45:34.77-04	2025-06-08 22:05:25.39-04	2025-06-08 22:05:25.357-04
fgz_01JX92CPNGQQQTXYJCF5GCA90Q	country	it	\N	\N	serzo_01JX92CPNGDNHM6B968JAM0PDS	\N	\N	2025-06-08 20:45:34.77-04	2025-06-08 22:05:25.39-04	2025-06-08 22:05:25.357-04
fgz_01JXTHJVYTVH43H12CNWH4QJ9W	country	cl	\N	\N	serzo_01JXTHJVYTYGDCBFTJ1KNSV57Q	\N	\N	2025-06-15 15:38:10.779-04	2025-06-15 15:38:10.779-04	\N
\.


--
-- Data for Name: image; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.image (id, url, metadata, created_at, updated_at, deleted_at, rank, product_id) FROM stdin;
img_01JX95HQ30889VF8A300C186T2	http://localhost:9000/static/1749433244747-w=1500,h=1500,fit=pad-13.webp	\N	2025-06-08 21:40:44.772-04	2025-06-08 21:47:24.863-04	2025-06-08 21:47:24.853-04	0	prod_01JX95HQ301NWH6SCMHTWD7MY0
img_01JX95HQ312DA14TGE9YB7F01F	http://localhost:9000/static/1749433244747-w=1500,h=1500,fit=pad-17.webp	\N	2025-06-08 21:40:44.772-04	2025-06-08 21:47:24.863-04	2025-06-08 21:47:24.853-04	1	prod_01JX95HQ301NWH6SCMHTWD7MY0
img_01JX95HQ315TE0T70DNNY0S5XF	http://localhost:9000/static/1749433244747-w=1500,h=1500,fit=pad-16.webp	\N	2025-06-08 21:40:44.772-04	2025-06-08 21:47:24.863-04	2025-06-08 21:47:24.853-04	2	prod_01JX95HQ301NWH6SCMHTWD7MY0
img_01JX95HQ316V7J1WHGNFPQ657Y	http://localhost:9000/static/1749433244747-w=1500,h=1500,fit=pad-15.webp	\N	2025-06-08 21:40:44.772-04	2025-06-08 21:47:24.863-04	2025-06-08 21:47:24.853-04	3	prod_01JX95HQ301NWH6SCMHTWD7MY0
img_01JX95HQ31JMTYECB31NMY272A	http://localhost:9000/static/1749433244746-w=1500,h=1500,fit=pad-14.webp	\N	2025-06-08 21:40:44.772-04	2025-06-08 21:47:24.863-04	2025-06-08 21:47:24.853-04	4	prod_01JX95HQ301NWH6SCMHTWD7MY0
img_01JX961R0PC96WT46E4C8588R6	http://localhost:9000/static/1749433769980-w=1500,h=1500,fit=pad-13.webp	\N	2025-06-08 21:49:30.011-04	2025-06-08 22:06:50.67-04	2025-06-08 22:06:50.653-04	0	prod_01JX961R0K4P63A4MK6HCCDQH7
img_01JX961R0Q9N6BKTHE7EXBK2RB	http://localhost:9000/static/1749433769981-w=1500,h=1500,fit=pad-17.webp	\N	2025-06-08 21:49:30.011-04	2025-06-08 22:06:50.67-04	2025-06-08 22:06:50.653-04	1	prod_01JX961R0K4P63A4MK6HCCDQH7
img_01JX961R0QX948K6X5VWREB850	http://localhost:9000/static/1749433769981-w=1500,h=1500,fit=pad-16.webp	\N	2025-06-08 21:49:30.011-04	2025-06-08 22:06:50.67-04	2025-06-08 22:06:50.653-04	2	prod_01JX961R0K4P63A4MK6HCCDQH7
img_01JX961R0Q1H850FHGCXF3X8QA	http://localhost:9000/static/1749433769981-w=1500,h=1500,fit=pad-15.webp	\N	2025-06-08 21:49:30.011-04	2025-06-08 22:06:50.67-04	2025-06-08 22:06:50.653-04	3	prod_01JX961R0K4P63A4MK6HCCDQH7
img_01JX961R0R5KPR4HV8PT0VPR6N	http://localhost:9000/static/1749433769981-w=1500,h=1500,fit=pad-14.webp	\N	2025-06-08 21:49:30.011-04	2025-06-08 22:06:50.67-04	2025-06-08 22:06:50.653-04	4	prod_01JX961R0K4P63A4MK6HCCDQH7
img_01JX974N8V9V82YYSTWFR5GBV8	http://localhost:9000/static/1749434914057-w=1500,h=1500,fit=pad-13.webp	\N	2025-06-08 22:08:34.077-04	2025-06-08 22:08:34.077-04	\N	0	prod_01JX974N8STXW6ACEYYRTBB1QD
img_01JX92CPTVBGZX0A2N2WFBRDCG	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:19:57.694-04	2025-06-08 22:19:57.684-04	0	prod_01JX92CPTN3EQ8DBW9PR5BWTY6
img_01JX92CPTVN5P5MV6F67VD4NT0	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-back.png	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:19:57.694-04	2025-06-08 22:19:57.684-04	1	prod_01JX92CPTN3EQ8DBW9PR5BWTY6
img_01JX92CPTWR24J20ZMSNR2C6AN	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:03.476-04	2025-06-08 22:20:03.467-04	0	prod_01JX92CPTNEZ2T087281MJ9GTZ
img_01JX92CPTWP6P3HTPDGZ9HPFTH	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-back.png	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:03.476-04	2025-06-08 22:20:03.467-04	1	prod_01JX92CPTNEZ2T087281MJ9GTZ
img_01JX92CPTV1BF350Y5918WZF92	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:08.178-04	2025-06-08 22:20:08.167-04	0	prod_01JX92CPTNNCVM0P17JH26FY7A
img_01JX92CPTVBATFD3V9ZJ94HVR7	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-back.png	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:08.178-04	2025-06-08 22:20:08.167-04	1	prod_01JX92CPTNNCVM0P17JH26FY7A
img_01JX92CPTS3XGY28FJT1GYWSVB	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04	0	prod_01JX92CPTNT0M9QXCDF6J720EH
img_01JX92CPTSCT34C3W67PV2PHGD	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-back.png	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04	1	prod_01JX92CPTNT0M9QXCDF6J720EH
img_01JX92CPTS7JK12D42WBD92YVV	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-front.png	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04	2	prod_01JX92CPTNT0M9QXCDF6J720EH
img_01JX92CPTSQPZA78PNVW6Q1P08	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-back.png	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04	3	prod_01JX92CPTNT0M9QXCDF6J720EH
\.


--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_item (id, created_at, updated_at, deleted_at, sku, origin_country, hs_code, mid_code, material, weight, length, height, width, requires_shipping, description, title, thumbnail, metadata) FROM stdin;
iitem_01JX95HQ5HQE72MBKDJK3QSG8V	2025-06-08 21:40:44.85-04	2025-06-08 21:47:24.82-04	2025-06-08 21:47:24.819-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Default variant	Default variant	\N	\N
iitem_01JX92CQ08JRX645FRXWP06ES2	2025-06-08 20:45:35.114-04	2025-06-08 22:19:57.644-04	2025-06-08 22:19:57.643-04	SWEATPANTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01JX92CQ0782J5JD2BNVGEN4MD	2025-06-08 20:45:35.114-04	2025-06-08 22:19:57.651-04	2025-06-08 22:19:57.643-04	SWEATPANTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01JX92CQ07TG1Z563Y5G6C1CTX	2025-06-08 20:45:35.114-04	2025-06-08 22:19:57.658-04	2025-06-08 22:19:57.643-04	SWEATPANTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01JX92CQ087W356H5GEKGGQ3WV	2025-06-08 20:45:35.114-04	2025-06-08 22:19:57.664-04	2025-06-08 22:19:57.643-04	SWEATPANTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01JX92CQ08X19XSXEWEXDQ5X6F	2025-06-08 20:45:35.114-04	2025-06-08 22:20:03.431-04	2025-06-08 22:20:03.431-04	SHORTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01JX92CQ082BDVTXWK0F11SWKX	2025-06-08 20:45:35.114-04	2025-06-08 22:20:03.438-04	2025-06-08 22:20:03.431-04	SHORTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01JX92CQ0809CY6R3S8TSWQTBE	2025-06-08 20:45:35.114-04	2025-06-08 22:20:03.443-04	2025-06-08 22:20:03.431-04	SHORTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01JX92CQ08ZYF4X9Y3MRH8W616	2025-06-08 20:45:35.114-04	2025-06-08 22:20:03.447-04	2025-06-08 22:20:03.431-04	SHORTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01JX92CQ072XVDAJD3BV5E961D	2025-06-08 20:45:35.113-04	2025-06-08 22:20:08.127-04	2025-06-08 22:20:08.126-04	SWEATSHIRT-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01JX92CQ07F42W84PQBBZDTV68	2025-06-08 20:45:35.113-04	2025-06-08 22:20:08.131-04	2025-06-08 22:20:08.126-04	SWEATSHIRT-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01JX92CQ0742MTQR07HA3E7BGN	2025-06-08 20:45:35.113-04	2025-06-08 22:20:08.144-04	2025-06-08 22:20:08.126-04	SWEATSHIRT-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01JX92CQ07N56R312366MR7V6A	2025-06-08 20:45:35.114-04	2025-06-08 22:20:08.149-04	2025-06-08 22:20:08.126-04	SWEATSHIRT-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01JX92CQ053C13Y920TAXPG0Z3	2025-06-08 20:45:35.113-04	2025-06-08 22:20:11.773-04	2025-06-08 22:20:11.773-04	SHIRT-L-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	L / Black	L / Black	\N	\N
iitem_01JX92CQ05DDXVMR50SZ03WNYJ	2025-06-08 20:45:35.113-04	2025-06-08 22:20:11.777-04	2025-06-08 22:20:11.773-04	SHIRT-L-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	L / White	L / White	\N	\N
iitem_01JX92CQ0507CRQ6W43ZPYYRKM	2025-06-08 20:45:35.113-04	2025-06-08 22:20:11.782-04	2025-06-08 22:20:11.773-04	SHIRT-M-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	M / Black	M / Black	\N	\N
iitem_01JX92CQ055RT50QPEAY8NEV1Q	2025-06-08 20:45:35.113-04	2025-06-08 22:20:11.785-04	2025-06-08 22:20:11.773-04	SHIRT-M-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	M / White	M / White	\N	\N
iitem_01JX92CQ041JS8E1ZNEX85FKBQ	2025-06-08 20:45:35.113-04	2025-06-08 22:20:11.791-04	2025-06-08 22:20:11.773-04	SHIRT-S-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	S / Black	S / Black	\N	\N
iitem_01JX92CQ04H0ZCZKDE95FDE0YR	2025-06-08 20:45:35.113-04	2025-06-08 22:20:11.795-04	2025-06-08 22:20:11.773-04	SHIRT-S-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	S / White	S / White	\N	\N
iitem_01JX92CQ06DW38WB0ZJ5EA14BB	2025-06-08 20:45:35.113-04	2025-06-08 22:20:11.8-04	2025-06-08 22:20:11.773-04	SHIRT-XL-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / Black	XL / Black	\N	\N
iitem_01JX92CQ06XC7ER1XF1EPRH2PP	2025-06-08 20:45:35.113-04	2025-06-08 22:20:11.807-04	2025-06-08 22:20:11.773-04	SHIRT-XL-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / White	XL / White	\N	\N
\.


--
-- Data for Name: inventory_level; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_level (id, created_at, updated_at, deleted_at, inventory_item_id, location_id, stocked_quantity, reserved_quantity, incoming_quantity, metadata, raw_stocked_quantity, raw_reserved_quantity, raw_incoming_quantity) FROM stdin;
ilev_01JX95M23YMM8BQQNZSYZ982FP	2025-06-08 21:42:01.599-04	2025-06-08 21:47:24.831-04	2025-06-08 21:47:24.819-04	iitem_01JX95HQ5HQE72MBKDJK3QSG8V	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	0	0	0	\N	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8PCEQGKKW1X5G7XTHV	2025-06-08 20:45:35.383-04	2025-06-08 22:19:57.65-04	2025-06-08 22:19:57.643-04	iitem_01JX92CQ08JRX645FRXWP06ES2	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8P67WMZ31RTSG78DMA	2025-06-08 20:45:35.383-04	2025-06-08 22:19:57.658-04	2025-06-08 22:19:57.643-04	iitem_01JX92CQ0782J5JD2BNVGEN4MD	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8P2RY8T5V1ECY3NY1Z	2025-06-08 20:45:35.383-04	2025-06-08 22:19:57.664-04	2025-06-08 22:19:57.643-04	iitem_01JX92CQ07TG1Z563Y5G6C1CTX	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8PH5APTY7YRVYVAVXT	2025-06-08 20:45:35.383-04	2025-06-08 22:19:57.668-04	2025-06-08 22:19:57.643-04	iitem_01JX92CQ087W356H5GEKGGQ3WV	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8PM7VYDSDK9910F6X1	2025-06-08 20:45:35.383-04	2025-06-08 22:20:03.438-04	2025-06-08 22:20:03.431-04	iitem_01JX92CQ08X19XSXEWEXDQ5X6F	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8PG1V12WYVGKP8Z2X0	2025-06-08 20:45:35.383-04	2025-06-08 22:20:03.443-04	2025-06-08 22:20:03.431-04	iitem_01JX92CQ082BDVTXWK0F11SWKX	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8PR4P7AFGSX1VM9G3Q	2025-06-08 20:45:35.383-04	2025-06-08 22:20:03.447-04	2025-06-08 22:20:03.431-04	iitem_01JX92CQ0809CY6R3S8TSWQTBE	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8PQRNG13AC5V06PMYE	2025-06-08 20:45:35.383-04	2025-06-08 22:20:03.45-04	2025-06-08 22:20:03.431-04	iitem_01JX92CQ08ZYF4X9Y3MRH8W616	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8NHJC2B8G5YS8GEJE2	2025-06-08 20:45:35.383-04	2025-06-08 22:20:08.131-04	2025-06-08 22:20:08.126-04	iitem_01JX92CQ072XVDAJD3BV5E961D	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8PW8MZ4YZENDSWZV46	2025-06-08 20:45:35.383-04	2025-06-08 22:20:08.143-04	2025-06-08 22:20:08.126-04	iitem_01JX92CQ07F42W84PQBBZDTV68	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8PWSFEAS2M2AFG1GP4	2025-06-08 20:45:35.383-04	2025-06-08 22:20:08.148-04	2025-06-08 22:20:08.126-04	iitem_01JX92CQ0742MTQR07HA3E7BGN	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8P3CKKF3B16SV71T9H	2025-06-08 20:45:35.383-04	2025-06-08 22:20:08.153-04	2025-06-08 22:20:08.126-04	iitem_01JX92CQ07N56R312366MR7V6A	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8NDQGY3KAW8CS8PJD3	2025-06-08 20:45:35.383-04	2025-06-08 22:20:11.777-04	2025-06-08 22:20:11.773-04	iitem_01JX92CQ053C13Y920TAXPG0Z3	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8NJ1XEB154TZESE01N	2025-06-08 20:45:35.383-04	2025-06-08 22:20:11.781-04	2025-06-08 22:20:11.773-04	iitem_01JX92CQ05DDXVMR50SZ03WNYJ	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8N4PCXVN3ZX05ZDKGP	2025-06-08 20:45:35.383-04	2025-06-08 22:20:11.785-04	2025-06-08 22:20:11.773-04	iitem_01JX92CQ0507CRQ6W43ZPYYRKM	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8N32NE37V4WCYEAAX5	2025-06-08 20:45:35.383-04	2025-06-08 22:20:11.791-04	2025-06-08 22:20:11.773-04	iitem_01JX92CQ055RT50QPEAY8NEV1Q	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8MFAAE2KPN65T8HKCG	2025-06-08 20:45:35.383-04	2025-06-08 22:20:11.795-04	2025-06-08 22:20:11.773-04	iitem_01JX92CQ041JS8E1ZNEX85FKBQ	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8N9MEN6B4BW71NKWQB	2025-06-08 20:45:35.383-04	2025-06-08 22:20:11.8-04	2025-06-08 22:20:11.773-04	iitem_01JX92CQ04H0ZCZKDE95FDE0YR	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8N2T3MRZQHG5CETZPS	2025-06-08 20:45:35.383-04	2025-06-08 22:20:11.807-04	2025-06-08 22:20:11.773-04	iitem_01JX92CQ06DW38WB0ZJ5EA14BB	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JX92CQ8NCZDHPME42CR7FVTP	2025-06-08 20:45:35.383-04	2025-06-08 22:20:11.812-04	2025-06-08 22:20:11.773-04	iitem_01JX92CQ06XC7ER1XF1EPRH2PP	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
\.


--
-- Data for Name: invite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invite (id, email, accepted, token, expires_at, metadata, created_at, updated_at, deleted_at) FROM stdin;
invite_01JX92CH8ZDG6Q7CB9NQ04ED35	admin@medusa-test.com	f	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Imludml0ZV8wMUpYOTJDSDhaREc2UTdDQjlOUTA0RUQzNSIsImVtYWlsIjoiYWRtaW5AbWVkdXNhLXRlc3QuY29tIiwiaWF0IjoxNzQ5NDI5OTI5LCJleHAiOjE3NDk1MTYzMjksImp0aSI6IjMzZTFiYjQwLTUyYTctNDk0ZS1iMTY5LThiNzg2ZjI4NTNmNCJ9._aZE9BLdJaTT1eN7zkw7E6893ya3DqUqoqZc4IBOLco	2025-06-09 20:45:29.247-04	\N	2025-06-08 20:45:29.251-04	2025-06-08 20:46:11.794-04	2025-06-08 20:46:11.794-04
\.


--
-- Data for Name: link_module_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.link_module_migrations (id, table_name, link_descriptor, created_at) FROM stdin;
1	cart_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "cart", "fromModule": "cart"}	2025-06-08 20:45:18.759264
2	cart_promotion	{"toModel": "promotions", "toModule": "promotion", "fromModel": "cart", "fromModule": "cart"}	2025-06-08 20:45:18.765583
3	location_fulfillment_provider	{"toModel": "fulfillment_provider", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2025-06-08 20:45:18.77318
4	location_fulfillment_set	{"toModel": "fulfillment_set", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2025-06-08 20:45:18.795655
5	order_cart	{"toModel": "cart", "toModule": "cart", "fromModel": "order", "fromModule": "order"}	2025-06-08 20:45:18.800658
6	order_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "order", "fromModule": "order"}	2025-06-08 20:45:18.807725
7	order_promotion	{"toModel": "promotion", "toModule": "promotion", "fromModel": "order", "fromModule": "order"}	2025-06-08 20:45:18.813218
8	return_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "return", "fromModule": "order"}	2025-06-08 20:45:18.813807
9	order_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "order", "fromModule": "order"}	2025-06-08 20:45:18.813158
10	product_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "product", "fromModule": "product"}	2025-06-08 20:45:18.81892
12	product_variant_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "variant", "fromModule": "product"}	2025-06-08 20:45:18.821953
11	product_variant_inventory_item	{"toModel": "inventory", "toModule": "inventory", "fromModel": "variant", "fromModule": "product"}	2025-06-08 20:45:18.819962
13	publishable_api_key_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "api_key", "fromModule": "api_key"}	2025-06-08 20:45:18.836081
14	region_payment_provider	{"toModel": "payment_provider", "toModule": "payment", "fromModel": "region", "fromModule": "region"}	2025-06-08 20:45:18.842818
15	sales_channel_stock_location	{"toModel": "location", "toModule": "stock_location", "fromModel": "sales_channel", "fromModule": "sales_channel"}	2025-06-08 20:45:18.847441
16	shipping_option_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "shipping_option", "fromModule": "fulfillment"}	2025-06-08 20:45:18.847834
17	product_shipping_profile	{"toModel": "shipping_profile", "toModule": "fulfillment", "fromModel": "product", "fromModule": "product"}	2025-06-08 20:45:18.848535
18	customer_account_holder	{"toModel": "account_holder", "toModule": "payment", "fromModel": "customer", "fromModule": "customer"}	2025-06-08 20:45:18.851713
\.


--
-- Data for Name: location_fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location_fulfillment_provider (stock_location_id, fulfillment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01JX92CPMT9DRJ3NG9ADFABK6B	manual_manual	locfp_01JX92CPN3ET77PAKV9QETNZ5F	2025-06-08 20:45:34.75503-04	2025-06-08 20:45:34.75503-04	\N
\.


--
-- Data for Name: location_fulfillment_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location_fulfillment_set (stock_location_id, fulfillment_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01JX92CPMT9DRJ3NG9ADFABK6B	fuset_01JX92CPNH64CNS7A776NMFWXQ	locfs_01JX92CPP401QRA57V4P1JEBVD	2025-06-08 20:45:34.788251-04	2025-06-08 22:05:25.415-04	2025-06-08 22:05:25.414-04
sloc_01JX92CPMT9DRJ3NG9ADFABK6B	fuset_01JX96YZ86A2S68JBMYHF5GBRW	locfs_01JX96YZ8GP0C4RZATN7EW35AV	2025-06-08 22:05:27.695781-04	2025-06-08 22:05:27.695781-04	\N
sloc_01JX92CPMT9DRJ3NG9ADFABK6B	fuset_01JXTHF7ZJG371GDYRN7WD7WS0	locfs_01JXTHF7ZXZWQ41MDAMRBF6S1E	2025-06-15 15:36:12.029265-04	2025-06-15 15:36:12.029265-04	\N
\.


--
-- Data for Name: mikro_orm_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mikro_orm_migrations (id, name, executed_at) FROM stdin;
1	Migration20240307161216	2025-06-08 20:45:14.196864-04
2	Migration20241210073813	2025-06-08 20:45:14.196864-04
3	Migration20250106142624	2025-06-08 20:45:14.196864-04
4	Migration20250120110820	2025-06-08 20:45:14.196864-04
5	Migration20240307132720	2025-06-08 20:45:14.327445-04
6	Migration20240719123015	2025-06-08 20:45:14.327445-04
7	Migration20241213063611	2025-06-08 20:45:14.327445-04
8	InitialSetup20240401153642	2025-06-08 20:45:14.454139-04
9	Migration20240601111544	2025-06-08 20:45:14.454139-04
10	Migration202408271511	2025-06-08 20:45:14.454139-04
11	Migration20241122120331	2025-06-08 20:45:14.454139-04
12	Migration20241125090957	2025-06-08 20:45:14.454139-04
13	Migration20250411073236	2025-06-08 20:45:14.454139-04
14	Migration20250516081326	2025-06-08 20:45:14.454139-04
15	Migration20230929122253	2025-06-08 20:45:14.77532-04
16	Migration20240322094407	2025-06-08 20:45:14.77532-04
17	Migration20240322113359	2025-06-08 20:45:14.77532-04
18	Migration20240322120125	2025-06-08 20:45:14.77532-04
19	Migration20240626133555	2025-06-08 20:45:14.77532-04
20	Migration20240704094505	2025-06-08 20:45:14.77532-04
21	Migration20241127114534	2025-06-08 20:45:14.77532-04
22	Migration20241127223829	2025-06-08 20:45:14.77532-04
23	Migration20241128055359	2025-06-08 20:45:14.77532-04
24	Migration20241212190401	2025-06-08 20:45:14.77532-04
25	Migration20250408145122	2025-06-08 20:45:14.77532-04
26	Migration20250409122219	2025-06-08 20:45:14.77532-04
27	Migration20240227120221	2025-06-08 20:45:15.121723-04
28	Migration20240617102917	2025-06-08 20:45:15.121723-04
29	Migration20240624153824	2025-06-08 20:45:15.121723-04
30	Migration20241211061114	2025-06-08 20:45:15.121723-04
31	Migration20250113094144	2025-06-08 20:45:15.121723-04
32	Migration20250120110700	2025-06-08 20:45:15.121723-04
33	Migration20250226130616	2025-06-08 20:45:15.121723-04
34	Migration20240124154000	2025-06-08 20:45:15.400212-04
35	Migration20240524123112	2025-06-08 20:45:15.400212-04
36	Migration20240602110946	2025-06-08 20:45:15.400212-04
37	Migration20241211074630	2025-06-08 20:45:15.400212-04
38	Migration20240115152146	2025-06-08 20:45:15.582671-04
39	Migration20240222170223	2025-06-08 20:45:15.651242-04
40	Migration20240831125857	2025-06-08 20:45:15.651242-04
41	Migration20241106085918	2025-06-08 20:45:15.651242-04
42	Migration20241205095237	2025-06-08 20:45:15.651242-04
43	Migration20241216183049	2025-06-08 20:45:15.651242-04
44	Migration20241218091938	2025-06-08 20:45:15.651242-04
45	Migration20250120115059	2025-06-08 20:45:15.651242-04
46	Migration20250212131240	2025-06-08 20:45:15.651242-04
47	Migration20250326151602	2025-06-08 20:45:15.651242-04
48	Migration20240205173216	2025-06-08 20:45:15.882358-04
49	Migration20240624200006	2025-06-08 20:45:15.882358-04
50	Migration20250120110744	2025-06-08 20:45:15.882358-04
51	InitialSetup20240221144943	2025-06-08 20:45:16.07484-04
52	Migration20240604080145	2025-06-08 20:45:16.07484-04
53	Migration20241205122700	2025-06-08 20:45:16.07484-04
54	InitialSetup20240227075933	2025-06-08 20:45:16.154018-04
55	Migration20240621145944	2025-06-08 20:45:16.154018-04
56	Migration20241206083313	2025-06-08 20:45:16.154018-04
57	Migration20240227090331	2025-06-08 20:45:16.233322-04
58	Migration20240710135844	2025-06-08 20:45:16.233322-04
59	Migration20240924114005	2025-06-08 20:45:16.233322-04
60	Migration20241212052837	2025-06-08 20:45:16.233322-04
61	InitialSetup20240228133303	2025-06-08 20:45:16.382129-04
62	Migration20240624082354	2025-06-08 20:45:16.382129-04
63	Migration20240225134525	2025-06-08 20:45:16.450564-04
64	Migration20240806072619	2025-06-08 20:45:16.450564-04
65	Migration20241211151053	2025-06-08 20:45:16.450564-04
66	Migration20250115160517	2025-06-08 20:45:16.450564-04
67	Migration20250120110552	2025-06-08 20:45:16.450564-04
68	Migration20250123122334	2025-06-08 20:45:16.450564-04
69	Migration20250206105639	2025-06-08 20:45:16.450564-04
70	Migration20250207132723	2025-06-08 20:45:16.450564-04
71	Migration20240219102530	2025-06-08 20:45:16.664075-04
72	Migration20240604100512	2025-06-08 20:45:16.664075-04
73	Migration20240715102100	2025-06-08 20:45:16.664075-04
74	Migration20240715174100	2025-06-08 20:45:16.664075-04
75	Migration20240716081800	2025-06-08 20:45:16.664075-04
76	Migration20240801085921	2025-06-08 20:45:16.664075-04
77	Migration20240821164505	2025-06-08 20:45:16.664075-04
78	Migration20240821170920	2025-06-08 20:45:16.664075-04
79	Migration20240827133639	2025-06-08 20:45:16.664075-04
80	Migration20240902195921	2025-06-08 20:45:16.664075-04
81	Migration20240913092514	2025-06-08 20:45:16.664075-04
82	Migration20240930122627	2025-06-08 20:45:16.664075-04
83	Migration20241014142943	2025-06-08 20:45:16.664075-04
84	Migration20241106085223	2025-06-08 20:45:16.664075-04
85	Migration20241129124827	2025-06-08 20:45:16.664075-04
86	Migration20241217162224	2025-06-08 20:45:16.664075-04
87	Migration20250326151554	2025-06-08 20:45:16.664075-04
88	Migration20250522181137	2025-06-08 20:45:16.664075-04
89	Migration20240205025928	2025-06-08 20:45:17.370678-04
90	Migration20240529080336	2025-06-08 20:45:17.370678-04
91	Migration20241202100304	2025-06-08 20:45:17.370678-04
92	Migration20240214033943	2025-06-08 20:45:17.528867-04
93	Migration20240703095850	2025-06-08 20:45:17.528867-04
94	Migration20241202103352	2025-06-08 20:45:17.528867-04
95	Migration20240311145700_InitialSetupMigration	2025-06-08 20:45:17.624091-04
96	Migration20240821170957	2025-06-08 20:45:17.624091-04
97	Migration20240917161003	2025-06-08 20:45:17.624091-04
98	Migration20241217110416	2025-06-08 20:45:17.624091-04
99	Migration20250113122235	2025-06-08 20:45:17.624091-04
100	Migration20250120115002	2025-06-08 20:45:17.624091-04
101	Migration20240509083918_InitialSetupMigration	2025-06-08 20:45:17.892623-04
102	Migration20240628075401	2025-06-08 20:45:17.892623-04
103	Migration20240830094712	2025-06-08 20:45:17.892623-04
104	Migration20250120110514	2025-06-08 20:45:17.892623-04
105	Migration20231228143900	2025-06-08 20:45:18.068579-04
106	Migration20241206101446	2025-06-08 20:45:18.068579-04
107	Migration20250128174331	2025-06-08 20:45:18.068579-04
108	Migration20250505092459	2025-06-08 20:45:18.068579-04
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, "to", channel, template, data, trigger_type, resource_id, resource_type, receiver_id, original_notification_id, idempotency_key, external_id, provider_id, created_at, updated_at, deleted_at, status) FROM stdin;
\.


--
-- Data for Name: notification_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_provider (id, handle, name, is_enabled, channels, created_at, updated_at, deleted_at) FROM stdin;
local	local	local	t	{feed}	2025-06-08 20:45:21.722-04	2025-06-08 20:45:21.722-04	\N
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."order" (id, region_id, display_id, customer_id, version, sales_channel_id, status, is_draft_order, email, currency_code, shipping_address_id, billing_address_id, no_notification, metadata, created_at, updated_at, deleted_at, canceled_at) FROM stdin;
\.


--
-- Data for Name: order_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_cart (order_id, cart_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_change; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_change (id, order_id, version, description, status, internal_note, created_by, requested_by, requested_at, confirmed_by, confirmed_at, declined_by, declined_reason, metadata, declined_at, canceled_by, canceled_at, created_at, updated_at, change_type, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: order_change_action; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_change_action (id, order_id, version, ordering, order_change_id, reference, reference_id, action, details, amount, raw_amount, internal_note, applied, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: order_claim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_claim (id, order_id, return_id, order_version, display_id, type, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_claim_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_claim_item (id, claim_id, item_id, is_additional_item, reason, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_claim_item_image; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_claim_item_image (id, claim_item_id, url, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_credit_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_credit_line (id, order_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_exchange; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_exchange (id, order_id, return_id, order_version, display_id, no_notification, allow_backorder, difference_due, raw_difference_due, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_exchange_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_exchange_item (id, exchange_id, item_id, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_fulfillment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_fulfillment (order_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_item (id, order_id, version, item_id, quantity, raw_quantity, fulfilled_quantity, raw_fulfilled_quantity, shipped_quantity, raw_shipped_quantity, return_requested_quantity, raw_return_requested_quantity, return_received_quantity, raw_return_received_quantity, return_dismissed_quantity, raw_return_dismissed_quantity, written_off_quantity, raw_written_off_quantity, metadata, created_at, updated_at, deleted_at, delivered_quantity, raw_delivered_quantity, unit_price, raw_unit_price, compare_at_unit_price, raw_compare_at_unit_price) FROM stdin;
\.


--
-- Data for Name: order_line_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_line_item (id, totals_id, title, subtitle, thumbnail, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, is_custom_price, product_type_id, is_giftcard) FROM stdin;
\.


--
-- Data for Name: order_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, item_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_line_item_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, item_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_payment_collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_payment_collection (order_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_promotion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_promotion (order_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_shipping (id, order_id, version, shipping_method_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: order_shipping_method; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_shipping_method (id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at, is_custom_amount) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_shipping_method_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_summary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_summary (id, order_id, version, totals, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_transaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_transaction (id, order_id, version, amount, raw_amount, currency_code, reference, reference_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment (id, amount, raw_amount, currency_code, provider_id, data, created_at, updated_at, deleted_at, captured_at, canceled_at, payment_collection_id, payment_session_id, metadata) FROM stdin;
\.


--
-- Data for Name: payment_collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_collection (id, currency_code, amount, raw_amount, authorized_amount, raw_authorized_amount, captured_amount, raw_captured_amount, refunded_amount, raw_refunded_amount, created_at, updated_at, deleted_at, completed_at, status, metadata) FROM stdin;
\.


--
-- Data for Name: payment_collection_payment_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_collection_payment_providers (payment_collection_id, payment_provider_id) FROM stdin;
\.


--
-- Data for Name: payment_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
pp_system_default	t	2025-06-08 20:45:21.398-04	2025-06-08 20:45:21.398-04	\N
\.


--
-- Data for Name: payment_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_session (id, currency_code, amount, raw_amount, provider_id, data, context, status, authorized_at, payment_collection_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price (id, title, price_set_id, currency_code, raw_amount, rules_count, created_at, updated_at, deleted_at, price_list_id, amount, min_quantity, max_quantity) FROM stdin;
price_01JX92CPQXNRWXCRHZVBAXMFZ0	\N	pset_01JX92CPQYQ7T154EWGE3ZZFKC	usd	{"value": "10", "precision": 20}	0	2025-06-08 20:45:34.847-04	2025-06-08 20:45:34.847-04	\N	\N	10	\N	\N
price_01JX92CPQXVKHZ7H7H0TR1WX5P	\N	pset_01JX92CPQYQ7T154EWGE3ZZFKC	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:34.847-04	2025-06-08 20:45:34.847-04	\N	\N	10	\N	\N
price_01JX92CPQYMTAA1JWFGCZB4S6A	\N	pset_01JX92CPQYQ7T154EWGE3ZZFKC	eur	{"value": "10", "precision": 20}	1	2025-06-08 20:45:34.847-04	2025-06-08 20:45:34.847-04	\N	\N	10	\N	\N
price_01JX92CPQYFPEED6MR54FEX791	\N	pset_01JX92CPQZ68RJA37RSM4H83G5	usd	{"value": "10", "precision": 20}	0	2025-06-08 20:45:34.848-04	2025-06-08 20:45:34.848-04	\N	\N	10	\N	\N
price_01JX92CPQYPZGKY855HWSQNSWF	\N	pset_01JX92CPQZ68RJA37RSM4H83G5	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:34.848-04	2025-06-08 20:45:34.848-04	\N	\N	10	\N	\N
price_01JX92CPQY64SQQQB3M95631FV	\N	pset_01JX92CPQZ68RJA37RSM4H83G5	eur	{"value": "10", "precision": 20}	1	2025-06-08 20:45:34.848-04	2025-06-08 20:45:34.848-04	\N	\N	10	\N	\N
price_01JX92CQ38HX5QNYM7JK972HM1	\N	pset_01JX92CQ39Z1554YQZVAAQGJJP	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:20:03.482-04	2025-06-08 22:20:03.478-04	\N	10	\N	\N
price_01JX92CQ38KHM8A879W2Z36SP3	\N	pset_01JX92CQ39Z1554YQZVAAQGJJP	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:20:03.482-04	2025-06-08 22:20:03.478-04	\N	15	\N	\N
price_01JX92CQ3930KAZBEXYGTKCHC4	\N	pset_01JX92CQ3965QF1BNPQ31ZAKCS	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:20:03.495-04	2025-06-08 22:20:03.478-04	\N	10	\N	\N
price_01JX92CQ39Y7WTWX48KGYE3G8F	\N	pset_01JX92CQ3965QF1BNPQ31ZAKCS	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:20:03.495-04	2025-06-08 22:20:03.478-04	\N	15	\N	\N
price_01JX92CQ39YAYRFVP2HM1XC5KR	\N	pset_01JX92CQ39CK47RKV8YH22D23B	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:20:03.517-04	2025-06-08 22:20:03.478-04	\N	10	\N	\N
price_01JX92CQ3912HBTEEP9WF6HAGX	\N	pset_01JX92CQ39CK47RKV8YH22D23B	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:20:03.517-04	2025-06-08 22:20:03.478-04	\N	15	\N	\N
price_01JX92CQ399HBT4VBJGMW1T7AX	\N	pset_01JX92CQ39JEN969RF8E1RXW1Z	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:20:03.524-04	2025-06-08 22:20:03.478-04	\N	10	\N	\N
price_01JX92CQ355XN8SNV9YWR20MAC	\N	pset_01JX92CQ35SACFZTZ6YF04CE8R	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.196-04	2025-06-08 22:20:08.185-04	\N	10	\N	\N
price_01JX92CQ35X4XE6XZ7H9V2NB8X	\N	pset_01JX92CQ35SACFZTZ6YF04CE8R	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.196-04	2025-06-08 22:20:08.185-04	\N	15	\N	\N
price_01JX92CQ35VTY353S5C2K5XBSV	\N	pset_01JX92CQ36BRCK7P693MQHNXHF	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.204-04	2025-06-08 22:20:08.185-04	\N	10	\N	\N
price_01JX92CQ364B636GJ26YNHA5JF	\N	pset_01JX92CQ36BRCK7P693MQHNXHF	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.204-04	2025-06-08 22:20:08.185-04	\N	15	\N	\N
price_01JX92CQ368KPX1GNVE0ZTK0T3	\N	pset_01JX92CQ36FK289G8J387XTKZ1	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.212-04	2025-06-08 22:20:08.185-04	\N	10	\N	\N
price_01JX92CQ3670H2XNBS9PDVWJHA	\N	pset_01JX92CQ36FK289G8J387XTKZ1	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.212-04	2025-06-08 22:20:08.185-04	\N	15	\N	\N
price_01JX92CQ360HSTERRG458W60FA	\N	pset_01JX92CQ37AZ9S6MCQ23XZFDHK	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.218-04	2025-06-08 22:20:08.185-04	\N	10	\N	\N
price_01JX92CQ31TDMH8R0XAGNMFEBG	\N	pset_01JX92CQ32RPBZ3TMZNQBW7REX	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.852-04	2025-06-08 22:20:11.849-04	\N	10	\N	\N
price_01JX92CQ32NQ9P8SZRW8CX4ZFJ	\N	pset_01JX92CQ32RPBZ3TMZNQBW7REX	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.853-04	2025-06-08 22:20:11.849-04	\N	15	\N	\N
price_01JX92CQ324QT56Z1C0Z89QY2K	\N	pset_01JX92CQ332EWYGB9HCRG7B2N7	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.862-04	2025-06-08 22:20:11.849-04	\N	10	\N	\N
price_01JX92CQ334K2046QPYZK7H14E	\N	pset_01JX92CQ332EWYGB9HCRG7B2N7	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.862-04	2025-06-08 22:20:11.849-04	\N	15	\N	\N
price_01JX92CQ33FN82CY88TJ3JAXTX	\N	pset_01JX92CQ33X4FZHZZX7JSGSGVX	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.87-04	2025-06-08 22:20:11.849-04	\N	10	\N	\N
price_01JX92CQ33B9XSKRVFZR450Y3B	\N	pset_01JX92CQ33X4FZHZZX7JSGSGVX	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.87-04	2025-06-08 22:20:11.849-04	\N	15	\N	\N
price_01JX92CQ33ECK2B35Z2VNYAWQ8	\N	pset_01JX92CQ335B245D2M81BTX8BF	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.877-04	2025-06-08 22:20:11.849-04	\N	10	\N	\N
price_01JX961R5AS31MNJBVM1N8RDB1	\N	pset_01JX961R5DWGSSY9SGHDTYYY2Q	eur	{"value": "44900", "precision": 20}	0	2025-06-08 21:49:30.159-04	2025-06-08 22:06:50.686-04	2025-06-08 22:06:50.677-04	\N	44900	\N	\N
price_01JX961R5B1AP08N9867JH5TN3	\N	pset_01JX961R5DWGSSY9SGHDTYYY2Q	usd	{"value": "44990", "precision": 20}	0	2025-06-08 21:49:30.16-04	2025-06-08 22:06:50.686-04	2025-06-08 22:06:50.677-04	\N	44990	\N	\N
price_01JX974NB5N5E50SJC9R0SC903	\N	pset_01JX974NB6KVCJE7YQK30XRZ1V	clp	{"value": "49900", "precision": 20}	0	2025-06-08 22:08:34.15-04	2025-06-08 22:08:34.15-04	\N	\N	49900	\N	\N
price_01JX92CQ37QNF3JV6FY25R7AM6	\N	pset_01JX92CQ37MC7SV097GN7GTAC0	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.711-04	2025-06-08 22:19:57.706-04	\N	10	\N	\N
price_01JX92CQ370R8QHSHGZ2VJ44WN	\N	pset_01JX92CQ37MC7SV097GN7GTAC0	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.711-04	2025-06-08 22:19:57.706-04	\N	15	\N	\N
price_01JX92CQ37RDAMAFCWGFA19E4R	\N	pset_01JX92CQ389Z7E1WPYHHC5XT69	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.717-04	2025-06-08 22:19:57.706-04	\N	10	\N	\N
price_01JX92CQ38CRFKPMG8DGXPS4E9	\N	pset_01JX92CQ389Z7E1WPYHHC5XT69	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.717-04	2025-06-08 22:19:57.706-04	\N	15	\N	\N
price_01JX92CQ38AH8MTBX8PXM5WR3M	\N	pset_01JX92CQ383R9HS1B9CJT2RFQ6	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.724-04	2025-06-08 22:19:57.706-04	\N	10	\N	\N
price_01JX92CQ38Q7VTGXV9JH19TG2W	\N	pset_01JX92CQ383R9HS1B9CJT2RFQ6	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.724-04	2025-06-08 22:19:57.706-04	\N	15	\N	\N
price_01JX92CQ38A52QY6Z82SJ2J5D1	\N	pset_01JX92CQ38ZJ2KMB07MVT348BX	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.73-04	2025-06-08 22:19:57.706-04	\N	10	\N	\N
price_01JX92CQ38ENFWDQ8T8DK9EKSJ	\N	pset_01JX92CQ38ZJ2KMB07MVT348BX	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:19:57.73-04	2025-06-08 22:19:57.706-04	\N	15	\N	\N
price_01JX92CQ39YG8MZA552HPH70DR	\N	pset_01JX92CQ39JEN969RF8E1RXW1Z	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.212-04	2025-06-08 22:20:03.524-04	2025-06-08 22:20:03.478-04	\N	15	\N	\N
price_01JX92CQ37VXP0KG69R1QSB8S8	\N	pset_01JX92CQ37AZ9S6MCQ23XZFDHK	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.219-04	2025-06-08 22:20:08.185-04	\N	15	\N	\N
price_01JX92CQ335BQCTEAKHVV99KPQ	\N	pset_01JX92CQ335B245D2M81BTX8BF	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.877-04	2025-06-08 22:20:11.849-04	\N	15	\N	\N
price_01JX92CQ33S14CA9BA2TG44VDB	\N	pset_01JX92CQ34KVJSNERAM14109QV	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.883-04	2025-06-08 22:20:11.849-04	\N	10	\N	\N
price_01JX92CQ34GZFPQ4GTXKVJPTAV	\N	pset_01JX92CQ34KVJSNERAM14109QV	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.883-04	2025-06-08 22:20:11.849-04	\N	15	\N	\N
price_01JX92CQ34SXRDJ70BHPANFYK8	\N	pset_01JX92CQ34KR0ZHKSB0MYV9QXX	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.889-04	2025-06-08 22:20:11.849-04	\N	10	\N	\N
price_01JX92CQ349NDD57ZKWCX2B372	\N	pset_01JX92CQ34KR0ZHKSB0MYV9QXX	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.889-04	2025-06-08 22:20:11.849-04	\N	15	\N	\N
price_01JX92CQ35R3TJCZ7TC280J54S	\N	pset_01JX92CQ35JXPWTBZ707DK589Z	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.894-04	2025-06-08 22:20:11.849-04	\N	10	\N	\N
price_01JX92CQ354QCHG1ZEGE675SJV	\N	pset_01JX92CQ35JXPWTBZ707DK589Z	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.894-04	2025-06-08 22:20:11.849-04	\N	15	\N	\N
price_01JX92CQ35JD9VQ39YNXGJN1Y6	\N	pset_01JX92CQ3544V5P61CS5D0Q92E	eur	{"value": "10", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.9-04	2025-06-08 22:20:11.849-04	\N	10	\N	\N
price_01JX92CQ35V18JDSJGEWGDCYQZ	\N	pset_01JX92CQ3544V5P61CS5D0Q92E	usd	{"value": "15", "precision": 20}	0	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.9-04	2025-06-08 22:20:11.849-04	\N	15	\N	\N
\.


--
-- Data for Name: price_list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_list (id, status, starts_at, ends_at, rules_count, title, description, type, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: price_list_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_list_rule (id, price_list_id, created_at, updated_at, deleted_at, value, attribute) FROM stdin;
\.


--
-- Data for Name: price_preference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_preference (id, attribute, value, is_tax_inclusive, created_at, updated_at, deleted_at) FROM stdin;
prpref_01JX92CH7VSFEMFSF1YWVV3YP3	currency_code	eur	f	2025-06-08 20:45:29.211-04	2025-06-08 20:45:29.211-04	\N
prpref_01JX92CPJFSHX22RNJFY9D7H33	currency_code	usd	f	2025-06-08 20:45:34.671-04	2025-06-08 20:45:34.672-04	\N
prpref_01JX92CPKP11SHCEEYN8EG7PJN	region_id	reg_01JX92CPJV4PY6T452C0KP8M4V	f	2025-06-08 20:45:34.71-04	2025-06-08 20:45:34.71-04	\N
prpref_01JX96S0QNJMATKSAV0JJKB4HS	currency_code	clp	t	2025-06-08 22:02:12.597-04	2025-06-08 22:02:12.597-04	\N
prpref_01JX96W5D0NV9VWM4W1FYRF6QA	region_id	reg_01JX96W5CAFG1XZM8E72ARJY8Z	t	2025-06-08 22:03:55.68-04	2025-06-15 15:34:04.357-04	\N
\.


--
-- Data for Name: price_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_rule (id, value, priority, price_id, created_at, updated_at, deleted_at, attribute, operator) FROM stdin;
prule_01JX92CPQY0XRZZ18YC952JGAN	reg_01JX92CPJV4PY6T452C0KP8M4V	0	price_01JX92CPQYMTAA1JWFGCZB4S6A	2025-06-08 20:45:34.847-04	2025-06-08 20:45:34.847-04	\N	region_id	eq
prule_01JX92CPQYCPAC2GYEHG76TE6C	reg_01JX92CPJV4PY6T452C0KP8M4V	0	price_01JX92CPQY64SQQQB3M95631FV	2025-06-08 20:45:34.848-04	2025-06-08 20:45:34.848-04	\N	region_id	eq
\.


--
-- Data for Name: price_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_set (id, created_at, updated_at, deleted_at) FROM stdin;
pset_01JX92CPQYQ7T154EWGE3ZZFKC	2025-06-08 20:45:34.847-04	2025-06-08 20:45:34.847-04	\N
pset_01JX92CPQZ68RJA37RSM4H83G5	2025-06-08 20:45:34.847-04	2025-06-08 20:45:34.847-04	\N
pset_01JX95HQ636VTGK6D30N15Z98X	2025-06-08 21:40:44.868-04	2025-06-08 21:47:24.879-04	2025-06-08 21:47:24.879-04
pset_01JX961R5DWGSSY9SGHDTYYY2Q	2025-06-08 21:49:30.158-04	2025-06-08 22:06:50.677-04	2025-06-08 22:06:50.677-04
pset_01JX974NB6KVCJE7YQK30XRZ1V	2025-06-08 22:08:34.15-04	2025-06-08 22:08:34.15-04	\N
pset_01JX92CQ37MC7SV097GN7GTAC0	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.707-04	2025-06-08 22:19:57.706-04
pset_01JX92CQ389Z7E1WPYHHC5XT69	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.715-04	2025-06-08 22:19:57.706-04
pset_01JX92CQ383R9HS1B9CJT2RFQ6	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.722-04	2025-06-08 22:19:57.706-04
pset_01JX92CQ38ZJ2KMB07MVT348BX	2025-06-08 20:45:35.211-04	2025-06-08 22:19:57.727-04	2025-06-08 22:19:57.706-04
pset_01JX92CQ39Z1554YQZVAAQGJJP	2025-06-08 20:45:35.211-04	2025-06-08 22:20:03.478-04	2025-06-08 22:20:03.478-04
pset_01JX92CQ3965QF1BNPQ31ZAKCS	2025-06-08 20:45:35.211-04	2025-06-08 22:20:03.492-04	2025-06-08 22:20:03.478-04
pset_01JX92CQ39CK47RKV8YH22D23B	2025-06-08 20:45:35.211-04	2025-06-08 22:20:03.5-04	2025-06-08 22:20:03.478-04
pset_01JX92CQ39JEN969RF8E1RXW1Z	2025-06-08 20:45:35.211-04	2025-06-08 22:20:03.521-04	2025-06-08 22:20:03.478-04
pset_01JX92CQ35SACFZTZ6YF04CE8R	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.186-04	2025-06-08 22:20:08.185-04
pset_01JX92CQ36BRCK7P693MQHNXHF	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.2-04	2025-06-08 22:20:08.185-04
pset_01JX92CQ36FK289G8J387XTKZ1	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.208-04	2025-06-08 22:20:08.185-04
pset_01JX92CQ37AZ9S6MCQ23XZFDHK	2025-06-08 20:45:35.211-04	2025-06-08 22:20:08.216-04	2025-06-08 22:20:08.185-04
pset_01JX92CQ32RPBZ3TMZNQBW7REX	2025-06-08 20:45:35.21-04	2025-06-08 22:20:11.849-04	2025-06-08 22:20:11.849-04
pset_01JX92CQ332EWYGB9HCRG7B2N7	2025-06-08 20:45:35.21-04	2025-06-08 22:20:11.858-04	2025-06-08 22:20:11.849-04
pset_01JX92CQ33X4FZHZZX7JSGSGVX	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.866-04	2025-06-08 22:20:11.849-04
pset_01JX92CQ335B245D2M81BTX8BF	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.874-04	2025-06-08 22:20:11.849-04
pset_01JX92CQ34KVJSNERAM14109QV	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.88-04	2025-06-08 22:20:11.849-04
pset_01JX92CQ34KR0ZHKSB0MYV9QXX	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.886-04	2025-06-08 22:20:11.849-04
pset_01JX92CQ35JXPWTBZ707DK589Z	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.892-04	2025-06-08 22:20:11.849-04
pset_01JX92CQ3544V5P61CS5D0Q92E	2025-06-08 20:45:35.211-04	2025-06-08 22:20:11.898-04	2025-06-08 22:20:11.849-04
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (id, title, handle, subtitle, description, is_giftcard, status, thumbnail, weight, length, height, width, origin_country, hs_code, mid_code, material, collection_id, type_id, discountable, external_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
prod_01JX95HQ301NWH6SCMHTWD7MY0	Ventilador de techo Flight 52" (132 cm)	ventilador-de-techo-flight-52-132-cm	Precio Retail $134.900	\N	f	published	http://localhost:9000/static/1749433244747-w=1500,h=1500,fit=pad-13.webp	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-06-08 21:40:44.77-04	2025-06-08 21:47:24.853-04	2025-06-08 21:47:24.853-04	{}
prod_01JX961R0K4P63A4MK6HCCDQH7	Ventilador de techo Flight 52" (132 cm)	ventilador-de-techo-flight-52-132-cm	\N	⚡ EL PAPITA LO HIZO DE NUEVO\nRetail: $134.990 (auch)\nLa Papita: $49.990 (¡aaaah!)\nAhorraste $84.000 para más papas fritas 🍟	f	published	http://localhost:9000/static/1749433769980-w=1500,h=1500,fit=pad-13.webp	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-06-08 21:49:30.01-04	2025-06-08 22:06:50.654-04	2025-06-08 22:06:50.653-04	\N
prod_01JX92CPTN3EQ8DBW9PR5BWTY6	Medusa Sweatpants	sweatpants	\N	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-06-08 20:45:34.941-04	2025-06-08 22:19:57.684-04	2025-06-08 22:19:57.684-04	\N
prod_01JX92CPTNEZ2T087281MJ9GTZ	Medusa Shorts	shorts	\N	Reimagine the feeling of classic shorts. With our cotton shorts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-06-08 20:45:34.941-04	2025-06-08 22:20:03.467-04	2025-06-08 22:20:03.467-04	\N
prod_01JX92CPTNNCVM0P17JH26FY7A	Medusa Sweatshirt	sweatshirt	\N	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-06-08 20:45:34.941-04	2025-06-08 22:20:08.167-04	2025-06-08 22:20:08.167-04	\N
prod_01JX92CPTNT0M9QXCDF6J720EH	Medusa T-Shirt	t-shirt	\N	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-06-08 20:45:34.941-04	2025-06-08 22:20:11.824-04	2025-06-08 22:20:11.823-04	\N
prod_01JX974N8STXW6ACEYYRTBB1QD	Ventilador de techo Flight 52" (132 cm)	ventilador-de-techo-flight-52-132-cm	\N	⚡ EL PAPITA CRISTIAN LO HIZO DE NUEVO\nRetail: $134.990 (auch)\nLa Papita: $49.990 (¡aaaah!)\nAhorraste $84.000 para más papas fritas 🍟	f	published	http://localhost:9000/static/1749434914057-w=1500,h=1500,fit=pad-13.webp	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-06-08 22:08:34.076-04	2025-06-15 16:25:09.376-04	\N	\N
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_category (id, name, description, handle, mpath, is_active, is_internal, rank, parent_category_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
pcat_01JX92CPT7SSB75B92QBZR23JR	Sweatshirts		sweatshirts	pcat_01JX92CPT7SSB75B92QBZR23JR	t	f	0	\N	2025-06-08 20:45:34.921-04	2025-06-15 15:15:40.241-04	\N	\N
pcat_01JX92CPT8HNXQ1C9KSXH996GK	Pants		pants	pcat_01JX92CPT8HNXQ1C9KSXH996GK	t	f	1	\N	2025-06-08 20:45:34.921-04	2025-06-15 15:15:40.241-04	\N	\N
pcat_01JX92CPT81NRJ3WYQAZ920H0M	Merch		merch	pcat_01JX92CPT81NRJ3WYQAZ920H0M	t	f	2	\N	2025-06-08 20:45:34.921-04	2025-06-15 15:15:40.241-04	\N	\N
pcat_01JX92CPT7DTVAB648XB6WRQ3Z	Shirts		shirts	pcat_01JX92CPT7DTVAB648XB6WRQ3Z	f	f	0	\N	2025-06-08 20:45:34.92-04	2025-06-15 15:15:40.245-04	2025-06-15 15:15:40.244-04	\N
pcat_01JXTGD6W8HT0TWY3YDANRAG8C	Niños	La papita para los reyes de la casa: diversión garantizada y menos berrinches (por lo menos por un rato).	ninos	pcat_01JXTGD6W8HT0TWY3YDANRAG8C	t	f	3	\N	2025-06-15 15:17:36.777-04	2025-06-15 16:18:30.659-04	\N	\N
pcat_01JXTFWGJ820YDASWC0AR6ZKFG	test		test	pcat_01JXTGD6W8HT0TWY3YDANRAG8C.pcat_01JXTFWGJ820YDASWC0AR6ZKFG	t	f	0	pcat_01JXTGD6W8HT0TWY3YDANRAG8C	2025-06-15 15:08:29.64-04	2025-06-15 16:18:30.659-04	\N	\N
\.


--
-- Data for Name: product_category_product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_category_product (product_id, product_category_id) FROM stdin;
prod_01JX92CPTNT0M9QXCDF6J720EH	pcat_01JX92CPT7DTVAB648XB6WRQ3Z
prod_01JX92CPTNNCVM0P17JH26FY7A	pcat_01JX92CPT7SSB75B92QBZR23JR
prod_01JX92CPTN3EQ8DBW9PR5BWTY6	pcat_01JX92CPT8HNXQ1C9KSXH996GK
prod_01JX92CPTNEZ2T087281MJ9GTZ	pcat_01JX92CPT81NRJ3WYQAZ920H0M
prod_01JX95HQ301NWH6SCMHTWD7MY0	pcat_01JX92CPT7DTVAB648XB6WRQ3Z
prod_01JX961R0K4P63A4MK6HCCDQH7	pcat_01JX92CPT7DTVAB648XB6WRQ3Z
prod_01JX974N8STXW6ACEYYRTBB1QD	pcat_01JX92CPT7DTVAB648XB6WRQ3Z
prod_01JX974N8STXW6ACEYYRTBB1QD	pcat_01JXTGD6W8HT0TWY3YDANRAG8C
\.


--
-- Data for Name: product_collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_collection (id, title, handle, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_option; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_option (id, title, product_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
opt_01JX95HQ302T4HACCN9GXDHD02	Default option	prod_01JX95HQ301NWH6SCMHTWD7MY0	\N	2025-06-08 21:40:44.771-04	2025-06-08 21:47:24.863-04	2025-06-08 21:47:24.853-04
opt_01JX961R0P2PP0CDBRBMMEJGK2	Default option	prod_01JX961R0K4P63A4MK6HCCDQH7	\N	2025-06-08 21:49:30.011-04	2025-06-08 22:06:50.67-04	2025-06-08 22:06:50.653-04
opt_01JX974N8TATTDBW774W7XC3BR	Default option	prod_01JX974N8STXW6ACEYYRTBB1QD	\N	2025-06-08 22:08:34.077-04	2025-06-08 22:08:34.077-04	\N
opt_01JX92CPTVTMN02771TCE1VQGS	Size	prod_01JX92CPTN3EQ8DBW9PR5BWTY6	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:19:57.694-04	2025-06-08 22:19:57.684-04
opt_01JX92CPTWA1E8EK0Q3HAAR2F0	Size	prod_01JX92CPTNEZ2T087281MJ9GTZ	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:03.476-04	2025-06-08 22:20:03.467-04
opt_01JX92CPTTZ4D60GGXJZK845P6	Size	prod_01JX92CPTNNCVM0P17JH26FY7A	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:08.178-04	2025-06-08 22:20:08.167-04
opt_01JX92CPTR6N26Y625ZJBFGJEP	Size	prod_01JX92CPTNT0M9QXCDF6J720EH	\N	2025-06-08 20:45:34.941-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
opt_01JX92CPTRT1D2X8SZEQA5PJQT	Color	prod_01JX92CPTNT0M9QXCDF6J720EH	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
\.


--
-- Data for Name: product_option_value; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_option_value (id, value, option_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
optval_01JX95HQ30XR6YF806KN7868DH	Default option value	opt_01JX95HQ302T4HACCN9GXDHD02	\N	2025-06-08 21:40:44.772-04	2025-06-08 21:47:24.882-04	2025-06-08 21:47:24.853-04
optval_01JX961R0N36AEC0Q93PVX73JV	Default option value	opt_01JX961R0P2PP0CDBRBMMEJGK2	\N	2025-06-08 21:49:30.011-04	2025-06-08 22:06:50.68-04	2025-06-08 22:06:50.653-04
optval_01JX974N8TCJ6GZR13NFKTRRY6	Default option value	opt_01JX974N8TATTDBW774W7XC3BR	\N	2025-06-08 22:08:34.077-04	2025-06-08 22:08:34.077-04	\N
optval_01JX92CPTVZKN4MNCXK5JJ3VBB	S	opt_01JX92CPTVTMN02771TCE1VQGS	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:19:57.705-04	2025-06-08 22:19:57.684-04
optval_01JX92CPTV8NR2VSA6C0C8FCNB	M	opt_01JX92CPTVTMN02771TCE1VQGS	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:19:57.705-04	2025-06-08 22:19:57.684-04
optval_01JX92CPTVVXKDM88RFT2KZN22	L	opt_01JX92CPTVTMN02771TCE1VQGS	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:19:57.705-04	2025-06-08 22:19:57.684-04
optval_01JX92CPTVQKNTM4BSK5PE9GAH	XL	opt_01JX92CPTVTMN02771TCE1VQGS	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:19:57.705-04	2025-06-08 22:19:57.684-04
optval_01JX92CPTW2XV26N328T8RBZY3	S	opt_01JX92CPTWA1E8EK0Q3HAAR2F0	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:03.488-04	2025-06-08 22:20:03.467-04
optval_01JX92CPTW4ZGN7GCY8X1MDQ3N	M	opt_01JX92CPTWA1E8EK0Q3HAAR2F0	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:03.488-04	2025-06-08 22:20:03.467-04
optval_01JX92CPTWY4YRNE3JDQRAG9M3	L	opt_01JX92CPTWA1E8EK0Q3HAAR2F0	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:03.488-04	2025-06-08 22:20:03.467-04
optval_01JX92CPTW5Q9W12W53KE514Y4	XL	opt_01JX92CPTWA1E8EK0Q3HAAR2F0	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:03.488-04	2025-06-08 22:20:03.467-04
optval_01JX92CPTTZESBZCA04H14E4FW	S	opt_01JX92CPTTZ4D60GGXJZK845P6	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:08.189-04	2025-06-08 22:20:08.167-04
optval_01JX92CPTTGCZRK7DY7GHB6E4C	M	opt_01JX92CPTTZ4D60GGXJZK845P6	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:08.189-04	2025-06-08 22:20:08.167-04
optval_01JX92CPTTK8DHY1TEGQ1P6ZNE	L	opt_01JX92CPTTZ4D60GGXJZK845P6	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:08.189-04	2025-06-08 22:20:08.167-04
optval_01JX92CPTTWJ25VYAK90XS416K	XL	opt_01JX92CPTTZ4D60GGXJZK845P6	\N	2025-06-08 20:45:34.943-04	2025-06-08 22:20:08.189-04	2025-06-08 22:20:08.167-04
optval_01JX92CPTQPYDMPGZ45YJ5WV18	S	opt_01JX92CPTR6N26Y625ZJBFGJEP	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.848-04	2025-06-08 22:20:11.823-04
optval_01JX92CPTQ8J27SDRZ7SG6KB42	M	opt_01JX92CPTR6N26Y625ZJBFGJEP	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.848-04	2025-06-08 22:20:11.823-04
optval_01JX92CPTRK653RZ50W1RW86XS	L	opt_01JX92CPTR6N26Y625ZJBFGJEP	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.848-04	2025-06-08 22:20:11.823-04
optval_01JX92CPTRWRZGRQDMMYASPQY4	XL	opt_01JX92CPTR6N26Y625ZJBFGJEP	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.848-04	2025-06-08 22:20:11.823-04
optval_01JX92CPTRT5MMK08ZPVZJKAMG	Black	opt_01JX92CPTRT1D2X8SZEQA5PJQT	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.848-04	2025-06-08 22:20:11.823-04
optval_01JX92CPTRV5P5PCY1VJWSP1JK	White	opt_01JX92CPTRT1D2X8SZEQA5PJQT	\N	2025-06-08 20:45:34.942-04	2025-06-08 22:20:11.848-04	2025-06-08 22:20:11.823-04
\.


--
-- Data for Name: product_sales_channel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_sales_channel (product_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01JX95HQ301NWH6SCMHTWD7MY0	sc_01JX92CH43K6G3YZSHBR6WXNYP	prodsc_01JX95HQ48NRV42JKPMA8QSJ1P	2025-06-08 21:40:44.806554-04	2025-06-08 21:47:24.875-04	2025-06-08 21:47:24.875-04
prod_01JX961R0K4P63A4MK6HCCDQH7	sc_01JX92CH43K6G3YZSHBR6WXNYP	prodsc_01JX961R1Y1E3ZR269P97RJ37E	2025-06-08 21:49:30.046109-04	2025-06-08 22:06:50.664-04	2025-06-08 22:06:50.664-04
prod_01JX974N8STXW6ACEYYRTBB1QD	sc_01JX92CH43K6G3YZSHBR6WXNYP	prodsc_01JX974N9EE5BEDKHR499G0JBG	2025-06-08 22:08:34.09412-04	2025-06-08 22:08:34.09412-04	\N
prod_01JX92CPTN3EQ8DBW9PR5BWTY6	sc_01JX92CH43K6G3YZSHBR6WXNYP	prodsc_01JX92CPW052WCB1RGTMSWZN2P	2025-06-08 20:45:34.974947-04	2025-06-08 22:19:57.689-04	2025-06-08 22:19:57.689-04
prod_01JX92CPTNEZ2T087281MJ9GTZ	sc_01JX92CH43K6G3YZSHBR6WXNYP	prodsc_01JX92CPW04ZCVEAWPNFVD1X02	2025-06-08 20:45:34.974947-04	2025-06-08 22:20:03.469-04	2025-06-08 22:20:03.469-04
prod_01JX92CPTNNCVM0P17JH26FY7A	sc_01JX92CH43K6G3YZSHBR6WXNYP	prodsc_01JX92CPW0QDTPB8XC26CQR2K2	2025-06-08 20:45:34.974947-04	2025-06-08 22:20:08.18-04	2025-06-08 22:20:08.18-04
prod_01JX92CPTNT0M9QXCDF6J720EH	sc_01JX92CH43K6G3YZSHBR6WXNYP	prodsc_01JX92CPVZRND7NQ7FAWE7FTCK	2025-06-08 20:45:34.974947-04	2025-06-08 22:20:11.838-04	2025-06-08 22:20:11.838-04
\.


--
-- Data for Name: product_shipping_profile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_shipping_profile (product_id, shipping_profile_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01JX974N8STXW6ACEYYRTBB1QD	sp_01JX92CB66MQ5J3HTB51ZX1R1N	prodsp_01JX974N9PVXF3BQWQ2C10MVYS	2025-06-08 22:08:34.10265-04	2025-06-08 22:08:34.10265-04	\N
prod_01JX92CPTN3EQ8DBW9PR5BWTY6	sp_01JX92CB66MQ5J3HTB51ZX1R1N	prodsp_01JX92CPWP83E0TCSAJ7BES87P	2025-06-08 20:45:34.996977-04	2025-06-08 22:19:57.696-04	2025-06-08 22:19:57.695-04
prod_01JX92CPTNEZ2T087281MJ9GTZ	sp_01JX92CB66MQ5J3HTB51ZX1R1N	prodsp_01JX92CPWPZH6BMWNPR7GSC2B6	2025-06-08 20:45:34.996977-04	2025-06-08 22:20:03.47-04	2025-06-08 22:20:03.47-04
prod_01JX92CPTNNCVM0P17JH26FY7A	sp_01JX92CB66MQ5J3HTB51ZX1R1N	prodsp_01JX92CPWNMD5EEV256Y51H6R7	2025-06-08 20:45:34.996977-04	2025-06-08 22:20:08.173-04	2025-06-08 22:20:08.173-04
prod_01JX92CPTNT0M9QXCDF6J720EH	sp_01JX92CB66MQ5J3HTB51ZX1R1N	prodsp_01JX92CPWNTER3QMNZ9B3JWQTJ	2025-06-08 20:45:34.996977-04	2025-06-08 22:20:11.84-04	2025-06-08 22:20:11.84-04
\.


--
-- Data for Name: product_tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_tag (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_tags (product_id, product_tag_id) FROM stdin;
\.


--
-- Data for Name: product_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_type (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_variant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variant (id, title, sku, barcode, ean, upc, allow_backorder, manage_inventory, hs_code, origin_country, mid_code, material, weight, length, height, width, metadata, variant_rank, product_id, created_at, updated_at, deleted_at) FROM stdin;
variant_01JX95HQ549G12BJ5APAR3D70G	Default variant	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX95HQ301NWH6SCMHTWD7MY0	2025-06-08 21:40:44.836-04	2025-06-08 21:47:24.863-04	2025-06-08 21:47:24.853-04
variant_01JX961R3F8WEYC4EZCS4PTG6K	Default variant	\N	\N	\N	\N	t	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX961R0K4P63A4MK6HCCDQH7	2025-06-08 21:49:30.095-04	2025-06-08 22:06:50.67-04	2025-06-08 22:06:50.653-04
variant_01JX974NA6C3EH827GXE39F966	Default variant	\N	\N	\N	\N	t	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX974N8STXW6ACEYYRTBB1QD	2025-06-08 22:08:34.119-04	2025-06-08 22:08:34.119-04	\N
variant_01JX92CPYD3FY4GQNV5J4Q0FT6	S	SWEATPANTS-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTN3EQ8DBW9PR5BWTY6	2025-06-08 20:45:35.057-04	2025-06-08 22:19:57.694-04	2025-06-08 22:19:57.684-04
variant_01JX92CPYD7KM69SZFHB5CEDX5	M	SWEATPANTS-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTN3EQ8DBW9PR5BWTY6	2025-06-08 20:45:35.057-04	2025-06-08 22:19:57.694-04	2025-06-08 22:19:57.684-04
variant_01JX92CPYDCEMVX838T5ENTNSR	L	SWEATPANTS-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTN3EQ8DBW9PR5BWTY6	2025-06-08 20:45:35.057-04	2025-06-08 22:19:57.694-04	2025-06-08 22:19:57.684-04
variant_01JX92CPYDGW7P218JENEPA5WG	XL	SWEATPANTS-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTN3EQ8DBW9PR5BWTY6	2025-06-08 20:45:35.057-04	2025-06-08 22:19:57.694-04	2025-06-08 22:19:57.684-04
variant_01JX92CPYER60FQZRCKCD52NY8	S	SHORTS-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNEZ2T087281MJ9GTZ	2025-06-08 20:45:35.057-04	2025-06-08 22:20:03.476-04	2025-06-08 22:20:03.467-04
variant_01JX92CPYEQ1VRPXP656TS8XAQ	M	SHORTS-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNEZ2T087281MJ9GTZ	2025-06-08 20:45:35.057-04	2025-06-08 22:20:03.476-04	2025-06-08 22:20:03.467-04
variant_01JX92CPYEWTJYT0CF7JCTMG2D	L	SHORTS-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNEZ2T087281MJ9GTZ	2025-06-08 20:45:35.057-04	2025-06-08 22:20:03.476-04	2025-06-08 22:20:03.467-04
variant_01JX92CPYEB84JC3ZHET7BZS3C	XL	SHORTS-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNEZ2T087281MJ9GTZ	2025-06-08 20:45:35.057-04	2025-06-08 22:20:03.476-04	2025-06-08 22:20:03.467-04
variant_01JX92CPYCCRPWC1TC9SKNVDVE	S	SWEATSHIRT-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNNCVM0P17JH26FY7A	2025-06-08 20:45:35.056-04	2025-06-08 22:20:08.178-04	2025-06-08 22:20:08.167-04
variant_01JX92CPYCZBDNXN3X5MVSG8R6	M	SWEATSHIRT-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNNCVM0P17JH26FY7A	2025-06-08 20:45:35.057-04	2025-06-08 22:20:08.178-04	2025-06-08 22:20:08.167-04
variant_01JX92CPYDG5WC39GF1FCC55TC	L	SWEATSHIRT-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNNCVM0P17JH26FY7A	2025-06-08 20:45:35.057-04	2025-06-08 22:20:08.178-04	2025-06-08 22:20:08.167-04
variant_01JX92CPYDJK1TC5BRXMTD1QSJ	XL	SWEATSHIRT-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNNCVM0P17JH26FY7A	2025-06-08 20:45:35.057-04	2025-06-08 22:20:08.178-04	2025-06-08 22:20:08.167-04
variant_01JX92CPY828FJG6HDR3RJBVGV	S / Black	SHIRT-S-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNT0M9QXCDF6J720EH	2025-06-08 20:45:35.055-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
variant_01JX92CPY9NB56ECFQPDAQ98JE	S / White	SHIRT-S-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNT0M9QXCDF6J720EH	2025-06-08 20:45:35.056-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
variant_01JX92CPY9PEER38EW4JM54JQD	M / Black	SHIRT-M-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNT0M9QXCDF6J720EH	2025-06-08 20:45:35.056-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
variant_01JX92CPYAV9XNEACXDK6F72EH	M / White	SHIRT-M-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNT0M9QXCDF6J720EH	2025-06-08 20:45:35.056-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
variant_01JX92CPYAEXC5CQVQSGBZGTJ0	L / Black	SHIRT-L-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNT0M9QXCDF6J720EH	2025-06-08 20:45:35.056-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
variant_01JX92CPYBCKX0QJ3DYCVRWR65	L / White	SHIRT-L-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNT0M9QXCDF6J720EH	2025-06-08 20:45:35.056-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
variant_01JX92CPYB1PFMBRPX9W12TZY7	XL / Black	SHIRT-XL-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNT0M9QXCDF6J720EH	2025-06-08 20:45:35.056-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
variant_01JX92CPYBFVAGV3N9A95W0YDP	XL / White	SHIRT-XL-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JX92CPTNT0M9QXCDF6J720EH	2025-06-08 20:45:35.056-04	2025-06-08 22:20:11.837-04	2025-06-08 22:20:11.823-04
\.


--
-- Data for Name: product_variant_inventory_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variant_inventory_item (variant_id, inventory_item_id, id, required_quantity, created_at, updated_at, deleted_at) FROM stdin;
variant_01JX95HQ549G12BJ5APAR3D70G	iitem_01JX95HQ5HQE72MBKDJK3QSG8V	pvitem_01JX95HQ5YHW42P1ZP4RH1N9XY	1	2025-06-08 21:40:44.861392-04	2025-06-08 21:47:24.84-04	2025-06-08 21:47:24.84-04
variant_01JX92CPYD3FY4GQNV5J4Q0FT6	iitem_01JX92CQ07TG1Z563Y5G6C1CTX	pvitem_01JX92CQ1HHDC0CXM1NEN6G311	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:19:57.676-04	2025-06-08 22:19:57.675-04
variant_01JX92CPYD7KM69SZFHB5CEDX5	iitem_01JX92CQ0782J5JD2BNVGEN4MD	pvitem_01JX92CQ1H1P760B24JYHFDD12	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:19:57.676-04	2025-06-08 22:19:57.675-04
variant_01JX92CPYDCEMVX838T5ENTNSR	iitem_01JX92CQ08JRX645FRXWP06ES2	pvitem_01JX92CQ1HN29Y8D8XH967SFAJ	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:19:57.676-04	2025-06-08 22:19:57.675-04
variant_01JX92CPYDGW7P218JENEPA5WG	iitem_01JX92CQ087W356H5GEKGGQ3WV	pvitem_01JX92CQ1JY3GB5KKKB7HBZXS8	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:19:57.676-04	2025-06-08 22:19:57.675-04
variant_01JX92CPYER60FQZRCKCD52NY8	iitem_01JX92CQ0809CY6R3S8TSWQTBE	pvitem_01JX92CQ1J1TJDP2NCPA41ENXN	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:03.455-04	2025-06-08 22:20:03.455-04
variant_01JX92CPYEQ1VRPXP656TS8XAQ	iitem_01JX92CQ082BDVTXWK0F11SWKX	pvitem_01JX92CQ1J3EAJ21FJP8VPP1G8	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:03.455-04	2025-06-08 22:20:03.455-04
variant_01JX92CPYEWTJYT0CF7JCTMG2D	iitem_01JX92CQ08X19XSXEWEXDQ5X6F	pvitem_01JX92CQ1JWRVRAF6AVDWJJ1SX	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:03.455-04	2025-06-08 22:20:03.455-04
variant_01JX92CPYEB84JC3ZHET7BZS3C	iitem_01JX92CQ08ZYF4X9Y3MRH8W616	pvitem_01JX92CQ1J4EYQ3T5XZRXKKFJS	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:03.455-04	2025-06-08 22:20:03.455-04
variant_01JX92CPYCCRPWC1TC9SKNVDVE	iitem_01JX92CQ0742MTQR07HA3E7BGN	pvitem_01JX92CQ1GV68HRJS1F4M6CP1B	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:08.159-04	2025-06-08 22:20:08.158-04
variant_01JX92CPYCZBDNXN3X5MVSG8R6	iitem_01JX92CQ07F42W84PQBBZDTV68	pvitem_01JX92CQ1HVW13G5S1SX492A4Q	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:08.159-04	2025-06-08 22:20:08.158-04
variant_01JX92CPYDG5WC39GF1FCC55TC	iitem_01JX92CQ072XVDAJD3BV5E961D	pvitem_01JX92CQ1HKBVAJNE7N30PKMT8	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:08.159-04	2025-06-08 22:20:08.158-04
variant_01JX92CPYDJK1TC5BRXMTD1QSJ	iitem_01JX92CQ07N56R312366MR7V6A	pvitem_01JX92CQ1HPG77V03FNG09X8BS	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:08.159-04	2025-06-08 22:20:08.158-04
variant_01JX92CPY828FJG6HDR3RJBVGV	iitem_01JX92CQ041JS8E1ZNEX85FKBQ	pvitem_01JX92CQ1FF8SDWSYJQE8DTE8Z	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:11.816-04	2025-06-08 22:20:11.816-04
variant_01JX92CPY9NB56ECFQPDAQ98JE	iitem_01JX92CQ04H0ZCZKDE95FDE0YR	pvitem_01JX92CQ1GE5T5V27ZTEN9M2KZ	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:11.816-04	2025-06-08 22:20:11.816-04
variant_01JX92CPY9PEER38EW4JM54JQD	iitem_01JX92CQ0507CRQ6W43ZPYYRKM	pvitem_01JX92CQ1GT4YC5PKD60NSRMYP	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:11.816-04	2025-06-08 22:20:11.816-04
variant_01JX92CPYAV9XNEACXDK6F72EH	iitem_01JX92CQ055RT50QPEAY8NEV1Q	pvitem_01JX92CQ1GHP5R4VRMD2MCY0AN	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:11.816-04	2025-06-08 22:20:11.816-04
variant_01JX92CPYAEXC5CQVQSGBZGTJ0	iitem_01JX92CQ053C13Y920TAXPG0Z3	pvitem_01JX92CQ1G80YPZQPZKA0WNDC6	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:11.816-04	2025-06-08 22:20:11.816-04
variant_01JX92CPYBCKX0QJ3DYCVRWR65	iitem_01JX92CQ05DDXVMR50SZ03WNYJ	pvitem_01JX92CQ1GSEC20ZG3M8GAB2PH	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:11.816-04	2025-06-08 22:20:11.816-04
variant_01JX92CPYB1PFMBRPX9W12TZY7	iitem_01JX92CQ06DW38WB0ZJ5EA14BB	pvitem_01JX92CQ1GKNJ9WE4D5ZJVS6A3	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:11.816-04	2025-06-08 22:20:11.816-04
variant_01JX92CPYBFVAGV3N9A95W0YDP	iitem_01JX92CQ06XC7ER1XF1EPRH2PP	pvitem_01JX92CQ1GJZGC2A4PSVCJG1FG	1	2025-06-08 20:45:35.149199-04	2025-06-08 22:20:11.816-04	2025-06-08 22:20:11.816-04
\.


--
-- Data for Name: product_variant_option; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variant_option (variant_id, option_value_id) FROM stdin;
variant_01JX92CPY828FJG6HDR3RJBVGV	optval_01JX92CPTQPYDMPGZ45YJ5WV18
variant_01JX92CPY828FJG6HDR3RJBVGV	optval_01JX92CPTRT5MMK08ZPVZJKAMG
variant_01JX92CPY9NB56ECFQPDAQ98JE	optval_01JX92CPTQPYDMPGZ45YJ5WV18
variant_01JX92CPY9NB56ECFQPDAQ98JE	optval_01JX92CPTRV5P5PCY1VJWSP1JK
variant_01JX92CPY9PEER38EW4JM54JQD	optval_01JX92CPTQ8J27SDRZ7SG6KB42
variant_01JX92CPY9PEER38EW4JM54JQD	optval_01JX92CPTRT5MMK08ZPVZJKAMG
variant_01JX92CPYAV9XNEACXDK6F72EH	optval_01JX92CPTQ8J27SDRZ7SG6KB42
variant_01JX92CPYAV9XNEACXDK6F72EH	optval_01JX92CPTRV5P5PCY1VJWSP1JK
variant_01JX92CPYAEXC5CQVQSGBZGTJ0	optval_01JX92CPTRK653RZ50W1RW86XS
variant_01JX92CPYAEXC5CQVQSGBZGTJ0	optval_01JX92CPTRT5MMK08ZPVZJKAMG
variant_01JX92CPYBCKX0QJ3DYCVRWR65	optval_01JX92CPTRK653RZ50W1RW86XS
variant_01JX92CPYBCKX0QJ3DYCVRWR65	optval_01JX92CPTRV5P5PCY1VJWSP1JK
variant_01JX92CPYB1PFMBRPX9W12TZY7	optval_01JX92CPTRWRZGRQDMMYASPQY4
variant_01JX92CPYB1PFMBRPX9W12TZY7	optval_01JX92CPTRT5MMK08ZPVZJKAMG
variant_01JX92CPYBFVAGV3N9A95W0YDP	optval_01JX92CPTRWRZGRQDMMYASPQY4
variant_01JX92CPYBFVAGV3N9A95W0YDP	optval_01JX92CPTRV5P5PCY1VJWSP1JK
variant_01JX92CPYCCRPWC1TC9SKNVDVE	optval_01JX92CPTTZESBZCA04H14E4FW
variant_01JX92CPYCZBDNXN3X5MVSG8R6	optval_01JX92CPTTGCZRK7DY7GHB6E4C
variant_01JX92CPYDG5WC39GF1FCC55TC	optval_01JX92CPTTK8DHY1TEGQ1P6ZNE
variant_01JX92CPYDJK1TC5BRXMTD1QSJ	optval_01JX92CPTTWJ25VYAK90XS416K
variant_01JX92CPYD3FY4GQNV5J4Q0FT6	optval_01JX92CPTVZKN4MNCXK5JJ3VBB
variant_01JX92CPYD7KM69SZFHB5CEDX5	optval_01JX92CPTV8NR2VSA6C0C8FCNB
variant_01JX92CPYDCEMVX838T5ENTNSR	optval_01JX92CPTVVXKDM88RFT2KZN22
variant_01JX92CPYDGW7P218JENEPA5WG	optval_01JX92CPTVQKNTM4BSK5PE9GAH
variant_01JX92CPYER60FQZRCKCD52NY8	optval_01JX92CPTW2XV26N328T8RBZY3
variant_01JX92CPYEQ1VRPXP656TS8XAQ	optval_01JX92CPTW4ZGN7GCY8X1MDQ3N
variant_01JX92CPYEWTJYT0CF7JCTMG2D	optval_01JX92CPTWY4YRNE3JDQRAG9M3
variant_01JX92CPYEB84JC3ZHET7BZS3C	optval_01JX92CPTW5Q9W12W53KE514Y4
variant_01JX95HQ549G12BJ5APAR3D70G	optval_01JX95HQ30XR6YF806KN7868DH
variant_01JX961R3F8WEYC4EZCS4PTG6K	optval_01JX961R0N36AEC0Q93PVX73JV
variant_01JX974NA6C3EH827GXE39F966	optval_01JX974N8TCJ6GZR13NFKTRRY6
\.


--
-- Data for Name: product_variant_price_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variant_price_set (variant_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
variant_01JX95HQ549G12BJ5APAR3D70G	pset_01JX95HQ636VTGK6D30N15Z98X	pvps_01JX95HQ6HQ6SEFACMMFKJMJP5	2025-06-08 21:40:44.880996-04	2025-06-08 21:47:24.865-04	2025-06-08 21:47:24.865-04
variant_01JX961R3F8WEYC4EZCS4PTG6K	pset_01JX961R5DWGSSY9SGHDTYYY2Q	pvps_01JX961R6KJB0WYCBTA2D1V4WR	2025-06-08 21:49:30.195315-04	2025-06-08 22:06:50.663-04	2025-06-08 22:06:50.662-04
variant_01JX974NA6C3EH827GXE39F966	pset_01JX974NB6KVCJE7YQK30XRZ1V	pvps_01JX974NBRQNGWXM0M9M9023T7	2025-06-08 22:08:34.167713-04	2025-06-08 22:08:34.167713-04	\N
variant_01JX92CPYD3FY4GQNV5J4Q0FT6	pset_01JX92CQ37MC7SV097GN7GTAC0	pvps_01JX92CQ5SDWV09K8BHRJHB08E	2025-06-08 20:45:35.277765-04	2025-06-08 22:19:57.691-04	2025-06-08 22:19:57.691-04
variant_01JX92CPYD7KM69SZFHB5CEDX5	pset_01JX92CQ389Z7E1WPYHHC5XT69	pvps_01JX92CQ5SA8SDHVWXEW0A7QBH	2025-06-08 20:45:35.277765-04	2025-06-08 22:19:57.691-04	2025-06-08 22:19:57.691-04
variant_01JX92CPYDCEMVX838T5ENTNSR	pset_01JX92CQ383R9HS1B9CJT2RFQ6	pvps_01JX92CQ5SE5ETH53TPPJB7V98	2025-06-08 20:45:35.277765-04	2025-06-08 22:19:57.691-04	2025-06-08 22:19:57.691-04
variant_01JX92CPYDGW7P218JENEPA5WG	pset_01JX92CQ38ZJ2KMB07MVT348BX	pvps_01JX92CQ5S54RP469X9RGM8PMR	2025-06-08 20:45:35.277765-04	2025-06-08 22:19:57.691-04	2025-06-08 22:19:57.691-04
variant_01JX92CPYER60FQZRCKCD52NY8	pset_01JX92CQ39Z1554YQZVAAQGJJP	pvps_01JX92CQ5SQ9VH52PTECK2DMT1	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:03.465-04	2025-06-08 22:20:03.464-04
variant_01JX92CPYEQ1VRPXP656TS8XAQ	pset_01JX92CQ3965QF1BNPQ31ZAKCS	pvps_01JX92CQ5SKY2M5A8X1M7FPWJ3	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:03.465-04	2025-06-08 22:20:03.464-04
variant_01JX92CPYEWTJYT0CF7JCTMG2D	pset_01JX92CQ39CK47RKV8YH22D23B	pvps_01JX92CQ5SHENX2F515WAEN03E	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:03.465-04	2025-06-08 22:20:03.464-04
variant_01JX92CPYEB84JC3ZHET7BZS3C	pset_01JX92CQ39JEN969RF8E1RXW1Z	pvps_01JX92CQ5SCZ0VG8BEWZKBDCVY	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:03.465-04	2025-06-08 22:20:03.464-04
variant_01JX92CPYCCRPWC1TC9SKNVDVE	pset_01JX92CQ35SACFZTZ6YF04CE8R	pvps_01JX92CQ5R68GA377HYHAQ4B52	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:08.172-04	2025-06-08 22:20:08.172-04
variant_01JX92CPYCZBDNXN3X5MVSG8R6	pset_01JX92CQ36BRCK7P693MQHNXHF	pvps_01JX92CQ5R06WRPB5VJ9MWQ61W	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:08.172-04	2025-06-08 22:20:08.172-04
variant_01JX92CPYDG5WC39GF1FCC55TC	pset_01JX92CQ36FK289G8J387XTKZ1	pvps_01JX92CQ5RXZSB0ZPHMQJ4QES4	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:08.172-04	2025-06-08 22:20:08.172-04
variant_01JX92CPYDJK1TC5BRXMTD1QSJ	pset_01JX92CQ37AZ9S6MCQ23XZFDHK	pvps_01JX92CQ5SW2WVQ066MTRSFXAS	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:08.172-04	2025-06-08 22:20:08.172-04
variant_01JX92CPY828FJG6HDR3RJBVGV	pset_01JX92CQ32RPBZ3TMZNQBW7REX	pvps_01JX92CQ5E8FN69PQ26A36MEBF	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:11.828-04	2025-06-08 22:20:11.827-04
variant_01JX92CPY9NB56ECFQPDAQ98JE	pset_01JX92CQ332EWYGB9HCRG7B2N7	pvps_01JX92CQ5FWY5GY3ZHFWR9WB8B	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:11.828-04	2025-06-08 22:20:11.827-04
variant_01JX92CPY9PEER38EW4JM54JQD	pset_01JX92CQ33X4FZHZZX7JSGSGVX	pvps_01JX92CQ5FEVBTRP8PGWX9P0CX	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:11.828-04	2025-06-08 22:20:11.827-04
variant_01JX92CPYAV9XNEACXDK6F72EH	pset_01JX92CQ335B245D2M81BTX8BF	pvps_01JX92CQ5FZ16QX5GNH3HXEXY0	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:11.828-04	2025-06-08 22:20:11.827-04
variant_01JX92CPYAEXC5CQVQSGBZGTJ0	pset_01JX92CQ34KVJSNERAM14109QV	pvps_01JX92CQ5GY25333X41GGEJ6YB	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:11.828-04	2025-06-08 22:20:11.827-04
variant_01JX92CPYBCKX0QJ3DYCVRWR65	pset_01JX92CQ34KR0ZHKSB0MYV9QXX	pvps_01JX92CQ5GPDX45T2PJYMRQSZJ	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:11.828-04	2025-06-08 22:20:11.827-04
variant_01JX92CPYB1PFMBRPX9W12TZY7	pset_01JX92CQ35JXPWTBZ707DK589Z	pvps_01JX92CQ5G0ZMA94KWMGCADK6W	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:11.828-04	2025-06-08 22:20:11.827-04
variant_01JX92CPYBFVAGV3N9A95W0YDP	pset_01JX92CQ3544V5P61CS5D0Q92E	pvps_01JX92CQ5G9ZKYBEJXJ0R1K0B3	2025-06-08 20:45:35.277765-04	2025-06-08 22:20:11.828-04	2025-06-08 22:20:11.827-04
\.


--
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion (id, code, campaign_id, is_automatic, type, created_at, updated_at, deleted_at, status) FROM stdin;
\.


--
-- Data for Name: promotion_application_method; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_application_method (id, value, raw_value, max_quantity, apply_to_quantity, buy_rules_min_quantity, type, target_type, allocation, promotion_id, created_at, updated_at, deleted_at, currency_code) FROM stdin;
\.


--
-- Data for Name: promotion_campaign; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_campaign (id, name, description, campaign_identifier, starts_at, ends_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_campaign_budget (id, type, campaign_id, "limit", raw_limit, used, raw_used, created_at, updated_at, deleted_at, currency_code) FROM stdin;
\.


--
-- Data for Name: promotion_promotion_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_promotion_rule (promotion_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: promotion_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_rule (id, description, attribute, operator, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_rule_value; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_rule_value (id, promotion_rule_id, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: provider_identity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provider_identity (id, entity_id, provider, auth_identity_id, user_metadata, provider_metadata, created_at, updated_at, deleted_at) FROM stdin;
01JX92DTRZRJD5TJGF3Y3VEERK	crt@tdcom.cl	emailpass	authid_01JX92DTS06QT5NF3GXDGT2HAD	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAX4PidF2drb0xd8xEsXnWzibmF5mG2Ps/gDD8wWDwI/M1pYnYuH5Bu7e/zo/0lsSEAlqyV5XVYYYC+UV9YRZiNLAs7URCaMDEWpoeHFFa95A"}	2025-06-08 20:46:11.745-04	2025-06-08 20:46:11.745-04	\N
01JXAPHBZH91AH8B99EG3RXMTD	cmutinelli@gmail.com	emailpass	authid_01JXAPHBZJ6BT751M77619ZK46	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAcPbcVzGwPF9pwYU6XhbSxDna9WBJ6gQROH8EvQkiwuTRQDDbLtjvvFxMH0yTKrt7KWay+bkEwCS5S9p4oQ3XxM80HP5dNTmDgykBXA7eLQW"}	2025-06-09 11:56:53.62-04	2025-06-09 11:56:53.62-04	\N
\.


--
-- Data for Name: publishable_api_key_sales_channel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publishable_api_key_sales_channel (publishable_key_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
apk_01JX92CPSBNQ861PZSH11P3N6B	sc_01JX92CH43K6G3YZSHBR6WXNYP	pksc_01JX92CPSN8D3TEDBT79WNBSJS	2025-06-08 20:45:34.901497-04	2025-06-08 20:45:34.901497-04	\N
\.


--
-- Data for Name: refund; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refund (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata, refund_reason_id, note) FROM stdin;
\.


--
-- Data for Name: refund_reason; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refund_reason (id, label, description, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.region (id, name, currency_code, metadata, created_at, updated_at, deleted_at, automatic_taxes) FROM stdin;
reg_01JX92CPJV4PY6T452C0KP8M4V	Europe	eur	\N	2025-06-08 20:45:34.694-04	2025-06-08 20:45:34.694-04	\N	t
reg_01JX96W5CAFG1XZM8E72ARJY8Z	Chile	clp	\N	2025-06-08 22:03:55.666-04	2025-06-08 22:03:55.666-04	\N	f
\.


--
-- Data for Name: region_country; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.region_country (iso_2, iso_3, num_code, name, display_name, region_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
af	afg	004	AFGHANISTAN	Afghanistan	\N	\N	2025-06-08 20:45:21.167-04	2025-06-08 20:45:21.167-04	\N
al	alb	008	ALBANIA	Albania	\N	\N	2025-06-08 20:45:21.168-04	2025-06-08 20:45:21.168-04	\N
dz	dza	012	ALGERIA	Algeria	\N	\N	2025-06-08 20:45:21.168-04	2025-06-08 20:45:21.168-04	\N
as	asm	016	AMERICAN SAMOA	American Samoa	\N	\N	2025-06-08 20:45:21.168-04	2025-06-08 20:45:21.168-04	\N
ad	and	020	ANDORRA	Andorra	\N	\N	2025-06-08 20:45:21.168-04	2025-06-08 20:45:21.168-04	\N
ao	ago	024	ANGOLA	Angola	\N	\N	2025-06-08 20:45:21.168-04	2025-06-08 20:45:21.169-04	\N
ai	aia	660	ANGUILLA	Anguilla	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
aq	ata	010	ANTARCTICA	Antarctica	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
ag	atg	028	ANTIGUA AND BARBUDA	Antigua and Barbuda	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
ar	arg	032	ARGENTINA	Argentina	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
am	arm	051	ARMENIA	Armenia	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
aw	abw	533	ARUBA	Aruba	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
au	aus	036	AUSTRALIA	Australia	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
at	aut	040	AUSTRIA	Austria	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
az	aze	031	AZERBAIJAN	Azerbaijan	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bs	bhs	044	BAHAMAS	Bahamas	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bh	bhr	048	BAHRAIN	Bahrain	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bd	bgd	050	BANGLADESH	Bangladesh	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bb	brb	052	BARBADOS	Barbados	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
by	blr	112	BELARUS	Belarus	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
be	bel	056	BELGIUM	Belgium	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bz	blz	084	BELIZE	Belize	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bj	ben	204	BENIN	Benin	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bm	bmu	060	BERMUDA	Bermuda	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bt	btn	064	BHUTAN	Bhutan	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bo	bol	068	BOLIVIA	Bolivia	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bq	bes	535	BONAIRE, SINT EUSTATIUS AND SABA	Bonaire, Sint Eustatius and Saba	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
ba	bih	070	BOSNIA AND HERZEGOVINA	Bosnia and Herzegovina	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bw	bwa	072	BOTSWANA	Botswana	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bv	bvd	074	BOUVET ISLAND	Bouvet Island	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
br	bra	076	BRAZIL	Brazil	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
io	iot	086	BRITISH INDIAN OCEAN TERRITORY	British Indian Ocean Territory	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bn	brn	096	BRUNEI DARUSSALAM	Brunei Darussalam	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bg	bgr	100	BULGARIA	Bulgaria	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bf	bfa	854	BURKINA FASO	Burkina Faso	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
bi	bdi	108	BURUNDI	Burundi	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
kh	khm	116	CAMBODIA	Cambodia	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
cm	cmr	120	CAMEROON	Cameroon	\N	\N	2025-06-08 20:45:21.169-04	2025-06-08 20:45:21.169-04	\N
ca	can	124	CANADA	Canada	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cv	cpv	132	CAPE VERDE	Cape Verde	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
ky	cym	136	CAYMAN ISLANDS	Cayman Islands	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cf	caf	140	CENTRAL AFRICAN REPUBLIC	Central African Republic	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
td	tcd	148	CHAD	Chad	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cn	chn	156	CHINA	China	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cx	cxr	162	CHRISTMAS ISLAND	Christmas Island	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cc	cck	166	COCOS (KEELING) ISLANDS	Cocos (Keeling) Islands	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
co	col	170	COLOMBIA	Colombia	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
km	com	174	COMOROS	Comoros	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cg	cog	178	CONGO	Congo	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cd	cod	180	CONGO, THE DEMOCRATIC REPUBLIC OF THE	Congo, the Democratic Republic of the	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
ck	cok	184	COOK ISLANDS	Cook Islands	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cr	cri	188	COSTA RICA	Costa Rica	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
ci	civ	384	COTE D'IVOIRE	Cote D'Ivoire	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
hr	hrv	191	CROATIA	Croatia	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cu	cub	192	CUBA	Cuba	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cw	cuw	531	CURAÇAO	Curaçao	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cy	cyp	196	CYPRUS	Cyprus	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
cz	cze	203	CZECH REPUBLIC	Czech Republic	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
dj	dji	262	DJIBOUTI	Djibouti	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
dm	dma	212	DOMINICA	Dominica	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
do	dom	214	DOMINICAN REPUBLIC	Dominican Republic	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
ec	ecu	218	ECUADOR	Ecuador	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
eg	egy	818	EGYPT	Egypt	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
sv	slv	222	EL SALVADOR	El Salvador	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
gq	gnq	226	EQUATORIAL GUINEA	Equatorial Guinea	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
er	eri	232	ERITREA	Eritrea	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
ee	est	233	ESTONIA	Estonia	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
et	eth	231	ETHIOPIA	Ethiopia	\N	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:21.17-04	\N
fk	flk	238	FALKLAND ISLANDS (MALVINAS)	Falkland Islands (Malvinas)	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
fo	fro	234	FAROE ISLANDS	Faroe Islands	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
fj	fji	242	FIJI	Fiji	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
fi	fin	246	FINLAND	Finland	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gf	guf	254	FRENCH GUIANA	French Guiana	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
pf	pyf	258	FRENCH POLYNESIA	French Polynesia	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
tf	atf	260	FRENCH SOUTHERN TERRITORIES	French Southern Territories	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ga	gab	266	GABON	Gabon	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gm	gmb	270	GAMBIA	Gambia	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ge	geo	268	GEORGIA	Georgia	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gh	gha	288	GHANA	Ghana	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gi	gib	292	GIBRALTAR	Gibraltar	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gr	grc	300	GREECE	Greece	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gl	grl	304	GREENLAND	Greenland	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gd	grd	308	GRENADA	Grenada	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gp	glp	312	GUADELOUPE	Guadeloupe	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gu	gum	316	GUAM	Guam	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gt	gtm	320	GUATEMALA	Guatemala	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gg	ggy	831	GUERNSEY	Guernsey	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
cl	chl	152	CHILE	Chile	reg_01JX96W5CAFG1XZM8E72ARJY8Z	\N	2025-06-08 20:45:21.17-04	2025-06-08 22:03:55.666-04	\N
gn	gin	324	GUINEA	Guinea	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gw	gnb	624	GUINEA-BISSAU	Guinea-Bissau	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
gy	guy	328	GUYANA	Guyana	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ht	hti	332	HAITI	Haiti	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
hm	hmd	334	HEARD ISLAND AND MCDONALD ISLANDS	Heard Island And Mcdonald Islands	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
va	vat	336	HOLY SEE (VATICAN CITY STATE)	Holy See (Vatican City State)	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
hn	hnd	340	HONDURAS	Honduras	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
hk	hkg	344	HONG KONG	Hong Kong	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
hu	hun	348	HUNGARY	Hungary	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
is	isl	352	ICELAND	Iceland	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
in	ind	356	INDIA	India	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
id	idn	360	INDONESIA	Indonesia	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ir	irn	364	IRAN, ISLAMIC REPUBLIC OF	Iran, Islamic Republic of	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
iq	irq	368	IRAQ	Iraq	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ie	irl	372	IRELAND	Ireland	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
im	imn	833	ISLE OF MAN	Isle Of Man	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
il	isr	376	ISRAEL	Israel	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
jm	jam	388	JAMAICA	Jamaica	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
jp	jpn	392	JAPAN	Japan	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
je	jey	832	JERSEY	Jersey	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
jo	jor	400	JORDAN	Jordan	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
kz	kaz	398	KAZAKHSTAN	Kazakhstan	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ke	ken	404	KENYA	Kenya	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ki	kir	296	KIRIBATI	Kiribati	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
kp	prk	408	KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF	Korea, Democratic People's Republic of	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
kr	kor	410	KOREA, REPUBLIC OF	Korea, Republic of	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
xk	xkx	900	KOSOVO	Kosovo	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
kw	kwt	414	KUWAIT	Kuwait	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
kg	kgz	417	KYRGYZSTAN	Kyrgyzstan	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
la	lao	418	LAO PEOPLE'S DEMOCRATIC REPUBLIC	Lao People's Democratic Republic	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
lv	lva	428	LATVIA	Latvia	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
lb	lbn	422	LEBANON	Lebanon	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ls	lso	426	LESOTHO	Lesotho	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
lr	lbr	430	LIBERIA	Liberia	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ly	lby	434	LIBYA	Libya	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
li	lie	438	LIECHTENSTEIN	Liechtenstein	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
lt	ltu	440	LITHUANIA	Lithuania	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
lu	lux	442	LUXEMBOURG	Luxembourg	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mo	mac	446	MACAO	Macao	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mg	mdg	450	MADAGASCAR	Madagascar	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mw	mwi	454	MALAWI	Malawi	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
my	mys	458	MALAYSIA	Malaysia	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mv	mdv	462	MALDIVES	Maldives	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
ml	mli	466	MALI	Mali	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mt	mlt	470	MALTA	Malta	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mh	mhl	584	MARSHALL ISLANDS	Marshall Islands	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mq	mtq	474	MARTINIQUE	Martinique	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mr	mrt	478	MAURITANIA	Mauritania	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mu	mus	480	MAURITIUS	Mauritius	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
yt	myt	175	MAYOTTE	Mayotte	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mx	mex	484	MEXICO	Mexico	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
fm	fsm	583	MICRONESIA, FEDERATED STATES OF	Micronesia, Federated States of	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
md	mda	498	MOLDOVA, REPUBLIC OF	Moldova, Republic of	\N	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:21.171-04	\N
mc	mco	492	MONACO	Monaco	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
mn	mng	496	MONGOLIA	Mongolia	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
me	mne	499	MONTENEGRO	Montenegro	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ms	msr	500	MONTSERRAT	Montserrat	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ma	mar	504	MOROCCO	Morocco	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
mz	moz	508	MOZAMBIQUE	Mozambique	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
mm	mmr	104	MYANMAR	Myanmar	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
na	nam	516	NAMIBIA	Namibia	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
nr	nru	520	NAURU	Nauru	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
np	npl	524	NEPAL	Nepal	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
nl	nld	528	NETHERLANDS	Netherlands	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
nc	ncl	540	NEW CALEDONIA	New Caledonia	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
nz	nzl	554	NEW ZEALAND	New Zealand	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ni	nic	558	NICARAGUA	Nicaragua	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ne	ner	562	NIGER	Niger	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ng	nga	566	NIGERIA	Nigeria	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
nu	niu	570	NIUE	Niue	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
nf	nfk	574	NORFOLK ISLAND	Norfolk Island	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
mk	mkd	807	NORTH MACEDONIA	North Macedonia	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
mp	mnp	580	NORTHERN MARIANA ISLANDS	Northern Mariana Islands	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
no	nor	578	NORWAY	Norway	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
om	omn	512	OMAN	Oman	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pk	pak	586	PAKISTAN	Pakistan	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pw	plw	585	PALAU	Palau	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ps	pse	275	PALESTINIAN TERRITORY, OCCUPIED	Palestinian Territory, Occupied	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pa	pan	591	PANAMA	Panama	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pg	png	598	PAPUA NEW GUINEA	Papua New Guinea	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
py	pry	600	PARAGUAY	Paraguay	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pe	per	604	PERU	Peru	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ph	phl	608	PHILIPPINES	Philippines	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pn	pcn	612	PITCAIRN	Pitcairn	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pl	pol	616	POLAND	Poland	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pt	prt	620	PORTUGAL	Portugal	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pr	pri	630	PUERTO RICO	Puerto Rico	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
qa	qat	634	QATAR	Qatar	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
re	reu	638	REUNION	Reunion	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ro	rom	642	ROMANIA	Romania	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
ru	rus	643	RUSSIAN FEDERATION	Russian Federation	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
rw	rwa	646	RWANDA	Rwanda	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
bl	blm	652	SAINT BARTHÉLEMY	Saint Barthélemy	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
sh	shn	654	SAINT HELENA	Saint Helena	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
kn	kna	659	SAINT KITTS AND NEVIS	Saint Kitts and Nevis	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
lc	lca	662	SAINT LUCIA	Saint Lucia	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
mf	maf	663	SAINT MARTIN (FRENCH PART)	Saint Martin (French part)	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
pm	spm	666	SAINT PIERRE AND MIQUELON	Saint Pierre and Miquelon	\N	\N	2025-06-08 20:45:21.172-04	2025-06-08 20:45:21.172-04	\N
vc	vct	670	SAINT VINCENT AND THE GRENADINES	Saint Vincent and the Grenadines	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
ws	wsm	882	SAMOA	Samoa	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sm	smr	674	SAN MARINO	San Marino	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
st	stp	678	SAO TOME AND PRINCIPE	Sao Tome and Principe	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sa	sau	682	SAUDI ARABIA	Saudi Arabia	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sn	sen	686	SENEGAL	Senegal	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
rs	srb	688	SERBIA	Serbia	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sc	syc	690	SEYCHELLES	Seychelles	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sl	sle	694	SIERRA LEONE	Sierra Leone	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sg	sgp	702	SINGAPORE	Singapore	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sx	sxm	534	SINT MAARTEN	Sint Maarten	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sk	svk	703	SLOVAKIA	Slovakia	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
si	svn	705	SLOVENIA	Slovenia	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sb	slb	090	SOLOMON ISLANDS	Solomon Islands	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
so	som	706	SOMALIA	Somalia	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
za	zaf	710	SOUTH AFRICA	South Africa	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
gs	sgs	239	SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS	South Georgia and the South Sandwich Islands	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
ss	ssd	728	SOUTH SUDAN	South Sudan	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
lk	lka	144	SRI LANKA	Sri Lanka	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sd	sdn	729	SUDAN	Sudan	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sr	sur	740	SURINAME	Suriname	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sj	sjm	744	SVALBARD AND JAN MAYEN	Svalbard and Jan Mayen	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sz	swz	748	SWAZILAND	Swaziland	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
ch	che	756	SWITZERLAND	Switzerland	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
sy	syr	760	SYRIAN ARAB REPUBLIC	Syrian Arab Republic	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tw	twn	158	TAIWAN, PROVINCE OF CHINA	Taiwan, Province of China	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tj	tjk	762	TAJIKISTAN	Tajikistan	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tz	tza	834	TANZANIA, UNITED REPUBLIC OF	Tanzania, United Republic of	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
th	tha	764	THAILAND	Thailand	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tl	tls	626	TIMOR LESTE	Timor Leste	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tg	tgo	768	TOGO	Togo	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tk	tkl	772	TOKELAU	Tokelau	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
to	ton	776	TONGA	Tonga	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tt	tto	780	TRINIDAD AND TOBAGO	Trinidad and Tobago	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tn	tun	788	TUNISIA	Tunisia	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tr	tur	792	TURKEY	Turkey	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tm	tkm	795	TURKMENISTAN	Turkmenistan	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tc	tca	796	TURKS AND CAICOS ISLANDS	Turks and Caicos Islands	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
tv	tuv	798	TUVALU	Tuvalu	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
ug	uga	800	UGANDA	Uganda	\N	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:21.173-04	\N
ua	ukr	804	UKRAINE	Ukraine	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
ae	are	784	UNITED ARAB EMIRATES	United Arab Emirates	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
us	usa	840	UNITED STATES	United States	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
um	umi	581	UNITED STATES MINOR OUTLYING ISLANDS	United States Minor Outlying Islands	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
uy	ury	858	URUGUAY	Uruguay	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
uz	uzb	860	UZBEKISTAN	Uzbekistan	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
vu	vut	548	VANUATU	Vanuatu	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
ve	ven	862	VENEZUELA	Venezuela	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
vn	vnm	704	VIET NAM	Viet Nam	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
vg	vgb	092	VIRGIN ISLANDS, BRITISH	Virgin Islands, British	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
vi	vir	850	VIRGIN ISLANDS, U.S.	Virgin Islands, U.S.	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
wf	wlf	876	WALLIS AND FUTUNA	Wallis and Futuna	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
eh	esh	732	WESTERN SAHARA	Western Sahara	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
ye	yem	887	YEMEN	Yemen	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
zm	zmb	894	ZAMBIA	Zambia	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
zw	zwe	716	ZIMBABWE	Zimbabwe	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
ax	ala	248	ÅLAND ISLANDS	Åland Islands	\N	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:21.174-04	\N
dk	dnk	208	DENMARK	Denmark	reg_01JX92CPJV4PY6T452C0KP8M4V	\N	2025-06-08 20:45:21.17-04	2025-06-08 20:45:34.694-04	\N
fr	fra	250	FRANCE	France	reg_01JX92CPJV4PY6T452C0KP8M4V	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:34.694-04	\N
de	deu	276	GERMANY	Germany	reg_01JX92CPJV4PY6T452C0KP8M4V	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:34.694-04	\N
it	ita	380	ITALY	Italy	reg_01JX92CPJV4PY6T452C0KP8M4V	\N	2025-06-08 20:45:21.171-04	2025-06-08 20:45:34.694-04	\N
es	esp	724	SPAIN	Spain	reg_01JX92CPJV4PY6T452C0KP8M4V	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:34.694-04	\N
se	swe	752	SWEDEN	Sweden	reg_01JX92CPJV4PY6T452C0KP8M4V	\N	2025-06-08 20:45:21.173-04	2025-06-08 20:45:34.694-04	\N
gb	gbr	826	UNITED KINGDOM	United Kingdom	reg_01JX92CPJV4PY6T452C0KP8M4V	\N	2025-06-08 20:45:21.174-04	2025-06-08 20:45:34.694-04	\N
\.


--
-- Data for Name: region_payment_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.region_payment_provider (region_id, payment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
reg_01JX92CPJV4PY6T452C0KP8M4V	pp_system_default	regpp_01JX92CPM082NA39MX760EKR2N	2025-06-08 20:45:34.720128-04	2025-06-08 20:45:34.720128-04	\N
reg_01JX96W5CAFG1XZM8E72ARJY8Z	pp_system_default	regpp_01JX96W5D5S3G949TVS7A8XZ2M	2025-06-08 22:03:55.685349-04	2025-06-08 22:03:55.685349-04	\N
\.


--
-- Data for Name: reservation_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation_item (id, created_at, updated_at, deleted_at, line_item_id, location_id, quantity, external_id, description, created_by, metadata, inventory_item_id, allow_backorder, raw_quantity) FROM stdin;
\.


--
-- Data for Name: return; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return (id, order_id, claim_id, exchange_id, order_version, display_id, status, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, received_at, canceled_at, location_id, requested_at, created_by) FROM stdin;
\.


--
-- Data for Name: return_fulfillment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return_fulfillment (return_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: return_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return_item (id, return_id, reason_id, item_id, quantity, raw_quantity, received_quantity, raw_received_quantity, note, metadata, created_at, updated_at, deleted_at, damaged_quantity, raw_damaged_quantity) FROM stdin;
\.


--
-- Data for Name: return_reason; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return_reason (id, value, label, description, metadata, parent_return_reason_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sales_channel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_channel (id, name, description, is_disabled, metadata, created_at, updated_at, deleted_at) FROM stdin;
sc_01JX92CH43K6G3YZSHBR6WXNYP	Default Sales Channel	Created by Medusa	f	\N	2025-06-08 20:45:29.092-04	2025-06-08 20:45:29.092-04	\N
\.


--
-- Data for Name: sales_channel_stock_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_channel_stock_location (sales_channel_id, stock_location_id, id, created_at, updated_at, deleted_at) FROM stdin;
sc_01JX92CH43K6G3YZSHBR6WXNYP	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	scloc_01JX92CPS26673HGY8N7F8N00Y	2025-06-08 20:45:34.882694-04	2025-06-08 20:45:34.882694-04	\N
\.


--
-- Data for Name: script_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.script_migrations (id, script_name, created_at, finished_at) FROM stdin;
1	migrate-product-shipping-profile.js	2025-06-08 20:45:22.990473-04	2025-06-08 20:45:23.021915-04
2	migrate-tax-region-provider.js	2025-06-08 20:45:23.025319-04	2025-06-08 20:45:23.03923-04
\.


--
-- Data for Name: service_zone; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_zone (id, name, metadata, fulfillment_set_id, created_at, updated_at, deleted_at) FROM stdin;
serzo_01JX92CPNGDNHM6B968JAM0PDS	Europe	\N	fuset_01JX92CPNH64CNS7A776NMFWXQ	2025-06-08 20:45:34.769-04	2025-06-08 22:05:25.38-04	2025-06-08 22:05:25.357-04
serzo_01JXTHJVYTYGDCBFTJ1KNSV57Q	Starken (por pagar)	\N	fuset_01JXTHF7ZJG371GDYRN7WD7WS0	2025-06-15 15:38:10.778-04	2025-06-15 15:38:10.778-04	\N
\.


--
-- Data for Name: shipping_option; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_option (id, name, price_type, service_zone_id, shipping_profile_id, provider_id, data, metadata, shipping_option_type_id, created_at, updated_at, deleted_at) FROM stdin;
so_01JX92CPQBXH758CSQ5KXNCQ52	Standard Shipping	flat	serzo_01JX92CPNGDNHM6B968JAM0PDS	sp_01JX92CB66MQ5J3HTB51ZX1R1N	manual_manual	\N	\N	sotype_01JX92CPQA1A8B1DYYKMGZT0YY	2025-06-08 20:45:34.828-04	2025-06-08 22:05:25.39-04	2025-06-08 22:05:25.357-04
so_01JX92CPQBSNZA1D1MVRK301MN	Express Shipping	flat	serzo_01JX92CPNGDNHM6B968JAM0PDS	sp_01JX92CB66MQ5J3HTB51ZX1R1N	manual_manual	\N	\N	sotype_01JX92CPQBH6NVYNS4GHSQS34R	2025-06-08 20:45:34.828-04	2025-06-08 22:05:25.39-04	2025-06-08 22:05:25.357-04
\.


--
-- Data for Name: shipping_option_price_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_option_price_set (shipping_option_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
so_01JX92CPQBXH758CSQ5KXNCQ52	pset_01JX92CPQYQ7T154EWGE3ZZFKC	sops_01JX92CPRT8ASSAWCZKASXN81T	2025-06-08 20:45:34.874609-04	2025-06-08 20:45:34.874609-04	\N
so_01JX92CPQBSNZA1D1MVRK301MN	pset_01JX92CPQZ68RJA37RSM4H83G5	sops_01JX92CPRVHY6HRPQPVCRJPVGK	2025-06-08 20:45:34.874609-04	2025-06-08 20:45:34.874609-04	\N
\.


--
-- Data for Name: shipping_option_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_option_rule (id, attribute, operator, value, shipping_option_id, created_at, updated_at, deleted_at) FROM stdin;
sorul_01JX92CPQBS24GZ8N00N63TDFE	enabled_in_store	eq	"true"	so_01JX92CPQBXH758CSQ5KXNCQ52	2025-06-08 20:45:34.828-04	2025-06-08 22:05:25.405-04	2025-06-08 22:05:25.357-04
sorul_01JX92CPQB96AY6D7DVYH1MDGR	is_return	eq	"false"	so_01JX92CPQBXH758CSQ5KXNCQ52	2025-06-08 20:45:34.828-04	2025-06-08 22:05:25.405-04	2025-06-08 22:05:25.357-04
sorul_01JX92CPQBWWNV424EF0FY68FZ	enabled_in_store	eq	"true"	so_01JX92CPQBSNZA1D1MVRK301MN	2025-06-08 20:45:34.828-04	2025-06-08 22:05:25.405-04	2025-06-08 22:05:25.357-04
sorul_01JX92CPQBQQJKFYP3F1R7WG55	is_return	eq	"false"	so_01JX92CPQBSNZA1D1MVRK301MN	2025-06-08 20:45:34.828-04	2025-06-08 22:05:25.405-04	2025-06-08 22:05:25.357-04
\.


--
-- Data for Name: shipping_option_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_option_type (id, label, description, code, created_at, updated_at, deleted_at) FROM stdin;
sotype_01JX92CPQA1A8B1DYYKMGZT0YY	Standard	Ship in 2-3 days.	standard	2025-06-08 20:45:34.828-04	2025-06-08 22:05:25.405-04	2025-06-08 22:05:25.357-04
sotype_01JX92CPQBH6NVYNS4GHSQS34R	Express	Ship in 24 hours.	express	2025-06-08 20:45:34.828-04	2025-06-08 22:05:25.405-04	2025-06-08 22:05:25.357-04
\.


--
-- Data for Name: shipping_profile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_profile (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
sp_01JX92CB66MQ5J3HTB51ZX1R1N	Default Shipping Profile	default	\N	2025-06-08 20:45:23.016-04	2025-06-08 20:45:23.016-04	\N
\.


--
-- Data for Name: stock_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_location (id, created_at, updated_at, deleted_at, name, address_id, metadata) FROM stdin;
sloc_01JX92CPMT9DRJ3NG9ADFABK6B	2025-06-08 20:45:34.747-04	2025-06-08 22:05:16.052-04	\N	La bodega de la papita	laddr_01JX92CPMTCY80J5TWM8ZJPNTD	\N
\.


--
-- Data for Name: stock_location_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_location_address (id, created_at, updated_at, deleted_at, address_1, address_2, company, city, country_code, phone, province, postal_code, metadata) FROM stdin;
laddr_01JX92CPMTCY80J5TWM8ZJPNTD	2025-06-08 20:45:34.746-04	2025-06-08 22:05:16.04-04	\N	Javier de la rosa			Santiago	cl				\N
\.


--
-- Data for Name: store; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store (id, name, default_sales_channel_id, default_region_id, default_location_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
store_01JX92CH4RFXJ2903VQQ68A6JG	La Papita	sc_01JX92CH43K6G3YZSHBR6WXNYP	reg_01JX96W5CAFG1XZM8E72ARJY8Z	sloc_01JX92CPMT9DRJ3NG9ADFABK6B	\N	2025-06-08 20:45:29.110674-04	2025-06-08 20:45:29.110674-04	\N
\.


--
-- Data for Name: store_currency; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store_currency (id, currency_code, is_default, store_id, created_at, updated_at, deleted_at) FROM stdin;
stocur_01JX96ZM69DRHNZ2PGFEASN31E	clp	t	store_01JX92CH4RFXJ2903VQQ68A6JG	2025-06-08 22:05:49.124255-04	2025-06-08 22:05:49.124255-04	\N
stocur_01JX96ZM69EJ4531A29S1S0MZ3	eur	f	store_01JX92CH4RFXJ2903VQQ68A6JG	2025-06-08 22:05:49.124255-04	2025-06-08 22:05:49.124255-04	\N
stocur_01JX96ZM6A16V04P06D7Z1HN72	usd	f	store_01JX92CH4RFXJ2903VQQ68A6JG	2025-06-08 22:05:49.124255-04	2025-06-08 22:05:49.124255-04	\N
\.


--
-- Data for Name: tax_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tax_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
tp_system	t	2025-06-08 20:45:21.29-04	2025-06-08 20:45:21.29-04	\N
\.


--
-- Data for Name: tax_rate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tax_rate (id, rate, code, name, is_default, is_combinable, tax_region_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
txr_01JXTHDMYRYCVEG8S6D377F9Z0	19		IVA	t	f	txreg_01JXTHDMYGA0YW9T1VZRSDE3AS	\N	2025-06-15 15:35:19.768-04	2025-06-15 15:35:19.768-04	user_01JX92DTT9EE5ADVH465X383R4	\N
\.


--
-- Data for Name: tax_rate_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tax_rate_rule (id, tax_rate_id, reference_id, reference, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_region; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tax_region (id, provider_id, country_code, province_code, parent_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
txreg_01JX92CPMC2K56TJSR1S18XPXW	tp_system	de	\N	\N	\N	2025-06-08 20:45:34.733-04	2025-06-15 15:34:32-04	\N	2025-06-15 15:34:31.999-04
txreg_01JX92CPMCRD6QWJ671QXRDPDP	tp_system	dk	\N	\N	\N	2025-06-08 20:45:34.733-04	2025-06-15 15:34:37.744-04	\N	2025-06-15 15:34:37.743-04
txreg_01JX92CPMCGPGEKB9XAXD567TK	tp_system	es	\N	\N	\N	2025-06-08 20:45:34.733-04	2025-06-15 15:34:42.16-04	\N	2025-06-15 15:34:42.159-04
txreg_01JX92CPMCMFYN6HAXHD365GEV	tp_system	fr	\N	\N	\N	2025-06-08 20:45:34.733-04	2025-06-15 15:34:45.736-04	\N	2025-06-15 15:34:45.735-04
txreg_01JX92CPMCZSZDE98VH5J75NJQ	tp_system	gb	\N	\N	\N	2025-06-08 20:45:34.733-04	2025-06-15 15:34:49.772-04	\N	2025-06-15 15:34:49.772-04
txreg_01JX92CPMCX324KN4DWNCPFJVP	tp_system	it	\N	\N	\N	2025-06-08 20:45:34.733-04	2025-06-15 15:34:53.39-04	\N	2025-06-15 15:34:53.39-04
txreg_01JX92CPMC3W2RMX7S41262TTX	tp_system	se	\N	\N	\N	2025-06-08 20:45:34.733-04	2025-06-15 15:34:56.504-04	\N	2025-06-15 15:34:56.504-04
txreg_01JXTHDMYGA0YW9T1VZRSDE3AS	tp_system	cl	\N	\N	\N	2025-06-15 15:35:19.76-04	2025-06-15 15:35:19.76-04	user_01JX92DTT9EE5ADVH465X383R4	\N
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, first_name, last_name, email, avatar_url, metadata, created_at, updated_at, deleted_at) FROM stdin;
user_01JX92DTT9EE5ADVH465X383R4	Crisitan	Ruiz-Tagle	crt@tdcom.cl	\N	\N	2025-06-08 20:46:11.785-04	2025-06-08 20:46:11.785-04	\N
\.


--
-- Data for Name: workflow_execution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_execution (id, workflow_id, transaction_id, execution, context, state, created_at, updated_at, deleted_at, retention_time, run_id) FROM stdin;
\.


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.link_module_migrations_id_seq', 18, true);


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mikro_orm_migrations_id_seq', 108, true);


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_change_action_ordering_seq', 1, false);


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_claim_display_id_seq', 1, false);


--
-- Name: order_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_display_id_seq', 1, false);


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_exchange_display_id_seq', 1, false);


--
-- Name: return_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.return_display_id_seq', 1, false);


--
-- Name: script_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.script_migrations_id_seq', 2, true);


--
-- Name: account_holder account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_holder
    ADD CONSTRAINT account_holder_pkey PRIMARY KEY (id);


--
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- Name: application_method_buy_rules application_method_buy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: application_method_target_rules application_method_target_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY (id);


--
-- Name: capture capture_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_pkey PRIMARY KEY (id);


--
-- Name: cart_address cart_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_address
    ADD CONSTRAINT cart_address_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item cart_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: cart_payment_collection cart_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_payment_collection
    ADD CONSTRAINT cart_payment_collection_pkey PRIMARY KEY (cart_id, payment_collection_id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: cart_promotion cart_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_promotion
    ADD CONSTRAINT cart_promotion_pkey PRIMARY KEY (cart_id, promotion_id);


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method cart_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: credit_line credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_pkey PRIMARY KEY (id);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (code);


--
-- Name: customer_account_holder customer_account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_account_holder
    ADD CONSTRAINT customer_account_holder_pkey PRIMARY KEY (customer_id, account_holder_id);


--
-- Name: customer_address customer_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_pkey PRIMARY KEY (id);


--
-- Name: customer_group_customer customer_group_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_pkey PRIMARY KEY (id);


--
-- Name: customer_group customer_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group
    ADD CONSTRAINT customer_group_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_address fulfillment_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_address
    ADD CONSTRAINT fulfillment_address_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_item fulfillment_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_label fulfillment_label_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_pkey PRIMARY KEY (id);


--
-- Name: fulfillment fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_provider fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_provider
    ADD CONSTRAINT fulfillment_provider_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_set fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_set
    ADD CONSTRAINT fulfillment_set_pkey PRIMARY KEY (id);


--
-- Name: geo_zone geo_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (id);


--
-- Name: inventory_level inventory_level_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_pkey PRIMARY KEY (id);


--
-- Name: invite invite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invite
    ADD CONSTRAINT invite_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_table_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_table_name_key UNIQUE (table_name);


--
-- Name: location_fulfillment_provider location_fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_fulfillment_provider
    ADD CONSTRAINT location_fulfillment_provider_pkey PRIMARY KEY (stock_location_id, fulfillment_provider_id);


--
-- Name: location_fulfillment_set location_fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_fulfillment_set
    ADD CONSTRAINT location_fulfillment_set_pkey PRIMARY KEY (stock_location_id, fulfillment_set_id);


--
-- Name: mikro_orm_migrations mikro_orm_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mikro_orm_migrations
    ADD CONSTRAINT mikro_orm_migrations_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_provider notification_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_provider
    ADD CONSTRAINT notification_provider_pkey PRIMARY KEY (id);


--
-- Name: order_address order_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_address
    ADD CONSTRAINT order_address_pkey PRIMARY KEY (id);


--
-- Name: order_cart order_cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_cart
    ADD CONSTRAINT order_cart_pkey PRIMARY KEY (order_id, cart_id);


--
-- Name: order_change_action order_change_action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_pkey PRIMARY KEY (id);


--
-- Name: order_change order_change_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item_image order_claim_item_image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_claim_item_image
    ADD CONSTRAINT order_claim_item_image_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item order_claim_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_claim_item
    ADD CONSTRAINT order_claim_item_pkey PRIMARY KEY (id);


--
-- Name: order_claim order_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_claim
    ADD CONSTRAINT order_claim_pkey PRIMARY KEY (id);


--
-- Name: order_credit_line order_credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_pkey PRIMARY KEY (id);


--
-- Name: order_exchange_item order_exchange_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_exchange_item
    ADD CONSTRAINT order_exchange_item_pkey PRIMARY KEY (id);


--
-- Name: order_exchange order_exchange_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_exchange
    ADD CONSTRAINT order_exchange_pkey PRIMARY KEY (id);


--
-- Name: order_fulfillment order_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_fulfillment
    ADD CONSTRAINT order_fulfillment_pkey PRIMARY KEY (order_id, fulfillment_id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_adjustment order_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_line_item order_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_tax_line order_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_payment_collection order_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payment_collection
    ADD CONSTRAINT order_payment_collection_pkey PRIMARY KEY (order_id, payment_collection_id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: order_promotion order_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_promotion
    ADD CONSTRAINT order_promotion_pkey PRIMARY KEY (order_id, promotion_id);


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method order_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method
    ADD CONSTRAINT order_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_shipping order_shipping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_pkey PRIMARY KEY (id);


--
-- Name: order_summary order_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_pkey PRIMARY KEY (id);


--
-- Name: order_transaction order_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_pkey PRIMARY KEY (id);


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_pkey PRIMARY KEY (payment_collection_id, payment_provider_id);


--
-- Name: payment_collection payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_collection
    ADD CONSTRAINT payment_collection_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: payment_provider payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_provider
    ADD CONSTRAINT payment_provider_pkey PRIMARY KEY (id);


--
-- Name: payment_session payment_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_pkey PRIMARY KEY (id);


--
-- Name: price_list price_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_list
    ADD CONSTRAINT price_list_pkey PRIMARY KEY (id);


--
-- Name: price_list_rule price_list_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_pkey PRIMARY KEY (id);


--
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (id);


--
-- Name: price_preference price_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_preference
    ADD CONSTRAINT price_preference_pkey PRIMARY KEY (id);


--
-- Name: price_rule price_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_pkey PRIMARY KEY (id);


--
-- Name: price_set price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_set
    ADD CONSTRAINT price_set_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product_category_product product_category_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_pkey PRIMARY KEY (product_id, product_category_id);


--
-- Name: product_collection product_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT product_collection_pkey PRIMARY KEY (id);


--
-- Name: product_option product_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_pkey PRIMARY KEY (id);


--
-- Name: product_option_value product_option_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_sales_channel product_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT product_sales_channel_pkey PRIMARY KEY (product_id, sales_channel_id);


--
-- Name: product_shipping_profile product_shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_shipping_profile
    ADD CONSTRAINT product_shipping_profile_pkey PRIMARY KEY (product_id, shipping_profile_id);


--
-- Name: product_tag product_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_tag
    ADD CONSTRAINT product_tag_pkey PRIMARY KEY (id);


--
-- Name: product_tags product_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_pkey PRIMARY KEY (product_id, product_tag_id);


--
-- Name: product_type product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);


--
-- Name: product_variant_inventory_item product_variant_inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_inventory_item
    ADD CONSTRAINT product_variant_inventory_item_pkey PRIMARY KEY (variant_id, inventory_item_id);


--
-- Name: product_variant_option product_variant_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_pkey PRIMARY KEY (variant_id, option_value_id);


--
-- Name: product_variant product_variant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_pkey PRIMARY KEY (id);


--
-- Name: product_variant_price_set product_variant_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_price_set
    ADD CONSTRAINT product_variant_price_set_pkey PRIMARY KEY (variant_id, price_set_id);


--
-- Name: promotion_application_method promotion_application_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget promotion_campaign_budget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign promotion_campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_campaign
    ADD CONSTRAINT promotion_campaign_pkey PRIMARY KEY (id);


--
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);


--
-- Name: promotion_promotion_rule promotion_promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_pkey PRIMARY KEY (promotion_id, promotion_rule_id);


--
-- Name: promotion_rule promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_rule
    ADD CONSTRAINT promotion_rule_pkey PRIMARY KEY (id);


--
-- Name: promotion_rule_value promotion_rule_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_pkey PRIMARY KEY (id);


--
-- Name: provider_identity provider_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_pkey PRIMARY KEY (id);


--
-- Name: publishable_api_key_sales_channel publishable_api_key_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publishable_api_key_sales_channel
    ADD CONSTRAINT publishable_api_key_sales_channel_pkey PRIMARY KEY (publishable_key_id, sales_channel_id);


--
-- Name: refund refund_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_pkey PRIMARY KEY (id);


--
-- Name: refund_reason refund_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refund_reason
    ADD CONSTRAINT refund_reason_pkey PRIMARY KEY (id);


--
-- Name: region_country region_country_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_pkey PRIMARY KEY (iso_2);


--
-- Name: region_payment_provider region_payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region_payment_provider
    ADD CONSTRAINT region_payment_provider_pkey PRIMARY KEY (region_id, payment_provider_id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: reservation_item reservation_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_pkey PRIMARY KEY (id);


--
-- Name: return_fulfillment return_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_fulfillment
    ADD CONSTRAINT return_fulfillment_pkey PRIMARY KEY (return_id, fulfillment_id);


--
-- Name: return_item return_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT return_item_pkey PRIMARY KEY (id);


--
-- Name: return return_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_pkey PRIMARY KEY (id);


--
-- Name: return_reason return_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_pkey PRIMARY KEY (id);


--
-- Name: sales_channel sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_channel
    ADD CONSTRAINT sales_channel_pkey PRIMARY KEY (id);


--
-- Name: sales_channel_stock_location sales_channel_stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_channel_stock_location
    ADD CONSTRAINT sales_channel_stock_location_pkey PRIMARY KEY (sales_channel_id, stock_location_id);


--
-- Name: script_migrations script_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.script_migrations
    ADD CONSTRAINT script_migrations_pkey PRIMARY KEY (id);


--
-- Name: service_zone service_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_pkey PRIMARY KEY (id);


--
-- Name: shipping_option shipping_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_price_set shipping_option_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option_price_set
    ADD CONSTRAINT shipping_option_price_set_pkey PRIMARY KEY (shipping_option_id, price_set_id);


--
-- Name: shipping_option_rule shipping_option_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_type shipping_option_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option_type
    ADD CONSTRAINT shipping_option_type_pkey PRIMARY KEY (id);


--
-- Name: shipping_profile shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_profile
    ADD CONSTRAINT shipping_profile_pkey PRIMARY KEY (id);


--
-- Name: stock_location_address stock_location_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_location_address
    ADD CONSTRAINT stock_location_address_pkey PRIMARY KEY (id);


--
-- Name: stock_location stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_pkey PRIMARY KEY (id);


--
-- Name: store_currency store_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_pkey PRIMARY KEY (id);


--
-- Name: store store_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);


--
-- Name: tax_provider tax_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_provider
    ADD CONSTRAINT tax_provider_pkey PRIMARY KEY (id);


--
-- Name: tax_rate tax_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT tax_rate_pkey PRIMARY KEY (id);


--
-- Name: tax_rate_rule tax_rate_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT tax_rate_rule_pkey PRIMARY KEY (id);


--
-- Name: tax_region tax_region_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT tax_region_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: workflow_execution workflow_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_execution
    ADD CONSTRAINT workflow_execution_pkey PRIMARY KEY (workflow_id, transaction_id, run_id);


--
-- Name: IDX_account_holder_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_account_holder_deleted_at" ON public.account_holder USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_account_holder_id_5cb3a0c0" ON public.customer_account_holder USING btree (account_holder_id);


--
-- Name: IDX_account_holder_provider_id_external_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_account_holder_provider_id_external_id_unique" ON public.account_holder USING btree (provider_id, external_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_adjustment_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_adjustment_item_id" ON public.cart_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_adjustment_shipping_method_id" ON public.cart_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_api_key_deleted_at" ON public.api_key USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_token_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_api_key_token_unique" ON public.api_key USING btree (token);


--
-- Name: IDX_api_key_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_api_key_type" ON public.api_key USING btree (type);


--
-- Name: IDX_application_method_allocation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_application_method_allocation" ON public.promotion_application_method USING btree (allocation);


--
-- Name: IDX_application_method_target_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_application_method_target_type" ON public.promotion_application_method USING btree (target_type);


--
-- Name: IDX_application_method_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_application_method_type" ON public.promotion_application_method USING btree (type);


--
-- Name: IDX_auth_identity_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_auth_identity_deleted_at" ON public.auth_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_campaign_budget_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_campaign_budget_type" ON public.promotion_campaign_budget USING btree (type);


--
-- Name: IDX_capture_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_capture_deleted_at" ON public.capture USING btree (deleted_at);


--
-- Name: IDX_capture_payment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_capture_payment_id" ON public.capture USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_address_deleted_at" ON public.cart_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_billing_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_billing_address_id" ON public.cart USING btree (billing_address_id) WHERE ((deleted_at IS NULL) AND (billing_address_id IS NOT NULL));


--
-- Name: IDX_cart_credit_line_reference_reference_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_credit_line_reference_reference_id" ON public.credit_line USING btree (reference, reference_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_currency_code" ON public.cart USING btree (currency_code);


--
-- Name: IDX_cart_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_customer_id" ON public.cart USING btree (customer_id) WHERE ((deleted_at IS NULL) AND (customer_id IS NOT NULL));


--
-- Name: IDX_cart_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_deleted_at" ON public.cart USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_id_-4a39f6c9" ON public.cart_payment_collection USING btree (cart_id);


--
-- Name: IDX_cart_id_-71069c16; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_id_-71069c16" ON public.order_cart USING btree (cart_id);


--
-- Name: IDX_cart_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_id_-a9d4a70b" ON public.cart_promotion USING btree (cart_id);


--
-- Name: IDX_cart_line_item_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_adjustment_deleted_at" ON public.cart_line_item_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_adjustment_item_id" ON public.cart_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_cart_id" ON public.cart_line_item USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_deleted_at" ON public.cart_line_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_tax_line_deleted_at" ON public.cart_line_item_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_tax_line_item_id" ON public.cart_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_region_id" ON public.cart USING btree (region_id) WHERE ((deleted_at IS NULL) AND (region_id IS NOT NULL));


--
-- Name: IDX_cart_sales_channel_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_sales_channel_id" ON public.cart USING btree (sales_channel_id) WHERE ((deleted_at IS NULL) AND (sales_channel_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_address_id" ON public.cart USING btree (shipping_address_id) WHERE ((deleted_at IS NULL) AND (shipping_address_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_method_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_deleted_at" ON public.cart_shipping_method_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_shipping_method_id" ON public.cart_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_cart_id" ON public.cart_shipping_method USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_deleted_at" ON public.cart_shipping_method USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_deleted_at" ON public.cart_shipping_method_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_shipping_method_id" ON public.cart_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_category_handle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_category_handle_unique" ON public.product_category USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_collection_handle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_collection_handle_unique" ON public.product_collection USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_credit_line_cart_id" ON public.credit_line USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_credit_line_deleted_at" ON public.credit_line USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_address_customer_id" ON public.customer_address USING btree (customer_id);


--
-- Name: IDX_customer_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_address_deleted_at" ON public.customer_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_unique_customer_billing; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_billing" ON public.customer_address USING btree (customer_id) WHERE (is_default_billing = true);


--
-- Name: IDX_customer_address_unique_customer_shipping; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_shipping" ON public.customer_address USING btree (customer_id) WHERE (is_default_shipping = true);


--
-- Name: IDX_customer_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_deleted_at" ON public.customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_email_has_account_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_email_has_account_unique" ON public.customer USING btree (email, has_account) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_group_customer_customer_group_id" ON public.customer_group_customer USING btree (customer_group_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_group_customer_customer_id" ON public.customer_group_customer USING btree (customer_id);


--
-- Name: IDX_customer_group_customer_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_group_customer_deleted_at" ON public.customer_group_customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_group_deleted_at" ON public.customer_group USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_group_name" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_group_name_unique" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_id_5cb3a0c0" ON public.customer_account_holder USING btree (customer_id);


--
-- Name: IDX_deleted_at_-1d67bae40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-1e5992737; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-1e5992737" ON public.location_fulfillment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-31ea43a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-31ea43a" ON public.return_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-4a39f6c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-4a39f6c9" ON public.cart_payment_collection USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71069c16; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-71069c16" ON public.order_cart USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71518339; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-71518339" ON public.order_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-a9d4a70b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-a9d4a70b" ON public.cart_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e88adb96; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-e88adb96" ON public.location_fulfillment_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e8d2543e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-e8d2543e" ON public.order_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17a262437; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_17a262437" ON public.product_shipping_profile USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17b4c4e35; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_17b4c4e35" ON public.product_variant_inventory_item USING btree (deleted_at);


--
-- Name: IDX_deleted_at_1c934dab0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_1c934dab0" ON public.region_payment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_20b454295; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_20b454295" ON public.product_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_26d06f470; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_26d06f470" ON public.sales_channel_stock_location USING btree (deleted_at);


--
-- Name: IDX_deleted_at_52b23597; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_52b23597" ON public.product_variant_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_5cb3a0c0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_5cb3a0c0" ON public.customer_account_holder USING btree (deleted_at);


--
-- Name: IDX_deleted_at_ba32fa9c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_ba32fa9c" ON public.shipping_option_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_f42b9949; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_f42b9949" ON public.order_payment_collection USING btree (deleted_at);


--
-- Name: IDX_fulfillment_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_address_deleted_at" ON public.fulfillment_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_deleted_at" ON public.fulfillment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_id_-31ea43a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_id_-31ea43a" ON public.return_fulfillment USING btree (fulfillment_id);


--
-- Name: IDX_fulfillment_id_-e8d2543e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_id_-e8d2543e" ON public.order_fulfillment USING btree (fulfillment_id);


--
-- Name: IDX_fulfillment_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_item_deleted_at" ON public.fulfillment_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_item_fulfillment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_item_fulfillment_id" ON public.fulfillment_item USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_inventory_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_item_inventory_item_id" ON public.fulfillment_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_item_line_item_id" ON public.fulfillment_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_label_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_label_deleted_at" ON public.fulfillment_label USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_label_fulfillment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_label_fulfillment_id" ON public.fulfillment_label USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_location_id" ON public.fulfillment USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_provider_deleted_at" ON public.fulfillment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_id_-1e5992737; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_provider_id_-1e5992737" ON public.location_fulfillment_provider USING btree (fulfillment_provider_id);


--
-- Name: IDX_fulfillment_set_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_set_deleted_at" ON public.fulfillment_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_set_id_-e88adb96; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_set_id_-e88adb96" ON public.location_fulfillment_set USING btree (fulfillment_set_id);


--
-- Name: IDX_fulfillment_set_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_fulfillment_set_name_unique" ON public.fulfillment_set USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_shipping_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_shipping_option_id" ON public.fulfillment USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_city" ON public.geo_zone USING btree (city) WHERE ((deleted_at IS NULL) AND (city IS NOT NULL));


--
-- Name: IDX_geo_zone_country_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_country_code" ON public.geo_zone USING btree (country_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_deleted_at" ON public.geo_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_geo_zone_province_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_province_code" ON public.geo_zone USING btree (province_code) WHERE ((deleted_at IS NULL) AND (province_code IS NOT NULL));


--
-- Name: IDX_geo_zone_service_zone_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_service_zone_id" ON public.geo_zone USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_id_-1d67bae40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (id);


--
-- Name: IDX_id_-1e5992737; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-1e5992737" ON public.location_fulfillment_provider USING btree (id);


--
-- Name: IDX_id_-31ea43a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-31ea43a" ON public.return_fulfillment USING btree (id);


--
-- Name: IDX_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-4a39f6c9" ON public.cart_payment_collection USING btree (id);


--
-- Name: IDX_id_-71069c16; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-71069c16" ON public.order_cart USING btree (id);


--
-- Name: IDX_id_-71518339; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-71518339" ON public.order_promotion USING btree (id);


--
-- Name: IDX_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-a9d4a70b" ON public.cart_promotion USING btree (id);


--
-- Name: IDX_id_-e88adb96; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-e88adb96" ON public.location_fulfillment_set USING btree (id);


--
-- Name: IDX_id_-e8d2543e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-e8d2543e" ON public.order_fulfillment USING btree (id);


--
-- Name: IDX_id_17a262437; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_17a262437" ON public.product_shipping_profile USING btree (id);


--
-- Name: IDX_id_17b4c4e35; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (id);


--
-- Name: IDX_id_1c934dab0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_1c934dab0" ON public.region_payment_provider USING btree (id);


--
-- Name: IDX_id_20b454295; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_20b454295" ON public.product_sales_channel USING btree (id);


--
-- Name: IDX_id_26d06f470; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_26d06f470" ON public.sales_channel_stock_location USING btree (id);


--
-- Name: IDX_id_52b23597; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_52b23597" ON public.product_variant_price_set USING btree (id);


--
-- Name: IDX_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_5cb3a0c0" ON public.customer_account_holder USING btree (id);


--
-- Name: IDX_id_ba32fa9c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_ba32fa9c" ON public.shipping_option_price_set USING btree (id);


--
-- Name: IDX_id_f42b9949; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_f42b9949" ON public.order_payment_collection USING btree (id);


--
-- Name: IDX_image_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_image_deleted_at" ON public.image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_image_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_image_product_id" ON public.image USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_item_deleted_at" ON public.inventory_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_item_id_17b4c4e35; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_item_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (inventory_item_id);


--
-- Name: IDX_inventory_item_sku; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_inventory_item_sku" ON public.inventory_item USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_level_deleted_at" ON public.inventory_level USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_level_inventory_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_level_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_item_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_inventory_level_item_location" ON public.inventory_level USING btree (inventory_item_id, location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_level_location_id" ON public.inventory_level USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id_inventory_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_inventory_level_location_id_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id, location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_invite_deleted_at" ON public.invite USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_invite_email_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_invite_email_unique" ON public.invite USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_invite_token" ON public.invite USING btree (token) WHERE (deleted_at IS NULL);


--
-- Name: IDX_line_item_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_adjustment_promotion_id" ON public.cart_line_item_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_line_item_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_cart_id" ON public.cart_line_item USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_line_item_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_product_id" ON public.cart_line_item USING btree (product_id) WHERE ((deleted_at IS NULL) AND (product_id IS NOT NULL));


--
-- Name: IDX_line_item_product_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_product_type_id" ON public.cart_line_item USING btree (product_type_id) WHERE ((deleted_at IS NULL) AND (product_type_id IS NOT NULL));


--
-- Name: IDX_line_item_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_tax_line_tax_rate_id" ON public.cart_line_item_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_line_item_variant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_variant_id" ON public.cart_line_item USING btree (variant_id) WHERE ((deleted_at IS NULL) AND (variant_id IS NOT NULL));


--
-- Name: IDX_notification_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_notification_deleted_at" ON public.notification USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_idempotency_key_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_notification_idempotency_key_unique" ON public.notification USING btree (idempotency_key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_notification_provider_deleted_at" ON public.notification_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_notification_provider_id" ON public.notification USING btree (provider_id);


--
-- Name: IDX_notification_receiver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_notification_receiver_id" ON public.notification USING btree (receiver_id);


--
-- Name: IDX_option_product_id_title_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_option_product_id_title_unique" ON public.product_option USING btree (product_id, title) WHERE (deleted_at IS NULL);


--
-- Name: IDX_option_value_option_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_option_value_option_id_unique" ON public.product_option_value USING btree (option_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_address_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_address_customer_id" ON public.order_address USING btree (customer_id);


--
-- Name: IDX_order_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_address_deleted_at" ON public.order_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_billing_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_billing_address_id" ON public."order" USING btree (billing_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_claim_id" ON public.order_change_action USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_deleted_at" ON public.order_change_action USING btree (deleted_at);


--
-- Name: IDX_order_change_action_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_exchange_id" ON public.order_change_action USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_order_change_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_order_change_id" ON public.order_change_action USING btree (order_change_id);


--
-- Name: IDX_order_change_action_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_order_id" ON public.order_change_action USING btree (order_id);


--
-- Name: IDX_order_change_action_ordering; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_ordering" ON public.order_change_action USING btree (ordering);


--
-- Name: IDX_order_change_action_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_return_id" ON public.order_change_action USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_change_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_change_type" ON public.order_change USING btree (change_type);


--
-- Name: IDX_order_change_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_claim_id" ON public.order_change USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_deleted_at" ON public.order_change USING btree (deleted_at);


--
-- Name: IDX_order_change_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_exchange_id" ON public.order_change USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_order_id" ON public.order_change USING btree (order_id);


--
-- Name: IDX_order_change_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_order_id_version" ON public.order_change USING btree (order_id, version);


--
-- Name: IDX_order_change_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_return_id" ON public.order_change USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_status" ON public.order_change USING btree (status);


--
-- Name: IDX_order_claim_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_deleted_at" ON public.order_claim USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_display_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_display_id" ON public.order_claim USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_claim_id" ON public.order_claim_item USING btree (claim_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_deleted_at" ON public.order_claim_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_claim_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_image_claim_item_id" ON public.order_claim_item_image USING btree (claim_item_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_claim_item_image_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_image_deleted_at" ON public.order_claim_item_image USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_claim_item_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_item_id" ON public.order_claim_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_order_id" ON public.order_claim USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_return_id" ON public.order_claim USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_credit_line_deleted_at" ON public.order_credit_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_credit_line_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_credit_line_order_id" ON public.order_credit_line USING btree (order_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_currency_code" ON public."order" USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_customer_id" ON public."order" USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_deleted_at" ON public."order" USING btree (deleted_at);


--
-- Name: IDX_order_display_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_display_id" ON public."order" USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_deleted_at" ON public.order_exchange USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_display_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_display_id" ON public.order_exchange USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_item_deleted_at" ON public.order_exchange_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_item_exchange_id" ON public.order_exchange_item USING btree (exchange_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_item_item_id" ON public.order_exchange_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_order_id" ON public.order_exchange USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_return_id" ON public.order_exchange USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_id_-71069c16; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_id_-71069c16" ON public.order_cart USING btree (order_id);


--
-- Name: IDX_order_id_-71518339; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_id_-71518339" ON public.order_promotion USING btree (order_id);


--
-- Name: IDX_order_id_-e8d2543e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_id_-e8d2543e" ON public.order_fulfillment USING btree (order_id);


--
-- Name: IDX_order_id_f42b9949; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_id_f42b9949" ON public.order_payment_collection USING btree (order_id);


--
-- Name: IDX_order_is_draft_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_is_draft_order" ON public."order" USING btree (is_draft_order) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_item_deleted_at" ON public.order_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_item_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_item_item_id" ON public.order_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_item_order_id" ON public.order_item USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_item_order_id_version" ON public.order_item USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_line_item_adjustment_item_id" ON public.order_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_line_item_product_id" ON public.order_line_item USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_line_item_tax_line_item_id" ON public.order_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_variant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_line_item_variant_id" ON public.order_line_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_region_id" ON public."order" USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_address_id" ON public."order" USING btree (shipping_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_claim_id" ON public.order_shipping USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_deleted_at" ON public.order_shipping USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_shipping_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_exchange_id" ON public.order_shipping USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_item_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_method_adjustment_shipping_method_id" ON public.order_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_shipping_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_method_shipping_option_id" ON public.order_shipping_method USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_method_tax_line_shipping_method_id" ON public.order_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_order_id" ON public.order_shipping USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_order_id_version" ON public.order_shipping USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_return_id" ON public.order_shipping USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_summary_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_summary_deleted_at" ON public.order_summary USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_summary_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_summary_order_id_version" ON public.order_summary USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_claim_id" ON public.order_transaction USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_currency_code" ON public.order_transaction USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_exchange_id" ON public.order_transaction USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_order_id_version" ON public.order_transaction USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_reference_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_reference_id" ON public.order_transaction USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_return_id" ON public.order_transaction USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_payment_collection_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_collection_deleted_at" ON public.payment_collection USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_collection_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_collection_id_-4a39f6c9" ON public.cart_payment_collection USING btree (payment_collection_id);


--
-- Name: IDX_payment_collection_id_f42b9949; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_collection_id_f42b9949" ON public.order_payment_collection USING btree (payment_collection_id);


--
-- Name: IDX_payment_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_deleted_at" ON public.payment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_payment_collection_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_payment_collection_id" ON public.payment USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_payment_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_payment_session_id" ON public.payment USING btree (payment_session_id);


--
-- Name: IDX_payment_payment_session_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_payment_payment_session_id_unique" ON public.payment USING btree (payment_session_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_provider_deleted_at" ON public.payment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_provider_id" ON public.payment USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id_1c934dab0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_provider_id_1c934dab0" ON public.region_payment_provider USING btree (payment_provider_id);


--
-- Name: IDX_payment_session_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_session_deleted_at" ON public.payment_session USING btree (deleted_at);


--
-- Name: IDX_payment_session_payment_collection_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_session_payment_collection_id" ON public.payment_session USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_currency_code" ON public.price USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_deleted_at" ON public.price USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_list_deleted_at" ON public.price_list USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_attribute; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_list_rule_attribute" ON public.price_list_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_list_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_list_rule_deleted_at" ON public.price_list_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_price_list_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_list_rule_price_list_id" ON public.price_list_rule USING btree (price_list_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_preference_attribute_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_price_preference_attribute_value" ON public.price_preference USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_preference_deleted_at" ON public.price_preference USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_price_list_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_price_list_id" ON public.price USING btree (price_list_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_price_set_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_price_set_id" ON public.price USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_attribute" ON public.price_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_attribute_value" ON public.price_rule USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_deleted_at" ON public.price_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_rule_operator; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_operator" ON public.price_rule USING btree (operator);


--
-- Name: IDX_price_rule_operator_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_operator_value" ON public.price_rule USING btree (operator, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_price_id" ON public.price_rule USING btree (price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id_attribute_operator_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_price_rule_price_id_attribute_operator_unique" ON public.price_rule USING btree (price_id, attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_set_deleted_at" ON public.price_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_set_id_52b23597; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_set_id_52b23597" ON public.product_variant_price_set USING btree (price_set_id);


--
-- Name: IDX_price_set_id_ba32fa9c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_set_id_ba32fa9c" ON public.shipping_option_price_set USING btree (price_set_id);


--
-- Name: IDX_product_category_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_category_deleted_at" ON public.product_collection USING btree (deleted_at);


--
-- Name: IDX_product_category_parent_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_category_parent_category_id" ON public.product_category USING btree (parent_category_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_path; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_category_path" ON public.product_category USING btree (mpath) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_collection_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_collection_deleted_at" ON public.product_collection USING btree (deleted_at);


--
-- Name: IDX_product_collection_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_collection_id" ON public.product USING btree (collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_deleted_at" ON public.product USING btree (deleted_at);


--
-- Name: IDX_product_handle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_handle_unique" ON public.product USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_17a262437; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_id_17a262437" ON public.product_shipping_profile USING btree (product_id);


--
-- Name: IDX_product_id_20b454295; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_id_20b454295" ON public.product_sales_channel USING btree (product_id);


--
-- Name: IDX_product_image_url; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_image_url" ON public.image USING btree (url) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_option_deleted_at" ON public.product_option USING btree (deleted_at);


--
-- Name: IDX_product_option_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_option_product_id" ON public.product_option USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_value_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_option_value_deleted_at" ON public.product_option_value USING btree (deleted_at);


--
-- Name: IDX_product_option_value_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_option_value_option_id" ON public.product_option_value USING btree (option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_tag_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_tag_deleted_at" ON public.product_tag USING btree (deleted_at);


--
-- Name: IDX_product_type_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_type_deleted_at" ON public.product_type USING btree (deleted_at);


--
-- Name: IDX_product_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_type_id" ON public.product USING btree (type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_barcode_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_variant_barcode_unique" ON public.product_variant USING btree (barcode) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_variant_deleted_at" ON public.product_variant USING btree (deleted_at);


--
-- Name: IDX_product_variant_ean_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_variant_ean_unique" ON public.product_variant USING btree (ean) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_id_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_variant_id_product_id" ON public.product_variant USING btree (id, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_variant_product_id" ON public.product_variant USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_sku_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_variant_sku_unique" ON public.product_variant USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_upc_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_variant_upc_unique" ON public.product_variant USING btree (upc) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_application_method_currency_code" ON public.promotion_application_method USING btree (currency_code) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_promotion_application_method_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_application_method_deleted_at" ON public.promotion_application_method USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_promotion_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_promotion_application_method_promotion_id_unique" ON public.promotion_application_method USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_campaign_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_campaign_id_unique" ON public.promotion_campaign_budget USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_campaign_budget_deleted_at" ON public.promotion_campaign_budget USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_campaign_identifier_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_campaign_identifier_unique" ON public.promotion_campaign USING btree (campaign_identifier) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_campaign_deleted_at" ON public.promotion_campaign USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_campaign_id" ON public.promotion USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_deleted_at" ON public.promotion USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-71518339; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_id_-71518339" ON public.order_promotion USING btree (promotion_id);


--
-- Name: IDX_promotion_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_id_-a9d4a70b" ON public.cart_promotion USING btree (promotion_id);


--
-- Name: IDX_promotion_rule_attribute; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_attribute" ON public.promotion_rule USING btree (attribute);


--
-- Name: IDX_promotion_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_deleted_at" ON public.promotion_rule USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_operator; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_operator" ON public.promotion_rule USING btree (operator);


--
-- Name: IDX_promotion_rule_value_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_value_deleted_at" ON public.promotion_rule_value USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_promotion_rule_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_value_promotion_rule_id" ON public.promotion_rule_value USING btree (promotion_rule_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_status" ON public.promotion USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_type" ON public.promotion USING btree (type);


--
-- Name: IDX_provider_identity_auth_identity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_provider_identity_auth_identity_id" ON public.provider_identity USING btree (auth_identity_id);


--
-- Name: IDX_provider_identity_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_provider_identity_deleted_at" ON public.provider_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_provider_identity_provider_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_provider_identity_provider_entity_id" ON public.provider_identity USING btree (entity_id, provider);


--
-- Name: IDX_publishable_key_id_-1d67bae40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_publishable_key_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (publishable_key_id);


--
-- Name: IDX_refund_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_refund_deleted_at" ON public.refund USING btree (deleted_at);


--
-- Name: IDX_refund_payment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_refund_payment_id" ON public.refund USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_reason_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_refund_reason_deleted_at" ON public.refund_reason USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_refund_reason_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_refund_refund_reason_id" ON public.refund USING btree (refund_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_region_country_deleted_at" ON public.region_country USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_region_country_region_id" ON public.region_country USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id_iso_2_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_region_country_region_id_iso_2_unique" ON public.region_country USING btree (region_id, iso_2);


--
-- Name: IDX_region_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_region_deleted_at" ON public.region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_region_id_1c934dab0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_region_id_1c934dab0" ON public.region_payment_provider USING btree (region_id);


--
-- Name: IDX_reservation_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_reservation_item_deleted_at" ON public.reservation_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_reservation_item_inventory_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_reservation_item_inventory_item_id" ON public.reservation_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_reservation_item_line_item_id" ON public.reservation_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_reservation_item_location_id" ON public.reservation_item USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_claim_id" ON public.return USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_display_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_display_id" ON public.return USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_exchange_id" ON public.return USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_id_-31ea43a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_id_-31ea43a" ON public.return_fulfillment USING btree (return_id);


--
-- Name: IDX_return_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_item_deleted_at" ON public.return_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_item_item_id" ON public.return_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_reason_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_item_reason_id" ON public.return_item USING btree (reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_item_return_id" ON public.return_item USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_order_id" ON public.return USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_return_reason_value" ON public.return_reason USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_sales_channel_deleted_at" ON public.sales_channel USING btree (deleted_at);


--
-- Name: IDX_sales_channel_id_-1d67bae40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_sales_channel_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (sales_channel_id);


--
-- Name: IDX_sales_channel_id_20b454295; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_sales_channel_id_20b454295" ON public.product_sales_channel USING btree (sales_channel_id);


--
-- Name: IDX_sales_channel_id_26d06f470; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_sales_channel_id_26d06f470" ON public.sales_channel_stock_location USING btree (sales_channel_id);


--
-- Name: IDX_service_zone_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_service_zone_deleted_at" ON public.service_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_service_zone_fulfillment_set_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_service_zone_fulfillment_set_id" ON public.service_zone USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_service_zone_name_unique" ON public.service_zone USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_method_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_method_adjustment_promotion_id" ON public.cart_shipping_method_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_shipping_method_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_method_cart_id" ON public.cart_shipping_method USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_method_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_method_option_id" ON public.cart_shipping_method USING btree (shipping_option_id) WHERE ((deleted_at IS NULL) AND (shipping_option_id IS NOT NULL));


--
-- Name: IDX_shipping_method_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_method_tax_line_tax_rate_id" ON public.cart_shipping_method_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_shipping_option_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_deleted_at" ON public.shipping_option USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_id_ba32fa9c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_id_ba32fa9c" ON public.shipping_option_price_set USING btree (shipping_option_id);


--
-- Name: IDX_shipping_option_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_provider_id" ON public.shipping_option USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_rule_deleted_at" ON public.shipping_option_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_rule_shipping_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_rule_shipping_option_id" ON public.shipping_option_rule USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_service_zone_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_service_zone_id" ON public.shipping_option USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_shipping_profile_id" ON public.shipping_option USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_type_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_type_deleted_at" ON public.shipping_option_type USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_profile_deleted_at" ON public.shipping_profile USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_id_17a262437; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_profile_id_17a262437" ON public.product_shipping_profile USING btree (shipping_profile_id);


--
-- Name: IDX_shipping_profile_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_shipping_profile_name_unique" ON public.shipping_profile USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_single_default_region; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_single_default_region" ON public.tax_rate USING btree (tax_region_id) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- Name: IDX_stock_location_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_address_deleted_at" ON public.stock_location_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_address_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_stock_location_address_id_unique" ON public.stock_location USING btree (address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_deleted_at" ON public.stock_location USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_id_-1e5992737; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_id_-1e5992737" ON public.location_fulfillment_provider USING btree (stock_location_id);


--
-- Name: IDX_stock_location_id_-e88adb96; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_id_-e88adb96" ON public.location_fulfillment_set USING btree (stock_location_id);


--
-- Name: IDX_stock_location_id_26d06f470; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_id_26d06f470" ON public.sales_channel_stock_location USING btree (stock_location_id);


--
-- Name: IDX_store_currency_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_store_currency_deleted_at" ON public.store_currency USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_currency_store_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_store_currency_store_id" ON public.store_currency USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_store_deleted_at" ON public.store USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tag_value_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_tag_value_unique" ON public.product_tag USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_line_item_id" ON public.cart_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_line_shipping_method_id" ON public.cart_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_provider_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_provider_deleted_at" ON public.tax_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_deleted_at" ON public.tax_rate USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_rule_deleted_at" ON public.tax_rate_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_reference_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_rule_reference_id" ON public.tax_rate_rule USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_tax_rate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_rule_tax_rate_id" ON public.tax_rate_rule USING btree (tax_rate_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_unique_rate_reference; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_tax_rate_rule_unique_rate_reference" ON public.tax_rate_rule USING btree (tax_rate_id, reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_tax_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_tax_region_id" ON public.tax_rate USING btree (tax_region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_region_deleted_at" ON public.tax_region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_region_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_region_parent_id" ON public.tax_region USING btree (parent_id);


--
-- Name: IDX_tax_region_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_region_provider_id" ON public.tax_region USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_unique_country_nullable_province; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_nullable_province" ON public.tax_region USING btree (country_code) WHERE ((province_code IS NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_tax_region_unique_country_province; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_province" ON public.tax_region USING btree (country_code, province_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_type_value_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_type_value_unique" ON public.product_type USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_unique_promotion_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_unique_promotion_code" ON public.promotion USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_user_deleted_at" ON public."user" USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_user_email_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_user_email_unique" ON public."user" USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_17b4c4e35; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_variant_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (variant_id);


--
-- Name: IDX_variant_id_52b23597; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_variant_id_52b23597" ON public.product_variant_price_set USING btree (variant_id);


--
-- Name: IDX_workflow_execution_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_deleted_at" ON public.workflow_execution USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_id" ON public.workflow_execution USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_state" ON public.workflow_execution USING btree (state) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_transaction_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_transaction_id" ON public.workflow_execution USING btree (transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_workflow_id" ON public.workflow_execution USING btree (workflow_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id_run_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_workflow_execution_workflow_id_transaction_id_run_id_unique" ON public.workflow_execution USING btree (workflow_id, transaction_id, run_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_script_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_script_name_unique ON public.script_migrations USING btree (script_name);


--
-- Name: tax_rate_rule FK_tax_rate_rule_tax_rate_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT "FK_tax_rate_rule_tax_rate_id" FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;


--
-- Name: tax_rate FK_tax_rate_tax_region_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "FK_tax_rate_tax_region_id" FOREIGN KEY (tax_region_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_parent_id" FOREIGN KEY (parent_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_provider_id" FOREIGN KEY (provider_id) REFERENCES public.tax_provider(id) ON DELETE SET NULL;


--
-- Name: application_method_buy_rules application_method_buy_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_buy_rules application_method_buy_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: capture capture_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item cart_line_item_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method cart_shipping_method_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: credit_line credit_line_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE;


--
-- Name: customer_address customer_address_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_delivery_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_delivery_address_id_foreign FOREIGN KEY (delivery_address_id) REFERENCES public.fulfillment_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment_item fulfillment_item_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment_label fulfillment_label_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment fulfillment_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: geo_zone geo_zone_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: image image_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_level inventory_level_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notification notification_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.notification_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order order_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_change_action order_change_action_order_change_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_order_change_id_foreign FOREIGN KEY (order_change_id) REFERENCES public.order_change(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_change order_change_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_credit_line order_credit_line_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE;


--
-- Name: order_item order_item_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_adjustment order_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_tax_line order_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item order_line_item_totals_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_totals_id_foreign FOREIGN KEY (totals_id) REFERENCES public.order_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order order_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping order_shipping_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_summary order_summary_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_transaction order_transaction_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_col_aa276_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_col_aa276_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_pro_2d555_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_pro_2d555_foreign FOREIGN KEY (payment_provider_id) REFERENCES public.payment_provider(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment payment_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_session payment_session_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_list_rule price_list_rule_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_set_id_foreign FOREIGN KEY (price_set_id) REFERENCES public.price_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_rule price_rule_price_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_price_id_foreign FOREIGN KEY (price_id) REFERENCES public.price(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category product_category_parent_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_parent_category_id_foreign FOREIGN KEY (parent_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_category_id_foreign FOREIGN KEY (product_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_collection_id_foreign FOREIGN KEY (collection_id) REFERENCES public.product_collection(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_option product_option_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_option_value product_option_value_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_option_id_foreign FOREIGN KEY (option_id) REFERENCES public.product_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_tag_id_foreign FOREIGN KEY (product_tag_id) REFERENCES public.product_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_type_id_foreign FOREIGN KEY (type_id) REFERENCES public.product_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_variant_option product_variant_option_option_value_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_option_value_id_foreign FOREIGN KEY (option_value_id) REFERENCES public.product_option_value(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_option product_variant_option_variant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_variant_id_foreign FOREIGN KEY (variant_id) REFERENCES public.product_variant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant product_variant_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_application_method promotion_application_method_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget promotion_campaign_budget_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion promotion_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_rule_value promotion_rule_value_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: provider_identity provider_identity_auth_identity_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_auth_identity_id_foreign FOREIGN KEY (auth_identity_id) REFERENCES public.auth_identity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refund refund_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: region_country region_country_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.region(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reservation_item reservation_item_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: return_reason return_reason_parent_return_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_parent_return_reason_id_foreign FOREIGN KEY (parent_return_reason_id) REFERENCES public.return_reason(id);


--
-- Name: service_zone service_zone_fulfillment_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_fulfillment_set_id_foreign FOREIGN KEY (fulfillment_set_id) REFERENCES public.fulfillment_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: shipping_option_rule shipping_option_rule_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_option_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_option_type_id_foreign FOREIGN KEY (shipping_option_type_id) REFERENCES public.shipping_option_type(id) ON UPDATE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_profile_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_profile_id_foreign FOREIGN KEY (shipping_profile_id) REFERENCES public.shipping_profile(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: stock_location stock_location_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_address_id_foreign FOREIGN KEY (address_id) REFERENCES public.stock_location_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_currency store_currency_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

