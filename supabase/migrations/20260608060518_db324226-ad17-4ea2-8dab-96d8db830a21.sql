
-- ============================================================
-- Sprint G — Fase G4 Security Hardening
-- 1. Views → security_invoker=on (perbaiki 2 ERROR linter)
-- 2. _lovable_exec_sql → set search_path
-- 3. REVOKE EXECUTE FROM anon + PUBLIC untuk RPC internal; whitelist publik
-- 4. rbac_audit INSERT policy diperketat
-- ============================================================

-- 1. VIEWS ------------------------------------------------------
ALTER VIEW public.aset_nilai_buku SET (security_invoker = on);
ALTER VIEW public.v_permohonan_overdue SET (security_invoker = on);

-- 2. _lovable_exec_sql search_path ------------------------------
ALTER FUNCTION public._lovable_exec_sql(text) SET search_path = public;

-- 3. RPC ACCESS HARDENING --------------------------------------
-- Revoke EXECUTE on all SECURITY DEFINER callable functions from PUBLIC & anon,
-- then grant back to authenticated. Trigger functions (no args) tetap untouched
-- karena dipanggil oleh sistem, bukan API.

DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT p.oid, p.proname,
           pg_catalog.pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prosecdef = true
      AND p.pronargs > 0  -- skip trigger functions
  LOOP
    EXECUTE format('REVOKE EXECUTE ON FUNCTION public.%I(%s) FROM PUBLIC',
                   r.proname, r.args);
    EXECUTE format('REVOKE EXECUTE ON FUNCTION public.%I(%s) FROM anon',
                   r.proname, r.args);
    EXECUTE format('GRANT EXECUTE ON FUNCTION public.%I(%s) TO authenticated',
                   r.proname, r.args);
    EXECUTE format('GRANT EXECUTE ON FUNCTION public.%I(%s) TO service_role',
                   r.proname, r.args);
  END LOOP;
END $$;

-- Whitelist: fungsi yang sah dipanggil tanpa login.
GRANT EXECUTE ON FUNCTION public.rating_public_stats() TO anon;
GRANT EXECUTE ON FUNCTION public.fn_ikm_dashboard(uuid) TO anon;

-- 4. rbac_audit: perketat INSERT supaya user_id wajib auth.uid() ------
DROP POLICY IF EXISTS "rbac_audit insert authenticated" ON public.rbac_audit;
CREATE POLICY "rbac_audit insert authenticated"
  ON public.rbac_audit
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
