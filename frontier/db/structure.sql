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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    course_id uuid NOT NULL,
    title public.citext NOT NULL,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    submissions_count integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    title public.citext NOT NULL,
    "group" public.citext NOT NULL,
    semester character varying NOT NULL,
    year integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    assignment_id uuid,
    author_name character varying NOT NULL,
    author_group character varying NOT NULL,
    type character varying NOT NULL,
    status character varying DEFAULT 'created'::character varying NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: telegram_chats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telegram_chats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    external_identifier character varying NOT NULL,
    username character varying NOT NULL,
    name character varying,
    "group" character varying,
    last_submitted_course_id uuid,
    status character varying DEFAULT 'created'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: telegram_forms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telegram_forms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    course_id uuid,
    assignment_id uuid,
    submission_id uuid,
    telegram_chat_id uuid NOT NULL,
    stage character varying DEFAULT 'initial'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    uploadable_type character varying NOT NULL,
    uploadable_id uuid NOT NULL,
    filename character varying NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone
);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: telegram_chats telegram_chats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_chats
    ADD CONSTRAINT telegram_chats_pkey PRIMARY KEY (id);


--
-- Name: telegram_forms telegram_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_forms
    ADD CONSTRAINT telegram_forms_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_assignments_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_course_id ON public.assignments USING btree (course_id);


--
-- Name: index_assignments_on_course_id_and_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assignments_on_course_id_and_title ON public.assignments USING btree (course_id, title);


--
-- Name: index_courses_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_courses_on_title ON public.courses USING btree (title);


--
-- Name: index_courses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_on_user_id ON public.courses USING btree (user_id);


--
-- Name: index_submissions_on_assignment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submissions_on_assignment_id ON public.submissions USING btree (assignment_id);


--
-- Name: index_telegram_chats_on_external_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_telegram_chats_on_external_identifier ON public.telegram_chats USING btree (external_identifier);


--
-- Name: index_telegram_chats_on_last_submitted_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telegram_chats_on_last_submitted_course_id ON public.telegram_chats USING btree (last_submitted_course_id);


--
-- Name: index_telegram_forms_on_assignment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telegram_forms_on_assignment_id ON public.telegram_forms USING btree (assignment_id);


--
-- Name: index_telegram_forms_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telegram_forms_on_course_id ON public.telegram_forms USING btree (course_id);


--
-- Name: index_telegram_forms_on_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telegram_forms_on_submission_id ON public.telegram_forms USING btree (submission_id);


--
-- Name: index_telegram_forms_on_telegram_chat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telegram_forms_on_telegram_chat_id ON public.telegram_forms USING btree (telegram_chat_id);


--
-- Name: index_uploads_on_uploadable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploadable ON public.uploads USING btree (uploadable_type, uploadable_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: telegram_forms fk_rails_02a12ec360; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_forms
    ADD CONSTRAINT fk_rails_02a12ec360 FOREIGN KEY (telegram_chat_id) REFERENCES public.telegram_chats(id);


--
-- Name: telegram_forms fk_rails_188d60a62e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_forms
    ADD CONSTRAINT fk_rails_188d60a62e FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: assignments fk_rails_2194c084a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT fk_rails_2194c084a6 FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: telegram_chats fk_rails_5b0d55477a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_chats
    ADD CONSTRAINT fk_rails_5b0d55477a FOREIGN KEY (last_submitted_course_id) REFERENCES public.courses(id);


--
-- Name: submissions fk_rails_61cac0823d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT fk_rails_61cac0823d FOREIGN KEY (assignment_id) REFERENCES public.assignments(id);


--
-- Name: telegram_forms fk_rails_6b7ff3c0f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_forms
    ADD CONSTRAINT fk_rails_6b7ff3c0f8 FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: courses fk_rails_b3c61f05ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT fk_rails_b3c61f05ef FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: telegram_forms fk_rails_e05373b641; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_forms
    ADD CONSTRAINT fk_rails_e05373b641 FOREIGN KEY (assignment_id) REFERENCES public.assignments(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20231028164424'),
('20231020182643'),
('20231011202038'),
('20230514122273'),
('20230514122263'),
('20230514122253'),
('20230514122243'),
('20230505171657');

