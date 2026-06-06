-- ============================================================
-- REMEDIATION P0 - VERSI AMAN (tanpa butuh OWNER profiles/user_roles)
-- ============================================================
-- Catatan:
-- Tabel `profiles` & `user_roles` dimiliki oleh `supabase_auth_admin`
-- (karena trigger handle_new_user) sehingga ALTER TABLE biasa gagal
-- dengan ERROR 42501: must be owner of table profiles.
--
-- Solusi: bungkus perintah privileged via fungsi SECURITY DEFINER
-- `public._lovable_exec_sql(text)` yang dieksekusi sebagai pemilik fungsi.
--
-- Catatan tambahan:
-- Jangan panggil `auth.uid()` langsung di dalam blok dynamic SQL SECURITY
-- DEFINER karena owner fungsi helper bisa tidak punya USAGE ke schema `auth`.
-- Gunakan helper berbasis current_setting() di schema public.
-- ============================================================

-- Setara dengan auth.uid() Supabase: baca legacy GUC per-claim ATAU JSON
-- claims modern dari PostgREST. Bila hanya satu yang ada, fungsi tetap
-- mengembalikan uid yang benar; tanpa fallback ini policy bisa deny-all.
CREATE OR REPLACE FUNCTION public._lovable_request_uid()
RETURNS uuid
LANGUAGE sql
STABLE
AS $function$
  SELECT COALESCE(
    NULLIF(current_setting('request.jwt.claim.sub', true), ''),
    NULLIF(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub'
  )::uuid
$function$;

-- ------------------------------------------------------------
-- 1. profiles  → aktifkan RLS + policy berbasis auth.uid()
-- ------------------------------------------------------------
SELECT public._lovable_exec_sql($SQL$
  ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

  DROP POLICY IF EXISTS "profiles_select_self_or_admin" ON public.profiles;
  CREATE POLICY "profiles_select_self_or_admin"
    ON public.profiles FOR SELECT TO authenticated
    USING (
      id = public._lovable_request_uid()
      OR public.has_role(public._lovable_request_uid(), 'super_admin')
      OR public.has_role(public._lovable_request_uid(), 'admin_pemda')
      OR public.has_role(public._lovable_request_uid(), 'pimpinan')
      OR (public.has_role(public._lovable_request_uid(), 'admin_opd')
          AND opd_id = public.get_user_opd(public._lovable_request_uid()))
      OR (public.has_role(public._lovable_request_uid(), 'admin_desa')
          AND desa = public.get_user_desa(public._lovable_request_uid()))
    );

  DROP POLICY IF EXISTS "profiles_update_self_or_admin" ON public.profiles;
  CREATE POLICY "profiles_update_self_or_admin"
    ON public.profiles FOR UPDATE TO authenticated
    USING (
      id = public._lovable_request_uid()
      OR public.has_role(public._lovable_request_uid(), 'super_admin')
      OR public.has_role(public._lovable_request_uid(), 'admin_pemda')
      OR (public.has_role(public._lovable_request_uid(), 'admin_desa')
          AND desa = public.get_user_desa(public._lovable_request_uid()))
    )
    WITH CHECK (
      id = public._lovable_request_uid()
      OR public.has_role(public._lovable_request_uid(), 'super_admin')
      OR public.has_role(public._lovable_request_uid(), 'admin_pemda')
      OR (public.has_role(public._lovable_request_uid(), 'admin_desa')
          AND desa = public.get_user_desa(public._lovable_request_uid()))
    );

  DROP POLICY IF EXISTS "profiles_insert_self" ON public.profiles;
  CREATE POLICY "profiles_insert_self"
    ON public.profiles FOR INSERT TO authenticated
    WITH CHECK (
      id = public._lovable_request_uid()
      OR public.has_role(public._lovable_request_uid(),'super_admin')
    );

  GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
  GRANT ALL ON public.profiles TO service_role;
$SQL$);

-- ------------------------------------------------------------
-- 2. user_roles  → aktifkan RLS + policy (super_admin only write)
-- ------------------------------------------------------------
SELECT public._lovable_exec_sql($SQL$
  ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

  DROP POLICY IF EXISTS "user_roles_select_self_or_admin" ON public.user_roles;
  CREATE POLICY "user_roles_select_self_or_admin"
    ON public.user_roles FOR SELECT TO authenticated
    USING (
      user_id = public._lovable_request_uid()
      OR public.has_role(public._lovable_request_uid(),'super_admin')
      OR public.has_role(public._lovable_request_uid(),'admin_pemda')
    );

  DROP POLICY IF EXISTS "user_roles_all_super_admin" ON public.user_roles;
  CREATE POLICY "user_roles_all_super_admin"
    ON public.user_roles FOR ALL TO authenticated
    USING (public.has_role(public._lovable_request_uid(),'super_admin'))
    WITH CHECK (public.has_role(public._lovable_request_uid(),'super_admin'));

  GRANT SELECT ON public.user_roles TO authenticated;
  GRANT ALL ON public.user_roles TO service_role;
$SQL$);

-- ------------------------------------------------------------
-- 3. laporan_masyarakat  → tambahkan SELECT/UPDATE policy
-- ------------------------------------------------------------
SELECT public._lovable_exec_sql($SQL$
  ALTER TABLE public.laporan_masyarakat ENABLE ROW LEVEL SECURITY;

  DROP POLICY IF EXISTS "laporan_select_admin_scope" ON public.laporan_masyarakat;
  CREATE POLICY "laporan_select_admin_scope"
    ON public.laporan_masyarakat FOR SELECT TO authenticated
    USING (
      public.has_role(public._lovable_request_uid(),'super_admin')
      OR public.has_role(public._lovable_request_uid(),'admin_pemda')
      OR public.has_role(public._lovable_request_uid(),'pimpinan')
      OR (public.has_role(public._lovable_request_uid(),'admin_opd')
          AND opd_id = public.get_user_opd(public._lovable_request_uid()))
    );

  DROP POLICY IF EXISTS "laporan_update_admin_scope" ON public.laporan_masyarakat;
  CREATE POLICY "laporan_update_admin_scope"
    ON public.laporan_masyarakat FOR UPDATE TO authenticated
    USING (
      public.has_role(public._lovable_request_uid(),'super_admin')
      OR public.has_role(public._lovable_request_uid(),'admin_pemda')
      OR (public.has_role(public._lovable_request_uid(),'admin_opd')
          AND opd_id = public.get_user_opd(public._lovable_request_uid()))
    )
    WITH CHECK (
      public.has_role(public._lovable_request_uid(),'super_admin')
      OR public.has_role(public._lovable_request_uid(),'admin_pemda')
      OR (public.has_role(public._lovable_request_uid(),'admin_opd')
          AND opd_id = public.get_user_opd(public._lovable_request_uid()))
    );

  GRANT SELECT, UPDATE ON public.laporan_masyarakat TO authenticated;
  GRANT INSERT ON public.laporan_masyarakat TO anon, authenticated;
  GRANT ALL ON public.laporan_masyarakat TO service_role;
$SQL$);

-- ============================================================
-- VERIFIKASI - jalankan setelah ketiga blok di atas sukses
-- ============================================================
SELECT c.relname AS tabel,
       c.relrowsecurity AS rls_aktif,
       (SELECT COUNT(*) FROM pg_policies p
         WHERE p.schemaname='public' AND p.tablename=c.relname) AS jumlah_policy
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname='public'
  AND c.relname IN ('profiles','user_roles','laporan_masyarakat')
ORDER BY c.relname;
