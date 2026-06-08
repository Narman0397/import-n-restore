
-- Revoke seluruh SECURITY DEFINER functions termasuk trigger function (pronargs=0)
DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT p.oid, p.proname, pg_catalog.pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.prosecdef=true
  LOOP
    BEGIN
      EXECUTE format('REVOKE EXECUTE ON FUNCTION public.%I(%s) FROM PUBLIC', r.proname, r.args);
      EXECUTE format('REVOKE EXECUTE ON FUNCTION public.%I(%s) FROM anon', r.proname, r.args);
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
END $$;

-- Re-allow whitelist publik
GRANT EXECUTE ON FUNCTION public.rating_public_stats() TO anon;
GRANT EXECUTE ON FUNCTION public.fn_ikm_dashboard(uuid) TO anon;

-- _lovable_request_uid
ALTER FUNCTION public._lovable_request_uid() SET search_path = public;
