--
-- PostgreSQL database dump
--

\restrict rk6nZkAxtf2f6ZfiJDrLqyOIcQQvn48MpnSTfgTeA2YrfWmPuFPBMvr1DVapQZK

-- Dumped from database version 17.8
-- Dumped by pg_dump version 17.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_player_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournaments DROP CONSTRAINT IF EXISTS tournaments_winner_player_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournaments DROP CONSTRAINT IF EXISTS tournaments_season_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournaments DROP CONSTRAINT IF EXISTS tournaments_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_participants DROP CONSTRAINT IF EXISTS tournament_participants_tournament_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_participants DROP CONSTRAINT IF EXISTS tournament_participants_player_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_matches DROP CONSTRAINT IF EXISTS tournament_matches_winner_participant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_matches DROP CONSTRAINT IF EXISTS tournament_matches_tournament_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_matches DROP CONSTRAINT IF EXISTS tournament_matches_p2_participant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_matches DROP CONSTRAINT IF EXISTS tournament_matches_p1_participant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_matches DROP CONSTRAINT IF EXISTS tournament_matches_next_match_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_matches DROP CONSTRAINT IF EXISTS tournament_matches_loser_next_match_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_match_comments DROP CONSTRAINT IF EXISTS tournament_match_comments_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_match_attachments DROP CONSTRAINT IF EXISTS tournament_match_attachments_verified_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_match_attachments DROP CONSTRAINT IF EXISTS tournament_match_attachments_uploaded_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.sessions DROP CONSTRAINT IF EXISTS sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.matchday DROP CONSTRAINT IF EXISTS matchday_season_id_fkey;
ALTER TABLE IF EXISTS ONLY public.match_comments DROP CONSTRAINT IF EXISTS match_comments_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.match_attachments DROP CONSTRAINT IF EXISTS match_attachments_uploaded_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.handoff_requests DROP CONSTRAINT IF EXISTS handoff_requests_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.champion_result DROP CONSTRAINT IF EXISTS fk_champion_player;
DROP INDEX IF EXISTS public.users_player_id_uniq;
DROP INDEX IF EXISTS public.tp_display_name_uniq;
DROP INDEX IF EXISTS public.tournaments_status_idx;
DROP INDEX IF EXISTS public.tournaments_season_idx;
DROP INDEX IF EXISTS public.tournaments_created_at_idx;
DROP INDEX IF EXISTS public.tournament_participants_seed_uniq;
DROP INDEX IF EXISTS public.tournament_matches_tournament_round_idx;
DROP INDEX IF EXISTS public.sessions_user_active;
DROP INDEX IF EXISTS public.idx_match_games_match;
DROP INDEX IF EXISTS public.idx_match_comments_match;
DROP INDEX IF EXISTS public.idx_match_attachments_match;
DROP INDEX IF EXISTS public.idx_champion_name;
DROP INDEX IF EXISTS public.draft_author_idx;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.tournaments DROP CONSTRAINT IF EXISTS tournaments_slug_key;
ALTER TABLE IF EXISTS ONLY public.tournaments DROP CONSTRAINT IF EXISTS tournaments_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_pool_participants DROP CONSTRAINT IF EXISTS tournament_pool_participants_pool_id_participant_id_key;
ALTER TABLE IF EXISTS ONLY public.tournament_pool_participants DROP CONSTRAINT IF EXISTS tournament_pool_participants_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_participants DROP CONSTRAINT IF EXISTS tournament_participants_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_participant_stats DROP CONSTRAINT IF EXISTS tournament_participant_stats_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_participant_stats DROP CONSTRAINT IF EXISTS tournament_participant_stats_participant_id_phase_id_key;
ALTER TABLE IF EXISTS ONLY public.tournament_matches DROP CONSTRAINT IF EXISTS tournament_matches_tournament_id_round_no_slot_no_key;
ALTER TABLE IF EXISTS ONLY public.tournament_matches DROP CONSTRAINT IF EXISTS tournament_matches_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_match_comments DROP CONSTRAINT IF EXISTS tournament_match_comments_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_match_attachments DROP CONSTRAINT IF EXISTS tournament_match_attachments_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_groups DROP CONSTRAINT IF EXISTS tournament_groups_pkey;
ALTER TABLE IF EXISTS ONLY public.sessions DROP CONSTRAINT IF EXISTS sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.seasons DROP CONSTRAINT IF EXISTS seasons_pkey;
ALTER TABLE IF EXISTS ONLY public.season_totals DROP CONSTRAINT IF EXISTS season_totals_tag_key;
ALTER TABLE IF EXISTS ONLY public.season_totals DROP CONSTRAINT IF EXISTS season_totals_pkey;
ALTER TABLE IF EXISTS ONLY public.players DROP CONSTRAINT IF EXISTS players_pkey;
ALTER TABLE IF EXISTS ONLY public.matchday DROP CONSTRAINT IF EXISTS matchday_pkey;
ALTER TABLE IF EXISTS ONLY public.match_games DROP CONSTRAINT IF EXISTS match_games_pkey;
ALTER TABLE IF EXISTS ONLY public.match_games DROP CONSTRAINT IF EXISTS match_games_match_id_game_number_key;
ALTER TABLE IF EXISTS ONLY public.match_comments DROP CONSTRAINT IF EXISTS match_comments_pkey;
ALTER TABLE IF EXISTS ONLY public.match_attachments DROP CONSTRAINT IF EXISTS match_attachments_pkey;
ALTER TABLE IF EXISTS ONLY public.handoff_requests DROP CONSTRAINT IF EXISTS handoff_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.duels DROP CONSTRAINT IF EXISTS duels_pkey;
ALTER TABLE IF EXISTS ONLY public.draft DROP CONSTRAINT IF EXISTS draft_pkey;
ALTER TABLE IF EXISTS ONLY public.champion_result DROP CONSTRAINT IF EXISTS champion_result_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournaments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_pool_participants ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_participants ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_participant_stats ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_matches ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_match_comments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_match_attachments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_groups ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.seasons ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.season_totals ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.match_games ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.match_comments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.match_attachments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.duels ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.tournaments_id_seq;
DROP TABLE IF EXISTS public.tournaments;
DROP SEQUENCE IF EXISTS public.tournament_pool_participants_id_seq;
DROP TABLE IF EXISTS public.tournament_pool_participants;
DROP SEQUENCE IF EXISTS public.tournament_participants_id_seq;
DROP TABLE IF EXISTS public.tournament_participants;
DROP SEQUENCE IF EXISTS public.tournament_participant_stats_id_seq;
DROP TABLE IF EXISTS public.tournament_participant_stats;
DROP SEQUENCE IF EXISTS public.tournament_matches_id_seq;
DROP TABLE IF EXISTS public.tournament_matches;
DROP SEQUENCE IF EXISTS public.tournament_match_comments_id_seq;
DROP TABLE IF EXISTS public.tournament_match_comments;
DROP SEQUENCE IF EXISTS public.tournament_match_attachments_id_seq;
DROP TABLE IF EXISTS public.tournament_match_attachments;
DROP SEQUENCE IF EXISTS public.tournament_groups_id_seq;
DROP TABLE IF EXISTS public.tournament_groups;
DROP TABLE IF EXISTS public.sessions;
DROP SEQUENCE IF EXISTS public.seasons_id_seq;
DROP TABLE IF EXISTS public.seasons;
DROP SEQUENCE IF EXISTS public.season_totals_id_seq;
DROP TABLE IF EXISTS public.season_totals;
DROP TABLE IF EXISTS public.players;
DROP TABLE IF EXISTS public.matchday;
DROP SEQUENCE IF EXISTS public.match_games_id_seq;
DROP TABLE IF EXISTS public.match_games;
DROP SEQUENCE IF EXISTS public.match_comments_id_seq;
DROP TABLE IF EXISTS public.match_comments;
DROP SEQUENCE IF EXISTS public.match_attachments_id_seq;
DROP TABLE IF EXISTS public.match_attachments;
DROP TABLE IF EXISTS public.handoff_requests;
DROP SEQUENCE IF EXISTS public.duels_id_seq;
DROP TABLE IF EXISTS public.duels;
DROP TABLE IF EXISTS public.draft;
DROP TABLE IF EXISTS public.champion_result;
DROP FUNCTION IF EXISTS public.set_updated_at();
-- *not* dropping schema, since initdb creates it
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at = now();
  return new;
end
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: champion_result; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.champion_result (
    day date NOT NULL,
    division text NOT NULL,
    champion_name text NOT NULL,
    champion_id text,
    team_code text,
    CONSTRAINT champion_result_division_check CHECK ((division = ANY (ARRAY['D1'::text, 'D2'::text]))),
    CONSTRAINT champion_result_team_code_check CHECK (((team_code IS NULL) OR (char_length(team_code) <= 6)))
);


--
-- Name: draft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.draft (
    day date NOT NULL,
    payload jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    author_user_id integer
);


--
-- Name: duels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.duels (
    id integer NOT NULL,
    p1_id text NOT NULL,
    p2_id text NOT NULL,
    score_a integer NOT NULL,
    score_b integer NOT NULL,
    played_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: duels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.duels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: duels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.duels_id_seq OWNED BY public.duels.id;


--
-- Name: handoff_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.handoff_requests (
    id text NOT NULL,
    user_id integer,
    nonce text NOT NULL,
    new_device text,
    created_at timestamp with time zone DEFAULT now(),
    status text DEFAULT 'pending'::text NOT NULL,
    approved_at timestamp with time zone,
    denied_at timestamp with time zone,
    consumed_at timestamp with time zone
);


--
-- Name: match_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_attachments (
    id integer NOT NULL,
    match_id integer NOT NULL,
    uploaded_by_user_id integer,
    attachment_type text NOT NULL,
    attachment_url text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: match_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_attachments_id_seq OWNED BY public.match_attachments.id;


--
-- Name: match_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_comments (
    id integer NOT NULL,
    match_id integer NOT NULL,
    user_id integer,
    comment_text text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: match_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_comments_id_seq OWNED BY public.match_comments.id;


--
-- Name: match_games; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_games (
    id integer NOT NULL,
    match_id integer NOT NULL,
    game_number integer NOT NULL,
    score1 integer,
    score2 integer,
    winner_id integer,
    played_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: match_games_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_games_id_seq OWNED BY public.match_games.id;


--
-- Name: matchday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matchday (
    day date NOT NULL,
    season_id integer,
    payload jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.players (
    player_id text NOT NULL,
    name text NOT NULL,
    role text DEFAULT 'MEMBRE'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    profile_pic_url text
);


--
-- Name: season_totals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.season_totals (
    id integer NOT NULL,
    tag text DEFAULT 'current'::text NOT NULL,
    standings jsonb DEFAULT '[]'::jsonb NOT NULL,
    closed boolean DEFAULT false NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: season_totals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.season_totals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: season_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.season_totals_id_seq OWNED BY public.season_totals.id;


--
-- Name: seasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seasons (
    id integer NOT NULL,
    name text NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    is_closed boolean DEFAULT false NOT NULL
);


--
-- Name: seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seasons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seasons_id_seq OWNED BY public.seasons.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id text NOT NULL,
    user_id integer,
    device text,
    user_agent text,
    ip text,
    created_at timestamp with time zone DEFAULT now(),
    last_seen timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true NOT NULL,
    revoked_at timestamp with time zone,
    logout_at timestamp with time zone,
    cleaned_after_logout boolean DEFAULT false NOT NULL
);


--
-- Name: tournament_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournament_groups (
    id integer NOT NULL,
    tournament_id integer NOT NULL,
    group_name text NOT NULL,
    group_number integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: tournament_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tournament_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tournament_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tournament_groups_id_seq OWNED BY public.tournament_groups.id;


--
-- Name: tournament_match_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournament_match_attachments (
    id integer NOT NULL,
    match_id integer NOT NULL,
    uploaded_by_user_id integer,
    uploaded_by_participant_id integer,
    attachment_type text NOT NULL,
    url text NOT NULL,
    description text,
    verified boolean DEFAULT false,
    verified_by_user_id integer,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT attachment_type_check CHECK ((attachment_type = ANY (ARRAY['screenshot'::text, 'video'::text, 'link'::text, 'other'::text])))
);


--
-- Name: tournament_match_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tournament_match_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tournament_match_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tournament_match_attachments_id_seq OWNED BY public.tournament_match_attachments.id;


--
-- Name: tournament_match_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournament_match_comments (
    id integer NOT NULL,
    match_id integer NOT NULL,
    user_id integer,
    participant_id integer,
    comment_text text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: tournament_match_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tournament_match_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tournament_match_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tournament_match_comments_id_seq OWNED BY public.tournament_match_comments.id;


--
-- Name: tournament_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournament_matches (
    id integer NOT NULL,
    tournament_id integer NOT NULL,
    round_no integer NOT NULL,
    slot_no integer NOT NULL,
    best_of integer DEFAULT 1 NOT NULL,
    p1_participant_id integer,
    p2_participant_id integer,
    score_p1 integer,
    score_p2 integer,
    winner_participant_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    walkover boolean DEFAULT false NOT NULL,
    next_match_id integer,
    next_match_slot smallint,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    bracket_side text DEFAULT 'W'::text NOT NULL,
    loser_next_match_id integer,
    loser_next_match_slot smallint,
    group_no smallint,
    CONSTRAINT tournament_matches_best_of_check CHECK ((best_of > 0)),
    CONSTRAINT tournament_matches_next_match_slot_check CHECK ((next_match_slot = ANY (ARRAY[1, 2]))),
    CONSTRAINT tournament_matches_round_no_check CHECK ((round_no > 0)),
    CONSTRAINT tournament_matches_slot_no_check CHECK ((slot_no > 0)),
    CONSTRAINT tournament_matches_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'ready'::text, 'completed'::text])))
);


--
-- Name: tournament_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tournament_matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tournament_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tournament_matches_id_seq OWNED BY public.tournament_matches.id;


--
-- Name: tournament_participant_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournament_participant_stats (
    id integer NOT NULL,
    participant_id integer NOT NULL,
    phase_id integer,
    matches_played integer DEFAULT 0,
    matches_won integer DEFAULT 0,
    matches_lost integer DEFAULT 0,
    games_won integer DEFAULT 0,
    games_lost integer DEFAULT 0,
    points integer DEFAULT 0,
    buchholz real DEFAULT 0,
    pool_placement integer,
    phase_placement integer,
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: tournament_participant_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tournament_participant_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tournament_participant_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tournament_participant_stats_id_seq OWNED BY public.tournament_participant_stats.id;


--
-- Name: tournament_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournament_participants (
    id integer NOT NULL,
    tournament_id integer NOT NULL,
    player_id text,
    seed integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    group_no smallint,
    display_name text DEFAULT ''::text NOT NULL
);


--
-- Name: tournament_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tournament_participants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tournament_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tournament_participants_id_seq OWNED BY public.tournament_participants.id;


--
-- Name: tournament_pool_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournament_pool_participants (
    id integer NOT NULL,
    pool_id integer NOT NULL,
    participant_id integer NOT NULL,
    seed_in_pool integer
);


--
-- Name: tournament_pool_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tournament_pool_participants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tournament_pool_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tournament_pool_participants_id_seq OWNED BY public.tournament_pool_participants.id;


--
-- Name: tournaments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournaments (
    id integer NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    format text DEFAULT 'single_elimination'::text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    starts_at timestamp with time zone,
    ended_at timestamp with time zone,
    winner_player_id text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    nb_groups smallint,
    qualifiers_per_group smallint,
    winner_name text,
    member_tournament boolean DEFAULT true NOT NULL,
    season_id integer,
    day_comment text,
    counts_for_title boolean DEFAULT false NOT NULL,
    rr_match_mode text DEFAULT 'single'::text NOT NULL,
    rr_standings_mode text DEFAULT 'goals'::text NOT NULL,
    CONSTRAINT tournaments_format_chk CHECK ((format = ANY (ARRAY['single_elimination'::text, 'round_robin'::text, 'double_elimination'::text, 'groups_knockout'::text]))),
    CONSTRAINT tournaments_rr_match_mode_chk CHECK ((rr_match_mode = ANY (ARRAY['single'::text, 'home_away'::text]))),
    CONSTRAINT tournaments_rr_standings_mode_chk CHECK ((rr_standings_mode = ANY (ARRAY['goals'::text, 'wins'::text]))),
    CONSTRAINT tournaments_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'live'::text, 'completed'::text, 'archived'::text])))
);


--
-- Name: tournaments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tournaments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tournaments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tournaments_id_seq OWNED BY public.tournaments.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    role text DEFAULT 'member'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    player_id text,
    last_login timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
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
-- Name: duels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duels ALTER COLUMN id SET DEFAULT nextval('public.duels_id_seq'::regclass);


--
-- Name: match_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_attachments ALTER COLUMN id SET DEFAULT nextval('public.match_attachments_id_seq'::regclass);


--
-- Name: match_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_comments ALTER COLUMN id SET DEFAULT nextval('public.match_comments_id_seq'::regclass);


--
-- Name: match_games id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_games ALTER COLUMN id SET DEFAULT nextval('public.match_games_id_seq'::regclass);


--
-- Name: season_totals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.season_totals ALTER COLUMN id SET DEFAULT nextval('public.season_totals_id_seq'::regclass);


--
-- Name: seasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons ALTER COLUMN id SET DEFAULT nextval('public.seasons_id_seq'::regclass);


--
-- Name: tournament_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_groups ALTER COLUMN id SET DEFAULT nextval('public.tournament_groups_id_seq'::regclass);


--
-- Name: tournament_match_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_match_attachments ALTER COLUMN id SET DEFAULT nextval('public.tournament_match_attachments_id_seq'::regclass);


--
-- Name: tournament_match_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_match_comments ALTER COLUMN id SET DEFAULT nextval('public.tournament_match_comments_id_seq'::regclass);


--
-- Name: tournament_matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches ALTER COLUMN id SET DEFAULT nextval('public.tournament_matches_id_seq'::regclass);


--
-- Name: tournament_participant_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_participant_stats ALTER COLUMN id SET DEFAULT nextval('public.tournament_participant_stats_id_seq'::regclass);


--
-- Name: tournament_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_participants ALTER COLUMN id SET DEFAULT nextval('public.tournament_participants_id_seq'::regclass);


--
-- Name: tournament_pool_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_pool_participants ALTER COLUMN id SET DEFAULT nextval('public.tournament_pool_participants_id_seq'::regclass);


--
-- Name: tournaments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN id SET DEFAULT nextval('public.tournaments_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: champion_result; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.champion_result (day, division, champion_name, champion_id, team_code) FROM stdin;
\.


--
-- Data for Name: draft; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.draft (day, payload, updated_at, author_user_id) FROM stdin;
2025-08-23	{"d1": [{"a1": 5, "a2": 1, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 5, "r2": 0}, {"a1": 2, "a2": 2, "p1": "CBlacks_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 0}, {"a1": 2, "a2": 2, "p1": "IBR@93_GZ", "p2": "KenkNod_GZ", "r1": 4, "r2": 3}], "d2": [{"a1": 3, "a2": 2, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 4}, {"a1": 4, "a2": 0, "p1": "Akab_GZ", "p2": "Cephas", "r1": 8, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 5}, {"a1": 1, "a2": 0, "p1": "Akab_GZ", "p2": "Kem_GZ", "r1": 8, "r2": 3}, {"a1": 2, "a2": 1, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 0}, {"a1": 3, "a2": 2, "p1": "Rod_GZ", "p2": "Kem_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 4, "p1": "Rod_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 0}, {"a1": 3, "a2": 1, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 3}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "Kem_GZ", "r1": 4, "r2": 2}, {"a1": 0, "a2": 4, "p1": "Walé-GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 0, "p1": "Walé-GZ", "p2": "Cephas", "r1": 2, "r2": 1}, {"a1": 2, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Kem_GZ", "r1": 4, "r2": 1}, {"a1": 4, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Cephas", "r1": 7, "r2": 1}, {"a1": 5, "a2": 1, "p1": "Kem_GZ", "p2": "Cephas", "r1": 3, "r2": 2}, {"a1": 4, "a2": 0, "p1": "Rod_GZ", "p2": "Cephas", "r1": 4, "r2": 1}], "date": "2025-08-23", "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "EmRiCxX_GZ – Akab_GZ", "label": "Affiche : EmRiCxX_GZ – Akab_GZ", "notes": ""}, "champions": {"d1": {"team": "FRANCE"}, "d2": {"team": "FRANCE"}}}	2025-08-26 12:06:41.140924+00	\N
\.


--
-- Data for Name: duels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.duels (id, p1_id, p2_id, score_a, score_b, played_at, created_at) FROM stdin;
\.


--
-- Data for Name: handoff_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.handoff_requests (id, user_id, nonce, new_device, created_at, status, approved_at, denied_at, consumed_at) FROM stdin;
\.


--
-- Data for Name: match_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.match_attachments (id, match_id, uploaded_by_user_id, attachment_type, attachment_url, description, created_at) FROM stdin;
\.


--
-- Data for Name: match_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.match_comments (id, match_id, user_id, comment_text, created_at) FROM stdin;
\.


--
-- Data for Name: match_games; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.match_games (id, match_id, game_number, score1, score2, winner_id, played_at, created_at) FROM stdin;
\.


--
-- Data for Name: matchday; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.matchday (day, season_id, payload, created_at) FROM stdin;
2025-09-13	2	{"d1": [{"a1": 2, "a2": 2, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 3}, {"a1": 0, "a2": 0, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 3}, {"a1": 5, "a2": 2, "p1": "CBlacks_GZ", "p2": "Kem_GZ", "r1": 4, "r2": 1}, {"a1": 2, "a2": 0, "p1": "CBlacks_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 0}, {"a1": 3, "a2": 2, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 4, "r2": 1}, {"a1": 5, "a2": 2, "p1": "IBR@93_GZ", "p2": "Kem_GZ", "r1": 2, "r2": 0}, {"a1": 0, "a2": 3, "p1": "IBR@93_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 3}, {"a1": 2, "a2": 1, "p1": "Kem_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 5}, {"a1": 0, "a2": 3, "p1": "Kem_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 3}, {"a1": 0, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 2}], "d2": [{"a1": 1, "a2": 3, "p1": "Rod_GZ", "p2": "Ismo", "r1": 2, "r2": 4}, {"a1": 0, "a2": 2, "p1": "Rod_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 3}, {"a1": 5, "a2": 2, "p1": "Rod_GZ", "p2": "AminouFlash", "r1": 1, "r2": 5}, {"a1": 2, "a2": 1, "p1": "Rod_GZ", "p2": "GMT_GZ", "r1": 3, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 3, "p1": "KenkNod_GZ", "p2": "Ismo", "r1": 6, "r2": 0}, {"a1": 6, "a2": 1, "p1": "KenkNod_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 0}, {"a1": 1, "a2": 3, "p1": "KenkNod_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 1, "p1": "KenkNod_GZ", "p2": "AminouFlash", "r1": 3, "r2": 1}, {"a1": 0, "a2": 1, "p1": "GMT_GZ", "p2": "AminouFlash", "r1": 0, "r2": 4}, {"a1": 3, "a2": 1, "p1": "GMT_GZ", "p2": "Walé-GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 2, "p1": "GMT_GZ", "p2": "Ismo", "r1": 1, "r2": 3}, {"a1": 2, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "AminouFlash", "r1": 4, "r2": 3}, {"a1": 1, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "Ismo", "r1": 2, "r2": 3}, {"a1": 4, "a2": 3, "p1": "Ismo", "p2": "AminouFlash", "r1": 1, "r2": 2}, {"a1": 2, "a2": 4, "p1": "Walé-GZ", "p2": "AminouFlash", "r1": 2, "r2": 5}, {"a1": 0, "a2": 1, "p1": "Walé-GZ", "p2": "Ismo", "r1": 0, "r2": 1}, {"a1": 4, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 0, "p1": "Zyex_Legend_GZ", "p2": "Rod_GZ", "r1": 2, "r2": 2}, {"a1": 6, "a2": 0, "p1": "KenkNod_GZ", "p2": "Zyex_Legend_GZ", "r1": 4, "r2": 1}, {"a1": 3, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 3}], "barrage": {"m1": {"A": 0, "B": 3}, "m2": {"A": 0, "B": 3}, "m3": {}, "ids": "Rius_oyo_GZ – Zyex_Legend_GZ", "label": "Zyex_Legend_GZ monte en D1 · Rius_oyo_GZ est relégué en D2", "notes": "Dych gagne par forfait..."}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "REAL MADRID"}, "d2": {"id": "KenkNod_GZ", "team": "FRANCE"}, "barrage": {"ids": {"d1": "Rius_oyo_GZ", "d2": "Zyex_Legend_GZ"}, "label": "Zyex_Legend_GZ monte en D1 · Rius_oyo_GZ est relégué en D2", "matches": [{"A": 0, "B": 3}, {"A": 0, "B": 3}, {}]}}}	2025-09-13 21:04:36.917919+00
2025-08-23	2	{"d1": [{"a1": 5, "a2": 1, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 5, "r2": 0}, {"a1": 2, "a2": 2, "p1": "CBlacks_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 0}, {"a1": 2, "a2": 2, "p1": "IBR@93_GZ", "p2": "KenkNod_GZ", "r1": 4, "r2": 3}], "d2": [{"a1": 3, "a2": 2, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 4}, {"a1": 4, "a2": 0, "p1": "Akab_GZ", "p2": "Cephas", "r1": 8, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 5}, {"a1": 1, "a2": 0, "p1": "Akab_GZ", "p2": "Kem_GZ", "r1": 8, "r2": 3}, {"a1": 2, "a2": 1, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 0}, {"a1": 3, "a2": 2, "p1": "Rod_GZ", "p2": "Kem_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 4, "p1": "Rod_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 0}, {"a1": 3, "a2": 1, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 3}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "Kem_GZ", "r1": 4, "r2": 2}, {"a1": 0, "a2": 4, "p1": "Walé-GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 0, "p1": "Walé-GZ", "p2": "Cephas", "r1": 2, "r2": 1}, {"a1": 2, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Kem_GZ", "r1": 4, "r2": 1}, {"a1": 4, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Cephas", "r1": 7, "r2": 1}, {"a1": 5, "a2": 1, "p1": "Kem_GZ", "p2": "Cephas", "r1": 3, "r2": 2}, {"a1": 4, "a2": 0, "p1": "Rod_GZ", "p2": "Cephas", "r1": 4, "r2": 1}], "barrage": {"m1": {"A": 3, "B": 1}, "m2": {"A": 4, "B": 2}, "m3": {}, "ids": "EmRiCxX_GZ – Akab_GZ", "label": "EmRiCxX_GZ se maintient en D1 · Akab_GZ reste en D2", "notes": "LUC est directement relégué en D2"}, "champions": {"d1": {"id": "CBlacks_GZ", "team": "FRANCE"}, "d2": {"id": "Rius_oyo_GZ", "team": "FRANCE"}, "barrage": {"ids": {"d1": "EmRiCxX_GZ", "d2": "Akab_GZ"}, "label": "EmRiCxX_GZ se maintient en D1 · Akab_GZ reste en D2", "matches": [{"A": 3, "B": 1}, {"A": 4, "B": 2}, {}]}}}	2025-08-23 22:32:42.998498+00
2025-08-30	2	{"d1": [{"a1": 2, "a2": 1, "p1": "Yousscash_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 3}, {"a1": 0, "a2": 1, "p1": "Yousscash_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 0}, {"a1": 1, "a2": 2, "p1": "Yousscash_GZ", "p2": "CBlacks_GZ", "r1": 2, "r2": 0}, {"a1": 4, "a2": 0, "p1": "Yousscash_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 2, "p1": "Zyex_Legend_GZ", "p2": "CBlacks_GZ", "r1": 0, "r2": 6}, {"a1": 1, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 4}, {"a1": 4, "a2": 4, "p1": "Zyex_Legend_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 1, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 3}, {"a1": 2, "a2": 2, "p1": "IBR@93_GZ", "p2": "CBlacks_GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 2, "p1": "Rius_oyo_GZ", "p2": "CBlacks_GZ", "r1": 1, "r2": 1}], "d2": [{"a1": 2, "a2": 1, "p1": "KenkNod_GZ", "p2": "Kem_GZ", "r1": 3, "r2": 0}, {"a1": 1, "a2": 3, "p1": "KenkNod_GZ", "p2": "Akab_GZ", "r1": 2, "r2": 1}, {"a1": 4, "a2": 3, "p1": "KenkNod_GZ", "p2": "Rod_GZ", "r1": 3, "r2": 2}, {"a1": 4, "a2": 2, "p1": "KenkNod_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 2}, {"a1": 6, "a2": 1, "p1": "KenkNod_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 0, "p1": "Kem_GZ", "p2": "Akab_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 1, "p1": "Kem_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 2}, {"a1": 3, "a2": 2, "p1": "Kem_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 3}, {"a1": 0, "a2": 3, "p1": "GMT_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 3, "p1": "GMT_GZ", "p2": "Rod_GZ", "r1": 2, "r2": 4}, {"a1": 2, "a2": 0, "p1": "GMT_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Kem_GZ", "p2": "Rod_GZ", "r1": 3, "r2": 6}, {"a1": 2, "a2": 2, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 3}, {"a1": 0, "a2": 4, "p1": "Rod_GZ", "p2": "Akab_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "Matrix _GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 2}, {"a1": 2, "a2": 3, "p1": "Matrix _GZ", "p2": "Kem_GZ", "r1": 2, "r2": 2}, {"a1": 3, "a2": 2, "p1": "Matrix _GZ", "p2": "Rod_GZ", "r1": 4, "r2": 1}, {"a1": 4, "a2": 1, "p1": "Matrix _GZ", "p2": "GMT_GZ", "r1": 2, "r2": 0}, {"a1": 2, "a2": 2, "p1": "Matrix _GZ", "p2": "Akab_GZ", "r1": 0, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Matrix _GZ", "p2": "Walé-GZ", "r1": 1, "r2": 1}], "barrage": {"m1": {"A": 2, "B": 3}, "m2": {"A": 8, "B": 1}, "m3": {"A": 0, "B": 2}, "ids": "Rius_oyo_GZ – Akab_GZ", "label": "Akab_GZ monte en D1 · Rius_oyo_GZ est relégué en D2", "notes": "Dych est directement relégué en D2."}, "champions": {"d1": {"id": "CBlacks_GZ", "team": "FRANCE"}, "d2": {"id": "KenkNod_GZ", "team": "FRANCE"}, "barrage": {"ids": {"d1": "Rius_oyo_GZ", "d2": "Akab_GZ"}, "label": "Akab_GZ monte en D1 · Rius_oyo_GZ est relégué en D2", "matches": [{"A": 2, "B": 3}, {"A": 8, "B": 1}, {"A": 0, "B": 2}]}}}	2025-08-30 22:28:23.370968+00
2025-09-06	2	{"d1": [{"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Akab_GZ", "r1": 2, "r2": 2}, {"a1": 7, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 1}, {"a1": 1, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "CBlacks_GZ", "r1": 4, "r2": 3}, {"a1": 1, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 1}, {"a1": 2, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "Yousscash_GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 1, "p1": "CBlacks_GZ", "p2": "Akab_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 4}, {"a1": 1, "a2": 5, "p1": "CBlacks_GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 2}, {"a1": 3, "a2": 1, "p1": "CBlacks_GZ", "p2": "KenkNod_GZ", "r1": 4, "r2": 3}, {"a1": 0, "a2": 1, "p1": "Akab_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Akab_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 2, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 2, "p1": "Yousscash_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 0, "p1": "Yousscash_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 2}], "d2": [{"a1": 3, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "GMT_GZ", "r1": 6, "r2": 1}, {"a1": 3, "a2": 2, "p1": "Rius_oyo_GZ", "p2": "Kem_GZ", "r1": 3, "r2": 2}, {"a1": 3, "a2": 2, "p1": "Rius_oyo_GZ", "p2": "Rod_GZ", "r1": 6, "r2": 3}, {"a1": 4, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 0}, {"a1": 2, "a2": 1, "p1": "Rod_GZ", "p2": "Zyex_Legend_GZ", "r1": 3, "r2": 4}, {"a1": 2, "a2": 3, "p1": "Rod_GZ", "p2": "Kem_GZ", "r1": 2, "r2": 3}, {"a1": 2, "a2": 0, "p1": "Rod_GZ", "p2": "GMT_GZ", "r1": 5, "r2": 0}, {"a1": 1, "a2": 1, "p1": "Kem_GZ", "p2": "Zyex_Legend_GZ", "r1": 3, "r2": 2}, {"a1": 1, "a2": 0, "p1": "Kem_GZ", "p2": "GMT_GZ", "r1": 5, "r2": 0}, {"a1": 3, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Matrix _GZ", "p2": "Kem_GZ", "r1": 3, "r2": 1}, {"a1": 0, "a2": 2, "p1": "Matrix _GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 2}, {"a1": 1, "a2": 3, "p1": "Matrix _GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 3}, {"a1": 3, "a2": 3, "p1": "Matrix _GZ", "p2": "Rod_GZ", "r1": 0, "r2": 1}, {"a1": 5, "a2": 0, "p1": "Matrix _GZ", "p2": "GMT_GZ", "r1": 6, "r2": 2}], "barrage": {"m1": {"A": 3, "B": 0}, "m2": {"A": 0, "B": 1}, "m3": {"A": 1, "B": 2}, "ids": "Akab_GZ – Kem_GZ", "label": "Kem_GZ monte en D1 · Akab_GZ est relégué en D2", "notes": "Luc est directement relégué en D2.\\n\\nRius Champion sans défaite en D2 (10 matchs joués 10 matchs gagnés).\\n\\nTanguy dernier en D2  (10 matchs joués 10 matchs perdus)."}, "champions": {"d1": {"id": "Yousscash_GZ", "team": "ANGLETERRE"}, "d2": {"id": "Rius_oyo_GZ", "team": "FRANCE"}, "barrage": {"ids": {"d1": "Akab_GZ", "d2": "Kem_GZ"}, "label": "Kem_GZ monte en D1 · Akab_GZ est relégué en D2", "matches": [{"A": 3, "B": 0}, {"A": 0, "B": 1}, {"A": 1, "B": 2}]}}}	2025-09-06 21:02:51.246571+00
2025-09-27	2	{"d1": [{"a1": 0, "a2": 0, "p1": "Yousscash_GZ", "p2": "Zyex_Legend_GZ", "r1": 4, "r2": 0}, {"a1": 2, "a2": 0, "p1": "Yousscash_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 3, "p1": "Yousscash_GZ", "p2": "CBlacks_GZ", "r1": 1, "r2": 0}, {"a1": 1, "a2": 3, "p1": "Yousscash_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 4}, {"a1": 3, "a2": 1, "p1": "Yousscash_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 2}, {"a1": 2, "a2": 3, "p1": "KenkNod_GZ", "p2": "CBlacks_GZ", "r1": 2, "r2": 2}, {"a1": 0, "a2": 3, "p1": "KenkNod_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 2}, {"a1": 1, "a2": 4, "p1": "KenkNod_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 4}, {"a1": 3, "a2": 1, "p1": "KenkNod_GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 1, "p1": "IBR@93_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 5}, {"a1": 4, "a2": 2, "p1": "IBR@93_GZ", "p2": "CBlacks_GZ", "r1": 4, "r2": 0}, {"a1": 1, "a2": 3, "p1": "IBR@93_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 1}, {"a1": 0, "a2": 1, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 3, "r2": 3}, {"a1": 2, "a2": 2, "p1": "CBlacks_GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 1}, {"a1": 5, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 3}], "d2": [{"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 3, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 6}, {"a1": 4, "a2": 0, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 0, "r2": 2}, {"a1": 3, "a2": 1, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 1}, {"a1": 0, "a2": 4, "p1": "Akab_GZ", "p2": "Pat", "r1": 0, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Rod_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 4}, {"a1": 0, "a2": 4, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 0}, {"a1": 4, "a2": 0, "p1": "Rod_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 2}, {"a1": 0, "a2": 1, "p1": "Rod_GZ", "p2": "Pat", "r1": 3, "r2": 6}, {"a1": 1, "a2": 4, "p1": "Rius_oyo_GZ", "p2": "Pat", "r1": 0, "r2": 0}, {"a1": 6, "a2": 2, "p1": "Rius_oyo_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 0}, {"a1": 3, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 0}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "Pat", "r1": 3, "r2": 4}, {"a1": 3, "a2": 0, "p1": "Walé-GZ", "p2": "GMT_GZ", "r1": 3, "r2": 1}, {"a1": 2, "a2": 3, "p1": "GMT_GZ", "p2": "Pat", "r1": 1, "r2": 3}], "barrage": {"m1": {"A": 2, "B": 3}, "m2": {"A": 2, "B": 3}, "m3": {}, "ids": "KenkNod_GZ – Walé-GZ", "label": "Walé monte en D1 · KenkNod_GZ est relégué en D2", "notes": "Belle performance de Patrice. Champion sans défaite."}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Rius_oyo_GZ", "team": "FRANCE"}}}	2025-09-27 21:03:33.520657+00
2025-10-04	2	{"d1": [{"a1": 5, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 1}, {"a1": 9, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Pat", "r1": 7, "r2": 1}, {"a1": 8, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Walé-GZ", "r1": 4, "r2": 1}, {"a1": 5, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 3}, {"a1": 4, "a2": 2, "p1": "IBR@93_GZ", "p2": "Pat", "r1": 1, "r2": 0}, {"a1": 1, "a2": 0, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 4, "r2": 0}, {"a1": 4, "a2": 2, "p1": "IBR@93_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 1}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "Pat", "r1": 1, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 4}, {"a1": 0, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Pat", "r1": 1, "r2": 2}], "d2": [{"a1": 2, "a2": 0, "p1": "Akab_GZ", "p2": "AminouFlash", "r1": 1, "r2": 3}, {"a1": 2, "a2": 2, "p1": "Akab_GZ", "p2": "Kem_GZ", "r1": 2, "r2": 3}, {"a1": 4, "a2": 2, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 2}, {"a1": 1, "a2": 6, "p1": "Akab_GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 0}, {"a1": 2, "a2": 3, "p1": "KenkNod_GZ", "p2": "Zyex_Legend_GZ", "r1": 4, "r2": 1}, {"a1": 3, "a2": 4, "p1": "KenkNod_GZ", "p2": "AminouFlash", "r1": 3, "r2": 2}, {"a1": 1, "a2": 1, "p1": "KenkNod_GZ", "p2": "Kem_GZ", "r1": 1, "r2": 3}, {"a1": 3, "a2": 0, "p1": "Kem_GZ", "p2": "Zyex_Legend_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 4, "p1": "Kem_GZ", "p2": "AminouFlash", "r1": 2, "r2": 2}, {"a1": 3, "a2": 1, "p1": "AminouFlash", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 0}], "barrage": {"m1": {"A": 3, "B": 1}, "m2": {"A": 2, "B": 2}, "m3": {"A": 3, "B": 0}, "ids": "Rius_oyo_GZ – Akab_GZ", "label": "Rius_oyo_GZ se maintient en D1 · Akab_GZ reste en D2", "notes": ""}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Kem_GZ", "team": "MADRID"}}}	2025-10-13 12:12:18.481878+00
2025-10-11	2	{"d1": [{"a1": 0, "a2": 5, "p1": "Walé-GZ", "p2": "CBlacks_GZ", "r1": 2, "r2": 4}, {"a1": 0, "a2": 0, "p1": "Walé-GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 4}, {"a1": 0, "a2": 5, "p1": "Walé-GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 4}, {"a1": 1, "a2": 6, "p1": "Walé-GZ", "p2": "Akab_GZ", "r1": 0, "r2": 1}, {"a1": 2, "a2": 4, "p1": "Walé-GZ", "p2": "The_One_GZ", "r1": 0, "r2": 1}, {"a1": 2, "a2": 4, "p1": "Walé-GZ", "p2": "Matrix _GZ", "r1": 2, "r2": 4}, {"a1": 2, "a2": 3, "p1": "Walé-GZ", "p2": "KenkNod_GZ", "r1": 4, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "GMT_GZ", "r1": 4, "r2": 0}, {"a1": 0, "a2": 4, "p1": "Walé-GZ", "p2": "Rod_GZ", "r1": 1, "r2": 4}, {"a1": 1, "a2": 3, "p1": "Walé-GZ", "p2": "Pat", "r1": 2, "r2": 4}, {"a1": 1, "a2": 5, "p1": "IBR@93_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 7}, {"a1": 4, "a2": 0, "p1": "IBR@93_GZ", "p2": "Pat", "r1": 2, "r2": 3}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "Akab_GZ", "r1": 4, "r2": 1}, {"a1": 7, "a2": 0, "p1": "IBR@93_GZ", "p2": "Rod_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 4, "p1": "IBR@93_GZ", "p2": "The_One_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "CBlacks_GZ", "r1": 3, "r2": 1}, {"a1": 4, "a2": 1, "p1": "IBR@93_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 3}, {"a1": 3, "a2": 1, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 6}, {"a1": 4, "a2": 1, "p1": "IBR@93_GZ", "p2": "GMT_GZ", "r1": 6, "r2": 0}, {"a1": 3, "a2": 1, "p1": "IBR@93_GZ", "p2": "Matrix _GZ", "r1": 2, "r2": 1}, {"a1": 5, "a2": 1, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 1, "p1": "CBlacks_GZ", "p2": "Pat", "r1": 1, "r2": 0}, {"a1": 5, "a2": 0, "p1": "CBlacks_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 2, "p1": "CBlacks_GZ", "p2": "The_One_GZ", "r1": 6, "r2": 0}, {"a1": 2, "a2": 0, "p1": "CBlacks_GZ", "p2": "Akab_GZ", "r1": 3, "r2": 0}, {"a1": 3, "a2": 2, "p1": "CBlacks_GZ", "p2": "Matrix _GZ", "r1": 2, "r2": 1}, {"a1": 3, "a2": 0, "p1": "CBlacks_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 3}, {"a1": 0, "a2": 0, "p1": "CBlacks_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 3}, {"a1": 0, "a2": 0, "p1": "The_One_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 0}, {"a1": 2, "a2": 0, "p1": "The_One_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 2, "p1": "The_One_GZ", "p2": "Rod_GZ", "r1": 3, "r2": 6}, {"a1": 2, "a2": 2, "p1": "The_One_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 3}, {"a1": 1, "a2": 3, "p1": "The_One_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 4}, {"a1": 4, "a2": 2, "p1": "The_One_GZ", "p2": "Pat", "r1": 3, "r2": 4}, {"a1": 1, "a2": 1, "p1": "The_One_GZ", "p2": "Matrix _GZ", "r1": 0, "r2": 1}, {"a1": 4, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Pat", "r1": 3, "r2": 1}, {"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Rod_GZ", "r1": 4, "r2": 2}, {"a1": 3, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 1}, {"a1": 5, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "KenkNod_GZ", "r1": 7, "r2": 1}, {"a1": 4, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Matrix _GZ", "r1": 4, "r2": 1}, {"a1": 4, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 5, "r2": 0}, {"a1": 2, "a2": 0, "p1": "Matrix _GZ", "p2": "Pat", "r1": 1, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Matrix _GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 0, "p1": "Matrix _GZ", "p2": "GMT_GZ", "r1": 4, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Matrix _GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 2}, {"a1": 3, "a2": 1, "p1": "KenkNod_GZ", "p2": "GMT_GZ", "r1": 6, "r2": 1}, {"a1": 1, "a2": 1, "p1": "KenkNod_GZ", "p2": "Pat", "r1": 2, "r2": 3}, {"a1": 0, "a2": 1, "p1": "KenkNod_GZ", "p2": "Akab_GZ", "r1": 0, "r2": 1}, {"a1": 3, "a2": 0, "p1": "KenkNod_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Akab_GZ", "p2": "Pat", "r1": 1, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "Matrix _GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 5, "p1": "GMT_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 4}, {"a1": 2, "a2": 2, "p1": "GMT_GZ", "p2": "Pat", "r1": 1, "r2": 4}, {"a1": 2, "a2": 0, "p1": "GMT_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 2, "p1": "Rius_oyo_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 0}, {"a1": 2, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Pat", "r1": 4, "r2": 1}, {"a1": 1, "a2": 3, "p1": "Rod_GZ", "p2": "Pat", "r1": 0, "r2": 3}, {"a1": 6, "a2": 5, "p1": "Walé-GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 0}, {"a1": 4, "a2": 2, "p1": "CBlacks_GZ", "p2": "Rod_GZ", "r1": 3, "r2": 0}, {"a1": 0, "a2": 1, "p1": "Rod_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 2}, {"a1": 3, "a2": 0, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 3}, {"a1": 1, "a2": 5, "p1": "GMT_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 3}, {"a1": 0, "a2": 2, "p1": "Matrix _GZ", "p2": "Rod_GZ", "r1": 6, "r2": 1}, {"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "The_One_GZ", "r1": 3, "r2": 0}, {"a1": 1, "a2": 1, "p1": "KenkNod_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 1}], "d2": [], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "", "label": "—", "notes": ""}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "—", "team": ""}}}	2025-10-13 13:10:08.238484+00
2025-10-18	2	{"d1": [{"a1": 1, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Kem_GZ", "r1": 2, "r2": 0}, {"a1": 4, "a2": 3, "p1": "Rius_oyo_GZ", "p2": "AminouFlash", "r1": 3, "r2": 1}, {"a1": 2, "a2": 3, "p1": "Rius_oyo_GZ", "p2": "CBlacks_GZ", "r1": 0, "r2": 1}, {"a1": 3, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "Rius_oyo_GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 4}, {"a1": 0, "a2": 6, "p1": "Rius_oyo_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 4}, {"a1": 2, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Pat", "r1": 1, "r2": 3}, {"a1": 1, "a2": 4, "p1": "Yousscash_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Yousscash_GZ", "p2": "AminouFlash", "r1": 4, "r2": 2}, {"a1": 0, "a2": 1, "p1": "Yousscash_GZ", "p2": "CBlacks_GZ", "r1": 0, "r2": 3}, {"a1": 0, "a2": 3, "p1": "Yousscash_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 3}, {"a1": 2, "a2": 0, "p1": "Yousscash_GZ", "p2": "Kem_GZ", "r1": 4, "r2": 5}, {"a1": 1, "a2": 0, "p1": "Yousscash_GZ", "p2": "Pat", "r1": 5, "r2": 2}, {"a1": 3, "a2": 0, "p1": "CBlacks_GZ", "p2": "AminouFlash", "r1": 2, "r2": 2}, {"a1": 1, "a2": 1, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 2}, {"a1": 1, "a2": 2, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 0}, {"a1": 2, "a2": 1, "p1": "CBlacks_GZ", "p2": "Pat", "r1": 5, "r2": 1}, {"a1": 3, "a2": 0, "p1": "CBlacks_GZ", "p2": "Kem_GZ", "r1": 3, "r2": 0}, {"a1": 0, "a2": 3, "p1": "Kem_GZ", "p2": "Pat", "r1": 1, "r2": 2}, {"a1": 0, "a2": 6, "p1": "Kem_GZ", "p2": "AminouFlash", "r1": 2, "r2": 1}, {"a1": 0, "a2": 5, "p1": "Kem_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 4}, {"a1": 1, "a2": 2, "p1": "Kem_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 4}, {"a1": 2, "a2": 3, "p1": "IBR@93_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 6}, {"a1": 1, "a2": 0, "p1": "IBR@93_GZ", "p2": "Pat", "r1": 2, "r2": 0}, {"a1": 2, "a2": 5, "p1": "IBR@93_GZ", "p2": "AminouFlash", "r1": 4, "r2": 2}, {"a1": 4, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Pat", "r1": 3, "r2": 0}, {"a1": 3, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "AminouFlash", "r1": 2, "r2": 1}, {"a1": 1, "a2": 1, "p1": "AminouFlash", "p2": "Pat", "r1": 0, "r2": 3}], "d2": [{"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 4}, {"a1": 3, "a2": 0, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 2, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 3}, {"a1": 0, "a2": 2, "p1": "KenkNod_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 0}, {"a1": 4, "a2": 5, "p1": "KenkNod_GZ", "p2": "Walé-GZ", "r1": 5, "r2": 1}, {"a1": 3, "a2": 0, "p1": "KenkNod_GZ", "p2": "GMT_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 3, "p1": "GMT_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 3, "p1": "GMT_GZ", "p2": "Rod_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 2}], "barrage": {"m1": {"A": 0, "B": 3}, "m2": {"A": 0, "B": 3}, "m3": {}, "ids": "Rius_oyo_GZ – KenkNod_GZ", "label": "KenkNod_GZ monte en D1 · Rius_oyo_GZ est relégué en D2", "notes": ""}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Walé-GZ", "team": "FRANCE"}}}	2025-10-18 22:40:05.905336+00
2025-10-25	2	{"d1": [{"a1": 4, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 0}, {"a1": 0, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Yousscash_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 4, "r2": 4}, {"a1": 3, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "CBlacks_GZ", "r1": 2, "r2": 4}, {"a1": 2, "a2": 2, "p1": "IBR@93_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 0}, {"a1": 3, "a2": 1, "p1": "IBR@93_GZ", "p2": "CBlacks_GZ", "r1": 1, "r2": 1}, {"a1": 0, "a2": 0, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Yousscash_GZ", "p2": "CBlacks_GZ", "r1": 3, "r2": 1}, {"a1": 3, "a2": 1, "p1": "Yousscash_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Walé-GZ", "p2": "CBlacks_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 1, "p1": "KenkNod_GZ", "p2": "CBlacks_GZ", "r1": 2, "r2": 7}, {"a1": 2, "a2": 9, "p1": "KenkNod_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 9}, {"a1": 4, "a2": 5, "p1": "KenkNod_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 5, "p1": "KenkNod_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 2}, {"a1": 2, "a2": 2, "p1": "KenkNod_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 2}], "d2": [{"a1": 1, "a2": 4, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 0}, {"a1": 2, "a2": 3, "p1": "Akab_GZ", "p2": "Matrix _GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 3, "r2": 1}, {"a1": 3, "a2": 2, "p1": "Akab_GZ", "p2": "Kem_GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Matrix _GZ", "p2": "Kem_GZ", "r1": 0, "r2": 0}, {"a1": 2, "a2": 2, "p1": "Matrix _GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 3, "p1": "Matrix _GZ", "p2": "GMT_GZ", "r1": 5, "r2": 0}, {"a1": 0, "a2": 5, "p1": "GMT_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 4}, {"a1": 1, "a2": 2, "p1": "GMT_GZ", "p2": "Kem_GZ", "r1": 2, "r2": 2}, {"a1": 7, "a2": 2, "p1": "Rius_oyo_GZ", "p2": "Kem_GZ", "r1": 0, "r2": 0}], "barrage": {"m1": {"A": 6, "B": 3}, "m2": {"A": 3, "B": 1}, "m3": {}, "ids": "Walé_GZ – Matrix _GZ", "label": "Walé_GZ se maintient en D1 · Matrix _GZ reste en D2", "notes": ""}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Rius_oyo_GZ", "team": "FRANCE"}}}	2025-10-27 09:35:00.141537+00
2025-11-01	2	{"d1": [{"a1": 2, "a2": 4, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 3}, {"a1": 3, "a2": 2, "p1": "IBR@93_GZ", "p2": "Walé-GZ", "r1": 4, "r2": 1}, {"a1": 1, "a2": 2, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 2}, {"a1": 4, "a2": 2, "p1": "IBR@93_GZ", "p2": "CBlacks_GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 2, "p1": "IBR@93_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 2, "p1": "Walé-GZ", "p2": "CBlacks_GZ", "r1": 0, "r2": 2}, {"a1": 1, "a2": 2, "p1": "Walé-GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 4}, {"a1": 1, "a2": 2, "p1": "Walé-GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 2, "p1": "Yousscash_GZ", "p2": "CBlacks_GZ", "r1": 0, "r2": 2}, {"a1": 0, "a2": 1, "p1": "Yousscash_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 0}, {"a1": 4, "a2": 2, "p1": "Yousscash_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 0}, {"a1": 0, "a2": 3, "p1": "EmRiCxX_GZ", "p2": "CBlacks_GZ", "r1": 2, "r2": 4}, {"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 6, "r2": 5}, {"a1": 4, "a2": 3, "p1": "Rius_oyo_GZ", "p2": "CBlacks_GZ", "r1": 4, "r2": 2}], "d2": [{"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 4, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 3, "p1": "Akab_GZ", "p2": "Pat", "r1": 3, "r2": 3}, {"a1": 3, "a2": 5, "p1": "Akab_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 0}, {"a1": 3, "a2": 1, "p1": "Akab_GZ", "p2": "Kem_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 2, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 5, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Akab_GZ", "p2": "The_One_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 2, "p1": "Kem_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 0, "p1": "Kem_GZ", "p2": "The_One_GZ", "r1": 0, "r2": 1}, {"a1": 3, "a2": 4, "p1": "Kem_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Kem_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 1}, {"a1": 3, "a2": 2, "p1": "Kem_GZ", "p2": "Pat", "r1": 3, "r2": 2}, {"a1": 4, "a2": 4, "p1": "Kem_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 3}, {"a1": 4, "a2": 2, "p1": "GMT_GZ", "p2": "The_One_GZ", "r1": 2, "r2": 2}, {"a1": 1, "a2": 2, "p1": "GMT_GZ", "p2": "Pat", "r1": 0, "r2": 3}, {"a1": 2, "a2": 1, "p1": "GMT_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 2}, {"a1": 2, "a2": 3, "p1": "GMT_GZ", "p2": "Zyex_Legend_GZ", "r1": 0, "r2": 2}, {"a1": 3, "a2": 0, "p1": "GMT_GZ", "p2": "Rod_GZ", "r1": 2, "r2": 3}, {"a1": 0, "a2": 1, "p1": "The_One_GZ", "p2": "Pat", "r1": 0, "r2": 5}, {"a1": 1, "a2": 1, "p1": "The_One_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 1}, {"a1": 0, "a2": 1, "p1": "The_One_GZ", "p2": "KenkNod_GZ", "r1": 0, "r2": 5}, {"a1": 1, "a2": 2, "p1": "The_One_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 4, "p1": "Rod_GZ", "p2": "Pat", "r1": 1, "r2": 3}, {"a1": 3, "a2": 2, "p1": "Rod_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Rod_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 4}, {"a1": 2, "a2": 3, "p1": "Zyex_Legend_GZ", "p2": "Pat", "r1": 2, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "KenkNod_GZ", "r1": 4, "r2": 3}, {"a1": 2, "a2": 2, "p1": "KenkNod_GZ", "p2": "Pat", "r1": 1, "r2": 5}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "IBR@93_GZ – Rod_GZ", "label": "🏆 IBR@93_GZ se maintient en D1 · Rod_GZ reste en D2", "notes": "", "winner": "IBR@93_GZ"}, "champions": {"d1": {"id": "CBlacks_GZ", "team": "MADRID"}, "d2": {"id": "Zyex_Legend_GZ", "team": "FRANCE"}}}	2025-11-01 22:25:52.698877+00
2025-11-08	2	{"d1": [{"a1": 1, "a2": 3, "p1": "Yousscash_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 3, "p1": "Yousscash_GZ", "p2": "CBlacks_GZ", "r1": 5, "r2": 0}, {"a1": 2, "a2": 3, "p1": "Yousscash_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 0}, {"a1": 2, "a2": 2, "p1": "Yousscash_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 2}, {"a1": 3, "a2": 2, "p1": "Yousscash_GZ", "p2": "Zyex_Legend_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 1, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 4}, {"a1": 7, "a2": 3, "p1": "CBlacks_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 5}, {"a1": 0, "a2": 2, "p1": "CBlacks_GZ", "p2": "Zyex_Legend_GZ", "r1": 4, "r2": 0}, {"a1": 5, "a2": 2, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 2}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 2, "p1": "Rius_oyo_GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 3}, {"a1": 4, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "CBlacks_GZ", "r1": 3, "r2": 1}, {"a1": 5, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 2}, {"a1": 3, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 6, "r2": 1}, {"a1": 4, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 1}], "d2": [{"a1": 0, "a2": 0, "p1": "Akab_GZ", "p2": "Kem_GZ", "r1": 1, "r2": 0}, {"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 0}, {"a1": 2, "a2": 4, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 0, "r2": 2}, {"a1": 0, "a2": 2, "p1": "Akab_GZ", "p2": "Ismo", "r1": 0, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 1}, {"a1": 3, "a2": 2, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 1}, {"a1": 3, "a2": 0, "p1": "Kem_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 0}, {"a1": 5, "a2": 6, "p1": "Kem_GZ", "p2": "Walé-GZ", "r1": 8, "r2": 2}, {"a1": 1, "a2": 2, "p1": "Kem_GZ", "p2": "Ismo", "r1": 4, "r2": 2}, {"a1": 2, "a2": 0, "p1": "Kem_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 3}, {"a1": 1, "a2": 1, "p1": "Kem_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 1}, {"a1": 8, "a2": 2, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 5}, {"a1": 3, "a2": 0, "p1": "Rod_GZ", "p2": "Ismo", "r1": 2, "r2": 2}, {"a1": 0, "a2": 3, "p1": "Rod_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 2}, {"a1": 3, "a2": 0, "p1": "Rod_GZ", "p2": "GMT_GZ", "r1": 3, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Walé-GZ", "p2": "Ismo", "r1": 1, "r2": 6}, {"a1": 1, "a2": 4, "p1": "Walé-GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 1}, {"a1": 2, "a2": 4, "p1": "Ismo", "p2": "KenkNod_GZ", "r1": 2, "r2": 1}, {"a1": 1, "a2": 1, "p1": "Ismo", "p2": "GMT_GZ", "r1": 4, "r2": 1}, {"a1": 6, "a2": 2, "p1": "KenkNod_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 1}, {"a1": 3, "a2": 2, "p1": "GMT_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 1}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "CBlacks_GZ – Kem_GZ", "label": "🏆 CBlacks_GZ se maintient en D1 · Kem_GZ reste en D2", "notes": "", "winner": "CBlacks_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "KenkNod_GZ", "team": "FRANCE"}}}	2025-11-08 21:13:22.358346+00
2025-11-15	2	{"d1": [{"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "KenkNod_GZ", "r1": 4, "r2": 1}, {"a1": 1, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "IBR@93_GZ", "r1": 3, "r2": 5}, {"a1": 0, "a2": 0, "p1": "CBlacks_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 0}, {"a1": 3, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Zyex_Legend_GZ", "r1": 3, "r2": 0}, {"a1": 0, "a2": 0, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 1, "p1": "KenkNod_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 1}, {"a1": 4, "a2": 0, "p1": "CBlacks_GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 2, "p1": "IBR@93_GZ", "p2": "EmRiCxX_GZ", "r1": 3, "r2": 4}, {"a1": 4, "a2": 4, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 2}], "d2": [{"a1": 2, "a2": 1, "p1": "Akab_GZ", "p2": "Ismo", "r1": 2, "r2": 3}, {"a1": 4, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 0}, {"a1": 3, "a2": 1, "p1": "Kem_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 4, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 0, "r2": 3}, {"a1": 3, "a2": 1, "p1": "Ismo", "p2": "GMT_GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Kem_GZ", "r1": 5, "r2": 0}, {"a1": 2, "a2": 1, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 3, "r2": 3}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "Kem_GZ", "r1": 2, "r2": 6}, {"a1": 4, "a2": 1, "p1": "Ismo", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 1}, {"a1": 3, "a2": 0, "p1": "Akab_GZ", "p2": "Kem_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 4, "p1": "GMT_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 5}, {"a1": 1, "a2": 0, "p1": "Walé-GZ", "p2": "Ismo", "r1": 2, "r2": 2}, {"a1": 4, "a2": 4, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 2, "p1": "Kem_GZ", "p2": "Ismo", "r1": 3, "r2": 3}, {"a1": 1, "a2": 2, "p1": "GMT_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 7}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "IBR@93_GZ – Walé-GZ", "label": "🏆 IBR@93_GZ se maintient en D1 · Walé reste en D2", "notes": "", "winner": "IBR@93_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Rius_oyo_GZ", "team": "MADRID"}}}	2025-11-15 20:46:59.058976+00
2025-11-22	2	{"d1": [{"a1": 5, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 3, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 2, "p1": "CBlacks_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 3, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 3, "p1": "CBlacks_GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 4}, {"a1": 0, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 4}, {"a1": 2, "a2": 0, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 0}, {"a1": 3, "a2": 0, "p1": "Yousscash_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 3, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 4}, {"a1": 2, "a2": 1, "p1": "Yousscash_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 1}], "d2": [{"a1": 2, "a2": 2, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 3, "r2": 0}, {"a1": 0, "a2": 5, "p1": "Walé-GZ", "p2": "God's", "r1": 0, "r2": 4}, {"a1": 1, "a2": 4, "p1": "Kem_GZ", "p2": "Ismo", "r1": 2, "r2": 2}, {"a1": 0, "a2": 2, "p1": "Akab_GZ", "p2": "God's", "r1": 1, "r2": 2}, {"a1": 0, "a2": 3, "p1": "GMT_GZ", "p2": "Ismo", "r1": 0, "r2": 1}, {"a1": 1, "a2": 2, "p1": "Walé-GZ", "p2": "Kem_GZ", "r1": 0, "r2": 4}, {"a1": 3, "a2": 2, "p1": "Akab_GZ", "p2": "Ismo", "r1": 1, "r2": 1}, {"a1": 2, "a2": 2, "p1": "God's", "p2": "Kem_GZ", "r1": 6, "r2": 1}, {"a1": 0, "a2": 3, "p1": "GMT_GZ", "p2": "Walé-GZ", "r1": 0, "r2": 2}, {"a1": 1, "a2": 2, "p1": "Akab_GZ", "p2": "Kem_GZ", "r1": 3, "r2": 0}, {"a1": 3, "a2": 1, "p1": "Ismo", "p2": "Walé-GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 1, "p1": "God's", "p2": "GMT_GZ", "r1": 1, "r2": 0}, {"a1": 2, "a2": 0, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 2}, {"a1": 3, "a2": 0, "p1": "Kem_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 0, "p1": "Ismo", "p2": "God's", "r1": 3, "r2": 0}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "CBlacks_GZ – Kem_GZ", "label": "🏆 CBlacks_GZ se maintient en D1 · Kem_GZ reste en D2", "notes": "", "winner": "CBlacks_GZ"}, "champions": {"d1": {"id": "Yousscash_GZ", "team": "MADRID"}, "d2": {"id": "Akab_GZ", "team": "MADRID"}}}	2025-11-22 20:51:11.732341+00
2025-11-29	2	{"d1": [{"a1": 4, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "God's", "r1": 5, "r2": 3}, {"a1": 1, "a2": 0, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 1}, {"a1": 4, "a2": 2, "p1": "CBlacks_GZ", "p2": "God's", "r1": 2, "r2": 3}, {"a1": 4, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 2}, {"a1": 0, "a2": 1, "p1": "CBlacks_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 4}, {"a1": 2, "a2": 0, "p1": "God's", "p2": "IBR@93_GZ", "r1": 3, "r2": 4}, {"a1": 2, "a2": 3, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 2}, {"a1": 3, "a2": 1, "p1": "Yousscash_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 0}, {"a1": 1, "a2": 2, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 0}, {"a1": 2, "a2": 3, "p1": "Yousscash_GZ", "p2": "God's", "r1": 0, "r2": 0}], "d2": [{"a1": 0, "a2": 3, "p1": "Rod_GZ", "p2": "Ismo", "r1": 3, "r2": 1}, {"a1": 4, "a2": 1, "p1": "Walé-GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 1, "p1": "GMT_GZ", "p2": "Matrix _GZ", "r1": 0, "r2": 3}, {"a1": 2, "a2": 1, "p1": "Rod_GZ", "p2": "Rius_oyo_GZ", "r1": 4, "r2": 8}, {"a1": 3, "a2": 1, "p1": "Ismo", "p2": "Matrix _GZ", "r1": 2, "r2": 3}, {"a1": 2, "a2": 0, "p1": "Walé-GZ", "p2": "GMT_GZ", "r1": 0, "r2": 2}, {"a1": 0, "a2": 0, "p1": "Rod_GZ", "p2": "Matrix _GZ", "r1": 3, "r2": 0}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 3}, {"a1": 1, "a2": 2, "p1": "Ismo", "p2": "Walé-GZ", "r1": 5, "r2": 2}, {"a1": 1, "a2": 4, "p1": "Rod_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 0}, {"a1": 3, "a2": 1, "p1": "Matrix _GZ", "p2": "Walé-GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Ismo", "r1": 2, "r2": 5}, {"a1": 2, "a2": 0, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 4}, {"a1": 1, "a2": 1, "p1": "GMT_GZ", "p2": "Ismo", "r1": 0, "r2": 3}, {"a1": 3, "a2": 2, "p1": "Matrix _GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 4}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "EmRiCxX_GZ – Rod_GZ", "label": "🏆 EmRiCxX_GZ se maintient en D1 · Rod_GZ reste en D2", "notes": "", "winner": "EmRiCxX_GZ"}, "champions": {"d1": {"id": "Yousscash_GZ", "team": "MADRID"}, "d2": {"id": "Walé-GZ", "team": "MADRID"}}}	2025-11-29 20:39:54.314311+00
2025-12-06	2	{"d1": [{"a1": 5, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 6, "r2": 2}, {"a1": 0, "a2": 2, "p1": "Akab_GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 2, "p1": "Walé-GZ", "p2": "Ismo", "r1": 1, "r2": 2}, {"a1": 3, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 1}, {"a1": 3, "a2": 0, "p1": "IBR@93_GZ", "p2": "Ismo", "r1": 2, "r2": 3}, {"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 3}, {"a1": 4, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Ismo", "r1": 2, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Yousscash_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 0}, {"a1": 4, "a2": 1, "p1": "IBR@93_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Walé-GZ", "r1": 4, "r2": 3}, {"a1": 1, "a2": 1, "p1": "Ismo", "p2": "Akab_GZ", "r1": 4, "r2": 1}, {"a1": 5, "a2": 1, "p1": "Yousscash_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 2}, {"a1": 5, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Akab_GZ", "r1": 3, "r2": 2}, {"a1": 2, "a2": 5, "p1": "Walé-GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 3}, {"a1": 3, "a2": 3, "p1": "Ismo", "p2": "Yousscash_GZ", "r1": 0, "r2": 1}], "d2": [{"a1": 1, "a2": 3, "p1": "Matrix _GZ", "p2": "God's", "r1": 1, "r2": 2}, {"a1": 1, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 0}, {"a1": 0, "a2": 1, "p1": "GMT_GZ", "p2": "God's", "r1": 0, "r2": 4}, {"a1": 5, "a2": 3, "p1": "Matrix _GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 1, "p1": "GMT_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 1, "p1": "God's", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 3, "p1": "GMT_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 3}, {"a1": 2, "a2": 0, "p1": "Rod_GZ", "p2": "Matrix _GZ", "r1": 1, "r2": 3}, {"a1": 1, "a2": 2, "p1": "GMT_GZ", "p2": "Matrix _GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 1, "p1": "Rod_GZ", "p2": "God's", "r1": 2, "r2": 1}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "Akab_GZ – Rod_GZ", "label": "🏆 Akab_GZ se maintient en D1 · Rod_GZ reste en D2", "notes": "", "winner": "Akab_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Rius_oyo_GZ", "team": "FRANCE"}}}	2026-01-03 18:43:04.843183+00
2026-01-03	2	{"d1": [{"a1": 1, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Yousscash_GZ", "r1": 3, "r2": 3}, {"a1": 0, "a2": 2, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 4}, {"a1": 5, "a2": 2, "p1": "IBR@93_GZ", "p2": "Ismo", "r1": 1, "r2": 5}, {"a1": 3, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 2}, {"a1": 4, "a2": 2, "p1": "Yousscash_GZ", "p2": "Ismo", "r1": 2, "r2": 2}, {"a1": 1, "a2": 4, "p1": "Akab_GZ", "p2": "IBR@93_GZ", "r1": 4, "r2": 4}, {"a1": 2, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "Ismo", "r1": 3, "r2": 4}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 0, "p1": "Yousscash_GZ", "p2": "Akab_GZ", "r1": 2, "r2": 2}, {"a1": 4, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 3, "r2": 0}, {"a1": 1, "a2": 1, "p1": "Ismo", "p2": "Akab_GZ", "r1": 5, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Yousscash_GZ", "r1": 2, "r2": 3}, {"a1": 4, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "Akab_GZ", "r1": 3, "r2": 1}, {"a1": 3, "a2": 0, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 1}, {"a1": 3, "a2": 3, "p1": "Ismo", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 1}], "d2": [{"a1": 2, "a2": 0, "p1": "CBlacks_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 3}, {"a1": 2, "a2": 2, "p1": "AKA BIG", "p2": "Kem_GZ", "r1": 2, "r2": 0}, {"a1": 4, "a2": 1, "p1": "CBlacks_GZ", "p2": "Kem_GZ", "r1": 3, "r2": 1}, {"a1": 0, "a2": 2, "p1": "Rod_GZ", "p2": "AKA BIG", "r1": 0, "r2": 1}, {"a1": 0, "a2": 1, "p1": "CBlacks_GZ", "p2": "AKA BIG", "r1": 0, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Kem_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 1}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "IBR@93_GZ – Kem_GZ", "label": "Affiche : IBR@93_GZ – Kem_GZ", "notes": "", "winner": null}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "CBlacks_GZ", "team": "MAN CI"}}}	2026-01-03 19:37:28.220907+00
2026-01-10	2	{"d1": [{"a1": 1, "a2": 5, "p1": "IBR@93_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Ismo", "r1": 2, "r2": 2}, {"a1": 3, "a2": 0, "p1": "Yousscash_GZ", "p2": "AKA BIG", "r1": 0, "r2": 1}, {"a1": 4, "a2": 4, "p1": "IBR@93_GZ", "p2": "Ismo", "r1": 4, "r2": 2}, {"a1": 4, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "AKA BIG", "r1": 4, "r2": 2}, {"a1": 3, "a2": 3, "p1": "Rius_oyo_GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 3, "p1": "IBR@93_GZ", "p2": "AKA BIG", "r1": 1, "r2": 2}, {"a1": 3, "a2": 0, "p1": "Ismo", "p2": "Yousscash_GZ", "r1": 1, "r2": 2}, {"a1": 3, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 1}, {"a1": 5, "a2": 3, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": 2, "r2": 2}, {"a1": 2, "a2": 2, "p1": "AKA BIG", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 3, "p1": "Ismo", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 2}, {"a1": 2, "a2": 5, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Yousscash_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 0, "p1": "AKA BIG", "p2": "Ismo", "r1": 0, "r2": 0}], "d2": [{"a1": 1, "a2": 1, "p1": "Walé-GZ", "p2": "Matrix _GZ", "r1": 4, "r2": 0}, {"a1": 1, "a2": 1, "p1": "Rod_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 3}, {"a1": 3, "a2": 3, "p1": "Zyex_Legend_GZ", "p2": "Matrix _GZ", "r1": 2, "r2": 0}, {"a1": 2, "a2": 1, "p1": "Walé-GZ", "p2": "Rod_GZ", "r1": 3, "r2": 4}, {"a1": 0, "a2": 0, "p1": "Zyex_Legend_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 3, "p1": "Matrix _GZ", "p2": "Rod_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 0, "p1": "Zyex_Legend_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 2}, {"a1": 6, "a2": 2, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 2}, {"a1": 3, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 1}, {"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "Matrix _GZ", "r1": 3, "r2": 2}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "IBR@93_GZ – Zyex_Legend_GZ", "label": "🏆 IBR@93_GZ se maintient en D1 · Zyex_Legend_GZ reste en D2", "notes": "", "winner": "IBR@93_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Akab_GZ", "team": "FRANCE"}}}	2026-01-21 12:41:42.835928+00
2026-01-17	2	{"d1": [{"a1": null, "a2": null, "p1": "KenkNod_GZ", "p2": "Walé-GZ", "r1": null, "r2": null}, {"a1": 0, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 1}, {"a1": null, "a2": null, "p1": "Matrix _GZ", "p2": "Rod_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Akab_GZ", "p2": "Ismo", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Yousscash_GZ", "p2": "The_One_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "CBlacks_GZ", "p2": "Walé-GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "KenkNod_GZ", "p2": "Rod_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "EmRiCxX_GZ", "p2": "Ismo", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Matrix _GZ", "p2": "The_One_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Akab_GZ", "p2": "Yousscash_GZ", "r1": null, "r2": null}, {"a1": 1, "a2": 0, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Walé-GZ", "p2": "Rod_GZ", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "KenkNod_GZ", "p2": "The_One_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "EmRiCxX_GZ", "p2": "Yousscash_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Matrix _GZ", "p2": "Akab_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "CBlacks_GZ", "p2": "Rod_GZ", "r1": null, "r2": null}, {"a1": 1, "a2": 0, "p1": "IBR@93_GZ", "p2": "Ismo", "r1": 0, "r2": 0}, {"a1": 1, "a2": 0, "p1": "Walé-GZ", "p2": "The_One_GZ", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "KenkNod_GZ", "p2": "Akab_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "EmRiCxX_GZ", "p2": "Matrix _GZ", "r1": null, "r2": null}, {"a1": 1, "a2": 0, "p1": "CBlacks_GZ", "p2": "Ismo", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "Rod_GZ", "p2": "The_One_GZ", "r1": null, "r2": null}, {"a1": 1, "a2": 0, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Walé-GZ", "p2": "Akab_GZ", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "KenkNod_GZ", "p2": "EmRiCxX_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "CBlacks_GZ", "p2": "The_One_GZ", "r1": null, "r2": null}, {"a1": 0, "a2": 0, "p1": "Ismo", "p2": "Yousscash_GZ", "r1": 0, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Rod_GZ", "p2": "Akab_GZ", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "IBR@93_GZ", "p2": "Matrix _GZ", "r1": null, "r2": null}, {"a1": 0, "a2": 1, "p1": "Walé-GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 1, "p1": "CBlacks_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 0}, {"a1": 0, "a2": 1, "p1": "The_One_GZ", "p2": "Akab_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 0, "p1": "Ismo", "p2": "Matrix _GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 1, "p1": "Rod_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 0, "p1": "IBR@93_GZ", "p2": "KenkNod_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 0, "p1": "CBlacks_GZ", "p2": "Akab_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 0, "p1": "Yousscash_GZ", "p2": "Matrix _GZ", "r1": 0, "r2": 0}, {"a1": 0, "a2": 0, "p1": "The_One_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Ismo", "p2": "KenkNod_GZ", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "IBR@93_GZ", "p2": "Walé-GZ", "r1": null, "r2": null}, {"a1": 1, "a2": 0, "p1": "CBlacks_GZ", "p2": "Matrix _GZ", "r1": 0, "r2": 0}, {"a1": 0, "a2": 0, "p1": "Akab_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Yousscash_GZ", "p2": "KenkNod_GZ", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "Ismo", "p2": "Walé-GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Rod_GZ", "p2": "IBR@93_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": null, "r2": null}, {"a1": 0, "a2": 0, "p1": "Matrix _GZ", "p2": "KenkNod_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 0, "p1": "Yousscash_GZ", "p2": "Walé-GZ", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "The_One_GZ", "p2": "IBR@93_GZ", "r1": null, "r2": null}, {"a1": 1, "a2": 0, "p1": "Ismo", "p2": "Rod_GZ", "r1": 0, "r2": 0}, {"a1": null, "a2": null, "p1": "CBlacks_GZ", "p2": "KenkNod_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Matrix _GZ", "p2": "Walé-GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Akab_GZ", "p2": "IBR@93_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Yousscash_GZ", "p2": "Rod_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "The_One_GZ", "p2": "Ismo", "r1": null, "r2": null}], "d2": [], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "", "label": "—", "notes": "", "winner": null}, "champions": {"d1": {"id": "Yousscash_GZ", "team": "MADRID"}, "d2": {"id": "—", "team": ""}}}	2026-01-21 15:28:01.974927+00
2025-12-27	2	{"d1": [{"a1": 1, "a2": 0, "p1": "Yousscash_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 1, "p1": "Ismo", "p2": "IBR@93_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 0, "p1": "CBlacks_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 1, "p1": "Rod_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 0, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 1, "p1": "Walé-GZ", "p2": "Akab_GZ", "r1": 0, "r2": 0}, {"a1": 0, "a2": 1, "p1": "Rod_GZ", "p2": "EmRiCxX_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 1, "p1": "Yousscash_GZ", "p2": "Ismo", "r1": 1, "r2": 1}, {"a1": 1, "a2": 0, "p1": "CBlacks_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 0}, {"a1": null, "a2": null, "p1": "IBR@93_GZ", "p2": "EmRiCxX_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Walé-GZ", "p2": "Ismo", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Rod_GZ", "p2": "Yousscash_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Akab_GZ", "p2": "Ismo", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Walé-GZ", "p2": "Rod_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "CBlacks_GZ", "p2": "Ismo", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "EmRiCxX_GZ", "p2": "Yousscash_GZ", "r1": null, "r2": null}, {"a1": 1, "a2": 0, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 0}, {"a1": null, "a2": null, "p1": "IBR@93_GZ", "p2": "Walé-GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "CBlacks_GZ", "p2": "Yousscash_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Ismo", "p2": "Rod_GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "EmRiCxX_GZ", "p2": "Walé-GZ", "r1": null, "r2": null}, {"a1": null, "a2": null, "p1": "Akab_GZ", "p2": "IBR@93_GZ", "r1": null, "r2": null}], "d2": [], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "IBR@93_GZ – Zyex_Legend_GZ", "label": "Affiche : IBR@93_GZ – Zyex_Legend_GZ", "notes": "", "winner": null}, "champions": {"d1": {"id": "CBlacks_GZ", "team": "FRANCE"}, "d2": {"id": "—", "team": ""}}}	2026-01-03 19:17:56.120629+00
2026-01-24	2	{"d1": [{"a1": 0, "a2": 2, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Akab_GZ", "r1": 3, "r2": 0}, {"a1": 3, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Kem_GZ", "r1": 3, "r2": 2}, {"a1": 2, "a2": 1, "p1": "CBlacks_GZ", "p2": "Akab_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "Kem_GZ", "r1": 6, "r2": 0}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 3}, {"a1": 5, "a2": 1, "p1": "CBlacks_GZ", "p2": "Kem_GZ", "r1": 4, "r2": 2}, {"a1": 1, "a2": 3, "p1": "Akab_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 4}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 3}, {"a1": 0, "a2": 1, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 4}, {"a1": 0, "a2": 1, "p1": "Kem_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 5}, {"a1": 2, "a2": 2, "p1": "Akab_GZ", "p2": "IBR@93_GZ", "r1": 3, "r2": 3}, {"a1": 1, "a2": 5, "p1": "CBlacks_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 0}, {"a1": 2, "a2": 1, "p1": "Kem_GZ", "p2": "Akab_GZ", "r1": 0, "r2": 3}], "d2": [{"a1": 3, "a2": 2, "p1": "Yousscash_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 2, "p1": "Walé-GZ", "p2": "God's", "r1": 1, "r2": 5}, {"a1": 1, "a2": 1, "p1": "Matrix _GZ", "p2": "Ousmane", "r1": 1, "r2": 3}, {"a1": 2, "a2": 0, "p1": "Yousscash_GZ", "p2": "God's", "r1": 0, "r2": 2}, {"a1": 4, "a2": 1, "p1": "KenkNod_GZ", "p2": "Ousmane", "r1": 1, "r2": 3}, {"a1": 2, "a2": 2, "p1": "Walé-GZ", "p2": "Matrix _GZ", "r1": 2, "r2": 2}, {"a1": 3, "a2": 2, "p1": "Yousscash_GZ", "p2": "Ousmane", "r1": 1, "r2": 0}, {"a1": 2, "a2": 1, "p1": "God's", "p2": "Matrix _GZ", "r1": 1, "r2": 1}, {"a1": 4, "a2": 2, "p1": "KenkNod_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 0, "p1": "Yousscash_GZ", "p2": "Matrix _GZ", "r1": 3, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Ousmane", "p2": "Walé-GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 2, "p1": "God's", "p2": "KenkNod_GZ", "r1": 4, "r2": 1}, {"a1": 4, "a2": 3, "p1": "Yousscash_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 1}, {"a1": 3, "a2": 2, "p1": "Matrix _GZ", "p2": "KenkNod_GZ", "r1": 5, "r2": 3}, {"a1": 0, "a2": 0, "p1": "Ousmane", "p2": "God's", "r1": 4, "r2": 3}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "Akab_GZ – KenkNod_GZ", "label": "🏆 Akab_GZ se maintient en D1 · KenkNod_GZ reste en D2", "notes": "", "winner": "Akab_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Yousscash_GZ", "team": "FRANCE"}}}	2026-01-24 20:47:05.879485+00
2026-01-31	2	{"d1": [{"a1": 3, "a2": 3, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 0}, {"a1": 5, "a2": 2, "p1": "CBlacks_GZ", "p2": "Rius_oyo_GZ", "r1": 4, "r2": 1}, {"a1": 6, "a2": 3, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 6, "r2": 1}, {"a1": 1, "a2": 1, "p1": "CBlacks_GZ", "p2": "Akab_GZ", "r1": 4, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 1}, {"a1": 3, "a2": 1, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 4, "p1": "Akab_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 3}, {"a1": 2, "a2": 3, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 1}, {"a1": 1, "a2": 2, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 1, "r2": 3}], "d2": [{"a1": 2, "a2": 1, "p1": "Ismo", "p2": "Rod_GZ", "r1": 5, "r2": 1}, {"a1": 0, "a2": 1, "p1": "KenkNod_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 0}, {"a1": 1, "a2": 0, "p1": "Ismo", "p2": "Walé-GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Rod_GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Ismo", "p2": "KenkNod_GZ", "r1": 0, "r2": 1}, {"a1": 1, "a2": 0, "p1": "Walé-GZ", "p2": "Rod_GZ", "r1": 2, "r2": 1}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "IBR@93_GZ – KenkNod_GZ", "label": "🏆 IBR@93_GZ se maintient en D1 · KenkNod_GZ reste en D2", "notes": "", "winner": "IBR@93_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Walé-GZ", "team": "MADRID"}}}	2026-01-31 18:49:44.284073+00
2026-02-07	2	{"d1": [{"a1": 2, "a2": 3, "p1": "AKA BIG", "p2": "EmRiCxX_GZ", "r1": 3, "r2": 2}, {"a1": 1, "a2": 6, "p1": "AKA BIG", "p2": "IBR@93_GZ", "r1": 2, "r2": 0}, {"a1": 0, "a2": 3, "p1": "AKA BIG", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 1}, {"a1": 4, "a2": 2, "p1": "AKA BIG", "p2": "Yousscash_GZ", "r1": 1, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Akab_GZ", "p2": "AKA BIG", "r1": 0, "r2": 1}, {"a1": 2, "a2": 3, "p1": "Akab_GZ", "p2": "Ismo", "r1": 1, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 0}, {"a1": 4, "a2": 1, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 1, "p1": "CBlacks_GZ", "p2": "AKA BIG", "r1": 3, "r2": 4}, {"a1": 3, "a2": 1, "p1": "CBlacks_GZ", "p2": "Akab_GZ", "r1": 4, "r2": 1}, {"a1": 0, "a2": 2, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 3}, {"a1": 6, "a2": 3, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 4, "r2": 1}, {"a1": 4, "a2": 1, "p1": "CBlacks_GZ", "p2": "Ismo", "r1": 0, "r2": 6}, {"a1": 2, "a2": 1, "p1": "CBlacks_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 2}, {"a1": 4, "a2": 1, "p1": "CBlacks_GZ", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 2}, {"a1": 1, "a2": 4, "p1": "CBlacks_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 2}, {"a1": 2, "a2": 0, "p1": "CBlacks_GZ", "p2": "Yousscash_GZ", "r1": 2, "r2": 3}, {"a1": 4, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 0}, {"a1": 4, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 3, "r2": 2}, {"a1": 2, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 4, "r2": 2}, {"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Yousscash_GZ", "r1": 2, "r2": 1}, {"a1": 3, "a2": 1, "p1": "IBR@93_GZ", "p2": "Akab_GZ", "r1": 4, "r2": 1}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "Ismo", "r1": 2, "r2": 2}, {"a1": 3, "a2": 2, "p1": "IBR@93_GZ", "p2": "KenkNod_GZ", "r1": 3, "r2": 3}, {"a1": 3, "a2": 3, "p1": "IBR@93_GZ", "p2": "Walé-GZ", "r1": 5, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Ismo", "p2": "AKA BIG", "r1": 1, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Ismo", "p2": "EmRiCxX_GZ", "r1": 4, "r2": 0}, {"a1": 3, "a2": 2, "p1": "Ismo", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 2}, {"a1": 0, "a2": 0, "p1": "Ismo", "p2": "Yousscash_GZ", "r1": 2, "r2": 2}, {"a1": 1, "a2": 2, "p1": "KenkNod_GZ", "p2": "AKA BIG", "r1": 1, "r2": 0}, {"a1": 3, "a2": 2, "p1": "KenkNod_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 3}, {"a1": 3, "a2": 1, "p1": "KenkNod_GZ", "p2": "Ismo", "r1": 2, "r2": 5}, {"a1": 5, "a2": 0, "p1": "KenkNod_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 3}, {"a1": 3, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Akab_GZ", "r1": 8, "r2": 1}, {"a1": 3, "a2": 4, "p1": "Rius_oyo_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 2}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Walé-GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 3, "p1": "Rius_oyo_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 0}, {"a1": 0, "a2": 3, "p1": "Walé-GZ", "p2": "AKA BIG", "r1": 0, "r2": 3}, {"a1": 0, "a2": 5, "p1": "Walé-GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 3}, {"a1": 2, "a2": 3, "p1": "Walé-GZ", "p2": "Ismo", "r1": 2, "r2": 4}, {"a1": 0, "a2": 1, "p1": "Walé-GZ", "p2": "KenkNod_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 0, "p1": "Yousscash_GZ", "p2": "Akab_GZ", "r1": 1, "r2": 0}, {"a1": 5, "a2": 1, "p1": "Yousscash_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 1}, {"a1": 4, "a2": 1, "p1": "Yousscash_GZ", "p2": "KenkNod_GZ", "r1": 5, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Yousscash_GZ", "p2": "Walé-GZ", "r1": 4, "r2": 4}], "d2": [], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "", "label": "—", "notes": "", "winner": null}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "—", "team": ""}}}	2026-02-12 12:42:10.500323+00
2026-02-14	2	{"d1": [{"a1": 0, "a2": 2, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 5}, {"a1": 3, "a2": 2, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 2}, {"a1": 6, "a2": 1, "p1": "CBlacks_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 6}, {"a1": 4, "a2": 3, "p1": "CBlacks_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 0}, {"a1": 3, "a2": 4, "p1": "CBlacks_GZ", "p2": "Yousscash_GZ", "r1": 3, "r2": 0}, {"a1": 4, "a2": 2, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 0}, {"a1": 3, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Walé-GZ", "r1": 5, "r2": 1}, {"a1": 1, "a2": 1, "p1": "IBR@93_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 1}, {"a1": 0, "a2": 3, "p1": "IBR@93_GZ", "p2": "Yousscash_GZ", "r1": 4, "r2": 3}, {"a1": 2, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Walé-GZ", "r1": 5, "r2": 1}, {"a1": 0, "a2": 3, "p1": "Walé-GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 1, "p1": "Walé-GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 5}, {"a1": 3, "a2": 2, "p1": "Yousscash_GZ", "p2": "EmRiCxX_GZ", "r1": 4, "r2": 6}, {"a1": 1, "a2": 2, "p1": "Yousscash_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 0}], "d2": [{"a1": 0, "a2": 2, "p1": "AKA BIG", "p2": "Akab_GZ", "r1": 1, "r2": 0}, {"a1": 6, "a2": 1, "p1": "AKA BIG", "p2": "KenkNod_GZ", "r1": 6, "r2": 0}, {"a1": 2, "a2": 2, "p1": "AKA BIG", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 1}, {"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 1}, {"a1": 1, "a2": 1, "p1": "KenkNod_GZ", "p2": "Zyex_Legend_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "Akab_GZ", "r1": 2, "r2": 0}], "barrage": {"m1": {}, "m2": {}, "m3": {}, "ids": "IBR@93_GZ – Akab_GZ", "label": "IBR@93_GZ se maintient en D1 · Akab_GZ reste en D2", "notes": "", "winner": "IBR@93_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "MADRID"}, "d2": {"id": "Zyex_Legend_GZ", "team": "FRANCE"}}}	2026-02-14 19:56:36.416736+00
2026-03-28	2	{"d1": [{"a1": 3, "a2": 2, "p1": "AKA BIG", "p2": "CBlacks_GZ", "r1": 3, "r2": 1}, {"a1": 1, "a2": 0, "p1": "AKA BIG", "p2": "EmRiCxX_GZ", "r1": 5, "r2": 1}, {"a1": 1, "a2": 0, "p1": "AKA BIG", "p2": "Ismo", "r1": 0, "r2": 3}, {"a1": 2, "a2": 0, "p1": "AKA BIG", "p2": "KenkNod_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 1, "p1": "AKA BIG", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 1}, {"a1": 1, "a2": 2, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 1, "p1": "CBlacks_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 2}, {"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Ismo", "r1": 2, "r2": 2}, {"a1": 2, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "Rius_oyo_GZ", "r1": 4, "r2": 1}, {"a1": 2, "a2": 0, "p1": "Ismo", "p2": "CBlacks_GZ", "r1": 1, "r2": 2}, {"a1": 3, "a2": 1, "p1": "Ismo", "p2": "KenkNod_GZ", "r1": 1, "r2": 1}, {"a1": 0, "a2": 3, "p1": "KenkNod_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 3}, {"a1": 1, "a2": 3, "p1": "KenkNod_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 6}, {"a1": 3, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "CBlacks_GZ", "r1": 1, "r2": 3}, {"a1": 2, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "Ismo", "r1": 2, "r2": 2}], "d2": [{"a1": 1, "a2": 0, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 1, "r2": 0}, {"a1": 2, "a2": 4, "p1": "Akab_GZ", "p2": "IBR@93_GZ", "r1": 0, "r2": 4}, {"a1": 3, "a2": 3, "p1": "Akab_GZ", "p2": "Ousmane", "r1": 2, "r2": 3}, {"a1": 2, "a2": 3, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 2, "p1": "Akab_GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 7}, {"a1": 1, "a2": 5, "p1": "GMT_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 4}, {"a1": 0, "a2": 1, "p1": "GMT_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 3}, {"a1": 1, "a2": 4, "p1": "GMT_GZ", "p2": "Yousscash_GZ", "r1": 0, "r2": 3}, {"a1": 3, "a2": 2, "p1": "IBR@93_GZ", "p2": "Ousmane", "r1": 5, "r2": 0}, {"a1": 4, "a2": 1, "p1": "IBR@93_GZ", "p2": "Walé-GZ", "r1": 2, "r2": 1}, {"a1": 4, "a2": 1, "p1": "Ousmane", "p2": "GMT_GZ", "r1": 4, "r2": 2}, {"a1": 2, "a2": 3, "p1": "Ousmane", "p2": "Rod_GZ", "r1": 0, "r2": 6}, {"a1": 0, "a2": 4, "p1": "Ousmane", "p2": "Yousscash_GZ", "r1": 0, "r2": 5}, {"a1": 1, "a2": 3, "p1": "Rod_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 3}, {"a1": 3, "a2": 1, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 4, "r2": 0}, {"a1": 2, "a2": 1, "p1": "Walé-GZ", "p2": "GMT_GZ", "r1": 2, "r2": 3}, {"a1": 1, "a2": 2, "p1": "Walé-GZ", "p2": "Ousmane", "r1": 2, "r2": 3}, {"a1": 0, "a2": 3, "p1": "Walé-GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 5}, {"a1": 0, "a2": 1, "p1": "Yousscash_GZ", "p2": "IBR@93_GZ", "r1": 6, "r2": 2}, {"a1": 1, "a2": 0, "p1": "Yousscash_GZ", "p2": "Rod_GZ", "r1": 4, "r2": 4}], "barrage": {"ids": "CBlacks_GZ – Yousscash_GZ", "notes": "", "winner": "CBlacks_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "Madrid "}, "d2": {"id": "IBR@93_GZ", "team": "France "}}}	2026-04-04 13:02:01.576883+00
2026-02-21	2	{"d1": [{"a1": 1, "a2": 2, "p1": "AKA BIG", "p2": "CBlacks_GZ", "r1": 4, "r2": 1}, {"a1": 0, "a2": 0, "p1": "AKA BIG", "p2": "Ismo", "r1": 1, "r2": 1}, {"a1": 2, "a2": 1, "p1": "AKA BIG", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 0}, {"a1": 2, "a2": 0, "p1": "AKA BIG", "p2": "Zyex_Legend_GZ", "r1": 6, "r2": 0}, {"a1": 1, "a2": 1, "p1": "CBlacks_GZ", "p2": "Ismo", "r1": 1, "r2": 1}, {"a1": 4, "a2": 2, "p1": "CBlacks_GZ", "p2": "Zyex_Legend_GZ", "r1": 1, "r2": 0}, {"a1": 1, "a2": 1, "p1": "Ismo", "p2": "Rius_oyo_GZ", "r1": 3, "r2": 2}, {"a1": 1, "a2": 1, "p1": "Rius_oyo_GZ", "p2": "CBlacks_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 4, "p1": "Rius_oyo_GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 1}, {"a1": 2, "a2": 1, "p1": "Zyex_Legend_GZ", "p2": "Ismo", "r1": 0, "r2": 2}], "d2": [{"a1": 3, "a2": 1, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 3}, {"a1": 5, "a2": 1, "p1": "Akab_GZ", "p2": "Matrix _GZ", "r1": 3, "r2": 1}, {"a1": 0, "a2": 4, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 0, "r2": 1}, {"a1": 2, "a2": 1, "p1": "GMT_GZ", "p2": "KenkNod_GZ", "r1": 0, "r2": 2}, {"a1": 1, "a2": 2, "p1": "GMT_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 1}, {"a1": 2, "a2": 2, "p1": "KenkNod_GZ", "p2": "Matrix _GZ", "r1": 3, "r2": 1}, {"a1": 2, "a2": 3, "p1": "Matrix _GZ", "p2": "GMT_GZ", "r1": 1, "r2": 4}, {"a1": 1, "a2": 0, "p1": "Matrix _GZ", "p2": "Rod_GZ", "r1": 1, "r2": 7}, {"a1": 3, "a2": 3, "p1": "Rod_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 2}], "barrage": {"ids": "Zyex_Legend_GZ – KenkNod_GZ", "notes": "", "winner": "KenkNod_GZ"}, "champions": {"d1": {"id": "CBlacks_GZ", "team": "Madrid"}, "d2": {"id": "Rod_GZ", "team": "France"}}}	2026-02-21 19:27:36.114505+00
2026-02-28	2	{"d1": [{"a1": 1, "a2": 1, "p1": "AKA BIG", "p2": "CBlacks_GZ", "r1": 1, "r2": 4}, {"a1": 3, "a2": 1, "p1": "AKA BIG", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 2}, {"a1": 4, "a2": 3, "p1": "AKA BIG", "p2": "IBR@93_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 0, "p1": "AKA BIG", "p2": "Rod_GZ", "r1": 4, "r2": 1}, {"a1": 3, "a2": 5, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 0}, {"a1": 1, "a2": 0, "p1": "CBlacks_GZ", "p2": "Rod_GZ", "r1": 3, "r2": 1}, {"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 0}, {"a1": 3, "a2": 0, "p1": "IBR@93_GZ", "p2": "CBlacks_GZ", "r1": 0, "r2": 0}, {"a1": 4, "a2": 2, "p1": "IBR@93_GZ", "p2": "Rod_GZ", "r1": 3, "r2": 2}, {"a1": 0, "a2": 3, "p1": "Rod_GZ", "p2": "EmRiCxX_GZ", "r1": 3, "r2": 4}], "d2": [{"a1": 1, "a2": 0, "p1": "Akab_GZ", "p2": "Matrix _GZ", "r1": 2, "r2": 2}, {"a1": 0, "a2": 1, "p1": "Akab_GZ", "p2": "Zyex_Legend_GZ", "r1": 0, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Matrix _GZ", "p2": "Zyex_Legend_GZ", "r1": 2, "r2": 1}], "barrage": {"ids": "IBR@93_GZ – Matrix _GZ", "notes": "", "winner": "IBR@93_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "Madrid"}, "d2": {"id": "Zyex_Legend_GZ", "team": "France"}}}	2026-02-28 19:17:19.070247+00
2026-03-21	2	{"d1": [{"a1": 2, "a2": 2, "p1": "AKA BIG", "p2": "CBlacks_GZ", "r1": 1, "r2": 0}, {"a1": 0, "a2": 1, "p1": "AKA BIG", "p2": "EmRiCxX_GZ", "r1": 4, "r2": 1}, {"a1": 1, "a2": 1, "p1": "AKA BIG", "p2": "IBR@93_GZ", "r1": 1, "r2": 1}, {"a1": 1, "a2": 0, "p1": "AKA BIG", "p2": "Ismo", "r1": 1, "r2": 4}, {"a1": 0, "a2": 1, "p1": "AKA BIG", "p2": "Zyex_Legend_GZ", "r1": 0, "r2": 1}, {"a1": 3, "a2": 4, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 2, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 4, "r2": 4}, {"a1": 2, "a2": 1, "p1": "CBlacks_GZ", "p2": "Zyex_Legend_GZ", "r1": 3, "r2": 1}, {"a1": 5, "a2": 3, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 0}, {"a1": 2, "a2": 1, "p1": "EmRiCxX_GZ", "p2": "Zyex_Legend_GZ", "r1": 6, "r2": 0}, {"a1": 2, "a2": 2, "p1": "IBR@93_GZ", "p2": "Ismo", "r1": 1, "r2": 4}, {"a1": 2, "a2": 1, "p1": "Ismo", "p2": "CBlacks_GZ", "r1": 1, "r2": 0}, {"a1": 2, "a2": 3, "p1": "Ismo", "p2": "EmRiCxX_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 1, "p1": "Ismo", "p2": "Zyex_Legend_GZ", "r1": 0, "r2": 0}, {"a1": 1, "a2": 0, "p1": "Zyex_Legend_GZ", "p2": "IBR@93_GZ", "r1": 1, "r2": 1}], "d2": [{"a1": 3, "a2": 0, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 4, "p1": "Akab_GZ", "p2": "Rius_oyo_GZ", "r1": 2, "r2": 4}, {"a1": 1, "a2": 2, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 2, "p1": "Akab_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 1, "p1": "GMT_GZ", "p2": "Rius_oyo_GZ", "r1": 0, "r2": 4}, {"a1": 4, "a2": 3, "p1": "GMT_GZ", "p2": "Walé-GZ", "r1": 4, "r2": 2}, {"a1": 0, "a2": 4, "p1": "Rius_oyo_GZ", "p2": "Rod_GZ", "r1": 1, "r2": 0}, {"a1": 1, "a2": 0, "p1": "Rius_oyo_GZ", "p2": "Walé-GZ", "r1": 7, "r2": 2}, {"a1": 4, "a2": 1, "p1": "Rod_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 3}, {"a1": 6, "a2": 2, "p1": "Rod_GZ", "p2": "Walé-GZ", "r1": 1, "r2": 2}], "barrage": {"ids": "CBlacks_GZ – Rod_GZ", "notes": "", "winner": "CBlacks_GZ"}, "champions": {"d1": {"id": "EmRiCxX_GZ", "team": "Madrid"}, "d2": {"id": "Rius_oyo_GZ", "team": "France"}}}	2026-03-21 22:32:11.213351+00
2026-04-11	2	{"d1": [{"a1": 4, "a2": 1, "p1": "CBlacks_GZ", "p2": "EmRiCxX_GZ", "r1": 1, "r2": 1}, {"a1": 0, "a2": 3, "p1": "CBlacks_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 0}, {"a1": 0, "a2": 0, "p1": "EmRiCxX_GZ", "p2": "IBR@93_GZ", "r1": 2, "r2": 0}], "d2": [{"a1": 4, "a2": 1, "p1": "Akab_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 4}, {"a1": 1, "a2": 4, "p1": "Akab_GZ", "p2": "God's", "r1": 2, "r2": 1}, {"a1": 0, "a2": 2, "p1": "Akab_GZ", "p2": "KenkNod_GZ", "r1": 2, "r2": 1}, {"a1": 0, "a2": 0, "p1": "Akab_GZ", "p2": "Matrix _GZ", "r1": 3, "r2": 4}, {"a1": 3, "a2": 0, "p1": "Akab_GZ", "p2": "Rod_GZ", "r1": 2, "r2": 1}, {"a1": 1, "a2": 4, "p1": "Akab_GZ", "p2": "Yousscash_GZ", "r1": 1, "r2": 2}, {"a1": 0, "a2": 2, "p1": "GMT_GZ", "p2": "God's", "r1": 2, "r2": 4}, {"a1": 1, "a2": 3, "p1": "GMT_GZ", "p2": "Matrix _GZ", "r1": 1, "r2": 2}, {"a1": 1, "a2": 3, "p1": "GMT_GZ", "p2": "Yousscash_GZ", "r1": 3, "r2": 4}, {"a1": 1, "a2": 0, "p1": "God's", "p2": "KenkNod_GZ", "r1": 1, "r2": 2}, {"a1": 2, "a2": 2, "p1": "God's", "p2": "Rod_GZ", "r1": 3, "r2": 2}, {"a1": 1, "a2": 0, "p1": "KenkNod_GZ", "p2": "GMT_GZ", "r1": 4, "r2": 1}, {"a1": 4, "a2": 1, "p1": "KenkNod_GZ", "p2": "Matrix _GZ", "r1": 1, "r2": 6}, {"a1": 0, "a2": 5, "p1": "KenkNod_GZ", "p2": "Yousscash_GZ", "r1": 2, "r2": 2}, {"a1": 3, "a2": 1, "p1": "Matrix _GZ", "p2": "God's", "r1": 0, "r2": 4}, {"a1": 3, "a2": 3, "p1": "Matrix _GZ", "p2": "Rod_GZ", "r1": 0, "r2": 1}, {"a1": 4, "a2": 0, "p1": "Rod_GZ", "p2": "GMT_GZ", "r1": 2, "r2": 4}, {"a1": 1, "a2": 1, "p1": "Rod_GZ", "p2": "KenkNod_GZ", "r1": 4, "r2": 3}, {"a1": 1, "a2": 2, "p1": "Rod_GZ", "p2": "Yousscash_GZ", "r1": 2, "r2": 6}, {"a1": 2, "a2": 0, "p1": "Yousscash_GZ", "p2": "God's", "r1": 2, "r2": 0}, {"a1": 2, "a2": 3, "p1": "Yousscash_GZ", "p2": "Matrix _GZ", "r1": 3, "r2": 0}], "barrage": {"ids": "EmRiCxX_GZ – Akab_GZ", "notes": "", "winner": "EmRiCxX_GZ"}, "champions": {"d1": {"id": "CBlacks_GZ", "team": "France "}, "d2": {"id": "Yousscash_GZ", "team": "Madrid "}}}	2026-04-11 21:05:20.498651+00
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.players (player_id, name, role, created_at, profile_pic_url) FROM stdin;
Fuego_GZ	Ephel	MEMBRE	2025-12-05 16:39:28.311841	\N
AKA BIG	Florient	INVITE	2026-01-03 16:02:31.488523	\N
Ousmane	Ousmane	INVITE	2026-01-24 15:39:30.01557	\N
God's	God'sWill	INVITE	2025-08-22 14:37:21.946341	\N
Ismo	Ismaël	INVITE	2025-08-22 14:30:38.277774	\N
EmRiCxX_GZ	Emeric	MEMBRE	2025-08-22 14:34:21.632291	\N
The_One_GZ	Fabio	MEMBRE	2025-08-22 14:36:41.563462	\N
Rod_GZ	Folly	MEMBRE	2025-08-22 14:35:13.773809	\N
IBR@93_GZ	Ibrahim	MEMBRE	2025-08-22 10:59:42.322807	\N
KenkNod_GZ	Koboyo	MEMBRE	2025-08-22 14:35:56.573512	\N
Rius_oyo_GZ	Marius	MEMBRE	2025-08-22 14:35:44.448771	\N
Fuente_GZ	Pierre	MEMBRE	2025-08-22 14:36:15.252212	\N
GMT_GZ	Tanguy	MEMBRE	2025-08-27 19:51:25.38438	\N
Walé-GZ	Walé	MEMBRE	2025-08-22 14:56:28.415451	\N
Yousscash_GZ	ISSOUFOU	MEMBRE	2025-08-22 14:33:12.04592	\N
Kem_GZ	Mawuko	MEMBRE	2025-08-22 13:19:58.836599	\N
Zyex_Legend_GZ	Ezechiel	MEMBRE	2025-09-01 11:43:05.04639	\N
Matrix _GZ	Max	MEMBRE	2025-09-01 16:37:15.208155	\N
AminouFlash	Aminou	INVITE	2025-09-13 16:01:47.41104	\N
CBlacks_GZ	Caringthon	MEMBRE	2025-08-23 15:00:51.166924	/uploads/players/unknown_mielq3jw.jpg
Akab_GZ	Emmanuel	MEMBRE	2025-08-22 14:53:16.196135	\N
\.


--
-- Data for Name: season_totals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.season_totals (id, tag, standings, closed, updated_at) FROM stdin;
1	current	[]	f	2025-08-25 18:06:08.443243
\.


--
-- Data for Name: seasons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.seasons (id, name, started_at, ended_at, is_closed) FROM stdin;
2	"2025-2026"	2025-08-25 11:21:28.520997+00	\N	f
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sessions (id, user_id, device, user_agent, ip, created_at, last_seen, is_active, revoked_at, logout_at, cleaned_after_logout) FROM stdin;
7b674b69-9686-475c-b182-b6834a98ce12	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 12:59:21.366196+00	2025-09-02 13:04:06.786473+00	f	2025-09-02 16:58:11.930535+00	\N	f
6717f3b3-9cfa-4d77-9bd9-4e58239e489b	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-15 13:25:11.870355+00	2025-09-15 13:26:28.003356+00	f	2025-09-16 12:42:50.595803+00	\N	f
3ebd7447-195c-4a5b-bfae-cd357ecb5993	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 16:58:11.933024+00	2025-09-02 17:02:50.286383+00	f	2025-09-02 17:40:20.520086+00	\N	f
62f0dc27-b011-4363-9014-46e6df922de9	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 12:33:06.0635+00	2025-09-02 12:33:19.225745+00	f	2025-09-02 16:56:41.202855+00	\N	f
d5b5e738-380c-4661-ae48-527e8656b3a2	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 17:42:25.644924+00	2025-09-02 17:44:24.669852+00	f	2025-09-02 17:45:12.163392+00	\N	f
dc4f020d-e338-472a-998d-ab8433537faf	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-03 10:09:28.276533+00	2025-09-03 11:53:51.769822+00	f	2025-09-03 11:54:06.187937+00	\N	f
24cef337-b62d-4aef-9e01-a8d57876e850	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 17:45:12.164407+00	2025-09-02 17:46:34.910914+00	f	2025-09-03 10:09:28.254641+00	\N	f
fc6635d8-fb22-4c1c-87c6-6c8cacd16022	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 11:58:57.196993+00	2025-09-02 12:00:32.413227+00	f	2025-09-02 12:59:21.362281+00	\N	f
e664997b-cd7d-4630-9aed-e19f6a0afa5c	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 17:40:21.54963+00	2025-09-02 17:41:54.482211+00	f	2025-09-02 17:42:25.64391+00	\N	f
b8df0ebf-c4d1-4a80-a904-62d1d3652452	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 16:56:41.208671+00	2025-09-02 16:56:48.347763+00	f	2025-09-02 16:57:18.068085+00	\N	f
51ec8636-c254-4cae-9160-d308772bfd8d	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-03 12:32:21.606381+00	2025-09-03 18:17:49.969826+00	f	2025-09-04 18:31:16.766403+00	\N	f
35c9c029-25fd-416c-897e-e3bc449c6c50	19	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.143	2025-09-02 17:46:05.96667+00	2025-09-02 17:46:32.01677+00	f	2025-09-03 17:46:34.235533+00	\N	f
d9e9a3f4-5aca-40b5-bcb8-39c1aadf01e4	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-04 19:20:46.559641+00	2025-09-05 08:33:27.876731+00	f	2025-09-05 08:33:47.743852+00	\N	f
e462e6f5-dfe1-4be6-99ad-5ea783d14f91	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-04 18:39:26.230546+00	2025-09-04 19:15:54.871012+00	f	2025-09-04 19:20:46.557891+00	\N	f
6443ee6a-61d8-4305-8209-1e234db2d17c	8	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.191	2025-09-04 19:16:52.035289+00	2025-09-04 20:58:14.587564+00	f	2025-09-05 20:58:41.359209+00	\N	f
57a6b572-c541-4227-8810-43474cf8a2bd	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-05 08:33:47.746182+00	2025-09-05 08:44:26.957267+00	f	2025-09-05 09:29:46.067688+00	\N	f
33f017a9-6aff-4336-851f-ff61742666df	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-03 11:54:06.190758+00	2025-09-03 11:55:50.910902+00	f	2025-09-03 12:32:21.60096+00	\N	f
3c06b6f3-7e0d-46af-90de-bbb6803bc70a	8	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.204	2025-09-02 17:01:46.956683+00	2025-09-02 17:02:41.077806+00	f	2025-09-03 17:03:34.341685+00	\N	f
f622b93a-0882-4519-a099-7e3f0c5450cb	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-02 16:57:18.069872+00	2025-09-02 16:57:52.884703+00	f	2025-09-03 17:03:34.341685+00	\N	f
13db1497-4b8f-4576-aac2-a9869121cfc0	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.191	2025-09-04 18:42:10.499378+00	2025-09-04 18:53:08.878469+00	f	2025-09-05 14:17:10.918391+00	\N	f
23d300ac-3401-4886-ba43-407dd6526ba8	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-16 12:57:17.289907+00	2025-09-16 12:58:02.46896+00	f	2025-09-16 17:02:42.511617+00	\N	f
d2f810e4-1c03-4ae3-a528-2576602dd721	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-16 16:38:33.28465+00	2025-09-16 17:02:35.731705+00	f	2025-09-16 17:03:17.58596+00	\N	f
7d2f1287-9151-478c-8de1-d9df6987486e	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36		2025-09-16 17:27:16.343861+00	2025-09-16 18:11:39.199378+00	f	2025-09-16 18:11:44.228231+00	\N	f
a71e4695-33ca-40eb-b2a0-c052b00f477d	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.191	2025-09-05 14:17:10.919512+00	2025-09-05 16:44:03.339118+00	f	2025-09-06 16:44:21.510041+00	\N	f
f221b2e4-2c94-4f1b-82cd-7fd225ff6f81	19	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.191	2025-09-05 16:46:06.124155+00	2025-09-05 18:19:05.435014+00	f	2025-09-06 18:19:22.23785+00	\N	f
47622a50-01c5-4ece-b8df-f58f5ecb5406	14	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.191	2025-09-05 18:35:41.238163+00	2025-09-05 19:36:53.290599+00	f	2025-09-06 19:37:51.525937+00	\N	f
70ee8adc-9b4d-4732-9165-f581d22bf72f	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-16 12:50:27.99041+00	2025-09-16 12:50:27.99041+00	f	2025-09-16 12:57:17.288255+00	\N	f
fe91b262-fe04-47fc-b560-13288ad80dac	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-16 12:43:27.293438+00	2025-09-16 12:43:27.293438+00	f	2025-09-16 12:50:27.98329+00	\N	f
86743d80-45f0-462b-811d-d10af31229bc	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-05 13:47:28.332016+00	2025-09-05 14:22:52.40655+00	f	2025-09-05 16:16:11.111303+00	\N	f
068fc053-32ca-4bc7-b16a-fa0688a1a804	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-05 09:29:46.07823+00	2025-09-05 10:08:36.814281+00	f	2025-09-05 10:24:29.817946+00	\N	f
06d1585e-5c3d-498d-b8eb-bf1061e5197d	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-05 10:24:29.820967+00	2025-09-05 10:57:39.160477+00	f	2025-09-05 13:47:28.329615+00	\N	f
4048b711-7072-41b2-992d-90a589bc38da	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-15 14:15:39.147025+00	2025-09-15 14:16:29.412624+00	f	2025-09-16 12:51:04.300905+00	\N	f
b95b2aa5-5f74-4f9e-8037-44f45e7421bb	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-16 12:53:09.952002+00	2025-09-16 12:53:09.952002+00	f	2025-09-16 12:57:01.531386+00	\N	f
7a0b5855-19f9-4f1e-9bc8-b100e37ad406	28	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.135	2025-10-25 16:37:51.58353+00	2025-10-25 16:59:41.819628+00	f	2025-10-27 08:53:38.942043+00	\N	f
a10be09f-2d3e-4bd3-a989-e8e8cfff8feb	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-16 12:57:01.539978+00	2025-09-16 12:57:07.934468+00	f	2025-09-16 13:33:22.119262+00	\N	f
6d35a96d-9c82-4448-8009-2851e7382e30	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-16 17:03:17.592067+00	2025-09-16 17:25:34.635587+00	f	2025-09-16 17:27:16.342751+00	\N	f
04b027d6-b7e6-449c-9b8e-ced973629fae	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-16 15:29:26.421802+00	2025-09-16 16:13:35.421754+00	f	2025-09-16 16:13:40.488526+00	\N	f
cb202da9-7508-4692-8b3a-96054bdbb384	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-05 16:16:11.114521+00	2025-09-05 16:43:33.734569+00	f	2025-09-06 12:23:58.355402+00	\N	f
c34589b5-acb8-4f28-83cd-988c2c8a4197	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-16 18:11:44.233391+00	2025-09-16 18:14:58.229695+00	f	2025-09-17 08:50:57.811572+00	\N	f
27a7779f-1b4d-4681-8882-9a11492e4251	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 09:03:33.510308+00	2025-09-17 09:18:28.097367+00	f	2025-09-17 09:18:53.013775+00	\N	f
ba5654e9-9b7f-4a32-a5dc-9b041c920cc9	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 09:18:53.018617+00	2025-09-17 09:18:53.384677+00	f	2025-09-17 09:19:01.66965+00	\N	f
3d094045-a954-4f16-b678-0ff24fbd4feb	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-15 10:04:50.33261+00	2025-09-15 13:24:58.483873+00	f	2025-09-15 14:15:39.143985+00	\N	f
04e0784f-cca6-4ba5-a027-c89bf8a65bf1	27	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.141	2025-09-13 20:50:51.88063+00	2025-09-13 20:54:43.47537+00	f	2025-09-14 20:55:32.315046+00	\N	f
919e7e36-c202-461e-823e-4b8ed3c2427d	26	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.128	2025-09-13 18:37:27.693407+00	2025-09-13 21:04:50.935053+00	f	2025-09-14 21:05:32.379465+00	\N	f
d46009ea-65ff-40e2-bdb7-e293a176eec7	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-16 12:42:50.605622+00	2025-09-16 12:42:50.605622+00	f	2025-09-16 12:43:27.289273+00	\N	f
f6dd5579-4c61-4278-a829-4e05fc3e0295	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.122	2025-09-06 12:23:58.365512+00	2025-09-06 13:52:42.516002+00	f	2025-09-08 08:54:14.084766+00	\N	f
2ab3566b-a933-4bb1-9b31-bc13a8f5032b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-16 12:51:04.312052+00	2025-09-16 12:51:04.312052+00	f	2025-09-16 12:53:09.947749+00	\N	f
8c24761f-a627-43e5-9620-284872a635e9	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36		2025-09-16 16:13:40.489901+00	2025-09-16 16:38:27.697599+00	f	2025-09-16 16:38:33.277208+00	\N	f
74684e2f-804d-431f-bb1b-e77218da6d5c	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.234	2025-09-16 13:33:22.12591+00	2025-09-16 13:33:22.15674+00	f	2025-09-16 15:29:26.415175+00	\N	f
52a25fa2-64f3-4978-b78e-919a9ae249f3	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	::ffff:192.168.1.129	2025-09-08 08:54:19.154927+00	2025-09-08 10:22:53.370964+00	f	2025-09-13 11:29:39.011496+00	\N	f
9f5d8745-4e83-4fcf-b0be-b9cfcfe6f762	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.131	2025-09-24 10:08:42.191805+00	2025-09-24 10:11:31.240119+00	f	2025-09-25 09:58:25.420293+00	\N	f
04f3c46b-cca3-4bc8-bf0e-8273f21ec0f5	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 08:50:57.82078+00	2025-09-17 09:03:21.097193+00	f	2025-09-17 09:03:33.506572+00	\N	f
c7221c67-e92a-4483-81c0-eeb8318aa13e	7	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.169	2025-09-17 09:08:37.261635+00	2025-09-17 09:41:43.549041+00	f	2025-09-17 09:59:26.36245+00	\N	f
aae5841e-83f4-4da1-9652-1d06637f59a1	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-16 17:02:42.513687+00	2025-09-16 17:02:58.394134+00	f	2025-09-16 17:25:45.156823+00	\N	f
033cd2ae-818f-4653-9948-a900c07eaf36	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-16 17:25:45.160646+00	2025-09-16 17:27:02.609352+00	f	2025-09-17 09:08:37.255401+00	\N	f
991d080f-951b-4766-b1be-1ef59a69873c	16	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/139.0.7258.76 Mobile/15E148 Safari/604.1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/139.0.7258.76 Mobile/15E148 Safari/604.1	::ffff:192.168.1.251	2025-09-13 15:55:02.163674+00	2025-09-13 15:57:48.053014+00	f	2025-09-14 15:58:29.931006+00	\N	f
4ec5bea5-e2cb-46a4-a001-a510ca8f7d77	1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/139.0.7258.76 Mobile/15E148 Safari/604.1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/139.0.7258.76 Mobile/15E148 Safari/604.1	::ffff:192.168.1.251	2025-09-13 15:59:45.545001+00	2025-09-13 20:43:22.839346+00	f	2025-09-14 20:43:32.214749+00	\N	f
0d33d9cd-7aa2-46af-bd61-2e0b92a4c112	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 09:19:01.670566+00	2025-09-17 09:45:07.30377+00	f	2025-09-17 09:45:12.047941+00	\N	f
f4c859b1-ac94-4948-8f4a-8bc1e91222c6	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.169	2025-09-16 17:31:14.413757+00	2025-09-16 17:32:41.988223+00	f	2025-09-17 09:41:52.104433+00	\N	f
e661ca62-2947-4d41-8d8f-5b90287db9aa	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.169	2025-09-17 09:41:52.110076+00	2025-09-17 10:27:52.490269+00	f	2025-09-17 10:28:06.153778+00	\N	f
be727671-e861-451b-a1b8-9bac7dc165c3	7	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.176	2025-09-17 17:18:22.302217+00	2025-09-17 17:23:02.027083+00	f	2025-09-18 17:23:43.310659+00	\N	f
5c2e703e-903e-4b18-9cca-f5676cb10d3b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 11:40:26.04816+00	2025-09-17 11:40:35.510922+00	f	2025-09-17 12:20:34.219508+00	\N	f
4317f3bb-7f01-4fa0-b63e-cf92e1f4808e	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-18 12:20:44.521246+00	2025-09-18 12:24:28.302285+00	f	2025-09-19 16:03:17.21458+00	\N	f
f8dd679b-598f-41cf-af82-98ff44bd0cd7	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-17 16:45:13.189349+00	2025-09-17 17:10:07.082554+00	f	2025-09-17 17:10:12.700017+00	\N	f
41e77101-6c42-49a5-b714-8d81c22d2add	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-20 16:58:02.082403+00	2025-10-20 17:10:01.738154+00	f	2025-10-21 17:10:13.335538+00	\N	f
30a67c38-35a0-4b47-8b41-0181d3234041	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-17 15:34:59.621999+00	2025-09-17 16:02:33.700373+00	f	2025-09-17 16:45:13.180225+00	\N	f
3e6916f4-3cef-4927-a308-10a35aa84812	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36		2025-09-17 12:23:26.889101+00	2025-09-17 13:44:43.658199+00	f	2025-09-17 13:45:16.76654+00	\N	f
a93988c9-eb90-4b9a-9f37-1b705b6a7509	8	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 10:23:07.403884+00	2025-09-17 10:59:24.651236+00	f	2025-09-17 10:59:24.718554+00	2025-09-17 10:59:24.718554+00	t
dacac3c1-2918-418d-9da6-877388f4bac5	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 11:41:13.45976+00	2025-09-17 12:20:29.631109+00	f	2025-09-17 12:23:26.88533+00	\N	f
b9aebb3c-6fb1-4251-a17f-e7797bd06fa4	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36		2025-09-17 10:59:29.367218+00	2025-09-17 11:40:20.595804+00	f	2025-09-17 11:41:13.456275+00	\N	f
f7b58f01-017b-4398-9366-1e572b9ee7ac	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36		2025-09-17 17:38:17.758761+00	2025-09-17 18:16:27.113251+00	f	2025-09-17 19:45:34.828433+00	\N	f
0f4fde13-3b43-46f7-b56a-9d015d300b7e	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 13:45:16.770474+00	2025-09-17 13:56:56.956849+00	f	2025-09-17 16:02:52.646265+00	\N	f
86a23418-a2f2-4884-a102-1299397bad7b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 12:20:34.22478+00	2025-09-17 12:23:15.282593+00	f	2025-09-17 13:44:48.587608+00	\N	f
539ce637-e9ce-4f18-96b7-65826393d642	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-17 17:10:12.701457+00	2025-09-17 17:26:23.013991+00	f	2025-09-17 17:38:17.74378+00	\N	f
ed8c34a8-bef4-4923-bac4-2615640f60d1	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 13:44:48.597488+00	2025-09-17 13:44:51.058297+00	f	2025-09-17 15:34:59.616434+00	\N	f
1ede0ab9-17e6-44c2-9ad5-905e5bfb40a6	7	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.176	2025-09-17 16:48:10.640042+00	2025-09-17 17:18:14.178655+00	f	2025-09-17 17:18:22.30041+00	\N	f
18ecade0-ec44-4fc2-b978-91b1880aa27e	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-17 16:02:52.649986+00	2025-09-17 16:45:05.821379+00	f	2025-09-17 16:48:10.638899+00	\N	f
1159ecbb-d8e4-41ef-a021-e9a921c173b1	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36		2025-09-17 19:45:34.834935+00	2025-09-18 09:46:17.270037+00	f	2025-09-18 09:46:28.679295+00	\N	f
0349a18f-23ad-4f59-a241-51bac6c9c28b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-18 09:46:28.779232+00	2025-09-18 11:56:10.450788+00	f	2025-09-18 11:56:16.178864+00	\N	f
31404052-a349-4de7-8c2c-e2d62a79dbac	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-24 10:21:34.597005+00	2025-10-24 11:18:41.199444+00	f	2025-10-25 15:21:10.968495+00	\N	f
84139801-1ad2-40c8-b50c-195e41cf0f63	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36		2025-09-26 10:01:08.250166+00	2025-09-26 10:25:46.065467+00	f	2025-09-26 10:25:51.975983+00	\N	f
da1cd058-ddef-45ea-ba37-b9c18ce5f07f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-19 16:06:29.319254+00	2025-09-19 16:07:45.553138+00	f	2025-09-19 16:28:12.609026+00	\N	f
cde6bceb-25d6-4d44-b2bd-e2205ab47b80	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.169	2025-09-17 11:20:51.262464+00	2025-09-17 11:21:29.837043+00	f	2025-09-17 11:21:29.837152+00	2025-09-17 11:21:29.837152+00	t
9a0123e7-5dac-4e45-986b-3d7470f75a38	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 09:59:26.366192+00	2025-09-17 10:22:57.143207+00	f	2025-09-17 10:22:57.145703+00	2025-09-17 10:22:57.145703+00	t
6795587e-86da-4d1d-a5bc-5b12b644cd58	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.131	2025-09-25 10:30:01.342344+00	2025-09-25 10:57:29.078247+00	f	2025-09-25 10:57:34.240289+00	\N	f
d7021c13-ed58-42ff-8785-4ffc0e0e9771	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-25 16:47:54.849081+00	2025-10-25 16:58:55.854277+00	f	2025-10-27 08:53:38.942043+00	\N	f
e605fae8-1a62-4679-877b-d49fa63fa114	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.159	2025-09-27 17:34:56.890099+00	2025-09-27 20:45:35.383494+00	f	2025-09-27 20:45:42.909278+00	\N	f
4eac26d2-4ee0-4ca6-908f-f9e4bc55b179	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-18 11:56:16.190339+00	2025-09-18 12:20:40.639193+00	f	2025-09-18 12:20:44.518501+00	\N	f
300c1b6d-4ad2-4c0e-a266-6d6204cf0c08	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	192.168.1.105	2025-09-19 16:28:12.62542+00	2025-09-19 16:44:57.576621+00	f	2025-09-19 17:27:57.773025+00	\N	f
7dd631d6-a429-426a-9e05-6517e10a210b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.159	2025-09-27 20:45:42.918004+00	2025-09-27 21:04:49.985247+00	f	2025-09-29 08:25:08.279256+00	\N	f
4e129de3-33c2-44fd-ab85-e84c3accf492	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.131	2025-09-25 09:58:25.429223+00	2025-09-25 10:29:49.418923+00	f	2025-09-25 10:30:01.335023+00	\N	f
a5b684b3-fdaa-49ae-9e19-13fb63a4ff36	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-19 17:27:57.800963+00	2025-09-19 17:36:42.082582+00	f	2025-09-24 10:05:14.38808+00	\N	f
59f3fee9-eaa4-4a9f-8052-4deb860a318f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36		2025-09-26 09:34:59.238114+00	2025-09-26 10:01:02.177759+00	f	2025-09-26 10:01:08.241459+00	\N	f
b9bdc2e0-1e55-4b73-8ceb-f63d8e2af1c3	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-13 13:44:26.899559+00	2025-10-13 13:55:52.604445+00	f	2025-10-14 13:55:56.19488+00	\N	f
502b3327-ed6e-44f5-9bde-e345a1b42d24	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-13 11:58:59.004394+00	2025-10-13 13:10:11.381956+00	f	2025-10-13 13:10:16.709018+00	\N	f
5d480b2d-511c-4170-8a34-71ef02385579	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.159	2025-09-26 10:25:51.989257+00	2025-09-26 10:40:21.940207+00	f	2025-09-27 17:31:41.09998+00	\N	f
3f3afb33-de87-4226-97cf-c9514b633a6c	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-13 13:10:16.710504+00	2025-10-13 13:44:20.557857+00	f	2025-10-13 13:44:26.896924+00	\N	f
5923eb6d-88b8-420b-aab8-51e40b369f1d	28	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.178	2025-10-18 18:27:15.367026+00	2025-10-18 20:54:29.856359+00	f	2025-10-18 20:55:42.152431+00	\N	f
cd60d19f-1b4b-4c84-b5f4-db4ad69dc20c	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.121	2025-10-27 09:20:19.800197+00	2025-10-27 09:34:17.720724+00	f	2025-10-29 08:57:22.558802+00	\N	f
85f38bcb-c494-4b9f-93dc-e71f65bfe941	28	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.182	2025-10-18 20:55:42.154596+00	2025-10-18 22:32:56.022356+00	f	2025-10-18 22:33:42.070676+00	\N	f
852f0da0-1c03-4ca0-9b3f-b01c4527db2d	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.135	2025-10-25 15:34:26.428616+00	2025-10-25 16:36:42.356574+00	f	2025-10-25 16:37:51.577347+00	\N	f
7c7ad96f-c667-4efb-acb4-5a4a0896931c	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.178	2025-10-18 15:16:34.523114+00	2025-10-18 15:31:58.022053+00	f	2025-10-18 16:40:25.074424+00	\N	f
1845ccc6-2375-4942-a8af-177da551a116	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.182	2025-10-18 22:33:42.071716+00	2025-10-18 22:41:38.522621+00	f	2025-10-19 22:41:52.411304+00	\N	f
56f664ea-59f3-4b0c-8ac3-e36860564f60	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-18 16:17:28.524323+00	2025-10-19 16:17:24.240613+00	f	2025-10-20 08:33:22.590244+00	\N	f
038a418f-e1b2-4781-a3fe-4088454fcad4	28	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.105	2025-11-25 09:56:48.036246+00	2025-11-25 09:58:05.503024+00	f	2025-11-25 09:58:05.503495+00	2025-11-25 09:58:05.503495+00	t
5d691002-560c-477d-9d43-87eb49606ef6	28	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.182	2025-10-18 17:31:02.316333+00	2025-10-18 18:23:18.639422+00	f	2025-10-18 18:27:15.365819+00	\N	f
f7213ddf-13ef-42e3-a09e-b4f66c824355	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-20 16:34:23.475799+00	2025-10-20 16:57:52.176679+00	f	2025-10-21 16:58:13.220222+00	\N	f
14ae2a99-1b01-4840-b0eb-cc6554f2f17d	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	::ffff:192.168.1.129	2025-11-17 18:42:27.185707+00	2025-11-17 18:43:31.863807+00	f	2025-11-17 18:54:33.933264+00	\N	f
e89c251a-da73-4faa-9468-318afe9c98ae	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-27 09:12:09.359567+00	2025-10-27 09:13:21.737335+00	f	2025-10-27 09:17:26.008863+00	\N	f
a48c8c6b-c624-4be7-bfb1-35a727cdd33a	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-20 16:07:38.640219+00	2025-10-20 16:07:58.067495+00	f	2025-10-20 16:34:23.464182+00	\N	f
132b0b9a-d0c0-49f8-a483-9efb418b80e2	28	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.178	2025-10-18 16:40:25.077452+00	2025-10-18 17:30:49.26009+00	f	2025-10-18 17:31:02.310706+00	\N	f
1839fe91-27f2-4a64-b812-6a8c16ebf9cc	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.129	2025-11-17 08:31:32.66698+00	2025-11-17 09:31:09.997301+00	f	2025-11-17 09:32:24.229245+00	\N	f
f926b753-0ca3-4862-b742-95559db457be	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.186	2025-11-22 15:32:13.776518+00	2025-11-22 18:39:45.746736+00	f	2025-11-22 18:46:29.192806+00	\N	f
c6996327-a2ae-454a-aad0-51ec467d07dd	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::1	2025-10-20 08:33:22.610084+00	2025-10-20 08:35:13.952233+00	f	2025-10-20 16:07:38.62815+00	\N	f
11d523a2-d7cd-4550-8940-2f461c353fff	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/3.0.2 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/3.0.2 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	127.0.0.1	2025-11-25 08:59:55.652246+00	2025-11-25 09:07:08.641538+00	f	2025-11-25 09:54:22.883853+00	\N	f
072be455-fa5d-4d09-a7fe-b37d233d69cb	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.166	2025-11-29 20:34:58.990914+00	2025-11-29 20:41:37.106128+00	f	2025-12-01 08:35:05.364422+00	\N	f
9501a3c9-f30f-4263-a2ee-793a7cec5694	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/141.0.7390.124 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/141.0.7390.124 Mobile Safari/537.36	192.168.1.193	2025-11-22 15:27:30.241548+00	2025-11-22 20:39:37.672694+00	f	2025-11-22 20:39:39.132362+00	\N	f
31d47763-910e-41f4-9c0e-26844b6e865f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 09:23:28.55669+00	2025-12-04 09:23:45.203111+00	f	2025-12-04 13:04:16.467372+00	\N	f
be3c71b3-abfd-427d-8676-cbe3617f7548	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/3.0.2 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/3.0.2 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	127.0.0.1	2025-11-25 09:12:23.877442+00	2025-11-25 09:12:34.994026+00	f	2025-11-25 09:37:33.15963+00	\N	f
e2a97022-3825-4c53-b8f2-a3ced15497b4	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/1.0.0 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/1.0.0 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	127.0.0.1	2025-11-21 12:19:24.284977+00	2025-11-21 12:21:10.345598+00	f	2025-11-21 18:35:04.335005+00	\N	f
5bd6fb2d-bdd9-423d-b5f7-b31e486c1d13	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/143.0.7499.146 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/143.0.7499.146 Mobile Safari/537.36	192.168.1.200	2026-01-03 15:54:29.597114+00	2026-01-03 19:38:02.560344+00	f	2026-01-05 07:59:35.862366+00	\N	f
05a33cfd-a2e6-4e4d-a92a-77a4d0ead8bc	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.129	2025-11-17 18:54:33.939577+00	2025-11-17 18:55:46.740929+00	f	2025-11-21 10:00:28.673144+00	\N	f
8b7f425c-cc1c-44df-93f4-da70a8b75df0	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.105	2025-11-25 13:18:16.775095+00	2025-11-25 13:18:32.527278+00	f	2025-11-25 13:18:32.527685+00	2025-11-25 13:18:32.527685+00	t
8b343986-1a4e-44a4-8c69-bfda50102ae8	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.105	2025-09-19 16:07:57.249458+00	2025-09-19 16:19:51.808209+00	f	2025-09-19 16:19:51.808788+00	2025-09-19 16:19:51.808788+00	t
3df12c44-23d2-49e2-b8ed-1c23172c8589	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-07 16:18:19.76569+00	2026-03-07 19:05:50.577624+00	f	2026-03-09 08:26:46.698301+00	\N	f
eca4ec4d-7eaf-4be2-a57b-49089c16360b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.121	2026-02-11 11:57:35.437106+00	2026-02-11 14:27:43.786313+00	f	2026-02-11 14:28:42.197891+00	\N	f
4a244485-e1f7-4527-8000-b6ee1f3c9542	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.135	2026-01-24 15:38:48.200935+00	2026-01-24 15:43:51.527719+00	f	2026-01-25 15:44:22.052992+00	\N	f
dabe1fab-f289-481f-9a00-688733325f20	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.176	2026-02-07 16:10:10.499241+00	2026-02-07 22:19:25.03848+00	f	2026-02-08 22:19:25.513667+00	\N	f
e4a203b3-3d45-4838-804d-9df771642fb2	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-03 10:46:15.285045+00	2025-11-03 11:14:23.535247+00	f	2025-11-03 11:50:48.472055+00	\N	f
187ac62b-b28e-425b-b1a8-c969fcf253f7	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.185	2025-11-01 20:19:38.727949+00	2025-11-01 22:31:54.25769+00	f	2025-11-03 08:21:38.180017+00	\N	f
a7a4b9d1-d68f-4106-9157-114525188a82	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-11-01 20:11:18.942666+00	2025-11-01 20:11:49.484844+00	f	2025-11-01 20:55:10.726789+00	\N	f
42b3872e-eebf-4c92-9f75-33e30b157ff8	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.155	2025-11-01 20:55:10.738124+00	2025-11-01 21:59:10.519867+00	f	2025-11-03 08:21:38.180017+00	\N	f
6fc2bd56-1653-4241-82c9-9c5a4666621c	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-03 08:23:37.803076+00	2025-11-03 08:25:23.657024+00	f	2025-11-03 08:29:27.059396+00	\N	f
964f5742-ce85-434b-926b-737f7cb86ece	7	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	192.168.1.122	2025-11-25 13:19:32.238655+00	2025-11-25 13:20:02.46534+00	f	2025-11-27 08:08:06.221299+00	\N	f
ad3ef16b-9a23-435d-b83a-f382ac192af1	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36		2025-11-03 16:24:03.293738+00	2025-11-04 09:49:25.23932+00	f	2025-11-05 16:24:35.477903+00	\N	f
42ae2651-e8e7-4b9a-8b69-29eed9ae5aae	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	::ffff:192.168.1.200	2025-10-27 09:17:26.037426+00	2025-10-27 09:57:02.301347+00	f	2025-10-29 08:57:22.558802+00	\N	f
d60015d3-7f7b-4a14-bfb8-63abf41ade70	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	::ffff:192.168.1.104	2025-10-29 09:01:48.89454+00	2025-10-29 10:11:36.349736+00	f	2025-11-01 20:10:31.469499+00	\N	f
a979a222-8cda-4f71-b125-5f0f6fc935df	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.114	2025-10-29 09:00:14.874458+00	2025-10-29 16:02:28.505784+00	f	2025-11-01 20:10:31.469499+00	\N	f
6599a21e-815e-443b-aefc-6448d3d63160	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-03 08:29:27.060479+00	2025-11-03 10:44:35.430444+00	f	2025-11-03 11:14:29.543869+00	\N	f
30792a7d-f9a9-4653-94ca-2e4485bed145	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.185	2025-11-03 10:49:59.662705+00	2025-11-03 11:32:09.930297+00	f	2025-11-03 11:32:16.264582+00	\N	f
92180535-52c4-476f-be47-334272290388	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.169	2025-09-17 10:28:06.159463+00	2025-09-17 10:29:17.748957+00	f	2025-09-17 10:29:17.749276+00	2025-09-17 10:29:17.749276+00	t
6b11703d-80cf-4c3b-8071-ff8b2f8c41c7	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-09 08:26:47.56623+00	2026-03-09 08:27:19.288524+00	f	2026-03-10 08:33:14.283493+00	\N	f
a626ffd1-1541-456c-960c-51f2896d5651	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.129	2025-11-17 09:31:24.987109+00	2025-11-17 09:32:19.239247+00	f	2025-11-17 09:32:19.398099+00	2025-11-17 09:32:19.398099+00	t
c9c3cb59-93d8-4c52-ab16-ea2becba7fa8	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-03 08:27:23.549831+00	2025-11-03 08:29:19.465788+00	f	2025-11-03 08:29:19.466043+00	2025-11-03 08:29:19.466043+00	t
a2af97cd-04b3-4231-a7e8-b3fcca09a288	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.185	2025-11-03 11:32:16.268101+00	2025-11-03 11:33:38.622602+00	f	2025-11-03 12:07:33.077973+00	\N	f
8bb25e2e-ded4-402c-900b-79de3df4456b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-03 11:14:29.545642+00	2025-11-03 11:33:25.02849+00	f	2025-11-03 11:39:18.577816+00	\N	f
cc37ea52-8506-4ccb-8d81-23a6ae83f1f1	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-03 11:50:48.473648+00	2025-11-03 11:51:04.1148+00	f	2025-11-03 16:24:03.278522+00	\N	f
d122db14-34aa-4013-bb60-d8071c72d3bd	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.185	2025-11-03 12:07:33.175208+00	2025-11-03 12:07:33.414417+00	f	2025-11-04 09:50:53.438546+00	\N	f
fca9f41a-b530-4a51-b8b6-9c300e541e07	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-03 12:08:08.70397+00	2025-11-03 16:23:52.635356+00	f	2025-11-04 09:49:33.19083+00	\N	f
10c322fc-90ca-4f36-b664-585327ecb9ce	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.185	2025-11-04 09:50:53.44407+00	2025-11-04 12:31:40.323371+00	f	2025-11-05 16:24:35.477903+00	\N	f
8f0fa73a-5647-4148-b181-a309022fdbaf	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-04 09:49:33.197367+00	2025-11-04 12:31:57.11223+00	f	2025-11-05 16:24:35.388568+00	\N	f
2b92cf82-7f5b-409c-a1e0-d23ac2378343	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-05 16:29:08.602419+00	2025-11-05 16:31:25.963254+00	f	2025-11-07 09:31:54.011217+00	\N	f
a9a3b00d-7ee1-4b15-b275-cb43b2713334	8	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/1.0.0 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/1.0.0 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	127.0.0.1	2025-11-21 12:21:23.906294+00	2025-11-21 12:21:39.304326+00	f	2025-11-22 15:04:00.822114+00	\N	f
662572df-e436-4ea3-af11-c80fe2fc0d08	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::1	2025-11-05 16:24:35.401917+00	2025-11-05 16:26:51.928503+00	f	2025-11-05 16:29:08.592227+00	\N	f
fa9afdf8-2473-4f0e-ac45-3c62f0982ba7	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	127.0.0.1	2025-11-29 19:47:26.539946+00	2025-11-29 19:50:27.663322+00	f	2025-11-29 19:50:40.165813+00	\N	f
0ece0fa8-4425-4d8b-9554-ad32142629e0	8	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.105	2025-11-25 10:09:03.296305+00	2025-11-25 10:09:34.118209+00	f	2025-11-25 10:09:34.118344+00	2025-11-25 10:09:34.118344+00	t
c9bcb21f-a82d-4b38-a9c0-76e6b769634b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 08:51:20.282747+00	2025-12-04 08:59:55.40625+00	f	2025-12-04 09:00:03.925885+00	\N	f
42cb5090-772a-4247-adbe-0ca6b723b2ba	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	127.0.0.1	2025-11-21 10:13:12.344326+00	2025-11-21 10:14:13.943995+00	f	2025-11-21 10:15:53.180713+00	\N	f
b3be99cd-b4e5-4ee2-97f2-1058f321481d	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.109 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.109 Mobile Safari/537.36	192.168.1.212	2026-02-07 16:21:06.869004+00	2026-02-07 22:22:05.552576+00	f	2026-02-08 22:22:20.634924+00	\N	f
f7c256be-75a8-44cb-a478-fcdb6ea5ee01	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.120 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.120 Mobile Safari/537.36	172.18.0.1	2026-03-07 16:38:02.461448+00	2026-03-07 16:55:50.42797+00	f	2026-03-07 17:03:23.771412+00	\N	f
16174830-507c-442a-ae92-a1f4807940c5	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	192.168.1.186	2026-01-03 19:39:09.398086+00	2026-01-03 19:39:24.624802+00	f	2026-01-05 07:59:35.862366+00	\N	f
80bedfc5-ce35-476d-9d3d-1d10d1da923f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	172.18.0.1	2026-04-24 19:36:08.24363+00	2026-04-24 19:43:22.571147+00	f	2026-04-24 19:43:22.571258+00	2026-04-24 19:43:22.571258+00	t
3ee05217-9b83-466e-8397-9557358c6a85	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.105	2025-11-25 09:54:22.890022+00	2025-11-25 10:06:31.219645+00	f	2025-11-25 10:06:31.222171+00	2025-11-25 10:06:31.222171+00	t
2d55142a-0618-45c2-a8a8-6c63552975d7	7	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.186	2025-11-22 18:40:05.173798+00	2025-11-22 18:46:18.159604+00	f	2025-11-22 18:46:18.159672+00	2025-11-22 18:46:18.159672+00	t
edf350c2-ab3f-4d7d-b569-a5c2cfa74297	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 09:15:25.915852+00	2025-12-04 09:18:36.254097+00	f	2025-12-04 09:18:36.254418+00	2025-12-04 09:18:36.254418+00	t
094580da-7bba-4fbf-8ce1-7250ed5b8cde	28	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.186	2025-11-22 18:46:29.198315+00	2025-11-22 19:07:00.955082+00	f	2025-11-24 08:01:35.978423+00	\N	f
f9f312c7-f2a3-495f-b989-afda5a13d08b	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.208	2025-11-17 17:45:28.114372+00	2025-11-17 17:48:25.566953+00	f	2025-11-21 10:00:28.673144+00	\N	f
e9ddf775-9b33-468f-9851-9d918194ae48	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/143.0.7499.192 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/143.0.7499.192 Mobile Safari/537.36	192.168.1.179	2026-01-31 17:49:46.202207+00	2026-01-31 18:46:33.189839+00	f	2026-02-01 18:46:56.89788+00	\N	f
68ec3e5f-427e-4d63-afba-606d20a5c277	28	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 09:24:38.638529+00	2025-12-04 10:32:22.283776+00	f	2025-12-05 10:32:49.813286+00	\N	f
f1d82ddb-a730-45ec-bc41-d4d8ba0e9776	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-03 11:39:18.58432+00	2025-11-03 11:50:39.08729+00	f	2025-11-03 11:50:39.087552+00	2025-11-03 11:50:39.087552+00	t
46cd039a-1667-4de1-83d0-83ce70661554	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.160.1	2025-11-21 10:15:53.186995+00	2025-11-21 10:16:17.282262+00	f	2025-11-21 10:44:13.430615+00	\N	f
3c938782-46a2-490b-9ea7-23f8a51f6074	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 09:00:03.927633+00	2025-12-04 09:03:19.114665+00	f	2025-12-04 09:03:36.496072+00	\N	f
bbd64e5f-aa59-4fcd-b58e-4175e0143253	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.105	2025-11-25 08:23:43.725793+00	2025-11-25 08:28:56.48801+00	f	2025-11-25 09:07:25.261458+00	\N	f
df3f999d-7424-46b2-8985-4e9a240901e2	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.102 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/142.0.7444.102 Mobile Safari/537.36	192.168.1.208	2025-11-29 19:50:40.169247+00	2025-11-29 20:24:34.974202+00	f	2025-11-29 20:32:20.431986+00	\N	f
6101d156-9733-4651-b597-e994d65acc33	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	192.168.160.1	2026-01-03 15:33:54.64661+00	2026-01-03 15:48:55.492112+00	f	2026-01-03 15:49:47.916319+00	\N	f
f5d4f784-5fda-41cb-9d33-3d869535065d	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	192.168.1.167	2026-01-24 15:13:21.970028+00	2026-01-24 15:14:44.536242+00	f	2026-01-24 15:33:39.342933+00	\N	f
4bace627-b5c5-4b7c-9ba0-7d9dd19c248f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0	192.168.160.1	2026-01-21 11:55:42.052155+00	2026-01-21 12:03:40.087005+00	f	2026-01-21 12:03:54.953253+00	\N	f
105bf2f3-a4a5-4d24-a039-419e6344dc49	7	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	192.168.1.122	2025-11-25 10:07:10.361997+00	2025-11-25 10:11:51.198678+00	f	2025-11-25 10:11:51.198839+00	2025-11-25 10:11:51.198839+00	t
1e11da4d-6fea-4f86-9acb-e548685db439	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-07 17:03:23.778394+00	2026-03-07 19:07:11.458888+00	f	2026-03-09 08:26:46.698301+00	\N	f
66dc39a1-d9d8-423b-8379-f67e65a1d911	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.187	2025-11-22 19:36:03.273212+00	2025-11-22 19:40:38.870666+00	f	2025-11-24 08:01:35.978423+00	\N	f
492f34f2-6d32-4e3a-8872-26fce7cbb31c	7	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	192.168.1.122	2025-11-21 10:18:41.456328+00	2025-11-21 10:18:56.971535+00	f	2025-11-21 12:19:24.28181+00	\N	f
9601ad0d-6c47-4594-a229-629d26e7ecff	28	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 09:18:42.189428+00	2025-12-04 09:18:55.790244+00	f	2025-12-04 09:18:55.836223+00	2025-12-04 09:18:55.836223+00	t
77bbf079-1722-4106-bfd3-db0e2574a462	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-14 16:22:47.253757+00	2026-03-14 17:05:03.35687+00	f	2026-03-14 17:05:08.775427+00	\N	f
a6a8e777-567b-4917-bdb5-decf537e95e0	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.121	2026-02-11 11:55:03.533754+00	2026-02-11 11:57:26.816261+00	f	2026-02-11 11:57:26.857059+00	2026-02-11 11:57:26.857059+00	t
e84e2607-749d-483c-a93f-6caeb8c46127	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-07 09:21:06.127776+00	2026-04-07 09:27:59.368809+00	f	2026-04-07 09:30:36.206035+00	\N	f
d9ad03f6-791b-4df3-b456-91e38f381fd5	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 10:54:49.221758+00	2025-11-11 11:36:28.286299+00	f	2025-11-12 11:36:55.556826+00	\N	f
5bd4baa1-aa12-4e39-8d74-faac740c0a33	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.145	2025-11-07 09:31:54.028601+00	2025-11-07 11:47:01.295815+00	f	2025-11-08 15:17:23.608737+00	\N	f
a616c5d4-841f-4113-88db-c5968e3a62cf	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.175	2025-11-08 20:41:07.54019+00	2025-11-08 21:53:59.980714+00	f	2025-11-09 21:54:09.698515+00	\N	f
78559a20-465a-4c38-9c12-3b2c050ce8fc	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 10:42:40.884944+00	2025-11-11 10:44:17.787705+00	f	2025-11-11 10:48:05.846864+00	\N	f
5804a754-5f85-48cb-be12-b1d87c3df381	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.188	2025-11-21 18:35:04.341856+00	2025-11-21 18:36:13.362816+00	f	2025-11-21 18:50:52.986055+00	\N	f
33c92ed0-1991-479d-8141-9ff866b4a89b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.112	2025-11-08 17:19:57.560239+00	2025-11-08 20:41:01.008726+00	f	2025-11-08 20:41:07.53078+00	\N	f
9300822f-7ccb-40c8-a728-2f1aa9917106	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 10:48:05.852716+00	2025-11-11 10:48:12.557435+00	f	2025-11-11 10:54:49.217067+00	\N	f
98d87d05-7f81-488e-abef-780b5e2152bd	8	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 11:36:51.840255+00	2025-11-11 11:37:21.981837+00	f	2025-11-12 11:37:55.690235+00	\N	f
3776781f-f569-428b-baeb-fb87912a999c	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.208	2025-11-15 16:54:30.416186+00	2025-11-15 19:35:39.187957+00	f	2025-11-15 20:40:13.656899+00	\N	f
8d6450f9-98e6-4396-9fc2-e692dd223236	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 11:37:39.763257+00	2025-11-11 13:28:49.948303+00	f	2025-11-12 16:05:30.347687+00	\N	f
ef83642f-de46-41b1-a2f5-944cb738b646	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/3.0.2 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/3.0.2 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	127.0.0.1	2025-11-25 09:07:25.263543+00	2025-11-25 09:08:41.271232+00	f	2025-11-25 09:12:23.871385+00	\N	f
4c9418fe-580c-42ee-a6c0-822991eb9ad3	27	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.120 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.120 Mobile Safari/537.36	172.18.0.1	2026-03-07 17:42:51.261+00	2026-03-07 17:42:51.579044+00	f	2026-03-07 17:43:04.507309+00	\N	f
fa79faf3-7b04-4d3f-90a0-1367b6dc5f3c	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.176	2026-01-31 17:50:57.36898+00	2026-01-31 18:50:46.459044+00	f	2026-02-01 18:50:56.904081+00	\N	f
c2f2e199-9b79-40c0-aaad-1e7ec48e86ae	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 09:03:36.503461+00	2025-12-04 09:10:01.140852+00	f	2025-12-04 09:10:21.101286+00	\N	f
165851ba-c9e0-48c5-a3e7-986e2751aae8	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.118	2025-12-03 17:19:03.102651+00	2025-12-03 17:21:26.911875+00	f	2025-12-04 09:19:02.537809+00	\N	f
cf96e353-2a6c-43d1-8cbb-03f420f267c8	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/3.0.2 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/3.0.2 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	127.0.0.1	2025-11-25 09:37:33.168809+00	2025-11-25 09:41:13.102459+00	f	2025-11-25 09:52:56.942744+00	\N	f
c4d99e04-14a9-4311-9f37-eaa33053056b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.100	2025-11-29 20:32:20.449802+00	2025-11-29 20:32:21.73971+00	f	2025-12-01 08:35:05.364422+00	\N	f
05d9e44c-8f87-40d1-9f3b-22119a0765f8	27	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.120 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.120 Mobile Safari/537.36	172.18.0.1	2026-03-07 17:43:04.509712+00	2026-03-07 19:03:32.521913+00	f	2026-03-09 08:26:46.698301+00	\N	f
67d37d43-b41a-4fdf-8b81-319ae35111b8	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.112	2025-11-08 17:18:01.258756+00	2025-11-08 17:19:52.160026+00	f	2025-11-08 17:19:52.161068+00	2025-11-08 17:19:52.161068+00	t
0e8f8b03-ace9-4a4a-8f87-a154fa1251da	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.188	2025-11-21 18:50:53.005723+00	2025-11-21 18:51:12.890651+00	f	2025-11-22 18:40:05.170624+00	\N	f
175822e1-ff2e-472c-aef7-42e4cc47623b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	192.168.1.124	2026-01-21 12:03:54.958094+00	2026-01-21 12:41:54.55272+00	f	2026-01-21 15:16:01.853123+00	\N	f
e0984b54-d5ca-429c-a148-a32f46541f0f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.129	2025-11-17 09:32:24.230922+00	2025-11-17 18:39:47.405241+00	f	2025-11-17 18:42:27.176086+00	\N	f
dd7441e0-1e7f-461a-9c20-c133cb346de4	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	192.168.1.197	2026-01-03 15:49:47.920049+00	2026-01-03 15:53:35.602204+00	f	2026-01-03 15:54:29.590661+00	\N	f
7c263bab-6f1e-411b-8acf-4f5ce5f1b35e	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/1.0.0 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/1.0.0 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	127.0.0.1	2025-11-21 10:44:13.443595+00	2025-11-21 10:44:13.443595+00	f	2025-11-21 11:31:06.560956+00	\N	f
071359a7-44df-4c95-ac04-8fe2c70878e6	28	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.208	2025-11-15 20:40:13.66331+00	2025-11-15 21:31:10.09163+00	f	2025-11-17 08:01:51.686428+00	\N	f
ba0c2744-0eb3-4013-bd49-559025736076	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.187	2025-11-22 20:39:42.661778+00	2025-11-22 20:51:47.312394+00	f	2025-11-24 08:01:35.978423+00	\N	f
03f03670-4fbc-4227-bae9-f669bae4b48a	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.211.1	2025-12-04 13:04:16.47484+00	2025-12-05 10:12:08.410544+00	f	2025-12-05 15:15:59.286726+00	\N	f
3638e016-cb6b-4ab5-8769-077e926b10bc	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/143.0.7499.192 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/143.0.7499.192 Mobile Safari/537.36	192.168.1.225	2026-01-24 15:33:39.370276+00	2026-01-24 22:09:40.725544+00	f	2026-01-25 22:09:43.449912+00	\N	f
82308a93-5fe7-4813-9bd9-4e197bd01c04	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-10 16:41:34.0639+00	2026-03-10 17:12:07.10101+00	f	2026-03-10 17:12:07.101179+00	2026-03-10 17:12:07.101179+00	t
964745eb-9812-4ff6-ab48-04763b13853c	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.111	2026-02-11 14:28:42.230748+00	2026-02-11 15:00:20.86445+00	f	2026-02-11 15:00:32.007143+00	\N	f
e6640fc1-b48c-4fcb-9b43-754d4525555e	8	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.111	2026-02-12 10:15:59.090736+00	2026-02-12 15:37:15.35071+00	f	2026-02-13 16:28:03.197203+00	\N	f
9bdd2cfc-2117-4815-8a06-66720b3d0005	1	Mozilla/5.0 (Linux; U; Android 9; SM-T540 Build/PPR1.180610.011; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/138.0.7204.179 Safari/537.36 OPR/97.1.2254.80849	Mozilla/5.0 (Linux; U; Android 9; SM-T540 Build/PPR1.180610.011; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/138.0.7204.179 Safari/537.36 OPR/97.1.2254.80849	192.168.1.253	2026-02-14 14:49:42.283449+00	2026-02-14 14:49:57.690645+00	f	2026-02-14 15:27:03.886684+00	\N	f
90f89d22-a13d-4b5b-ab14-9200fbbd7634	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	192.168.1.128	2026-02-14 15:43:19.734746+00	2026-02-14 20:19:26.549996+00	f	2026-02-16 13:40:47.833601+00	\N	f
03aa0f6a-4007-47ae-b041-2f2c467a6bb4	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.134	2026-02-12 12:45:29.328052+00	2026-02-12 18:05:04.586455+00	f	2026-02-12 18:05:11.885638+00	\N	f
f3de6576-4ede-4c88-8e1d-925b9ac6f7b1	28	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.134	2026-02-14 19:53:46.704886+00	2026-02-14 19:56:53.710983+00	f	2026-02-16 13:40:47.833601+00	\N	f
76899a2a-cf0d-4b30-bbd2-0b32bfe43ea9	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.111	2026-02-12 18:05:11.924958+00	2026-02-12 18:17:55.990225+00	f	2026-02-13 18:18:03.643132+00	\N	f
1539e67f-e614-4756-8b1b-8d38d080888c	28	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.134	2026-02-12 18:21:25.819066+00	2026-02-12 18:31:50.950408+00	f	2026-02-13 18:32:03.780877+00	\N	f
81f2601f-1026-4dba-b349-78fb177fea7f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	172.18.0.1	2026-04-24 20:28:40.757714+00	2026-04-24 20:28:47.249747+00	t	\N	\N	f
94f1e779-4ffc-4e08-98d4-2361ecaecf4b	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.121	2026-02-12 10:04:41.300049+00	2026-02-12 10:24:20.513536+00	f	2026-02-12 10:24:20.513642+00	2026-02-12 10:24:20.513642+00	t
2fb5fe27-36aa-4785-a40f-e16133aafef2	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	192.168.1.128	2026-02-14 15:27:03.894764+00	2026-02-14 15:39:17.399247+00	f	2026-02-14 15:43:19.728186+00	\N	f
74cf5d0c-3495-49f6-b820-78261ae5e38d	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.134	2026-02-14 13:35:53.487559+00	2026-02-14 14:31:28.060154+00	f	2026-02-14 14:49:42.273544+00	\N	f
734c0c46-3178-4aee-bc04-c6f1eb29a73c	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	2026-02-21 12:28:52.74544+00	2026-02-21 12:29:25.211166+00	f	2026-02-21 12:30:13.394627+00	\N	f
555fdb4a-c7be-420d-b5cb-3bcfe46c489e	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	192.168.1.122	2026-02-21 12:30:13.399039+00	2026-02-21 12:48:31.375294+00	f	2026-02-21 14:16:31.359751+00	\N	f
f40e8690-8fe6-4fd7-b003-44dd7fb49d51	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.26.144.1	2026-02-21 14:16:31.368019+00	2026-02-21 14:46:31.139329+00	f	2026-02-21 15:03:51.451697+00	\N	f
b23f0aa8-f93c-47e9-b1fe-b598aba0e748	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.26.144.1	2026-02-21 15:03:51.456998+00	2026-02-21 15:04:01.674068+00	f	2026-02-21 15:19:29.506098+00	\N	f
6852ae03-daaf-4e6e-8a17-1ff884a05624	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36	172.18.0.1	2026-04-07 09:30:36.210397+00	2026-04-07 09:31:22.463264+00	f	2026-04-07 13:02:24.375817+00	\N	f
3a5b718f-2191-447b-a68a-8946fa415922	7	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.120 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.159 Mobile Safari/537.36	172.18.0.1	2026-03-14 17:09:25.934161+00	2026-03-14 17:55:05.613463+00	f	2026-03-14 17:56:29.135711+00	\N	f
028b0192-0a24-45b6-9aa0-0d36470e67ef	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.112	2025-11-08 16:00:48.924865+00	2025-11-08 17:17:54.398493+00	f	2025-11-08 17:17:54.398871+00	2025-11-08 17:17:54.398871+00	t
872d71de-0838-4024-a179-2cf97fdd6c01	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.121	2026-02-11 15:00:32.012292+00	2026-02-12 10:04:12.236887+00	f	2026-02-12 10:04:12.237015+00	2026-02-12 10:04:12.237015+00	t
8e272d5f-e565-4ffa-9e37-52d2bd8cb399	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-25 12:33:32.946952+00	2026-02-26 11:17:40.628792+00	f	2026-02-26 12:37:56.684115+00	\N	f
805b73f2-72f0-43eb-8b36-3d124ef2995b	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-03-28 15:11:29.89944+00	2026-03-28 20:12:02.302839+00	f	2026-03-28 20:12:14.866212+00	\N	f
ac77b103-575c-40f1-abc9-3187df78c89e	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	172.18.0.1	2026-02-21 17:47:19.973688+00	2026-02-21 19:29:10.264058+00	f	2026-02-21 19:29:12.764986+00	\N	f
0012348e-fd48-43e9-ad53-7323b2178a20	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 09:19:02.538993+00	2025-12-04 09:23:23.086154+00	f	2025-12-04 09:23:23.086316+00	2025-12-04 09:23:23.086316+00	t
bf08b7d7-19e6-432c-9d51-e2673d90f351	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-21 15:19:29.509225+00	2026-02-21 15:21:05.760457+00	f	2026-02-21 15:30:00.162128+00	\N	f
5bd4e686-8a81-4e2a-ae14-33d6a67b2142	7	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	172.18.0.1	2026-02-27 12:37:59.198527+00	2026-02-27 12:42:32.113015+00	f	2026-02-27 12:42:32.124865+00	2026-02-27 12:42:32.124865+00	t
88a68bac-bfb6-4333-b42d-3d713c7fe9c9	7	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.159 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.159 Mobile Safari/537.36	172.18.0.1	2026-03-14 17:56:29.140398+00	2026-03-14 19:29:19.795637+00	f	2026-03-14 19:29:19.80915+00	2026-03-14 19:29:19.80915+00	t
2daaa75b-47c8-4dc3-8e6f-80d95d456034	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	172.18.0.1	2026-02-26 19:28:43.430368+00	2026-02-26 19:34:37.992642+00	f	2026-02-27 08:18:36.219407+00	\N	f
1b785cb5-a7d4-46e7-8592-0b24e675225c	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.159 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.159 Mobile Safari/537.36	172.18.0.1	2026-03-21 15:18:24.445+00	2026-03-21 22:35:21.606602+00	f	2026-03-23 08:01:30.370344+00	\N	f
053222f1-90d0-41ca-bbed-13213c2f210a	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-16 09:32:45.539345+00	2026-03-16 09:42:08.276555+00	f	2026-03-16 09:43:36.422165+00	\N	f
eafa6429-277e-4c58-a7de-8081e128ea06	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-04 13:00:14.646561+00	2026-04-04 21:13:36.316611+00	f	2026-04-05 21:14:16.512939+00	\N	f
c63ee08d-95ea-42da-b4c2-f692e7c18f84	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-07 13:02:24.384118+00	2026-04-07 13:16:36.353477+00	f	2026-04-10 08:17:25.700567+00	\N	f
ba3bfd43-c564-4658-8a8e-7c679774c87a	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	172.18.0.1	2026-04-11 15:14:01.361541+00	2026-04-11 15:16:47.543655+00	f	2026-04-11 16:21:13.254655+00	\N	f
414640ca-c89d-472d-8957-66e70ca48f84	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.121	2026-02-12 10:24:29.381259+00	2026-02-12 12:42:24.84128+00	f	2026-02-12 12:42:24.879252+00	2026-02-12 12:42:24.879252+00	t
fab82882-5f57-49b4-b5d1-7fdc939c1e5b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-21 19:29:12.768355+00	2026-02-21 19:49:31.724939+00	f	2026-02-23 08:08:32.79017+00	\N	f
117b66bf-39f8-4f59-b306-fb6a388caaa4	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 10:44:25.063312+00	2025-11-11 10:47:46.06558+00	f	2025-11-11 10:47:46.065758+00	2025-11-11 10:47:46.065758+00	t
41e3434d-5909-4d4f-8c89-18a4c3df879f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-23 18:23:28.359155+00	2026-02-24 14:41:15.603841+00	f	2026-02-24 19:34:19.836973+00	\N	f
8613c4f5-1629-4ce8-bb40-c360696ea903	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	172.18.0.1	2026-02-21 15:30:00.167021+00	2026-02-21 16:57:50.741051+00	f	2026-02-21 17:01:40.686014+00	\N	f
962ed5e4-d0e0-4d69-a421-483cd246dc07	28	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-03-21 15:37:54.313401+00	2026-03-21 18:07:03.712772+00	f	2026-03-21 22:31:36.628014+00	\N	f
e5f37221-bdfd-4e2c-bf79-9a8f8dce6a61	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-23 08:21:21.875359+00	2026-02-23 14:27:16.510018+00	f	2026-02-23 18:23:28.349388+00	\N	f
c21e6aed-5ab8-4148-8e4b-daf8e15e3100	1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-14 17:05:08.778836+00	2026-03-14 18:46:40.771861+00	f	2026-03-14 19:30:17.300223+00	\N	f
ae6139c7-8bed-45b0-8440-06c5ac7bef2d	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 10:32:16.88638+00	2025-11-11 10:32:53.223175+00	f	2025-11-11 10:32:53.223237+00	2025-11-11 10:32:53.223237+00	t
0c8071f2-ccc6-4d4c-9dee-96475bdbd544	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 10:13:03.315208+00	2025-11-11 10:31:36.408727+00	f	2025-11-11 10:31:36.502908+00	2025-11-11 10:31:36.502908+00	t
b2c4478a-a28b-4a72-bacc-bb2e903c9684	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 10:41:02.728088+00	2025-11-11 10:42:28.011407+00	f	2025-11-11 10:42:28.011481+00	2025-11-11 10:42:28.011481+00	t
beb4a0a3-2d84-4b45-bab5-c2ba7e6058c5	7	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	172.18.0.1	2026-02-25 18:52:20.673629+00	2026-02-25 19:14:43.657981+00	f	2026-02-26 19:15:18.632498+00	\N	f
f92b6448-1364-4648-b61b-2db04458320b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-16 09:43:36.42584+00	2026-03-16 10:12:45.456684+00	f	2026-03-17 10:13:28.144833+00	\N	f
fe233cca-2ce5-40c7-8c19-1462ba2e6e68	28	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/146.0.7680.119 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/146.0.7680.119 Mobile Safari/537.36	172.18.0.1	2026-03-28 16:34:55.807709+00	2026-03-28 22:01:36.270129+00	f	2026-03-28 22:01:36.717471+00	\N	f
686d7ef2-60b6-460d-b169-acacafac19d8	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-07 08:05:45.689022+00	2026-04-07 08:43:59.340139+00	f	2026-04-07 08:45:12.000758+00	\N	f
ae08bc3f-301e-4e9f-b57d-81d6e40e0631	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-11 16:21:13.259817+00	2026-04-11 21:05:44.018837+00	f	2026-04-13 08:13:05.744831+00	\N	f
26bf61ea-fb95-4244-8488-a8a4477a7a98	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.104	2025-09-17 09:45:12.049874+00	2025-09-17 09:59:18.405812+00	f	2025-09-17 09:59:18.496054+00	2025-09-17 09:59:18.496054+00	t
bafcf535-0c2d-40bc-8913-42f4bf32f9b4	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	::ffff:192.168.1.131	2025-09-25 10:57:34.241502+00	2025-09-25 11:17:41.450712+00	f	2025-09-25 11:17:41.451235+00	2025-09-25 11:17:41.451235+00	t
9779b51c-b27a-4ae4-865c-823e2321f6f5	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/1.0.0 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) gouzepe-efootball-desktop/1.0.0 Chrome/142.0.7444.175 Electron/39.2.3 Safari/537.36	127.0.0.1	2025-11-21 11:31:06.577493+00	2025-11-21 12:19:12.976105+00	f	2025-11-21 12:19:12.97649+00	2025-11-21 12:19:12.97649+00	t
ea904724-33f6-4170-a5ac-03eac51cc423	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-03-28 20:12:14.869739+00	2026-03-28 20:12:16.645716+00	f	2026-03-28 20:44:53.524284+00	\N	f
292c1839-a80e-49b2-843c-aee204aa1aa4	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	172.18.0.1	2026-04-13 10:46:51.290904+00	2026-04-13 10:48:40.19843+00	f	2026-04-13 10:48:40.198675+00	2026-04-13 10:48:40.198675+00	t
2c57227e-b4f9-4468-a3bf-04817cd04553	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-25 09:47:28.255082+00	2026-02-25 12:20:46.918422+00	f	2026-02-25 12:20:46.918764+00	2026-02-25 12:20:46.918764+00	t
a5b89dd2-31d1-4373-94c7-e7dcf25e4a08	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	172.18.0.1	2026-02-21 17:01:40.691038+00	2026-02-21 17:22:03.093899+00	f	2026-02-21 17:25:47.822353+00	\N	f
36790ed9-237e-4456-8e7e-9bf455b0b77c	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-07 08:45:12.005461+00	2026-04-07 08:45:12.028747+00	f	2026-04-07 08:45:22.994317+00	\N	f
150a490f-57a2-4356-ba5d-7cfca19ba90c	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-24 19:34:19.844356+00	2026-02-25 09:47:03.027072+00	f	2026-02-25 09:47:03.027222+00	2026-02-25 09:47:03.027222+00	t
2d670dd3-8374-409c-a2ed-9c1187127573	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	192.168.1.167	2026-01-21 15:16:01.866856+00	2026-01-21 15:33:06.734729+00	f	2026-01-21 15:33:06.734793+00	2026-01-21 15:33:06.734793+00	t
f6f8180f-89cd-4165-93f0-f21a2accfa7a	28	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-03-21 22:31:36.630629+00	2026-03-21 22:34:14.347873+00	f	2026-03-23 08:01:30.370344+00	\N	f
1dd8474d-cc22-4fe5-bd43-c8b6936db76b	28	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	172.18.0.1	2026-04-11 17:34:41.274195+00	2026-04-11 22:59:02.477637+00	f	2026-04-13 08:13:05.744831+00	\N	f
10bb793e-350a-464b-b611-c9f406f4ee46	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-14 19:30:17.304406+00	2026-03-14 19:33:43.955606+00	f	2026-03-16 08:03:33.272804+00	\N	f
f1441eab-97ad-41b0-8fbe-8f262f0e43c1	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-26 12:37:56.701241+00	2026-02-26 19:09:38.208236+00	f	2026-02-26 19:09:38.208407+00	2026-02-26 19:09:38.208407+00	t
50b57785-4057-4dd8-bfc4-d6fc5d1ac53e	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-27 08:18:36.224038+00	2026-02-27 17:45:48.654477+00	f	2026-02-27 17:45:48.654683+00	2026-02-27 17:45:48.654683+00	t
3d63b54f-4a87-4917-a672-afa27403734f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	192.168.1.121	2026-02-11 10:27:07.414413+00	2026-02-11 11:54:22.356099+00	f	2026-02-11 11:54:22.404598+00	2026-02-11 11:54:22.404598+00	t
b4e8b4d3-8675-446b-a1dc-118ea2e2d698	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.118	2025-12-03 17:15:33.545244+00	2025-12-03 17:18:51.025832+00	f	2025-12-03 17:18:51.02901+00	2025-12-03 17:18:51.02901+00	t
05707200-be1e-4b76-ada4-237c6cd895e8	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 10:31:42.07944+00	2025-11-11 10:32:10.553433+00	f	2025-11-11 10:32:10.626709+00	2025-11-11 10:32:10.626709+00	t
3b06473f-680a-44d4-a7f5-d8a7138227bd	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-03-28 20:44:53.527485+00	2026-03-28 22:40:34.393828+00	f	2026-03-30 08:44:53.798628+00	\N	f
a1097865-7740-482d-9dcc-c937044a223c	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	::ffff:192.168.1.124	2025-11-11 08:44:45.136782+00	2025-11-11 10:12:40.91672+00	f	2025-11-11 10:12:40.916803+00	2025-11-11 10:12:40.916803+00	t
37887808-8d1d-42d7-b4ca-50752acffd96	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.105	2025-11-25 10:02:29.929491+00	2025-11-25 10:09:48.265781+00	f	2025-11-25 10:09:48.266499+00	2025-11-25 10:09:48.266499+00	t
abf75bf3-f7b0-4e36-ab18-4fe141a7b5b1	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	172.18.0.1	2026-02-21 17:25:47.826319+00	2026-02-21 17:47:05.499088+00	f	2026-02-21 17:47:19.970311+00	\N	f
dd5abcbe-3cd3-4e81-b31e-911ccff9fdfe	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.105	2025-11-25 13:18:36.538419+00	2025-11-25 13:19:04.485257+00	f	2025-11-25 13:19:04.485384+00	2025-11-25 13:19:04.485384+00	t
e8d3e7fe-cb8b-490a-88b7-388fe4df4b64	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.1.105	2025-11-25 09:52:56.952284+00	2025-11-25 09:56:12.004003+00	f	2025-11-25 09:56:12.151518+00	2025-11-25 09:56:12.151518+00	t
09b8b0da-5e6e-4f3c-acbc-430610a8bdec	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-07 08:45:22.998522+00	2026-04-07 08:46:06.10778+00	f	2026-04-07 08:46:16.37647+00	\N	f
62b6c093-7d15-476d-8950-af029bce396f	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	192.168.211.1	2025-12-05 15:15:59.303314+00	2025-12-05 16:45:30.88351+00	f	2025-12-05 16:45:30.93975+00	2025-12-05 16:45:30.93975+00	t
3287c64a-7386-4dd2-96af-f39b07c39010	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-28 19:22:07.238302+00	2026-02-28 19:31:46.522189+00	f	2026-02-28 19:31:46.522323+00	2026-02-28 19:31:46.522323+00	t
6ef21fff-f65b-4664-9184-835796342678	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-02-28 19:35:38.548169+00	2026-02-28 23:16:44.607716+00	f	2026-03-02 09:06:55.706995+00	\N	f
e79f9dc0-dc8e-4ba6-9b61-5cb970f1ec74	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36	172.18.0.1	2026-02-28 15:42:23.435183+00	2026-02-28 19:22:02.164127+00	f	2026-02-28 19:22:07.141987+00	\N	f
b91e3f16-d67f-4b8a-8c3d-07085c6e9dfe	1	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 11; Smart TV Build/AR2101) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.132 Mobile Safari/537.36	172.18.0.1	2026-02-28 15:33:43.41322+00	2026-02-28 15:34:31.847678+00	f	2026-02-28 15:34:51.802766+00	\N	f
033bab53-136e-4e0e-86c0-5a577d5ba2b6	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	172.18.0.1	2026-02-28 15:34:51.80614+00	2026-02-28 15:37:53.249669+00	f	2026-02-28 15:42:23.430878+00	\N	f
2a5163af-9743-4e69-bb25-8a92cbb5a98a	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	172.18.0.1	2026-04-18 14:09:02.984747+00	2026-04-18 14:12:21.420111+00	f	2026-04-18 14:42:42.172944+00	\N	f
411b5d7a-55e9-4479-8c88-616b22da671b	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	172.18.0.1	2026-02-28 16:23:34.664771+00	2026-02-28 20:23:28.807116+00	f	2026-02-28 20:23:28.807302+00	2026-02-28 20:23:28.807302+00	t
274f2fd4-e1e2-4a87-a0a2-28607ca774e8	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	172.18.0.1	2026-02-28 15:33:07.274138+00	2026-02-28 15:33:39.265408+00	f	2026-02-28 15:33:43.41009+00	\N	f
740a5216-d757-4826-8685-b0fc4c2cac4a	28	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-03-28 22:01:36.720258+00	2026-03-28 22:01:53.677387+00	f	2026-03-30 08:44:53.798628+00	\N	f
597fee69-99e5-44c3-ab96-5aa0a1711c10	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-07 08:46:16.379869+00	2026-04-07 08:47:40.216751+00	f	2026-04-07 08:53:37.63281+00	\N	f
9996caa4-5497-45cb-87c8-4f9fc470cfd6	28	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	172.18.0.1	2026-02-28 20:23:34.447342+00	2026-02-28 20:25:08.494635+00	f	2026-03-02 09:06:55.706995+00	\N	f
d1ad8381-83fc-48f7-a5d6-9478f24b42da	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	172.18.0.1	2026-04-07 08:53:37.637056+00	2026-04-07 09:09:24.136609+00	f	2026-04-07 09:21:06.124546+00	\N	f
ca084d34-5d1b-4672-8ef6-dd0a3df5b88b	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-05 17:04:42.912085+00	2026-03-06 08:42:19.387824+00	f	2026-03-07 15:36:59.927824+00	\N	f
82e56670-e84f-4891-832b-1cdb6e155cbb	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-02 10:44:28.981351+00	2026-03-02 14:40:52.298958+00	f	2026-03-03 14:41:25.207118+00	\N	f
454ec7fd-caaa-4d3e-911b-59a40d852810	1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	172.18.0.1	2026-04-18 14:42:42.176193+00	2026-04-18 19:40:19.231131+00	f	2026-04-20 08:03:45.544814+00	\N	f
3e3f2855-836d-4f41-a2e1-1613ff6ecce3	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	192.168.1.223	2025-12-04 09:10:21.10386+00	2025-12-04 09:15:20.355021+00	f	2025-12-04 09:15:20.357112+00	2025-12-04 09:15:20.357112+00	t
5444b07f-7c89-4209-adbb-f78b716f2f7e	1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	172.18.0.1	2026-03-05 16:56:59.088907+00	2026-03-05 16:58:48.294891+00	f	2026-03-05 16:58:48.295276+00	2026-03-05 16:58:48.295276+00	t
\.


--
-- Data for Name: tournament_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tournament_groups (id, tournament_id, group_name, group_number, created_at) FROM stdin;
\.


--
-- Data for Name: tournament_match_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tournament_match_attachments (id, match_id, uploaded_by_user_id, uploaded_by_participant_id, attachment_type, url, description, verified, verified_by_user_id, verified_at, created_at) FROM stdin;
\.


--
-- Data for Name: tournament_match_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tournament_match_comments (id, match_id, user_id, participant_id, comment_text, created_at) FROM stdin;
\.


--
-- Data for Name: tournament_matches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tournament_matches (id, tournament_id, round_no, slot_no, best_of, p1_participant_id, p2_participant_id, score_p1, score_p2, winner_participant_id, status, walkover, next_match_id, next_match_slot, started_at, finished_at, created_at, updated_at, bracket_side, loser_next_match_id, loser_next_match_slot, group_no) FROM stdin;
410	19	1	2	1	222	220	0	1	220	completed	f	415	2	\N	2026-02-27 12:07:45.017685+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:07:45.017685+00	W	421	2	\N
428	19	13	2	1	216	\N	1	0	216	completed	t	430	1	\N	2026-02-27 12:12:04.935871+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:04.935871+00	L	\N	\N	\N
413	19	1	5	1	221	223	0	1	223	completed	f	417	1	\N	2026-02-27 12:07:49.623543+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:07:49.623543+00	W	423	1	\N
430	19	14	2	1	216	\N	1	0	216	completed	t	431	2	\N	2026-02-27 12:12:04.935871+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:04.935871+00	L	\N	\N	\N
414	19	1	6	1	219	216	0	1	216	completed	f	417	2	\N	2026-02-27 12:07:52.492901+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:07:52.492901+00	W	423	2	\N
427	19	13	1	1	222	225	2	0	222	completed	f	429	1	\N	2026-02-27 12:12:09.211722+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:09.211722+00	L	\N	\N	\N
415	19	2	1	1	218	220	0	1	220	completed	f	418	1	\N	2026-02-27 12:08:01.135772+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:08:01.135772+00	W	424	2	\N
429	19	14	1	1	222	220	1	0	222	completed	f	431	1	\N	2026-02-27 12:12:13.916425+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:13.916425+00	L	\N	\N	\N
411	19	1	3	1	225	217	0	1	217	completed	f	416	1	\N	2026-02-27 12:08:05.787671+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:08:05.787671+00	W	422	1	\N
719	29	2	2	1	322	321	3	1	322	completed	f	\N	\N	\N	2026-04-04 20:00:05.688742+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:00:05.688742+00	W	\N	\N	\N
420	19	4	1	1	217	223	1	0	217	completed	f	433	1	\N	2026-02-27 12:12:18.166307+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:18.166307+00	W	432	2	\N
422	19	11	2	1	225	\N	1	0	225	completed	t	425	1	\N	2026-02-27 12:08:05.787671+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:08:05.787671+00	L	\N	\N	\N
720	29	1	3	1	321	323	4	0	321	completed	f	\N	\N	\N	2026-04-04 20:00:15.785824+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:00:15.785824+00	W	\N	\N	\N
416	19	2	2	1	217	226	1	0	217	completed	f	418	2	\N	2026-02-27 12:08:08.333661+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:08:08.333661+00	W	425	2	\N
721	29	2	4	1	323	321	0	0	\N	completed	f	\N	\N	\N	2026-04-04 20:00:19.361545+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:00:19.361545+00	W	\N	\N	\N
431	19	15	1	1	222	216	1	0	222	completed	f	432	1	\N	2026-02-27 12:12:21.700218+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:21.700218+00	L	\N	\N	\N
432	19	16	1	1	222	223	1	0	222	completed	f	433	2	\N	2026-02-27 12:12:25.435602+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:25.435602+00	L	\N	\N	\N
433	19	20	1	1	217	222	1	0	217	completed	f	\N	\N	\N	2026-02-27 12:12:36.945441+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:36.945441+00	GF	\N	\N	\N
419	19	3	2	1	223	\N	1	0	223	completed	t	420	2	\N	2026-02-27 12:08:10.839246+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:08:10.839246+00	W	430	2	\N
615	25	1	1	1	291	292	0	2	292	completed	f	\N	\N	\N	2026-03-07 17:30:03.088521+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:30:03.088521+00	W	\N	\N	\N
417	19	2	3	1	223	216	1	0	223	completed	f	419	1	\N	2026-02-27 12:08:10.839246+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:08:16.322332+00	W	426	2	\N
418	19	3	1	1	220	217	0	2	217	completed	f	420	1	\N	2026-02-27 12:11:36.320995+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:11:36.320995+00	W	429	2	\N
616	25	2	2	1	292	291	2	4	291	completed	f	\N	\N	\N	2026-03-07 17:44:51.776774+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:44:51.776774+00	W	\N	\N	\N
421	19	11	1	1	224	222	0	2	222	completed	f	424	1	\N	2026-02-27 12:11:47.060356+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:11:47.060356+00	L	\N	\N	\N
423	19	11	3	1	221	219	0	2	219	completed	f	426	1	\N	2026-02-27 12:11:50.7642+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:11:50.7642+00	L	\N	\N	\N
424	19	12	1	1	222	218	1	0	222	completed	f	427	1	\N	2026-02-27 12:11:58.215902+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:11:58.215902+00	L	\N	\N	\N
425	19	12	2	1	225	226	1	0	225	completed	f	427	2	\N	2026-02-27 12:12:01.769562+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:01.769562+00	L	\N	\N	\N
426	19	12	3	1	219	216	0	1	216	completed	f	428	1	\N	2026-02-27 12:12:04.935871+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:12:04.935871+00	L	\N	\N	\N
621	25	1	7	1	291	295	0	1	295	completed	f	\N	\N	\N	2026-03-07 17:05:13.593922+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:05:13.593922+00	W	\N	\N	\N
622	25	2	8	1	295	291	3	0	295	completed	f	\N	\N	\N	2026-03-07 17:05:20.452094+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:05:20.452094+00	W	\N	\N	\N
624	25	2	10	1	293	292	4	0	293	completed	f	\N	\N	\N	2026-03-07 17:08:26.833491+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:08:26.833491+00	W	\N	\N	\N
623	25	1	9	1	292	293	0	1	293	completed	f	\N	\N	\N	2026-03-07 17:08:42.430371+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:08:42.430371+00	W	\N	\N	\N
629	25	1	15	1	293	294	1	1	\N	completed	f	\N	\N	\N	2026-03-07 17:09:20.726691+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:09:20.726691+00	W	\N	\N	\N
630	25	2	16	1	294	293	0	3	293	completed	f	\N	\N	\N	2026-03-07 17:09:31.257158+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:09:31.257158+00	W	\N	\N	\N
631	25	1	17	1	293	295	1	3	295	completed	f	\N	\N	\N	2026-03-07 17:47:15.592166+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:47:15.592166+00	W	\N	\N	\N
632	25	2	18	1	295	293	4	0	295	completed	f	\N	\N	\N	2026-03-07 17:47:33.728012+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:47:33.728012+00	W	\N	\N	\N
634	25	2	20	1	295	294	5	3	295	completed	f	\N	\N	\N	2026-03-07 17:48:01.449688+00	2026-03-07 17:04:49.191514+00	2026-03-07 17:48:01.449688+00	W	\N	\N	\N
412	19	1	4	1	226	\N	1	0	226	completed	t	416	2	\N	2026-02-27 12:07:33.87238+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:07:33.87238+00	W	422	2	\N
617	25	1	3	1	291	293	3	3	\N	completed	f	\N	\N	\N	2026-03-07 18:16:47.497787+00	2026-03-07 17:04:49.191514+00	2026-03-07 18:16:47.497787+00	W	\N	\N	\N
409	19	1	1	1	224	218	0	1	218	completed	f	415	1	\N	2026-02-27 12:07:41.478937+00	2026-02-27 12:07:33.87238+00	2026-02-27 12:07:41.478937+00	W	421	1	\N
618	25	2	4	1	293	291	1	3	291	completed	f	\N	\N	\N	2026-03-07 18:29:27.094933+00	2026-03-07 17:04:49.191514+00	2026-03-07 18:29:27.094933+00	W	\N	\N	\N
620	25	2	6	1	294	291	2	1	294	completed	f	\N	\N	\N	2026-03-07 18:46:03.046355+00	2026-03-07 17:04:49.191514+00	2026-03-07 18:46:03.046355+00	W	\N	\N	\N
626	25	2	12	1	294	292	2	1	294	completed	f	\N	\N	\N	2026-03-07 18:46:21.106429+00	2026-03-07 17:04:49.191514+00	2026-03-07 18:46:21.106429+00	W	\N	\N	\N
625	25	1	11	1	292	294	4	2	292	completed	f	\N	\N	\N	2026-03-07 18:46:29.00978+00	2026-03-07 17:04:49.191514+00	2026-03-07 18:46:29.00978+00	W	\N	\N	\N
628	25	2	14	1	295	292	2	0	295	completed	f	\N	\N	\N	2026-03-07 18:47:02.238776+00	2026-03-07 17:04:49.191514+00	2026-03-07 18:47:02.238776+00	W	\N	\N	\N
627	25	1	13	1	292	295	1	0	292	completed	f	\N	\N	\N	2026-03-07 18:46:55.4399+00	2026-03-07 17:04:49.191514+00	2026-03-07 18:47:25.078834+00	W	\N	\N	\N
619	25	1	5	1	291	294	3	4	294	completed	f	\N	\N	\N	2026-03-07 19:03:11.178299+00	2026-03-07 17:04:49.191514+00	2026-03-07 19:03:11.178299+00	W	\N	\N	\N
633	25	1	19	1	294	295	4	4	\N	completed	f	\N	\N	\N	2026-03-07 17:48:16.976666+00	2026-03-07 17:04:49.191514+00	2026-03-10 16:58:17.893983+00	W	\N	\N	\N
645	27	2	4	1	303	301	5	2	303	completed	f	\N	\N	\N	2026-03-14 17:00:54.283888+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:00:54.283888+00	W	\N	\N	\N
644	27	1	3	1	301	303	1	2	303	completed	f	\N	\N	\N	2026-03-14 17:01:00.589885+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:01:00.589885+00	W	\N	\N	\N
648	27	1	7	1	301	305	3	1	301	completed	f	\N	\N	\N	2026-03-14 17:01:51.12169+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:01:51.12169+00	W	\N	\N	\N
649	27	2	8	1	305	301	8	2	305	completed	f	\N	\N	\N	2026-03-14 17:01:56.756793+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:01:56.756793+00	W	\N	\N	\N
642	27	1	1	1	301	302	2	3	302	completed	f	\N	\N	\N	2026-03-14 17:12:02.238856+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:12:02.238856+00	W	\N	\N	\N
643	27	2	2	1	302	301	3	2	302	completed	f	\N	\N	\N	2026-03-14 17:12:11.352263+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:12:11.352263+00	W	\N	\N	\N
647	27	2	6	1	304	301	0	5	301	completed	f	\N	\N	\N	2026-03-14 17:57:14.547526+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:57:14.547526+00	W	\N	\N	\N
654	27	1	13	1	302	305	2	1	302	completed	f	\N	\N	\N	2026-03-14 17:16:46.53082+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:16:46.53082+00	W	\N	\N	\N
646	27	1	5	1	301	304	1	2	304	completed	f	\N	\N	\N	2026-03-14 17:12:26.632553+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:17:11.105544+00	W	\N	\N	\N
652	27	1	11	1	302	304	1	0	302	completed	f	\N	\N	\N	2026-03-14 17:57:26.494528+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:57:26.494528+00	W	\N	\N	\N
653	27	2	12	1	304	302	1	4	302	completed	f	\N	\N	\N	2026-03-14 17:57:41.122708+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:57:41.122708+00	W	\N	\N	\N
650	27	1	9	1	302	303	2	1	302	completed	f	\N	\N	\N	2026-03-14 18:31:54.602391+00	2026-03-14 16:25:15.177114+00	2026-03-14 18:31:54.602391+00	W	\N	\N	\N
651	27	2	10	1	303	302	1	1	\N	completed	f	\N	\N	\N	2026-03-14 18:32:03.851755+00	2026-03-14 16:25:15.177114+00	2026-03-14 18:32:03.851755+00	W	\N	\N	\N
656	27	1	15	1	303	304	2	1	303	completed	f	\N	\N	\N	2026-03-14 17:02:14.227739+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:02:14.227739+00	W	\N	\N	\N
657	27	2	16	1	304	303	1	3	303	completed	f	\N	\N	\N	2026-03-14 17:02:23.355078+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:02:23.355078+00	W	\N	\N	\N
660	27	1	19	1	304	305	1	5	305	completed	f	\N	\N	\N	2026-03-14 17:02:58.620384+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:02:58.620384+00	W	\N	\N	\N
661	27	2	20	1	305	304	5	1	305	completed	f	\N	\N	\N	2026-03-14 17:03:05.432245+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:03:05.432245+00	W	\N	\N	\N
655	27	2	14	1	305	302	1	0	305	completed	f	\N	\N	\N	2026-03-14 17:06:11.756281+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:06:11.756281+00	W	\N	\N	\N
658	27	1	17	1	303	305	3	2	303	completed	f	\N	\N	\N	2026-03-14 17:54:53.823837+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:54:53.823837+00	W	\N	\N	\N
659	27	2	18	1	305	303	3	0	305	completed	f	\N	\N	\N	2026-03-14 17:55:13.892897+00	2026-03-14 16:25:15.177114+00	2026-03-14 17:55:13.892897+00	W	\N	\N	\N
718	29	1	1	1	321	322	3	0	321	completed	f	\N	\N	\N	2026-04-04 19:59:59.773258+00	2026-04-04 19:59:40.184696+00	2026-04-04 19:59:59.773258+00	W	\N	\N	\N
728	29	1	11	1	321	327	7	2	321	completed	f	\N	\N	\N	2026-04-04 20:00:35.441869+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:00:35.441869+00	W	\N	\N	\N
729	29	2	12	1	327	321	1	4	321	completed	f	\N	\N	\N	2026-04-04 20:00:47.041395+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:00:47.041395+00	W	\N	\N	\N
727	29	2	10	1	326	321	2	5	321	completed	f	\N	\N	\N	2026-04-04 20:01:03.91537+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:01:03.91537+00	W	\N	\N	\N
730	29	1	13	1	321	328	4	0	321	completed	f	\N	\N	\N	2026-04-04 20:01:14.739239+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:01:14.739239+00	W	\N	\N	\N
731	29	2	14	1	328	321	2	3	321	completed	f	\N	\N	\N	2026-04-04 20:01:27.520543+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:01:27.520543+00	W	\N	\N	\N
738	29	1	21	1	322	326	2	0	322	completed	f	\N	\N	\N	2026-04-04 20:01:41.684309+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:01:41.684309+00	W	\N	\N	\N
739	29	2	22	1	326	322	0	3	322	completed	f	\N	\N	\N	2026-04-04 20:01:47.840587+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:01:47.840587+00	W	\N	\N	\N
740	29	1	23	1	322	327	2	0	322	completed	f	\N	\N	\N	2026-04-04 20:01:54.374267+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:01:54.374267+00	W	\N	\N	\N
741	29	2	24	1	327	322	1	2	322	completed	f	\N	\N	\N	2026-04-04 20:02:01.982028+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:02:01.982028+00	W	\N	\N	\N
732	29	1	15	1	322	323	0	2	323	completed	f	\N	\N	\N	2026-04-04 20:02:27.957785+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:02:27.957785+00	W	\N	\N	\N
733	29	2	16	1	323	322	0	2	322	completed	f	\N	\N	\N	2026-04-04 20:02:32.565917+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:02:32.565917+00	W	\N	\N	\N
736	29	1	19	1	322	325	0	3	325	completed	f	\N	\N	\N	2026-04-04 20:02:44.627055+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:02:44.627055+00	W	\N	\N	\N
737	29	2	20	1	325	322	0	0	\N	completed	f	\N	\N	\N	2026-04-04 20:02:48.692645+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:02:48.692645+00	W	\N	\N	\N
734	29	1	17	1	322	324	1	4	324	completed	f	\N	\N	\N	2026-04-04 20:02:58.881459+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:02:58.881459+00	W	\N	\N	\N
735	29	2	18	1	324	322	3	2	324	completed	f	\N	\N	\N	2026-04-04 20:03:05.651284+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:03:05.651284+00	W	\N	\N	\N
748	29	1	31	1	323	326	2	0	323	completed	f	\N	\N	\N	2026-04-04 20:03:53.277481+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:03:53.277481+00	W	\N	\N	\N
749	29	2	32	1	326	323	0	1	323	completed	f	\N	\N	\N	2026-04-04 20:04:00.576394+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:04:00.576394+00	W	\N	\N	\N
746	29	1	29	1	323	325	2	2	\N	completed	f	\N	\N	\N	2026-04-04 20:04:09.2408+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:04:09.2408+00	W	\N	\N	\N
747	29	2	30	1	325	323	2	0	325	completed	f	\N	\N	\N	2026-04-04 20:04:20.697533+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:04:20.697533+00	W	\N	\N	\N
752	29	1	35	1	323	328	4	0	323	completed	f	\N	\N	\N	2026-04-04 20:04:36.984835+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:04:36.984835+00	W	\N	\N	\N
753	29	2	36	1	328	323	1	1	\N	completed	f	\N	\N	\N	2026-04-04 20:04:43.024351+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:04:43.024351+00	W	\N	\N	\N
744	29	1	27	1	323	324	1	3	324	completed	f	\N	\N	\N	2026-04-04 20:04:51.536495+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:04:51.536495+00	W	\N	\N	\N
745	29	2	28	1	324	323	2	1	324	completed	f	\N	\N	\N	2026-04-04 20:04:56.04207+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:04:56.04207+00	W	\N	\N	\N
750	29	1	33	1	323	327	2	0	323	completed	f	\N	\N	\N	2026-04-04 20:05:18.609068+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:05:18.609068+00	W	\N	\N	\N
751	29	2	34	1	327	323	0	6	323	completed	f	\N	\N	\N	2026-04-04 20:05:24.103264+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:05:24.103264+00	W	\N	\N	\N
723	29	2	6	1	324	321	3	1	324	completed	f	\N	\N	\N	2026-04-04 20:05:32.922149+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:05:32.922149+00	W	\N	\N	\N
754	29	1	37	1	324	325	2	2	\N	completed	f	\N	\N	\N	2026-04-04 20:06:00.890826+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:06:00.890826+00	W	\N	\N	\N
755	29	2	38	1	325	324	1	3	324	completed	f	\N	\N	\N	2026-04-04 20:06:07.832548+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:06:07.832548+00	W	\N	\N	\N
756	29	1	39	1	324	326	2	0	324	completed	f	\N	\N	\N	2026-04-04 20:06:23.142637+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:06:23.142637+00	W	\N	\N	\N
757	29	2	40	1	326	324	1	3	324	completed	f	\N	\N	\N	2026-04-04 20:06:35.850305+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:06:35.850305+00	W	\N	\N	\N
758	29	1	41	1	324	327	1	0	324	completed	f	\N	\N	\N	2026-04-04 20:06:52.405504+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:06:52.405504+00	W	\N	\N	\N
759	29	2	42	1	327	324	0	3	324	completed	f	\N	\N	\N	2026-04-04 20:06:57.27321+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:06:57.27321+00	W	\N	\N	\N
760	29	1	43	1	324	328	3	2	324	completed	f	\N	\N	\N	2026-04-04 20:07:08.416486+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:07:08.416486+00	W	\N	\N	\N
761	29	2	44	1	328	324	0	5	324	completed	f	\N	\N	\N	2026-04-04 20:07:12.794963+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:07:12.794963+00	W	\N	\N	\N
762	29	1	45	1	325	326	5	2	325	completed	f	\N	\N	\N	2026-04-04 20:07:27.732479+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:07:27.732479+00	W	\N	\N	\N
763	29	2	46	1	326	325	2	3	325	completed	f	\N	\N	\N	2026-04-04 20:07:32.560006+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:07:32.560006+00	W	\N	\N	\N
768	29	1	51	1	326	327	4	1	326	completed	f	\N	\N	\N	2026-04-04 20:08:32.047222+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:08:32.047222+00	W	\N	\N	\N
769	29	2	52	1	327	326	3	3	\N	completed	f	\N	\N	\N	2026-04-04 20:08:36.225531+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:08:36.225531+00	W	\N	\N	\N
764	29	1	47	1	325	327	5	0	325	completed	f	\N	\N	\N	2026-04-04 20:08:49.552387+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:08:49.552387+00	W	\N	\N	\N
765	29	2	48	1	327	325	0	5	325	completed	f	\N	\N	\N	2026-04-04 20:08:54.068314+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:08:54.068314+00	W	\N	\N	\N
766	29	1	49	1	325	328	1	2	328	completed	f	\N	\N	\N	2026-04-04 20:09:05.134308+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:09:05.134308+00	W	\N	\N	\N
767	29	2	50	1	328	325	0	2	325	completed	f	\N	\N	\N	2026-04-04 20:09:09.702832+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:09:09.702832+00	W	\N	\N	\N
770	29	1	53	1	326	328	2	0	326	completed	f	\N	\N	\N	2026-04-04 20:09:27.461559+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:09:27.461559+00	W	\N	\N	\N
772	29	1	55	1	327	328	2	3	328	completed	f	\N	\N	\N	2026-04-04 20:09:57.499042+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:09:57.499042+00	W	\N	\N	\N
771	29	2	54	1	328	326	1	4	326	completed	f	\N	\N	\N	2026-04-04 20:09:32.148978+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:09:38.426887+00	W	\N	\N	\N
773	29	2	56	1	328	327	1	1	\N	completed	f	\N	\N	\N	2026-04-04 20:10:01.576285+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:10:01.576285+00	W	\N	\N	\N
725	29	2	8	1	325	321	2	2	\N	completed	f	\N	\N	\N	2026-04-04 20:11:16.518688+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:11:16.518688+00	W	\N	\N	\N
724	29	1	7	1	321	325	1	3	325	completed	f	\N	\N	\N	2026-04-04 20:11:01.557628+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:11:10.256507+00	W	\N	\N	\N
726	29	1	9	1	321	326	2	3	326	completed	f	\N	\N	\N	2026-04-04 20:00:55.71033+00	2026-04-04 19:59:40.184696+00	2026-04-07 09:22:27.956128+00	W	\N	\N	\N
742	29	1	25	1	322	328	1	1	\N	completed	f	\N	\N	\N	2026-04-04 20:32:26.619842+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:32:26.619842+00	W	\N	\N	\N
743	29	2	26	1	328	322	0	0	\N	completed	f	\N	\N	\N	2026-04-04 20:45:34.645808+00	2026-04-04 19:59:40.184696+00	2026-04-04 20:45:34.645808+00	W	\N	\N	\N
722	29	1	5	1	321	324	2	1	321	completed	f	\N	\N	\N	2026-04-04 20:19:37.696355+00	2026-04-04 19:59:40.184696+00	2026-04-07 09:22:21.142002+00	W	\N	\N	\N
\.


--
-- Data for Name: tournament_participant_stats; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tournament_participant_stats (id, participant_id, phase_id, matches_played, matches_won, matches_lost, games_won, games_lost, points, buchholz, pool_placement, phase_placement, updated_at) FROM stdin;
\.


--
-- Data for Name: tournament_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tournament_participants (id, tournament_id, player_id, seed, created_at, group_no, display_name) FROM stdin;
216	19	AminouFlash	1	2026-02-27 12:07:28.087548+00	\N	Aminou
217	19	CBlacks_GZ	2	2026-02-27 12:07:28.087548+00	\N	Caringthon
218	19	EmRiCxX_GZ	3	2026-02-27 12:07:28.087548+00	\N	Emeric
219	19	Akab_GZ	4	2026-02-27 12:07:28.087548+00	\N	Emmanuel
220	19	Fuego_GZ	5	2026-02-27 12:07:28.087548+00	\N	Ephel
221	19	Zyex_Legend_GZ	6	2026-02-27 12:07:28.087548+00	\N	Ezechiel
222	19	Yousscash_GZ	7	2026-02-27 12:07:28.087548+00	\N	ISSOUFOU
223	19	Ismo	8	2026-02-27 12:07:28.087548+00	\N	Ismaël
224	19	KenkNod_GZ	9	2026-02-27 12:07:28.087548+00	\N	Koboyo
225	19	Rius_oyo_GZ	10	2026-02-27 12:07:28.087548+00	\N	Marius
226	19	Kem_GZ	11	2026-02-27 12:07:28.087548+00	\N	Mawuko
291	25	CBlacks_GZ	1	2026-03-07 17:04:47.78865+00	\N	Caringthon
292	25	Akab_GZ	2	2026-03-07 17:04:47.78865+00	\N	Emmanuel
293	25	Zyex_Legend_GZ	3	2026-03-07 17:04:47.78865+00	\N	Ezechiel
294	25	KenkNod_GZ	4	2026-03-07 17:04:47.78865+00	\N	Koboyo
295	25	Rius_oyo_GZ	5	2026-03-07 17:04:47.78865+00	\N	Marius
301	27	Rod_GZ	1	2026-03-14 16:25:14.133644+00	\N	Folly
302	27	AKA BIG	2	2026-03-14 16:25:14.133644+00	\N	Florient
303	27	CBlacks_GZ	3	2026-03-14 16:25:14.133644+00	\N	Caringthon
304	27	KenkNod_GZ	4	2026-03-14 16:25:14.133644+00	\N	Koboyo
305	27	Ismo	5	2026-03-14 16:25:14.133644+00	\N	Ismaël
321	29	EmRiCxX_GZ	1	2026-04-04 19:59:29.913663+00	\N	Emeric
322	29	Akab_GZ	2	2026-04-04 19:59:29.913663+00	\N	Emmanuel
323	29	AKA BIG	3	2026-04-04 19:59:29.913663+00	\N	Florient
324	29	IBR@93_GZ	4	2026-04-04 19:59:29.913663+00	\N	Ibrahim
325	29	Ismo	5	2026-04-04 19:59:29.913663+00	\N	Ismaël
326	29	Matrix _GZ	6	2026-04-04 19:59:29.913663+00	\N	Max
327	29	GMT_GZ	7	2026-04-04 19:59:29.913663+00	\N	Tanguy
328	29	Walé-GZ	8	2026-04-04 19:59:29.913663+00	\N	Walé
\.


--
-- Data for Name: tournament_pool_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tournament_pool_participants (id, pool_id, participant_id, seed_in_pool) FROM stdin;
\.


--
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tournaments (id, slug, name, format, status, starts_at, ended_at, winner_player_id, created_by, created_at, updated_at, nb_groups, qualifiers_per_group, winner_name, member_tournament, season_id, day_comment, counts_for_title, rr_match_mode, rr_standings_mode) FROM stdin;
19	coupe-7o1hl	COUPE	double_elimination	archived	\N	2026-02-27 12:12:36.945441+00	\N	1	2026-02-27 12:07:11.855284+00	2026-02-27 12:13:28.120561+00	\N	\N	Caringthon	t	2	\N	f	single	goals
25	tournoi-gz-205kp	Tournoi GZ	round_robin	completed	2026-03-07 15:00:00+00	2026-03-10 16:58:17.893983+00	\N	1	2026-03-07 17:04:01.655191+00	2026-03-10 16:58:17.893983+00	\N	\N	Marius	t	2	\N	t	home_away	goals
27	gz-0hkvc	GZ_	round_robin	completed	2026-03-14 15:24:00+00	2026-03-14 18:32:03.851755+00	\N	1	2026-03-14 16:24:55.200232+00	2026-03-14 18:32:03.851755+00	\N	\N	Florient	t	2	\N	t	home_away	goals
29	cup-04-04-2026-sngda	Cup 04/04/2026	round_robin	completed	2026-04-04 15:59:00+00	2026-04-07 09:22:27.956128+00	\N	1	2026-04-04 19:59:12.151274+00	2026-04-07 09:22:27.956128+00	\N	\N	Ibrahim	t	2	\N	t	home_away	goals
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, password_hash, role, created_at, player_id, last_login) FROM stdin;
24	mawuko@gz.local	$2a$10$lkrpAXIOyjJq3IXDrsIdy.gt0ozxjp.zVBbGAlkbhc.Hdh/TiRLyS	member	2025-08-30 21:34:00.047625	Kem_GZ	\N
30	ephel@gz.local	$2a$10$GSAFd51J45CgYINb0xjgdOMpwepoQ/7Av4pcp4mDTjWoCRUVsbg.W	member	2025-12-05 16:41:18.605201	Fuego_GZ	\N
22	wale@gz.local	$2a$10$hQWB9c5br4pjigSuM2.izO072.qhSpOtq09P9HNYm9bx4qdRVhKSa	member	2025-08-28 12:15:14.190003	Walé-GZ	\N
21	tanguy@gz.local	$2a$10$W3oYZLLMYu0a5q68raQ47uyVXKIztsQpoZEljaHhS2tGwAfpHoWJG	member	2025-08-28 12:15:07.250621	GMT_GZ	\N
20	pierre@gz.local	$2a$10$VdLNy8KSY1auCI5YruBhI.Fe2/yBW.2IvPiFityKvQ1C70RDtxWza	member	2025-08-28 12:15:00.255616	Fuente_GZ	\N
17	marius@gz.local	$2a$10$GlHWxOW/D8qgGIVUNHencONDhfSkiKaro5ApsZd9VU6ahoIl7VcL2	member	2025-08-28 12:14:30.777276	Rius_oyo_GZ	\N
16	koboyo@gz.local	$2a$10$jfd4/IRiRoVW/cKf5fRL/OdYWHIJM1H8tGewOx97KheRRoo05tbGu	member	2025-08-28 12:14:24.361267	KenkNod_GZ	\N
14	ibrahim@gz.local	$2a$10$T1ayaWxILmbkXp1/wfoC/OGqgIqwAL3chrJ24FcpydaN3ANi7I1xi	member	2025-08-28 12:13:55.080589	IBR@93_GZ	\N
13	folly@gz.local	$2a$10$4lbdjOsQj3VyLO2U3gjt1uCKbNTCItomcGIEeNYoc3dg/CylA5RmK	member	2025-08-28 12:13:33.948244	Rod_GZ	\N
12	fabio@gz.local	$2a$10$2/pULiTzZIfODeMdQAqUleXCN0iha4BQS1EF6nmoTYnmooII2gh2m	member	2025-08-28 12:13:21.660953	The_One_GZ	\N
11	ezechiel@gz.local	$2a$10$uJqcNQMWkTDgrC9rLP0Hg.hzjKaLdPCUcp1Is9M1.OklLR2qicJH2	member	2025-08-28 12:13:11.296995	Zyex_Legend_GZ	\N
9	emmanuel@gz.local	$2a$10$ktRZcOUBhXi4071djt5IMu5VmNfOYCXe74Dg1kpKC8PnadUi9hpp.	member	2025-08-28 12:12:54.454099	Akab_GZ	\N
15	issifou@gz.local	$2a$10$2yuOAL23EHLCVbySfwh3NOIDY7P2phzxt1s5K5eoFqSDQQuoKF/UW	member	2025-08-28 12:14:13.040689	\N	\N
23	issoufou@gz.local	$2a$10$A5Uyn7hbEUiQmyrpzVy/weh2.rqtN/tkbhe86BGCvCCk1M.9nv7K2	member	2025-08-28 19:11:23.751365	Yousscash_GZ	\N
18	mawouko@gz.local	$2a$10$KcQuVs4hJ6GPyE5BuSL03eJ6woACQGnocLaHEsUSelFjpCIyu7I.a	member	2025-08-28 12:14:38.800057	\N	\N
19	max@gz.local	$2a$10$A4VcxT/Fa5qQ0bJLv5HhPeiZfZKWCCRNpVlXr94A6ad7/Mp2we40.	member	2025-08-28 12:14:46.846303	Matrix _GZ	\N
8	emeric@gz.local	$2a$10$bOn3gEAqBRS5BSg4fFJGOOow9wujI3m5mU0XN.lWClk/J3DkY0Ty6	member	2025-08-28 12:12:26.645738	EmRiCxX_GZ	2026-02-12 10:15:59.098485
26	admin1@gz	$2a$10$uZrv99p0F5Epd9TwcjFwFONp5ys8W3rhctfmsf7d7mq9QETE5KXpq	admin	2025-09-13 18:36:53.509717	\N	\N
7	caringthon@gz.local	$2a$10$XqjnGxfgNdbgB27bIC3QWeEsj3311XVrS/FK2o0aFDkzTnZUWqmXC	member	2025-08-28 11:09:11.349232	CBlacks_GZ	2026-03-14 17:56:29.145016
28	admin@gz.local	$2a$10$/crBZIm2epQVq5eRoL8zo.XvYjPP2YpUzazboqCHPnHy0cT0BpZKe	admin	2025-09-15 10:02:44.710247	\N	2026-04-11 17:34:41.278791
27	user1@gz	$2a$10$Vk5kt4YxwcBMzVttCRk.Te.toldxDIzFgiLvXHZuMQLjN7zgCFoBq	member	2025-09-13 20:40:41.378912	\N	2026-03-07 17:43:04.512867
1	admin@gz	$2a$10$amu0RD7Leykk2ROKsqcQC.AOE7AXnhkGSD4d3LaxNiK5hvrsR5KLu	admin	2025-08-22 10:33:58.882307	\N	2026-04-24 20:28:40.773163
\.


--
-- Name: duels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.duels_id_seq', 14, true);


--
-- Name: match_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.match_attachments_id_seq', 1, false);


--
-- Name: match_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.match_comments_id_seq', 1, false);


--
-- Name: match_games_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.match_games_id_seq', 1, false);


--
-- Name: season_totals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.season_totals_id_seq', 72, true);


--
-- Name: seasons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seasons_id_seq', 2, true);


--
-- Name: tournament_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tournament_groups_id_seq', 10, true);


--
-- Name: tournament_match_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tournament_match_attachments_id_seq', 1, false);


--
-- Name: tournament_match_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tournament_match_comments_id_seq', 1, false);


--
-- Name: tournament_matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tournament_matches_id_seq', 773, true);


--
-- Name: tournament_participant_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tournament_participant_stats_id_seq', 1, false);


--
-- Name: tournament_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tournament_participants_id_seq', 328, true);


--
-- Name: tournament_pool_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tournament_pool_participants_id_seq', 1, false);


--
-- Name: tournaments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tournaments_id_seq', 29, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 31, true);


--
-- Name: champion_result champion_result_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.champion_result
    ADD CONSTRAINT champion_result_pkey PRIMARY KEY (day, division);


--
-- Name: draft draft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.draft
    ADD CONSTRAINT draft_pkey PRIMARY KEY (day);


--
-- Name: duels duels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duels
    ADD CONSTRAINT duels_pkey PRIMARY KEY (id);


--
-- Name: handoff_requests handoff_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.handoff_requests
    ADD CONSTRAINT handoff_requests_pkey PRIMARY KEY (id);


--
-- Name: match_attachments match_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_attachments
    ADD CONSTRAINT match_attachments_pkey PRIMARY KEY (id);


--
-- Name: match_comments match_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_comments
    ADD CONSTRAINT match_comments_pkey PRIMARY KEY (id);


--
-- Name: match_games match_games_match_id_game_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_games
    ADD CONSTRAINT match_games_match_id_game_number_key UNIQUE (match_id, game_number);


--
-- Name: match_games match_games_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_games
    ADD CONSTRAINT match_games_pkey PRIMARY KEY (id);


--
-- Name: matchday matchday_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchday
    ADD CONSTRAINT matchday_pkey PRIMARY KEY (day);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (player_id);


--
-- Name: season_totals season_totals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.season_totals
    ADD CONSTRAINT season_totals_pkey PRIMARY KEY (id);


--
-- Name: season_totals season_totals_tag_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.season_totals
    ADD CONSTRAINT season_totals_tag_key UNIQUE (tag);


--
-- Name: seasons seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT seasons_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: tournament_groups tournament_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_groups
    ADD CONSTRAINT tournament_groups_pkey PRIMARY KEY (id);


--
-- Name: tournament_match_attachments tournament_match_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_match_attachments
    ADD CONSTRAINT tournament_match_attachments_pkey PRIMARY KEY (id);


--
-- Name: tournament_match_comments tournament_match_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_match_comments
    ADD CONSTRAINT tournament_match_comments_pkey PRIMARY KEY (id);


--
-- Name: tournament_matches tournament_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches
    ADD CONSTRAINT tournament_matches_pkey PRIMARY KEY (id);


--
-- Name: tournament_matches tournament_matches_tournament_id_round_no_slot_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches
    ADD CONSTRAINT tournament_matches_tournament_id_round_no_slot_no_key UNIQUE (tournament_id, round_no, slot_no);


--
-- Name: tournament_participant_stats tournament_participant_stats_participant_id_phase_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_participant_stats
    ADD CONSTRAINT tournament_participant_stats_participant_id_phase_id_key UNIQUE (participant_id, phase_id);


--
-- Name: tournament_participant_stats tournament_participant_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_participant_stats
    ADD CONSTRAINT tournament_participant_stats_pkey PRIMARY KEY (id);


--
-- Name: tournament_participants tournament_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_pkey PRIMARY KEY (id);


--
-- Name: tournament_pool_participants tournament_pool_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_pool_participants
    ADD CONSTRAINT tournament_pool_participants_pkey PRIMARY KEY (id);


--
-- Name: tournament_pool_participants tournament_pool_participants_pool_id_participant_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_pool_participants
    ADD CONSTRAINT tournament_pool_participants_pool_id_participant_id_key UNIQUE (pool_id, participant_id);


--
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (id);


--
-- Name: tournaments tournaments_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_slug_key UNIQUE (slug);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: draft_author_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX draft_author_idx ON public.draft USING btree (author_user_id);


--
-- Name: idx_champion_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_champion_name ON public.champion_result USING btree (champion_name);


--
-- Name: idx_match_attachments_match; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_match_attachments_match ON public.match_attachments USING btree (match_id);


--
-- Name: idx_match_comments_match; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_match_comments_match ON public.match_comments USING btree (match_id);


--
-- Name: idx_match_games_match; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_match_games_match ON public.match_games USING btree (match_id);


--
-- Name: sessions_user_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_user_active ON public.sessions USING btree (user_id) WHERE is_active;


--
-- Name: tournament_matches_tournament_round_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tournament_matches_tournament_round_idx ON public.tournament_matches USING btree (tournament_id, round_no, slot_no);


--
-- Name: tournament_participants_seed_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tournament_participants_seed_uniq ON public.tournament_participants USING btree (tournament_id, seed) WHERE (seed IS NOT NULL);


--
-- Name: tournaments_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tournaments_created_at_idx ON public.tournaments USING btree (created_at DESC);


--
-- Name: tournaments_season_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tournaments_season_idx ON public.tournaments USING btree (season_id);


--
-- Name: tournaments_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tournaments_status_idx ON public.tournaments USING btree (status);


--
-- Name: tp_display_name_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tp_display_name_uniq ON public.tournament_participants USING btree (tournament_id, lower(display_name));


--
-- Name: users_player_id_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_player_id_uniq ON public.users USING btree (player_id) WHERE (player_id IS NOT NULL);


--
-- Name: champion_result fk_champion_player; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.champion_result
    ADD CONSTRAINT fk_champion_player FOREIGN KEY (champion_id) REFERENCES public.players(player_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: handoff_requests handoff_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.handoff_requests
    ADD CONSTRAINT handoff_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: match_attachments match_attachments_uploaded_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_attachments
    ADD CONSTRAINT match_attachments_uploaded_by_user_id_fkey FOREIGN KEY (uploaded_by_user_id) REFERENCES public.users(id);


--
-- Name: match_comments match_comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_comments
    ADD CONSTRAINT match_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: matchday matchday_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchday
    ADD CONSTRAINT matchday_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tournament_match_attachments tournament_match_attachments_uploaded_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_match_attachments
    ADD CONSTRAINT tournament_match_attachments_uploaded_by_user_id_fkey FOREIGN KEY (uploaded_by_user_id) REFERENCES public.users(id);


--
-- Name: tournament_match_attachments tournament_match_attachments_verified_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_match_attachments
    ADD CONSTRAINT tournament_match_attachments_verified_by_user_id_fkey FOREIGN KEY (verified_by_user_id) REFERENCES public.users(id);


--
-- Name: tournament_match_comments tournament_match_comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_match_comments
    ADD CONSTRAINT tournament_match_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tournament_matches tournament_matches_loser_next_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches
    ADD CONSTRAINT tournament_matches_loser_next_match_id_fkey FOREIGN KEY (loser_next_match_id) REFERENCES public.tournament_matches(id) ON DELETE SET NULL;


--
-- Name: tournament_matches tournament_matches_next_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches
    ADD CONSTRAINT tournament_matches_next_match_id_fkey FOREIGN KEY (next_match_id) REFERENCES public.tournament_matches(id) ON DELETE SET NULL;


--
-- Name: tournament_matches tournament_matches_p1_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches
    ADD CONSTRAINT tournament_matches_p1_participant_id_fkey FOREIGN KEY (p1_participant_id) REFERENCES public.tournament_participants(id) ON DELETE SET NULL;


--
-- Name: tournament_matches tournament_matches_p2_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches
    ADD CONSTRAINT tournament_matches_p2_participant_id_fkey FOREIGN KEY (p2_participant_id) REFERENCES public.tournament_participants(id) ON DELETE SET NULL;


--
-- Name: tournament_matches tournament_matches_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches
    ADD CONSTRAINT tournament_matches_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: tournament_matches tournament_matches_winner_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_matches
    ADD CONSTRAINT tournament_matches_winner_participant_id_fkey FOREIGN KEY (winner_participant_id) REFERENCES public.tournament_participants(id) ON DELETE SET NULL;


--
-- Name: tournament_participants tournament_participants_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(player_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tournament_participants tournament_participants_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: tournaments tournaments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tournaments tournaments_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id) ON DELETE SET NULL;


--
-- Name: tournaments tournaments_winner_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_winner_player_id_fkey FOREIGN KEY (winner_player_id) REFERENCES public.players(player_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: users users_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(player_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict rk6nZkAxtf2f6ZfiJDrLqyOIcQQvn48MpnSTfgTeA2YrfWmPuFPBMvr1DVapQZK

