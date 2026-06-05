
CREATE TABLE IF NOT EXISTS public.overtime_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  opd_id uuid,
  tanggal date NOT NULL,
  jam_mulai time NOT NULL,
  jam_selesai time NOT NULL,
  alasan text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  approver_id uuid,
  approved_at timestamptz,
  catatan_approval text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.overtime_requests TO authenticated;
GRANT ALL ON public.overtime_requests TO service_role;
ALTER TABLE public.overtime_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ovr_own_or_admin" ON public.overtime_requests FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(),'super_admin') OR public.has_role(auth.uid(),'admin_opd'));
CREATE POLICY "ovr_insert_self" ON public.overtime_requests FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "ovr_admin_manage" ON public.overtime_requests FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(),'super_admin') OR public.has_role(auth.uid(),'admin_opd'));
CREATE TRIGGER set_overtime_updated_at BEFORE UPDATE ON public.overtime_requests
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.attendance_shift_assignment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  shift_id uuid NOT NULL REFERENCES public.attendance_shifts(id) ON DELETE CASCADE,
  dari date NOT NULL,
  sampai date,
  aktif boolean NOT NULL DEFAULT true,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.attendance_shift_assignment TO authenticated;
GRANT ALL ON public.attendance_shift_assignment TO service_role;
ALTER TABLE public.attendance_shift_assignment ENABLE ROW LEVEL SECURITY;
CREATE POLICY "asa_select" ON public.attendance_shift_assignment FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(),'super_admin') OR public.has_role(auth.uid(),'admin_opd'));
CREATE POLICY "asa_admin_manage" ON public.attendance_shift_assignment FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'super_admin') OR public.has_role(auth.uid(),'admin_opd'))
  WITH CHECK (public.has_role(auth.uid(),'super_admin') OR public.has_role(auth.uid(),'admin_opd'));

CREATE OR REPLACE VIEW public.v_permohonan_overdue AS
SELECT p.id, p.kode, p.opd_id, p.status::text,
  GREATEST(0, EXTRACT(DAY FROM (now() - p.tenggat))::int) AS overdue_days
FROM public.permohonan p
WHERE p.tenggat IS NOT NULL
  AND p.tenggat < now()
  AND p.status NOT IN ('selesai','ditolak','dibatalkan');
GRANT SELECT ON public.v_permohonan_overdue TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.rating_list_admin()
RETURNS TABLE(id uuid, permohonan_id uuid, skor int, komentar text, created_at timestamptz,
  kode text, opd_id uuid, opd_singkatan text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT r.id, r.permohonan_id, r.skor, r.komentar, r.created_at,
    p.kode, p.opd_id, o.singkatan
  FROM public.permohonan_rating r
  JOIN public.permohonan p ON p.id = r.permohonan_id
  LEFT JOIN public.opd o ON o.id = p.opd_id
  ORDER BY r.created_at DESC LIMIT 500;
$$;
GRANT EXECUTE ON FUNCTION public.rating_list_admin() TO authenticated, service_role;

-- FK so PostgREST recognizes the leave_balances → profiles relation
ALTER TABLE public.leave_balances
  ADD CONSTRAINT leave_balances_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.overtime_requests
  ADD CONSTRAINT overtime_requests_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
