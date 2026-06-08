
# Sprint G — Rebaseline, Legacy Activation, Dataset Consolidation, Security Hardening

Sprint ini sangat besar (estimasi 25–35 file baru, ratusan baris SQL, 7 modul UI baru, 4 area hardening). Saya pecah jadi 6 fase yang bisa dieksekusi berurutan. Setiap fase berhenti di titik yang aman (tidak meninggalkan build merah) sehingga Anda bisa review per-fase sebelum lanjut.

**Prinsip tetap:** tidak menghapus tabel, tidak menghapus fitur, tidak ada solusi sementara.

---

## Fase G1 — Migration Rebaseline (1 file SQL besar)

**Tujuan:** environment baru bisa direproduksi 100% dari `supabase/migrations/`.

**Pendekatan:**
1. Dump skema produksi via `pg_dump --schema-only --schema=public` (saya jalankan via `psql` introspection karena `pg_dump` tidak ada di sandbox — saya gabungkan `information_schema`, `pg_proc`, `pg_policies`, `pg_trigger`, `pg_indexes`, `pg_type` untuk merangkai SQL idempoten).
2. Tulis `supabase/migrations/000_production_baseline.sql`:
   - `CREATE EXTENSION IF NOT EXISTS` (pgcrypto, pg_net, pg_cron, dst).
   - `CREATE TYPE … IF NOT EXISTS` via blok `DO $$ … EXCEPTION WHEN duplicate_object` (Postgres tidak punya `CREATE TYPE IF NOT EXISTS`).
   - `CREATE TABLE IF NOT EXISTS` untuk 96 tabel.
   - `ALTER TABLE … ADD COLUMN IF NOT EXISTS` untuk kolom-kolom tambahan.
   - `CREATE INDEX IF NOT EXISTS` untuk seluruh index non-PK.
   - `CREATE OR REPLACE FUNCTION` untuk seluruh RPC & trigger function.
   - `DROP TRIGGER IF EXISTS … ; CREATE TRIGGER …` (idempoten).
   - `CREATE OR REPLACE VIEW` untuk 2 view.
   - `GRANT` per tabel sesuai role policy (authenticated / service_role / anon hanya bila perlu).
   - `ALTER TABLE … ENABLE ROW LEVEL SECURITY` + `DROP POLICY IF EXISTS … ; CREATE POLICY …`.
   - Bucket storage via `INSERT INTO storage.buckets … ON CONFLICT DO NOTHING`.
3. Arsipkan `supabase/sql/01.schema.sql` → `supabase/sql/_archived/` dengan README penjelasan.

**Catatan:** file ini hanya untuk reproduksi env baru — tidak dijalankan ulang di production (sudah ada datanya).

---

## Fase G2 — Aktivasi 17 Tabel Legacy

Tiap modul = 1 server function file + 1 atau lebih route admin + integrasi titik pakai.

### 2.1 Data Request (`data_requests`)
- `src/lib/data-requests.functions.ts` — list/create/approve/reject/fulfill.
- Route warga: `src/routes/data-permintaan.tsx` (form pengajuan).
- Route admin: `src/routes/admin.data-requests.tsx` (inbox + approval).
- Notifikasi via tabel `notifications`.

### 2.2 Document Access Audit (`document_access`)
- Logger di `src/lib/document-access.functions.ts` — `logDocumentOpen(doc_id, source)`.
- Hook ke pembukaan file (permohonan_berkas, form_submission_files, aset).
- Route admin: `src/routes/admin.document-access.tsx` (timeline + filter).

### 2.3 Nomor Surat (`nomor_surat_sequence`, `nomor_surat_issued`)
- Sudah ada `src/lib/nomor-surat.functions.ts` (issue + preview). Tambah:
  - `listIssued`, `searchByNomor`, `getSequenceConfig`, `updateSequenceConfig`.
- Route admin: `src/routes/admin.nomor-surat.tsx` (config format + histori + search).
- Integrasi tombol "Terbitkan Nomor Surat" di: detail permohonan, form submission final, BAST aset.

### 2.4 Komentar Permohonan (`permohonan_komentar`)
- `src/lib/permohonan-komentar.functions.ts` — list/create dengan flag `internal_only`.
- Komponen `PermohonanCommentThread.tsx` di `src/features/permohonan/`.
- Mount di `src/routes/permohonan.$id.tsx` (tab "Diskusi" — internal vs publik).
- Mention `@nama` parsing → notifikasi.

### 2.5 Share Paket (5 tabel)
- `src/lib/share.functions.ts` — CRUD paket, target, lampiran, komentar, riwayat.
- Hook upload reuse `useUploadSession`.
- Route: `src/routes/share.index.tsx` (inbox masuk/keluar), `src/routes/share.$id.tsx` (detail + komentar + approval), `src/routes/share.baru.tsx` (composer).
- Approval menggunakan trigger `set_paket_approval_flag` yang sudah ada.

### 2.6 Konsolidasi Rate Limit (`rate_limit` ↔ `rate_limit_hits`)
- **Tidak drop `rate_limit`.** Strategi: jadikan `rate_limit_hits` sebagai engine tulis (sudah ada `rate_limit_increment` RPC). `rate_limit` ditandai sebagai mirror/legacy via view kompat.
- Refactor `src/lib/security/rate-limit.ts` & `rate-limit.server.ts` untuk read/write konsisten ke `rate_limit_hits`.
- Backfill historical row `rate_limit` → `rate_limit_hits` (idempoten, sekali jalan via server fn).
- Route admin: `src/routes/admin.rate-limit.tsx` (top IP, endpoint, hits 24h, blocked).

### 2.7 Legacy Submission Center (`submissions`, `submission_answers`, `submission_files`, `submission_dispositions`)
- `src/lib/submissions-legacy.functions.ts` — read-only list/detail + export CSV.
- `src/lib/submissions-migrate.functions.ts` — wizard map field → Form Builder; tulis ke `form_submissions` + `form_submission_files`.
- Route: `src/routes/admin.submission-legacy.index.tsx`, `admin.submission-legacy.$id.tsx`, `admin.submission-legacy.migrate.$id.tsx`.
- Tidak ada DELETE — hanya tandai `migrated_to_submission_id`.

### 2.8 Master Unit Kerja (`unit_kerja`)
- `src/lib/unit-kerja.functions.ts` — CRUD + listByOpd.
- Route admin: `src/routes/admin.unit-kerja.tsx`.
- Integrasi:
  - Field `unit_kerja_id` di profil ASN (admin.asn + akun.tsx).
  - Target picker form builder (tambah opsi `unit_kerja`).
  - Filter assignment & absensi.

### 2.9 Verification Logs (`verification_logs`)
- `src/lib/verification-log.functions.ts` — list by entity + insert helper.
- Komponen `<VerificationTimeline entity="permohonan" id={…} />`.
- Inject ke detail: permohonan, dataset_submission, aset (tab "Verifikasi").
- Setiap perubahan status verifikasi sudah ditulis ke audit_log — tambahkan tulis paralel ke `verification_logs` untuk timeline domain-spesifik.

---

## Fase G3 — Dataset Consolidation

**Form Builder = platform utama. Pelaporan Data = read-through ke Form Builder.**

1. **Dataset Migration Center** (`src/routes/admin.dataset.migrate.tsx`):
   - List `dataset_template` aktif.
   - Tombol "Migrasi ke Form Builder" (panggil RPC `migrasi_dataset_ke_forms` yang sudah ada).
   - Preview hasil sebelum commit.
   - Rollback: hapus `forms` hasil migrasi + restore `aktif=true` pada template (transaksi).
2. **Banner "Modul Lama"** di `admin.dataset.tsx` + `admin.dataset.review.tsx` — link ke Form Builder.
3. **Dashboard Pelaporan Data** diubah agar query `forms` + `form_submissions` (bukan `dataset_template`/`dataset_submission` saja). Adapter di `src/lib/dataset.functions.ts`.

---

## Fase G4 — Security Hardening

1. **Views → `security_invoker=on`:**
   ```sql
   ALTER VIEW public.aset_nilai_buku SET (security_invoker = on);
   ALTER VIEW public.v_permohonan_overdue SET (security_invoker = on);
   ```
2. **Function `SET search_path = public`:** scan `pg_proc` untuk SECURITY DEFINER tanpa `proconfig`, generate `ALTER FUNCTION … SET search_path = public` (batch).
3. **REVOKE EXECUTE FROM anon** untuk RPC internal (whitelist publik: `rating_public_stats`, `fn_ikm_dashboard` jika dipakai anon; selebihnya revoke).
4. **RLS audit:** query `pg_policies` cari `qual='true'` atau `with_check='true'`, ganti dengan policy berbasis `has_role()`/`auth.uid()` per tabel.
5. **Extensions:** pindahkan pgcrypto/pg_net keluar `public` ke `extensions` schema bila aman (atau dokumentasikan acceptance bila migrasi berisiko).

Semua perubahan via 1 migrasi `001_security_hardening.sql` + verifikasi lewat `supabase--linter`.

---

## Fase G5 — Admin Experience

Tambah grup menu **Data Governance** di `AdminShell.tsx`:
- Nomor Surat → `/admin/nomor-surat`
- Unit Kerja → `/admin/unit-kerja`
- Verification Logs → `/admin/verification-log` (sudah ada partial)
- Data Requests → `/admin/data-requests`
- Shared Data → `/share`
- Legacy Submission → `/admin/submission-legacy`
- Rate Limit Monitor → `/admin/rate-limit`

---

## Fase G6 — Superadmin Dashboard Cards

Tambah 6 kartu di `src/routes/admin.index.tsx` (sumber: count query masing-masing tabel via 1 RPC agregat baru `governance_inventory()`):
- Total Nomor Surat Diterbitkan
- Total Share Paket aktif
- Total Verification Logs 30 hari
- Total Data Request pending
- Total Legacy Submission belum dimigrasi
- Status Migrasi Dataset (X dari Y template)

---

## Validasi & Laporan Akhir

- **Data uji:** seed minimal 1 record per modul baru via `supabase--insert` untuk 7 role.
- **Smoke test manual** via preview untuk tiap role.
- **Linter run** akhir → target 0 ERROR.
- **Laporan** ditulis ke `.lovable/sprint-g-report.md` dengan metrik:
  - Migration Coverage (CREATE TABLE di baseline / 96)
  - 17 tabel × status UI (✅/❌)
  - Konsolidasi dataset (banner + migration center + dashboard adapter)
  - Linter before/after
  - Production Readiness score

---

## Rekomendasi Eksekusi

Sprint ini terlalu besar untuk 1 build pass. Saya usulkan urutan persetujuan:

1. **G1 + G4** (DB foundation: baseline + hardening) — paling berisiko, validasi dulu.
2. **G2.3 + G2.4 + G2.9** (nomor surat, komentar permohonan, verification log — integrasi tinggi).
3. **G2.1 + G2.2 + G2.8** (data request, document access, unit kerja).
4. **G2.5** (share — modul terbesar).
5. **G2.6 + G2.7** (rate limit konsolidasi + legacy submission center).
6. **G3 + G5 + G6** (consolidation + menu + dashboard) + laporan akhir.

**Pertanyaan sebelum eksekusi:**
- Setuju dengan urutan 6 batch di atas, atau Anda ingin saya kerjakan sekaligus dalam 1 build (risiko: review jadi sulit, build bisa merah di tengah)?
- Untuk Fase G4 "Extensions in Public" — boleh saya pindahkan ke schema `extensions` (sedikit berisiko), atau cukup didokumentasikan sebagai accepted risk?
- Untuk konsolidasi rate_limit — `rate_limit` lama dipertahankan sebagai view kompat (read-only mirror dari `rate_limit_hits`), atau dibiarkan apa adanya tanpa write baru?
