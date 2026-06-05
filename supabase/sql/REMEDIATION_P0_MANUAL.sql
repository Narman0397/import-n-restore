-- ============================================================
-- REMEDIASI P0 — JALANKAN DARI LOVABLE CLOUD > BACKEND > SQL EDITOR
-- (Migration tool tidak punya ownership pada profiles/user_roles/laporan_masyarakat)
-- ============================================================

-- 1) profiles: aktifkan RLS + policy scoped per role
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_self_select" ON public.profiles;
CREATE POLICY "profiles_self_select" ON public.profiles
  FOR SELECT TO authenticated
  USING (
    id = auth.uid()
    OR public.has_role(auth.uid(),'super_admin')
    OR public.has_role(auth.uid(),'admin_pemda')
    OR public.has_role(auth.uid(),'pimpinan')
    OR (public.has_role(auth.uid(),'admin_opd') AND opd_id = public.get_user_opd(auth.uid()))
    OR (public.has_role(auth.uid(),'admin_desa') AND desa = public.get_user_desa(auth.uid()))
  );

DROP POLICY IF EXISTS "profiles_self_update" ON public.profiles;
CREATE POLICY "profiles_self_update" ON public.profiles
  FOR UPDATE TO authenticated
  USING (
    id = auth.uid()
    OR public.has_role(auth.uid(),'super_admin')
    OR public.has_role(auth.uid(),'admin_pemda')
    OR (public.has_role(auth.uid(),'admin_desa') AND desa = public.get_user_desa(auth.uid()))
  )
  WITH CHECK (true);

DROP POLICY IF EXISTS "profiles_insert_self" ON public.profiles;
CREATE POLICY "profiles_insert_self" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid() OR public.has_role(auth.uid(),'super_admin'));

-- 2) user_roles: aktifkan RLS + read terbatas, write hanya super_admin
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_roles_self_select" ON public.user_roles;
CREATE POLICY "user_roles_self_select" ON public.user_roles
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR public.has_role(auth.uid(),'super_admin')
    OR public.has_role(auth.uid(),'admin_pemda')
  );

DROP POLICY IF EXISTS "user_roles_super_manage" ON public.user_roles;
CREATE POLICY "user_roles_super_manage" ON public.user_roles
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'super_admin'))
  WITH CHECK (public.has_role(auth.uid(),'super_admin'));

-- 3) laporan_masyarakat: tambah SELECT/UPDATE scoped (sebelumnya cuma INSERT publik)
DROP POLICY IF EXISTS "laporan_admin_select" ON public.laporan_masyarakat;
CREATE POLICY "laporan_admin_select" ON public.laporan_masyarakat
  FOR SELECT TO authenticated
  USING (
    public.has_role(auth.uid(),'super_admin')
    OR public.has_role(auth.uid(),'admin_pemda')
    OR public.has_role(auth.uid(),'pimpinan')
    OR (public.has_role(auth.uid(),'admin_opd') AND opd_id = public.get_user_opd(auth.uid()))
  );

DROP POLICY IF EXISTS "laporan_admin_update" ON public.laporan_masyarakat;
CREATE POLICY "laporan_admin_update" ON public.laporan_masyarakat
  FOR UPDATE TO authenticated
  USING (
    public.has_role(auth.uid(),'super_admin')
    OR public.has_role(auth.uid(),'admin_pemda')
    OR (public.has_role(auth.uid(),'admin_opd') AND opd_id = public.get_user_opd(auth.uid()))
  )
  WITH CHECK (
    public.has_role(auth.uid(),'super_admin')
    OR public.has_role(auth.uid(),'admin_pemda')
    OR (public.has_role(auth.uid(),'admin_opd') AND opd_id = public.get_user_opd(auth.uid()))
  );

-- 4) Grants (idempotent)
GRANT SELECT, UPDATE, INSERT ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
GRANT SELECT, UPDATE ON public.laporan_masyarakat TO authenticated;
GRANT INSERT ON public.laporan_masyarakat TO anon, authenticated;
GRANT ALL ON public.laporan_masyarakat TO service_role;
