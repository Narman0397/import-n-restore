## 1. Satukan menu "Pengguna" + "Hak Akses"

Saat ini sidebar admin punya dua entri (`AdminShell.tsx` baris 69–70):
- `/admin/users` → halaman `admin.users.tsx` yang sudah berisi tabel user **dan** panel `UserRbacPanel` (role + permission override).
- `/admin/rbac` → cuma `redirect → /admin/users`. Jadi memang isinya identik.

Perubahan:
- Di `src/components/admin/AdminShell.tsx`: hapus entri `Hak Akses`, ganti label `Pengguna` jadi **"Pengguna & Hak Akses"** (ikon tetap `Users`, atau gabungkan dengan `ShieldIcon`).
- Biarkan file route `admin.rbac.tsx`, `admin.rbac.$userId.tsx`, `admin.rbac.audit.tsx` tetap sebagai redirect — supaya bookmark/lama tidak 404.
- Pastikan halaman `/admin/users` punya heading/section eksplisit "Hak Akses" agar user paham fitur menyatu.

## 2. Perbaiki error `work_schedule` ↔ `opd`

Penyebab: query `listSchedules` (di `src/lib/asn-advanced.functions.ts:46-48`) memakai PostgREST embed `opd:opd!opd_id(nama,singkatan)`, tapi tabel `public.work_schedule` **tidak punya FK** ke `public.opd` (dicek via `pg_constraint`). PostgREST melempar *"Could not find a relationship…"*.

Perbaikan (migration):
- Tambahkan FK `work_schedule.opd_id → public.opd(id) ON DELETE SET NULL` (set NULL agar baris jadwal global tetap valid).
- Bersihkan dulu nilai `opd_id` yang tidak match (`UPDATE … SET opd_id = NULL WHERE opd_id NOT IN (SELECT id FROM opd)`) supaya constraint bisa terbentuk.
- Setelah migration, PostgREST otomatis menyegarkan schema cache dan embed `opd:opd!opd_id(...)` berfungsi. Tidak perlu ubah kode aplikasi.

## 3. Audit form builder end-to-end

Telusuri alur lalu perbaiki temuan:
1. **Buat draft** di `/admin/forms` → `admin.forms.tsx` (`forms.functions.ts`: createForm).
2. **Edit field & target** di `/admin/forms/$id` (`FormFieldsTab`, `FormMetaTab`, `FormTargetsTab`).
3. **Publish** form (`status='published'`, `published_at`).
4. **Assignment** ke user/OPD (`form_assignments`).
5. **Pengisian** warga/ASN di `/pengisian` & `/pengisian/$id` (`FieldRenderer`, `FileUploader`, `useFormDraft`, `useUploadSession`).
6. **Submit → state machine** (`submissions.functions.ts`, `schema/state-machine.ts`: draft→submitted→under_review→approved/rejected/revision_required).
7. **Review admin** di `/admin/submission-review` + komentar (`submission_dispositions`, `form_submission_comment`).

Untuk setiap langkah: jalankan minimal satu data uji via `supabase--read_query` / serverFn untuk memastikan tidak ada error RLS/grant/embed. Catat & perbaiki bug yang ditemukan (tipikal: embed PostgREST yang FK-nya hilang, validator Zod, trigger `form_submission_guard` transition, RLS pada `form_submission_files`).

Karena ini investigatif, daftar perbaikan konkret baru bisa difinalisasi setelah audit. Hasil audit dilaporkan + diperbaiki dalam pass yang sama.

## Urutan kerja

1. Migration FK `work_schedule.opd_id`.
2. Edit `AdminShell.tsx` (gabungkan menu).
3. Jalankan audit form builder, perbaiki temuan satu per satu.
4. Verifikasi: buka `/admin/asn-kepatuhan` (tidak ada toast error), buka `/admin/users` (panel RBAC tampil), buat→isi→review form contoh.
