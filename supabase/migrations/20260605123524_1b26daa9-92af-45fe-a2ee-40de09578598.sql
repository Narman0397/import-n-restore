GRANT USAGE ON SCHEMA auth TO sandbox_exec, authenticated, service_role, anon;
GRANT SELECT, REFERENCES ON auth.users TO sandbox_exec;
GRANT SELECT, REFERENCES ON ALL TABLES IN SCHEMA auth TO sandbox_exec;