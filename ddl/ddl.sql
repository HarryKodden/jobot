--
-- Extensions
--

CREATE SCHEMA extensions;
ALTER SCHEMA extensions OWNER TO postgres;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;

--
-- Name: apikeys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.apikeys (
    created_at timestamp with time zone DEFAULT now(),
    user_id uuid,
    name character varying,
    key uuid DEFAULT extensions.uuid_generate_v4() NOT NULL
);


ALTER TABLE public.apikeys OWNER TO postgres;

--
-- Name: TABLE apikeys; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.apikeys IS 'ApiKeys';


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    user_id uuid,
    title character varying
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- Name: TABLE conversations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.conversations IS 'Conversations History';


--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    role text,
    content text,
    conversation_id uuid
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: TABLE messages; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.messages IS 'Messages per conversation';


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    username character varying,
    first_name character varying,
    last_name character varying,
    avatar_url character varying,
    bio character varying
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: TABLE profiles; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.profiles IS 'Profile Table';


--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    user_id uuid NOT NULL,
    slug character varying,
    title character varying,
    description character varying,
    system_prompt character varying,
    inputs jsonb,
    user_prompt character varying
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: TABLE skills; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.skills IS 'Skills Table';


--
-- Name: skills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.skills ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: apikeys apikeys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apikeys
    ADD CONSTRAINT apikeys_pkey PRIMARY KEY (key);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: profiles skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: skills skills_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey1 PRIMARY KEY (id);

--
-- Name: apikeys apikeys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apikeys
    ADD CONSTRAINT apikeys_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: conversations conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id);


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: skills skills_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id);

--
-- Name: apikeys Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON public.apikeys FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: conversations Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON public.conversations FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: messages Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users via access to conversations" ON public.messages FOR DELETE USING ((EXISTS ( SELECT conversations.created_at,
    conversations.user_id,
    conversations.title,
    conversations.id
   FROM public.conversations
  WHERE ((conversations.id = messages.conversation_id) AND (conversations.id = auth.uid())))));


--
-- Name: profiles Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON public.profiles FOR DELETE USING ((auth.uid() = id));


--
-- Name: apikeys Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON public.apikeys FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));


--
-- Name: conversations Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON public.conversations FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));


--
-- Name: messages Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for via access to conversations" ON public.messages FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT conversations.created_at,
    conversations.user_id,
    conversations.title,
    conversations.id
   FROM public.conversations
  WHERE ((conversations.id = messages.conversation_id) AND (conversations.id = auth.uid())))));


--
-- Name: profiles Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON public.profiles FOR INSERT TO authenticated WITH CHECK ((auth.uid() = id));


--
-- Name: skills Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON public.skills FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: apikeys Enable read access authenticated user only !; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access authenticated user only !" ON public.apikeys FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: messages Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access via access to conversations" ON public.messages FOR SELECT USING ((EXISTS ( SELECT conversations.created_at,
    conversations.user_id,
    conversations.title,
    conversations.id
   FROM public.conversations
  WHERE ((conversations.id = messages.conversation_id) AND (conversations.id = auth.uid())))));


--
-- Name: profiles Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.profiles FOR SELECT USING (true);


--
-- Name: skills Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.skills FOR SELECT USING (true);


--
-- Name: conversations Enable read for authenticated owner only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read for authenticated owner only" ON public.conversations FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: conversations Enable update for users based on email; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on email" ON public.conversations FOR UPDATE USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: messages Enable update for users based on email; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users via access to conversations" ON public.messages FOR UPDATE USING ((EXISTS ( SELECT conversations.created_at,
    conversations.user_id,
    conversations.title,
    conversations.id
   FROM public.conversations
  WHERE ((conversations.id = messages.conversation_id) AND (conversations.id = auth.uid()))))) WITH CHECK ((EXISTS ( SELECT conversations.created_at,
    conversations.user_id,
    conversations.title,
    conversations.id
   FROM public.conversations
  WHERE ((conversations.id = messages.conversation_id) AND (conversations.id = auth.uid())))));


--
-- Name: profiles Enable update for users based on email; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on email" ON public.profiles FOR UPDATE USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));


--
-- Name: skills Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON public.skills FOR UPDATE USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: apikeys; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.apikeys ENABLE ROW LEVEL SECURITY;

--
-- Name: conversations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: skills; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;

--
-- Name: TABLE apikeys; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.apikeys TO anon;
GRANT ALL ON TABLE public.apikeys TO authenticated;
GRANT ALL ON TABLE public.apikeys TO service_role;


--
-- Name: TABLE conversations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.conversations TO anon;
GRANT ALL ON TABLE public.conversations TO authenticated;
GRANT ALL ON TABLE public.conversations TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.messages TO anon;
GRANT ALL ON TABLE public.messages TO authenticated;
GRANT ALL ON TABLE public.messages TO service_role;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE skills; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.skills TO anon;
GRANT ALL ON TABLE public.skills TO authenticated;
GRANT ALL ON TABLE public.skills TO service_role;


--
-- Name: SEQUENCE skills_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.skills_id_seq TO anon;
GRANT ALL ON SEQUENCE public.skills_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.skills_id_seq TO service_role;

