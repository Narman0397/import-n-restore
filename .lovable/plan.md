## Sprint Database Reconciliation — Plan Eksekusi

Sprint ini sangat besar (11 fase, mencakup ±462 object drift). Saya butuh konfirmasi pendekatan sebelum mulai, karena beberapa keputusan akan menentukan banyak jam kerja & risiko terhadap production.

---

### Pendekatan Umum

Saya akan kerjakan **read-only inventarisasi dulu (Phase 1–9)**, hasilkan laporan lengkap, lalu **baru** menulis migrasi rekonstruksi (Phase 10) setelah Anda setuju cakupannya. Phase 11 (fresh-deploy test) tidak bisa saya jalankan langsung di sandbox — saya hanya bisa menyiapkan script-nya, lalu Anda jalankan di Supabase project baru.

### Output yang akan dihasilkan

Semua disimpan ke `/mnt/documents/db-reconciliation/`:

```text
db-reconciliation/
├── 01_live_inventory.json          # Phase 1
├── 02_schema_reconciliation.md     # Phase 2
├── 03_storage_audit.md             # Phase 3
├── 04_enum_audit.md                # Phase 4
├── 05_rpc_audit.md                 # Phase 5
├── 06_table_audit.md               # Phase 6
├── 07_rls_matrix.md                # Phase 7
├── 08_policy_validation.md         # Phase 8 (IDOR/leakage)
├── 09_performance_report.md        # Phase 9
├── 10_reconstruction.sql           # Phase 10 (additive, idempotent)
├── 11_fresh_deploy_test.md         # Phase 11 instruksi
└── SUMMARY.md                      # Drift summary + readiness score
```

### Prinsip Eksekusi

1. **Read-only sampai Phase 10.** Tidak ada `supabase--migration` dipanggil sampai laporan disetujui.
2. **Additive only.** Migrasi rekonstruksi pakai `CREATE … IF NOT EXISTS`, `CREATE OR REPLACE`, `DROP POLICY IF EXISTS` + `CREATE POLICY`. Tidak ada `DROP TABLE`, tidak ada `DROP COLUMN`, tidak ada penghapusan enum value.
3. **Tidak menyentuh business logic.** Hanya schema, RLS, indexes, RPC signatures, storage buckets.
4. **Code = source of truth untuk apa yang dipakai.** Live DB = source of truth untuk struktur. Migration repo akan direkonstruksi mengikuti live DB.

### Yang Saya Butuhkan Konfirmasi

1. **Apakah Phase 10 boleh menghasilkan SATU file SQL besar** (`10_reconstruction.sql`) yang dijalankan manual via SQL editor, atau Anda mau saya pecah jadi beberapa `supabase--migration` calls (yang masing-masing minta approval)?
2. **Bucket `branding` yang hilang:** boleh saya buat langsung dengan `supabase--storage_create_bucket` (private), atau cukup masukkan ke laporan dulu?
3. **Phase 8 (IDOR/policy validation):** apakah cukup analisis static (baca policy + bandingkan dengan akses code), atau Anda mau saya buat test queries dengan `SET LOCAL request.jwt.claims` untuk simulate tiap role? Yang kedua jauh lebih thorough tapi memakan waktu.
4. **Apakah Anda OK kalau saya tidak menjalankan Phase 11 sendiri?** Saya tidak punya akses ke project Supabase kosong; saya hanya bisa siapkan SQL + checklist untuk Anda jalankan di project staging.

Setelah Anda jawab, saya langsung mulai Phase 1.