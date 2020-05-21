--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;

--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: salsa
--

INSERT INTO public.alembic_version (version_num) VALUES ('e3a1fba5d24c');


--
-- Data for Name: exclusion_set; Type: TABLE DATA; Schema: public; Owner: salsa
--



--
-- Data for Name: user_role; Type: TABLE DATA; Schema: public; Owner: salsa
--

INSERT INTO public.user_role (id, title, description) VALUES ('ad6382b5-50a7-40fa-91e8-c98f67005e40', 'Admin', 'Administrator');
INSERT INTO public.user_role (id, title, description) VALUES ('51484d2c-7a3d-4fe9-b10d-52d6e7408031', 'User', 'Regular user');


--
-- Data for Name: user_account; Type: TABLE DATA; Schema: public; Owner: salsa
--

--
-- password is abc
--
INSERT INTO public.user_account (id, name, email, password_hashed, created_at, updated_at, user_name, user_role_id) VALUES ('b3793c45-0b19-433d-a24d-9e9cd5952adf', 'Test User 1', 'test_user_1@email.com', '$2b$12$JA6/fiuPQfJn3wzM0RJUeOvOOiT4p6fcmb7N1S0aFFWTKDRc6d8ii', '2020-03-15 22:03:44.914112', '2020-03-15 22:03:44.914112', 'test_user_1', '51484d2c-7a3d-4fe9-b10d-52d6e7408031');

--
-- password is 123
--
INSERT INTO public.user_account (id, name, email, password_hashed, created_at, updated_at, user_name, user_role_id) VALUES ('552b5eec-0fa2-4cd8-a78b-1b792b9bea92', 'God', 'god@email.com', '$2b$12$qB.WXaCRB1LG1MquzuAyw.ckwRYQPyKkzFDQhznTkealv4Zf//CCK', '2020-03-15 22:04:04.745385', '2020-03-15 22:04:04.745385', 'god', 'ad6382b5-50a7-40fa-91e8-c98f67005e40');


--
-- PostgreSQL database dump complete
--

