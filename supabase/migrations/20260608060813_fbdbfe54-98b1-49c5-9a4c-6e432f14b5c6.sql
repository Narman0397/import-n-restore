
CREATE OR REPLACE FUNCTION public.governance_inventory()
RETURNS jsonb
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _uid uuid := auth.uid();
  _result jsonb;
BEGIN
  IF _uid IS NULL OR NOT (
    public.has_role(_uid, 'super_admin') OR public.has_role(_uid, 'admin_pemda')
  ) THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  SELECT jsonb_build_object(
    'nomor_surat_total', (SELECT COUNT(*) FROM public.nomor_surat_issued),
    'nomor_surat_tahun_ini', (SELECT COUNT(*) FROM public.nomor_surat_issued WHERE tahun = EXTRACT(YEAR FROM now())::int),
    'share_paket_aktif', (SELECT COUNT(*) FROM public.share_paket WHERE status IS DISTINCT FROM 'dibatalkan'),
    'verification_logs_30d', (SELECT COUNT(*) FROM public.verification_logs WHERE created_at > now() - interval '30 days'),
    'data_request_pending', (SELECT COUNT(*) FROM public.data_requests WHERE status IN ('baru','review')),
    'legacy_submission_total', (SELECT COUNT(*) FROM public.submissions),
    'legacy_submission_unmigrated', (SELECT COUNT(*) FROM public.submissions s
       WHERE NOT EXISTS (SELECT 1 FROM public.form_submissions fs WHERE fs.legacy_submission_id = s.id)),
    'dataset_template_total', (SELECT COUNT(*) FROM public.dataset_template),
    'dataset_template_aktif', (SELECT COUNT(*) FROM public.dataset_template WHERE aktif),
    'unit_kerja_total', (SELECT COUNT(*) FROM public.unit_kerja),
    'rate_limit_hits_24h', (SELECT COUNT(*) FROM public.rate_limit_hits WHERE last_hit_at > now() - interval '24 hours')
  ) INTO _result;
  RETURN _result;
EXCEPTION WHEN undefined_column THEN
  -- legacy_submission_id belum ada di form_submissions: fallback tanpa hubungan migrasi
  SELECT jsonb_build_object(
    'nomor_surat_total', (SELECT COUNT(*) FROM public.nomor_surat_issued),
    'nomor_surat_tahun_ini', (SELECT COUNT(*) FROM public.nomor_surat_issued WHERE tahun = EXTRACT(YEAR FROM now())::int),
    'share_paket_aktif', (SELECT COUNT(*) FROM public.share_paket),
    'verification_logs_30d', (SELECT COUNT(*) FROM public.verification_logs WHERE created_at > now() - interval '30 days'),
    'data_request_pending', (SELECT COUNT(*) FROM public.data_requests),
    'legacy_submission_total', (SELECT COUNT(*) FROM public.submissions),
    'legacy_submission_unmigrated', (SELECT COUNT(*) FROM public.submissions),
    'dataset_template_total', (SELECT COUNT(*) FROM public.dataset_template),
    'dataset_template_aktif', (SELECT COUNT(*) FROM public.dataset_template WHERE aktif),
    'unit_kerja_total', (SELECT COUNT(*) FROM public.unit_kerja),
    'rate_limit_hits_24h', (SELECT COUNT(*) FROM public.rate_limit_hits WHERE last_hit_at > now() - interval '24 hours')
  ) INTO _result;
  RETURN _result;
END $$;

REVOKE EXECUTE ON FUNCTION public.governance_inventory() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.governance_inventory() TO authenticated, service_role;
