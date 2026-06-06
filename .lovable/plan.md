# Audit Migrasi RLS vs Kode

## Hasil verifikasi DB

| Tabel | RLS aktif | Jumlah policy | Kolom referensi | Sesuai kode? |
|---|---|---|---|---|
| profiles | ✅ | 3 (select/update/insert) | id, opd_id, desa | ✅ |
| user_roles | ✅ | 2 (select, all super_admin) | user_id | ✅ |
| laporan_masyarakat | ✅ | 3 (insert publik, select/update admin scope) | opd_id | ✅ |

Helper fungsi `has_role`, `get_user_opd`, `get_user_desa`, `_lovable_request_uid` semua ada. Struktur kolom yang direferensikan policy semua match dengan yang dipanggil di kode (`auth-context.tsx`, `permissions.functions.ts`, dll).

## Masalah yang ditemukan

Semua policy memakai `public._lovable_request_uid()` (workaround agar `CREATE POLICY` tidak butuh USAGE pada schema `auth`). Implementasi sekarang **hanya** membaca GUC legacy:

```
NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid
```

Sementara `auth.uid()` Supabase membaca dua sumber (legacy GUC + JSON `request.jwt.claims`). Bila PostgREST hanya men-set JSON claims (perilaku modern), helper kita return `NULL` → seluruh policy authenticated effectively deny-all (user tak bisa baca profil/role sendiri, dashboard admin kosong, dsb).

## Perbaikan

Update `REMEDIATION_P0_MANUAL.sql` dan jalankan ulang hanya bagian fungsi helper (policy tidak perlu di-recreate — fungsi STABLE dipanggil per-row saat eksekusi):

```sql
CREATE OR REPLACE FUNCTION public._lovable_request_uid()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    NULLIF(current_setting('request.jwt.claim.sub', true), ''),
    NULLIF(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub'
  )::uuid
$$;
```

Setelah patch, export ulang `/mnt/documents/REMEDIATION_P0_MANUAL.sql` agar user bisa run manual sekali untuk meng-`CREATE OR REPLACE` fungsi tersebut (tidak butuh hak owner table — fungsi milik kita sendiri di schema public).

## Verifikasi pasca-patch

1. Login sebagai user warga biasa → buka `/akun` → profil dan role harus terbaca (bukan kosong).
2. Login sebagai admin_opd → `/admin/laporan` harus menampilkan laporan dengan `opd_id` yang sesuai.
3. Login sebagai super_admin → `/admin/users` harus list semua profiles & user_roles.

Tidak ada perubahan pada kode aplikasi — semua patch hanya di SQL helper.
