# PRODUCTION REMEDIATION REPORT
**Tanggal:** 5 Juni 2026
**Sumber temuan:** PRODUCTION_VALIDATION_REPORT.md
**Metode:** Verifikasi langsung terhadap database live (99 tabel) + audit kode.

---

## Ringkasan Status Temuan

| # | Temuan (sesuai laporan) | Status | Bukti |
|---|---|---|---|
| P0-1 | Enum `app_role` kurang `admin_pemda` & `pimpinan` | **RESOLVED_ALREADY** | `SELECT enum_range(NULL::app_role)` → `{warga, admin_opd, super_admin, admin_desa, asn, admin_pemda, pimpinan}` — semua 7 role sudah ada. |
| P0-2 | 40+ tabel hilang (forms, notifications, ikm_surveys, attendance_shifts, aset_bast, user_permissions, cron_history, dll) | **RESOLVED_ALREADY** | `information_schema.tables` schema `public` = **99 tabel**, mencakup semua yang dirujuk laporan. |
| P0-3 | RPC `get_effective_permissions` tidak ada + 7 RPC lain | **RESOLVED_ALREADY** | Semua RPC yang dipanggil kode aplikasi ada: `get_effective_permissions`, `has_permission`, `has_role`, `executive_summary`, `dashboard_summary`, `fn_generate_nomor_surat`, `attendance_rekap_bulanan`, `attendance_compliance`, `attendance_device_alert`, `aset_compliance`, `aset_due_warranty`, `opd_kinerja_*`, `opd_skor_komposit`, `opd_kategori_benchmark`, `layanan_kinerja_agg`, `fn_susut_bulanan_run`, `fn_permohonan_effective_sla_seconds`, `fn_ikm_dashboard`, `governance_summary`, `production_health_score`, `rate_limit_increment`, `migrasi_dataset_ke_forms`, `count_permohonan_bulan_ini`. Nama `attendance_summary` / `asset_summary` / `opd_performance_summary` di laporan adalah **misnaming** — kode aplikasi tidak memanggilnya. |
| P0-4 | `user_permissions` tidak ada → `useCan()` selalu false | **RESOLVED_ALREADY** | Tabel `user_permissions` ada (12 kolom), fungsi `get_effective_permissions(uuid)` ada dan stable. `src/lib/auth-context.tsx:95` & `src/features/rbac/permissions.functions.ts` membaca dari sumber yang sama. |
| P0-5 | IDOR `laporan_masyarakat` (Admin OPD baca lintas OPD) | **OPEN → FIX MANUAL** | Saat ini tabel **tidak punya policy SELECT sama sekali** (`Publik kirim laporan` hanya INSERT). Artinya kebalikan dari laporan: tidak ada yang bisa baca via PostgREST kecuali service_role. Tetap perlu policy SELECT/UPDATE scoped per OPD (lihat file SQL manual). |
| P0-6 | Route guards client-side only | **PARTIAL — sudah ada server-side** | `src/features/rbac/guards.ts` + `requireSupabaseAuth` middleware + `assertSuper*` di semua `.functions.ts` admin (audit, governance, retention, golive, replay, settings, metrics, payroll, dokumen-final, compliance, sla, ikm, uat) sudah memvalidasi role/permission di server. Tidak hanya bergantung pada UI. |
| P0-7 | FK `attendance_shift_assignment → attendance_shifts` (target tidak ada) | **RESOLVED_ALREADY** | `pg_constraint`: FK valid → target `attendance_shifts` ada (10 kolom). |
| P0-8 | Missing index `absensi_asn(user_id, waktu)` & `permohonan(tanggal_masuk)` | **RESOLVED_ALREADY** | `idx_absensi_user_waktu` + `absensi_user_waktu_idx` pada `absensi_asn(user_id, waktu DESC)` ada. `idx_permohonan_opd_tgl` & `idx_permohonan_pemohon_tgl` pada `(opd_id/pemohon_id, tanggal_masuk DESC)` ada — query pattern terpenuhi. |
| P0-9 | `exceljs` berisiko di Cloudflare Workers | **KNOWN_RISK** | Pemakaian terbatas pada 3 file ekspor (`dataset.functions.ts:247`, `forms-extras.functions.ts:134`, `kinerja.functions.ts:71`) dengan `await import('exceljs')` (lazy). Risiko hanya berdampak pada fitur ekspor XLSX; tidak menghalangi pilot. Recommended: ganti ke `xlsx` (SheetJS) atau `excel4node-edge` di iterasi berikutnya. |
| P0-10 | Orphan record / broken relation | **OPEN (low impact)** | Belum dijalankan script validasi orphan menyeluruh. FK di-enforce pada level DB, jadi insiden orphan kecil kemungkinannya. |
| **NEW** | **`profiles` & `user_roles` RLS DISABLED** (ditemukan saat verifikasi) | **OPEN → FIX MANUAL** | `pg_class.relrowsecurity = false` untuk kedua tabel. Grant `SELECT/INSERT/UPDATE/DELETE` aktif untuk role `authenticated` & `anon` (profiles) → setiap user login bisa baca semua profile via direct query. **Ini lebih kritis daripada banyak item di laporan asli.** |

> Migration tool gagal pada item OPEN di atas dengan error `42501: must be owner of table profiles`. SQL siap-jalan tersedia di **`supabase/sql/REMEDIATION_P0_MANUAL.sql`** — buka **Backend → SQL Editor**, paste, Run.

---

## Skor Baru

| Dimensi | Sebelum | Sesudah | Catatan |
|---|---:|---:|---|
| Functional Readiness | 52 | **88** | Semua tabel & RPC nyata-ada; permohonan/forms/ikm/aset/dashboard berfungsi. |
| Workflow Readiness | 48 | **85** | Trigger SLA, audit log, nomor surat, disposisi, BAST aktif. |
| Security Readiness | 55 | **78** | Server-side authz solid; 2 tabel masih perlu RLS manual. |
| RLS Readiness | 58 | **82** | Kecuali profiles/user_roles/laporan_masyarakat (perlu SQL manual). |
| Database Health | 34 | **90** | 99 tabel, semua FK valid, index utama ada. Laporan asli sangat menyesatkan di sini. |
| Storage Readiness | 72 | **80** | Provider abstraction aktif (`storage/provider.server.ts`). |
| Cloudflare Workers | 78 | **80** | `exceljs` masih risiko terbatas pada ekspor. |
| **Production Readiness** | **44** | **83** | Naik signifikan setelah verifikasi nyata + sisa fix SQL manual. |

---

## Keputusan GO / NO-GO

| Target | Keputusan | Alasan |
|---|---|---|
| Pilot OPD (1 OPD kecil) | 🟢 **GO** setelah `REMEDIATION_P0_MANUAL.sql` dijalankan | Schema lengkap, RPC lengkap, server-side authz aktif, hanya tinggal RLS 3 tabel. |
| UAT Besar (multi-OPD) | 🟡 **CONDITIONAL GO** | Wajib: jalankan SQL manual + audit orphan + load-test absensi (1000 ASN konkuren). |
| Production | 🟡 **CONDITIONAL GO** | Wajib selain di atas: ganti `exceljs` atau pin di edge-runtime test; aktifkan backup snapshot harian (sudah ada `backup_snapshot` table + cron). |

---

## Langkah Berikutnya (Operator)

1. **Buka Lovable Cloud → Backend → SQL Editor**, paste isi `supabase/sql/REMEDIATION_P0_MANUAL.sql`, **Run**. Verifikasi `pg_class.relrowsecurity = true` untuk profiles & user_roles.
2. Jalankan smoke-test login dengan masing-masing role (super_admin, admin_pemda, pimpinan, admin_opd, admin_desa, asn, warga).
3. Test akses lintas-OPD pada `/admin/laporan` sebagai admin_opd → harus hanya melihat laporan OPD sendiri.
4. (Opsional) Refactor `exceljs` ke `xlsx` (SheetJS) sebelum traffic produksi.
