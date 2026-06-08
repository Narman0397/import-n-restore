
# Laporan Sinkronisasi Migrasi DB ↔ Kode

## 1. Ringkasan eksekutif

| Aspek | Jumlah |
|---|---|
| Tabel di database (schema `public`) | **96** |
| View di database | **2** (`aset_nilai_buku`, `v_permohonan_overdue`) |
| Entitas terdaftar di `src/integrations/supabase/types.ts` | 95 tables + 2 views ✅ |
| File migrasi (`supabase/migrations/*.sql`) | **6** |
| File schema baseline (`supabase/sql/01.schema.sql`) | 1 (24 CREATE TABLE — historis) |
| Tabel direferensikan langsung lewat `supabase.from(...)` di kode | 82 (+ `storage.objects`) |
| Linter Supabase | **166 temuan** (2 ERROR, 164 WARN) |

**Kesimpulan singkat:** types.ts **sinkron** dengan database (tidak ada drift skema). Namun ada **17 tabel "yatim"** di DB yang tidak pernah disentuh kode aplikasi, **6 file migrasi tidak mencerminkan seluruh 96 tabel** (sebagian besar skema lahir dari `supabase/sql/01.schema.sql` + `migration-manual.sql` yang dijalankan manual), dan ada **2 error linter** yang harus diperbaiki.

---

## 2. Sinkronisasi types.ts ↔ DB

Hasil diff:
- Tabel di DB tapi **tidak ada** di types.ts → **0** ✅
- Tabel di types.ts tapi **tidak ada** di DB → **0** ✅
- View `aset_nilai_buku` dan `v_permohonan_overdue` keduanya terdaftar di blok `Views` ✅

→ **types.ts terbaru, regenerasi tidak diperlukan.**

---

## 3. Tabel "yatim" — ada di DB tapi tidak dipakai kode

Pencarian `supabase.from("<table>")` di seluruh `src/` tidak menemukan referensi untuk 17 tabel berikut (semuanya `n_live_tup = 0`, kecuali `rate_limit` = 8):

```
data_requests              nomor_surat_issued        share_komentar
document_access            nomor_surat_sequence      share_lampiran
permohonan_komentar        rate_limit                share_paket
role_permissions           submissions               share_riwayat
submission_answers         submission_files          share_target
submission_dispositions    unit_kerja                verification_logs
```

Catatan:
- `submissions`, `submission_answers`, `submission_files`, `submission_dispositions` → kemungkinan **legacy** sebelum migrasi ke `form_submissions` / `form_submission_files`.
- `permohonan_komentar` masih dipakai trigger DB (`notify_permohonan_komentar`), namun UI/kode TS tidak pernah read/write — perlu konfirmasi apakah fitur komentar permohonan masih dipakai.
- `share_*` (5 tabel) lengkap dengan trigger `set_paket_approval_flag` & `log_share_event` tapi tidak ada UI sama sekali.
- `rate_limit` (lama) dan `rate_limit_hits` (baru) → ada **duplikasi**; kode `src/lib/security/rate-limit.ts` & `rate-limit.server.ts` masih merujuk `rate_limit`.
- `unit_kerja` dipanggil via RPC server-side (`listOpdsForTarget`), bukan via `supabase.from`.

**Rekomendasi:** audit & putuskan **drop atau implementasi UI** untuk setiap tabel ini.

---

## 4. Drift migrasi vs realita DB

```text
supabase/sql/01.schema.sql           24 CREATE TABLE   (baseline, dijalankan manual)
supabase/sql/migration-manual.sql    24 CREATE TABLE   (patch manual)
supabase/migrations/  (6 file)       17 CREATE TABLE total
                                     -----
Total tercermin                      ~65 tabel
Realitas DB                          96 tabel
```

**Selisih ~31 tabel** dibuat lewat jalur lain (SQL editor langsung / migrasi terhapus). Konsekuensinya:
- **Reproduksi environment baru** (staging/lokal) akan **gagal** — jalankan saja `supabase/migrations/` tidak menghasilkan skema yang sama dengan production.
- Tidak ada audit trail Git untuk 31 tabel tsb.

**Rekomendasi:** dump schema produksi → tulis ulang sebagai 1 migrasi baseline kanonik, arsipkan `supabase/sql/*.sql` sebagai histori.

---

## 5. Temuan linter Supabase (166)

- **2 ERROR — Security Definer View** → kemungkinan besar `aset_nilai_buku` / `v_permohonan_overdue`. Harus diubah ke `security_invoker = on`.
- **WARN dominan:**
  - "Function Search Path Mutable" (banyak fungsi) — sebagian besar sudah aman karena pakai `SET search_path = public`, tapi linter masih flag fungsi lama.
  - "Public Can Execute SECURITY DEFINER Function" — beberapa RPC bisa dipanggil anon, perlu `REVOKE EXECUTE FROM anon`.
  - "Extension in Public" — ekstensi (mis. `pgcrypto`) terpasang di schema `public`.
  - "RLS Policy Always True" — minimal 1 policy permisif untuk `INSERT/UPDATE/DELETE`.

---

## 6. Catatan lain

- Kode menyebut tabel `objects` → ini `storage.objects` (bawaan Supabase), bukan public schema. Aman.
- 6 migrasi terbaru (Juni 2026) berisi tweak kecil: trigger guard form_submission, kolom `visible_if` di `form_fields`, dsb. Semua tercermin di types.ts.

---

## 7. Rekomendasi tindak lanjut (urut prioritas)

1. **P0 — Perbaiki 2 ERROR linter** (Security Definer View → `security_invoker=on` untuk kedua view).
2. **P0 — Audit 17 tabel yatim**: tentukan drop vs aktifkan UI. Minimal hapus 4 tabel legacy `submissions*` dan duplikasi `rate_limit` setelah migrasi data.
3. **P1 — Rebaseline migrasi**: ekspor skema produksi → satu migrasi kanonik, supaya environment baru reproducible dari `supabase/migrations/`.
4. **P1 — Kurangi WARN linter**: tambahkan `SET search_path` ke fungsi yang tersisa, `REVOKE EXECUTE … FROM anon` untuk SECURITY DEFINER yang bukan publik, pindahkan extension keluar `public`.
5. **P2 — Pertegas modul `share_*` & `permohonan_komentar`**: bangun UI atau hapus skema + trigger terkait.

---

Saya hanya menyiapkan laporan ini — belum mengubah apapun. Setujui rencana ini, lalu beri tahu prioritas mana yang ingin saya kerjakan dulu (mis. "lanjut P0 dulu") dan saya akan eksekusi setelah masuk build mode.
