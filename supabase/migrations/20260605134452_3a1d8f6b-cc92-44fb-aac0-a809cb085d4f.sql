
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

CREATE OR REPLACE FUNCTION public.has_permission(_user_id uuid, _permission_code text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_permissions up
    WHERE up.user_id = _user_id
      AND up.permission_code = _permission_code
      AND up.granted = true
      AND up.revoked_at IS NULL
      AND (up.expires_at IS NULL OR up.expires_at > now())
  )
$$;

CREATE TABLE IF NOT EXISTS public.leave_balances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  tahun int NOT NULL,
  jenis text NOT NULL,
  kuota int NOT NULL DEFAULT 0,
  terpakai int NOT NULL DEFAULT 0,
  catatan text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, tahun, jenis)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.leave_balances TO authenticated;
GRANT ALL ON public.leave_balances TO service_role;
ALTER TABLE public.leave_balances ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own_or_admin_select" ON public.leave_balances FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(),'super_admin') OR public.has_role(auth.uid(),'admin_opd'));
CREATE POLICY "admin_manage" ON public.leave_balances FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'super_admin') OR public.has_role(auth.uid(),'admin_opd'))
  WITH CHECK (public.has_role(auth.uid(),'super_admin') OR public.has_role(auth.uid(),'admin_opd'));
CREATE TRIGGER set_leave_balances_updated_at BEFORE UPDATE ON public.leave_balances
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP FUNCTION IF EXISTS public.opd_kinerja_trend(uuid, integer);
CREATE OR REPLACE FUNCTION public.opd_kinerja_trend(_opd uuid DEFAULT NULL, _months integer DEFAULT 12)
RETURNS TABLE(bulan text, masuk bigint, selesai bigint, on_time bigint, selesai_dengan_sla bigint)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT to_char(date_trunc('month', p.tanggal_masuk), 'YYYY-MM') AS bulan,
    COUNT(*)::bigint, COUNT(*) FILTER (WHERE p.status='selesai')::bigint,
    COUNT(*) FILTER (WHERE p.status='selesai' AND p.tenggat IS NOT NULL AND p.updated_at <= p.tenggat)::bigint,
    COUNT(*) FILTER (WHERE p.status='selesai' AND p.tenggat IS NOT NULL)::bigint
  FROM public.permohonan p
  WHERE p.tanggal_masuk >= date_trunc('month', now()) - make_interval(months => GREATEST(_months,1))
    AND (_opd IS NULL OR p.opd_id = _opd)
  GROUP BY date_trunc('month', p.tanggal_masuk) ORDER BY 1;
$$;

DROP FUNCTION IF EXISTS public.layanan_kinerja_agg();
CREATE OR REPLACE FUNCTION public.layanan_kinerja_agg()
RETURNS TABLE(layanan_id uuid, layanan_judul text, opd_id uuid, opd_singkatan text,
  kategori text, total bigint, selesai bigint, on_time bigint, selesai_dengan_sla bigint, rata_hari_selesai numeric)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT NULL::uuid, p.kategori, p.opd_id, o.singkatan, p.kategori,
    COUNT(*)::bigint, COUNT(*) FILTER (WHERE p.status='selesai')::bigint,
    COUNT(*) FILTER (WHERE p.status='selesai' AND p.tenggat IS NOT NULL AND p.updated_at <= p.tenggat)::bigint,
    COUNT(*) FILTER (WHERE p.status='selesai' AND p.tenggat IS NOT NULL)::bigint,
    ROUND(AVG(EXTRACT(EPOCH FROM (p.updated_at - p.tanggal_masuk))/86400.0) FILTER (WHERE p.status='selesai')::numeric, 2)
  FROM public.permohonan p LEFT JOIN public.opd o ON o.id = p.opd_id
  GROUP BY p.kategori, p.opd_id, o.singkatan ORDER BY 6 DESC;
$$;

DROP FUNCTION IF EXISTS public.opd_skor_komposit();
CREATE OR REPLACE FUNCTION public.opd_skor_komposit()
RETURNS TABLE(opd_id uuid, opd_nama text, opd_singkatan text, kategori text[],
  total bigint, selesai bigint, sla_pct numeric, rating_avg numeric, completion_pct numeric, skor numeric)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  WITH agg AS (
    SELECT p.opd_id, COUNT(*)::bigint AS total,
      COUNT(*) FILTER (WHERE p.status='selesai')::numeric AS selesai,
      COUNT(*) FILTER (WHERE p.status='selesai' AND p.tenggat IS NOT NULL AND p.updated_at <= p.tenggat)::numeric AS on_time,
      COUNT(*) FILTER (WHERE p.status='selesai' AND p.tenggat IS NOT NULL)::numeric AS with_sla
    FROM public.permohonan p GROUP BY p.opd_id
  ),
  rate AS (
    SELECT p.opd_id, AVG(r.skor)::numeric AS r
    FROM public.permohonan_rating r JOIN public.permohonan p ON p.id = r.permohonan_id
    GROUP BY p.opd_id
  )
  SELECT o.id, o.nama, o.singkatan, NULL::text[],
    COALESCE(a.total,0)::bigint, COALESCE(a.selesai,0)::bigint,
    CASE WHEN a.with_sla>0 THEN ROUND(a.on_time/a.with_sla*100,2) ELSE NULL END,
    ROUND(COALESCE(rate.r,0)::numeric,2),
    CASE WHEN a.total>0 THEN ROUND(a.selesai/a.total*100,2) ELSE NULL END,
    ROUND(COALESCE(
      0.5 * CASE WHEN a.total>0 THEN a.selesai/a.total*100 ELSE 0 END
      + 0.3 * CASE WHEN a.with_sla>0 THEN a.on_time/a.with_sla*100 ELSE 0 END
      + 0.2 * COALESCE(rate.r,0)*20, 0)::numeric, 2)
  FROM public.opd o LEFT JOIN agg a ON a.opd_id = o.id LEFT JOIN rate ON rate.opd_id = o.id
  ORDER BY 10 DESC;
$$;

GRANT EXECUTE ON FUNCTION public.has_role(uuid, app_role) TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION public.has_permission(uuid, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.opd_kinerja_trend(uuid, integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.layanan_kinerja_agg() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.opd_skor_komposit() TO authenticated, service_role;
