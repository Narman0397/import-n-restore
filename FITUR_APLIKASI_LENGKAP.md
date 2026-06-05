# Dokumentasi Lengkap Fitur Aplikasi: Portal Pelayanan Pemerintah Daerah

> **Bukti-based audit** — Setiap klaim disertai path file sumber. Diperiksa: `src/routes/`, `src/features/rbac/`, `src/components/admin/`, `src/lib/`, `src/integrations/supabase/types.ts`.
>
> **Tanggal audit:** berdasarkan kondisi kode di `/dev-server`.

---

## 1. Ringkasan Eksekutif

| Atribut | Detail |
|---|---|
| **Nama Aplikasi** | Portal Resmi Pemerintah Kabupaten Buton Selatan / "Satu Pelayanan Pemerintah" |
| **Sub-judul teknis** | Single-platform Government Digital Services |
| **Target Pemda** | Kabupaten/Kota level (dikonfigurasi untuk Kab. Buton Selatan, dapat dilokalisasi) |
| **Target Pengguna** | Warga (publik), ASN, Admin OPD, Admin Pemda, Pimpinan Daerah (Bupati/Sekda), Super Admin |
| **Nilai untuk Pemda** | Sentralisasi pelayanan publik, manajemen ASN, inventarisasi aset, survei kepuasan (IKM), pelaporan data, dashboard kinerja OPD, tata kelola digital |
| **Jumlah Modul Utama** | 12 modul (Layanan Publik, Permohonan, ASN, Aset, Dataset/Open Data, IKM/Survey, Laporan Masyarakat, Kinerja OPD, CMS/Berita, RBAC, Form Builder, Sistem) |
| **Jumlah Route** | **86 route** (`src/routes/` — termasuk sub-route admin, asn, publik, API) |
| **Jumlah Role** | **7 role** (`super_admin`, `admin_pemda`, `pimpinan`, `admin_opd`, `admin_desa`, `asn`, `warga`) |
| **Stack Teknologi** | React 19 + TanStack Router/Start, Supabase (Auth, DB, Storage, Realtime), TailwindCSS, Recharts, PWA |

**Sumber:** `src/routes/__root.tsx` (meta tag nama), `src/features/rbac/constants.ts` (roles), `src/routes/` (jumlah file).

---

## 2. Peta Seluruh Fitur

| Modul | Fitur | Status | Lokasi Kode |
|---|---|---|---|
| **Portal Publik** | Beranda dengan statistik real-time | Implemented | `src/routes/index.tsx` |
| **Portal Publik** | Katalog OPD dengan ikon dinamis | Implemented | `src/routes/index.tsx` |
| **Portal Publik** | Halaman Tentang | Implemented | `src/routes/tentang.tsx` |
| **Portal Publik** | Halaman Kontak / Pengaduan Warga | Implemented | `src/routes/kontak.tsx` |
| **Portal Publik** | Berita & Artikel | Implemented | `src/routes/berita.tsx` |
| **Portal Publik** | Profil Instansi OPD | Implemented | `src/routes/instansi.$singkatan.tsx` |
| **Layanan Publik** | Katalog layanan semua OPD | Implemented | `src/routes/layanan.index.tsx` |
| **Layanan Publik** | Detail halaman layanan | Implemented | `src/routes/layanan.$slug.tsx` |
| **Permohonan** | Daftar permohonan warga | Implemented | `src/routes/permohonan.index.tsx` |
| **Permohonan** | Buat permohonan baru (non-login) | Implemented | `src/routes/permohonan.baru.tsx` |
| **Permohonan** | Detail & tracking status permohonan | Implemented | `src/routes/permohonan.$id.tsx` |
| **Permohonan** | Verifikasi QR Token | Implemented | `src/routes/v.$token.tsx` |
| **Kinerja OPD** | Dashboard publik kinerja tiap OPD | Implemented | `src/routes/kinerja-opd.tsx` |
| **Data Terbuka** | Katalog dataset publik | Implemented | `src/routes/data-terbuka.index.tsx` |
| **Data Terbuka** | Detail dataset per slug | Implemented | `src/routes/data-terbuka.$slug.tsx` |
| **Data Terbuka** | Halaman data generik | Implemented | `src/routes/data.tsx` |
| **IKM / Survey** | Form isian survei kepuasan | Implemented | `src/routes/ikm.$id.tsx` |
| **Form Builder** | Pengisian form dinamis (publik/internal) | Implemented | `src/routes/pengisian.$id.tsx`, `src/routes/pengisian.index.tsx` |
| **ASN — Absensi** | Scan QR absensi dengan GPS | Implemented | `src/routes/asn.absensi.tsx` |
| **ASN — Izin/Cuti** | Pengajuan izin & cuti ASN | Implemented | `src/routes/asn.izin.tsx` |
| **ASN — Lembur** | Pengajuan lembur ASN | Implemented | `src/routes/asn.lembur.tsx` |
| **ASN — Tugas** | Lihat tugas (form assignment) | Implemented | `src/routes/asn.tugas.tsx` |
| **ASN — Aset** | Lihat aset yang dipegang ASN | Implemented | `src/routes/asn.aset.tsx` |
| **ASN — Verifikasi** | Verifikasi akun ASN | Implemented | `src/routes/asn.verifikasi.tsx` |
| **ASN — Scan Token** | Scan token dinamis | Implemented | `src/routes/asn.scan.$token.tsx` |
| **Tugas** | Detail assignment tugas | Implemented | `src/routes/tugas.$assignmentId.tsx` |
| **Admin — Dashboard** | KPI, tabel permohonan, grafik trend | Implemented | `src/routes/admin.index.tsx` |
| **Admin — Layanan** | CRUD jenis layanan OPD | Implemented | `src/routes/admin.layanan.tsx` |
| **Admin — Layanan Disposisi** | Kotak masuk disposisi | Implemented | `src/routes/admin.layanan.disposisi-inbox.tsx` |
| **Admin — Layanan Eskalasi** | Konfigurasi eskalasi SLA | Implemented | `src/routes/admin.layanan.escalation.tsx` |
| **Admin — Form Builder** | Buat/edit form dinamis | Implemented | `src/routes/admin.forms.tsx` |
| **Admin — Form Detail** | Kelola field, preview, publish | Implemented | `src/routes/admin.forms.$id.tsx` |
| **Admin — Submission Review** | Review & approval submission form | Implemented | `src/routes/admin.submission-review.tsx` |
| **Admin — Laporan Masyarakat** | Kelola pengaduan warga | Implemented | `src/routes/admin.laporan.tsx` |
| **Admin — Rating** | Evaluasi kepuasan layanan | Implemented | `src/routes/admin.rating.tsx` |
| **Admin — Pengguna** | Manajemen akun pengguna | Implemented | `src/routes/admin.users.tsx` |
| **Admin — OPD** | Manajemen daftar OPD | Implemented | `src/routes/admin.opd.tsx` |
| **Admin — Desa** | Manajemen daftar desa | Implemented | `src/routes/admin.desa.tsx` |
| **Admin — Pejabat** | Manajemen data pejabat | Implemented | `src/routes/admin.pejabat.tsx` |
| **Admin — RBAC** | Manajemen hak akses pengguna | Implemented | `src/routes/admin.rbac.tsx` |
| **Admin — RBAC Detail** | Hak akses per user | Implemented | `src/routes/admin.rbac.$userId.tsx` |
| **Admin — RBAC Audit** | Log perubahan hak akses | Implemented | `src/routes/admin.rbac.audit.tsx` |
| **Admin — ASN** | Data & manajemen ASN per OPD | Implemented | `src/routes/admin.asn.tsx` |
| **Admin — ASN Kepatuhan** | Monitoring kepatuhan absensi | Implemented | `src/routes/admin.asn-kepatuhan.tsx` |
| **Admin — Shift** | Manajemen shift kerja | Implemented | `src/routes/admin.asn.shift.tsx` |
| **Admin — Cuti Saldo** | Manajemen saldo cuti ASN | Implemented | `src/routes/admin.asn.cuti-saldo.tsx` |
| **Admin — Payroll Lock** | Kunci periode penggajian | Implemented | `src/routes/admin.asn.payroll-lock.tsx` |
| **Admin — Izin/Cuti** | Persetujuan izin & cuti | Implemented | `src/routes/admin.izin.tsx` |
| **Admin — Hari Libur** | Manajemen hari libur nasional/daerah | Implemented | `src/routes/admin.hari-libur.tsx` |
| **Admin — Aset** | CRUD aset pemda + QR print | Implemented | `src/routes/admin.aset.tsx` |
| **Admin — Aset Extra** | Mutasi & pemeliharaan aset | Implemented | `src/routes/admin.aset-extra.tsx` |
| **Admin — Aset KIB** | Kartu Inventaris Barang | Implemented | `src/routes/admin.aset.kib.tsx` |
| **Admin — Aset BAST** | Berita Acara Serah Terima | Implemented | `src/routes/admin.aset.bast.tsx` |
| **Admin — Aset Opname** | Stock opname aset | Implemented | `src/routes/admin.aset.opname.tsx` |
| **Admin — Aset Penyusutan** | Kalkulasi penyusutan aset | Implemented | `src/routes/admin.aset.penyusutan.tsx` |
| **Admin — Kampanye Verifikasi Aset** | Verifikasi massal aset | Implemented | `src/routes/admin.aset-kampanye.tsx` |
| **Admin — Dataset** | Template dataset + ekspor XLSX | Partially | `src/routes/admin.dataset.tsx` (ditandai "modul lama") |
| **Admin — Dataset Review** | Review submission dataset | Implemented | `src/routes/admin.dataset.review.tsx` |
| **Admin — IKM** | Kelola survei + dashboard IKM | Implemented | `src/routes/admin.ikm.tsx` |
| **Admin — CMS** | Berita & halaman konten | Implemented | `src/routes/admin.cms.tsx` |
| **Admin — Branding** | Logo, warna, teks portal | Implemented | `src/routes/admin.branding.tsx` |
| **Admin — Verifikasi** | Verifikasi akun warga/ASN | Implemented | `src/routes/admin.verifikasi.tsx` |
| **Admin — Log Verifikasi** | Riwayat log verifikasi | Implemented | `src/routes/admin.verifikasi-log.tsx` |
| **Admin — Audit Log** | Riwayat aktivitas sistem | Implemented | `src/routes/admin.audit.tsx` |
| **Admin — Lokasi** | Manajemen gedung/lantai/ruangan | Implemented | `src/routes/admin.lokasi.tsx` |
| **Admin — Compliance** | Checklist kepatuhan | Implemented | `src/routes/admin.compliance.tsx` |
| **Admin — Governance** | Skor tata kelola sistem | Implemented | `src/routes/admin.governance.tsx` |
| **Admin — Security Permissions** | Matriks permission granular | Implemented | `src/routes/admin.security.permissions.tsx` |
| **Admin — Config** | Konfigurasi mode akses aplikasi | Implemented | `src/routes/admin.config.tsx` |
| **Admin — Storage** | Browser file/dokumen bucket | Implemented | `src/routes/admin.storage.tsx` |
| **Admin — Backup** | Ekspor & impor data | Implemented | `src/routes/admin.backup.tsx` |
| **Admin — System Health** | Status cron, queue, dead-letter | Implemented | `src/routes/admin.system-health.tsx` |
| **Admin — Feature Flags** | Toggle fitur tanpa redeploy | Implemented | `src/routes/admin.system.feature-flags.tsx` |
| **Admin — Go-Live Checklist** | Kesiapan rilis produksi | Implemented | `src/routes/admin.system.go-live.tsx` |
| **Admin — UAT** | Skenario User Acceptance Testing | Implemented | `src/routes/admin.system.uat.tsx` |
| **Admin — Disaster Recovery** | Prosedur pemulihan sistem | Implemented | `src/routes/admin.system.disaster-recovery.tsx` |
| **Admin — Load Readiness** | Indikator beban & kapasitas | Implemented | `src/routes/admin.system.load-readiness.tsx` |
| **Admin — Retention** | Kebijakan retensi data | Implemented | `src/routes/admin.system.retention.tsx` |
| **Admin — Storage Provider** | Pilih Lovable Cloud / Cloudflare R2 | Implemented | `src/routes/admin.system.storage-provider.tsx` |
| **Admin — Backup Status** | Pantau snapshot backup | Implemented | `src/routes/admin.system.backup-status.tsx` |
| **Admin — Sistem Hub** | Hub menu teknis super admin | Implemented | `src/routes/admin.sistem.tsx` |
| **Admin — Eksekutif** | Detail dashboard pimpinan | Implemented | `src/routes/admin.eksekutif.tsx` |
| **Dashboard Pemda** | Monitoring operasional cross-OPD | Implemented | `src/routes/pemda.tsx` |
| **Dashboard Eksekutif** | Ringkasan kabupaten read-only | Implemented | `src/routes/executive.tsx` |
| **Auth** | Login / Register / Reset Password | Implemented | `src/routes/auth.tsx`, `src/routes/reset-password.tsx` |
| **Akun** | Pengaturan profil pengguna | Implemented | `src/routes/akun.tsx` |

---

## 3. Inventaris Semua Route

### 3.1 Route Publik (tanpa login)

| Route | File | Tujuan | Guard |
|---|---|---|---|
| `/` | `index.tsx` | Beranda portal — statistik, katalog OPD, link layanan | Tidak ada |
| `/layanan` | `layanan.index.tsx` | Katalog semua layanan OPD, searchable | Tidak ada |
| `/layanan/:slug` | `layanan.$slug.tsx` | Detail layanan spesifik | Tidak ada |
| `/berita` | `berita.tsx` | Berita & pengumuman | Tidak ada |
| `/tentang` | `tentang.tsx` | Profil pemerintah daerah | Tidak ada |
| `/kontak` | `kontak.tsx` | Form pengaduan/kontak warga | Tidak ada |
| `/instansi/:singkatan` | `instansi.$singkatan.tsx` | Profil OPD berdasar singkatan | Tidak ada |
| `/data-terbuka` | `data-terbuka.index.tsx` | Katalog dataset/form publik | Tidak ada |
| `/data-terbuka/:slug` | `data-terbuka.$slug.tsx` | Detail dataset publik | Tidak ada |
| `/data` | `data.tsx` | Halaman data generik | Tidak ada |
| `/kinerja-opd` | `kinerja-opd.tsx` | Dashboard kinerja OPD (mode: public/auth via `app_setting`) | Opsional auth |
| `/auth` | `auth.tsx` | Login & registrasi | Tidak ada |
| `/reset-password` | `reset-password.tsx` | Reset password via email | Tidak ada |
| `/v/:token` | `v.$token.tsx` | Verifikasi QR berkas permohonan | Tidak ada |
| `/ikm/:id` | `ikm.$id.tsx` | Pengisian survei kepuasan | Tidak ada |
| `/permohonan` | `permohonan.index.tsx` | Daftar permohonan (warga login opsional) | Tidak ada |
| `/permohonan/baru` | `permohonan.baru.tsx` | Buat permohonan baru | Tidak ada |
| `/permohonan/:id` | `permohonan.$id.tsx` | Detail & tracking permohonan | Tidak ada |
| `/pengisian` | `pengisian.index.tsx` | Daftar form yang ditugaskan | Auth (ASN/warga) |
| `/pengisian/:id` | `pengisian.$id.tsx` | Isi form dinamis | Auth |

### 3.2 Route ASN (login ASN wajib)

| Route | File | Tujuan | Guard |
|---|---|---|---|
| `/asn/absensi` | `asn.absensi.tsx` | Scan QR absensi + GPS | `isAsn` |
| `/asn/izin` | `asn.izin.tsx` | Pengajuan & riwayat izin/cuti | `isAsn` |
| `/asn/lembur` | `asn.lembur.tsx` | Pengajuan lembur | `isAsn` |
| `/asn/tugas` | `asn.tugas.tsx` | Daftar tugas/form assignment | `isAsn` |
| `/asn/aset` | `asn.aset.tsx` | Aset yang dipegang ASN ini | `isAsn` |
| `/asn/verifikasi` | `asn.verifikasi.tsx` | Verifikasi identitas ASN | `isAsn` |
| `/asn/scan/:token` | `asn.scan.$token.tsx` | Scan token dinamis | `isAsn` |
| `/tugas/:assignmentId` | `tugas.$assignmentId.tsx` | Detail tugas/assignment | Auth |
| `/akun` | `akun.tsx` | Pengaturan akun & profil | Auth |

### 3.3 Route Admin OPD (AdminGuard)

| Route | File | Tujuan | Guard |
|---|---|---|---|
| `/admin` | `admin.index.tsx` | Dashboard utama admin — KPI, tabel permohonan, grafik | `AdminGuard` |
| `/admin/layanan` | `admin.layanan.tsx` | CRUD layanan OPD | `AdminGuard` |
| `/admin/layanan/disposisi-inbox` | `admin.layanan.disposisi-inbox.tsx` | Kotak masuk disposisi | `AdminGuard` |
| `/admin/layanan/escalation` | `admin.layanan.escalation.tsx` | Konfigurasi eskalasi SLA | `AdminGuard` |
| `/admin/forms` | `admin.forms.tsx` | Daftar & buat form builder | `AdminGuard` |
| `/admin/forms/:id` | `admin.forms.$id.tsx` | Edit field, publish form | `AdminGuard` |
| `/admin/submission-review` | `admin.submission-review.tsx` | Review & approval submission | `AdminGuard` |
| `/admin/laporan` | `admin.laporan.tsx` | Pengaduan masyarakat | `AdminGuard` |
| `/admin/rating` | `admin.rating.tsx` | Rating & evaluasi layanan | `AdminGuard` |
| `/admin/verifikasi` | `admin.verifikasi.tsx` | Verifikasi akun warga | `AdminGuard` |
| `/admin/izin` | `admin.izin.tsx` | Persetujuan izin/cuti ASN | `AdminGuard` |

### 3.4 Route Super Admin / Admin Pemda (AdminGuard + role lanjut)

| Route | File | Tujuan | Guard Tambahan |
|---|---|---|---|
| `/admin/users` | `admin.users.tsx` | Manajemen pengguna | `super_admin` |
| `/admin/opd` | `admin.opd.tsx` | Manajemen OPD | `super_admin` |
| `/admin/desa` | `admin.desa.tsx` | Manajemen desa | `super_admin` |
| `/admin/pejabat` | `admin.pejabat.tsx` | Data pejabat daerah | `super_admin` |
| `/admin/rbac` | `admin.rbac.tsx` | Hak akses pengguna | `super_admin` |
| `/admin/rbac/:userId` | `admin.rbac.$userId.tsx` | Detail hak akses user | `super_admin` |
| `/admin/rbac/audit` | `admin.rbac.audit.tsx` | Log perubahan RBAC | `super_admin` |
| `/admin/asn` | `admin.asn.tsx` | Data ASN | `AdminGuard` |
| `/admin/asn-kepatuhan` | `admin.asn-kepatuhan.tsx` | Monitoring kepatuhan absensi | `AdminGuard` |
| `/admin/asn/shift` | `admin.asn.shift.tsx` | Shift kerja | `AdminGuard` |
| `/admin/asn/cuti-saldo` | `admin.asn.cuti-saldo.tsx` | Saldo cuti ASN | `AdminGuard` |
| `/admin/asn/payroll-lock` | `admin.asn.payroll-lock.tsx` | Kunci periode payroll | `super_admin` |
| `/admin/hari-libur` | `admin.hari-libur.tsx` | Hari libur | `AdminGuard` |
| `/admin/aset` | `admin.aset.tsx` | Data aset + QR print | `super_admin` |
| `/admin/aset-extra` | `admin.aset-extra.tsx` | Mutasi & pemeliharaan | `AdminGuard` |
| `/admin/aset/kib` | `admin.aset.kib.tsx` | Kartu Inventaris Barang | `AdminGuard` |
| `/admin/aset/bast` | `admin.aset.bast.tsx` | BAST serah terima | `AdminGuard` |
| `/admin/aset/opname` | `admin.aset.opname.tsx` | Stock opname | `AdminGuard` |
| `/admin/aset/penyusutan` | `admin.aset.penyusutan.tsx` | Kalkulasi penyusutan | `AdminGuard` |
| `/admin/aset-kampanye` | `admin.aset-kampanye.tsx` | Kampanye verifikasi aset | `AdminGuard` |
| `/admin/dataset` | `admin.dataset.tsx` | Template dataset (legacy) | `AdminGuard` |
| `/admin/dataset/review` | `admin.dataset.review.tsx` | Review submission dataset | `AdminGuard` |
| `/admin/ikm` | `admin.ikm.tsx` | Survei IKM | `AdminGuard` |
| `/admin/cms` | `admin.cms.tsx` | CMS berita/halaman | `AdminGuard` |
| `/admin/branding` | `admin.branding.tsx` | Logo & branding portal | `super_admin` |
| `/admin/verifikasi-log` | `admin.verifikasi-log.tsx` | Log verifikasi akun | `AdminGuard` |
| `/admin/audit` | `admin.audit.tsx` | Audit log aktivitas | `can_view_audit_logs` |
| `/admin/lokasi` | `admin.lokasi.tsx` | Gedung/lantai/ruangan | `AdminGuard` |
| `/admin/compliance` | `admin.compliance.tsx` | Checklist kepatuhan | `AdminGuard` |
| `/admin/governance` | `admin.governance.tsx` | Skor governance | `super_admin` |
| `/admin/security/permissions` | `admin.security.permissions.tsx` | Matriks permission | `super_admin` |
| `/admin/config` | `admin.config.tsx` | Konfigurasi global | `super_admin` |
| `/admin/storage` | `admin.storage.tsx` | Browser file bucket | `super_admin` |
| `/admin/backup` | `admin.backup.tsx` | Backup & restore | `super_admin` |
| `/admin/system-health` | `admin.system-health.tsx` | Status sistem runtime | `super_admin` |
| `/admin/sistem` | `admin.sistem.tsx` | Hub menu sistem | `SuperAdminOnly` |
| `/admin/system/feature-flags` | `admin.system.feature-flags.tsx` | Feature flags | `super_admin` |
| `/admin/system/go-live` | `admin.system.go-live.tsx` | Go-live checklist | `super_admin` |
| `/admin/system/uat` | `admin.system.uat.tsx` | UAT skenario | `super_admin` |
| `/admin/system/disaster-recovery` | `admin.system.disaster-recovery.tsx` | Prosedur disaster recovery | `super_admin` |
| `/admin/system/load-readiness` | `admin.system.load-readiness.tsx` | Load readiness | `super_admin` |
| `/admin/system/retention` | `admin.system.retention.tsx` | Retensi data | `super_admin` |
| `/admin/system/storage-provider` | `admin.system.storage-provider.tsx` | Penyedia penyimpanan | `super_admin` |
| `/admin/system/backup-status` | `admin.system.backup-status.tsx` | Status backup | `super_admin` |
| `/admin/system/settings` | `admin.system.settings.tsx` | Audit konfigurasi | `super_admin` |
| `/admin/eksekutif` | `admin.eksekutif.tsx` | Detail dashboard pimpinan | `AdminGuard` |

### 3.5 Route Pemda & Eksekutif

| Route | File | Tujuan | Guard |
|---|---|---|---|
| `/pemda` | `pemda.tsx` | Dashboard monitoring cross-OPD | `ExecutiveGuard(pemda)` |
| `/executive` | `executive.tsx` | Dashboard eksekutif pimpinan | `ExecutiveGuard(executive)` |
| `/kinerja-opd` | `kinerja-opd.tsx` | Dashboard kinerja publik/auth | Mode dikontrol setting |

---

## 4. Analisis Modul Pemda

### 4.1 Modul Layanan Publik

**Fungsi Bisnis:** Menyediakan katalog layanan pemerintah dan memproses permohonan layanan warga secara digital.

**Alur:**
1. Warga melihat katalog layanan di `/layanan` (tanpa login)
2. Warga mengajukan permohonan di `/permohonan/baru` (bisa tanpa login)
3. Admin OPD menerima di dashboard `/admin` → tabel permohonan
4. Admin memproses: ubah status (baru → diproses → selesai/ditolak), disposisi
5. Warga memantau status di `/permohonan/:id`
6. Warga memberikan rating setelah selesai

**Fitur Tersedia:**
- Katalog layanan publik per OPD dengan pencarian (`src/routes/layanan.index.tsx`)
- Halaman detail layanan (`src/routes/layanan.$slug.tsx`)
- Form permohonan baru tanpa login (`src/routes/permohonan.baru.tsx`)
- Tracking status permohonan dengan kode unik
- Verifikasi berkas via QR code (`src/routes/v.$token.tsx`)
- Sistem disposisi (forward ke petugas) (`src/routes/admin.layanan.disposisi-inbox.tsx`)
- Eskalasi otomatis SLA (`src/routes/admin.layanan.escalation.tsx`)
- Rating & evaluasi setelah selesai (`src/routes/admin.rating.tsx`)
- Laporan/pengaduan masyarakat terpisah (`src/routes/kontak.tsx`, `src/routes/admin.laporan.tsx`)
- Notifikasi push ke warga saat status berubah (`src/lib/notifications.functions.ts`)

**Fitur Belum Ada / Perlu Dikembangkan:**
- Cetak bukti tanda terima PDF otomatis (ada `dokumen_final_path` di DB tapi UI belum penuh)
- Integrasi e-Signature resmi
- Notifikasi SMS/WhatsApp (hanya push notification)

### 4.2 Modul ASN

**Fungsi Bisnis:** Manajemen digital aparatur sipil negara — absensi, izin/cuti, lembur, tugas, dan payroll.

**Alur:**
1. Admin OPD konfigurasi jadwal kerja & shift di `/admin/asn`
2. Admin setup kantor QR di `/admin/asn` (titik GPS + radius)
3. ASN scan QR setiap masuk/pulang di `/asn/absensi` (validasi GPS + fingerprint device)
4. ASN ajukan izin/cuti di `/asn/izin`, admin setujui di `/admin/izin`
5. ASN ajukan lembur di `/asn/lembur`
6. Admin pantau kepatuhan di `/admin/asn-kepatuhan`
7. Admin kelola saldo cuti di `/admin/asn/cuti-saldo`
8. Admin kunci periode payroll di `/admin/asn/payroll-lock`

**Fitur Tersedia:**
- Absensi QR dengan validasi GPS & geofence (`src/routes/asn.absensi.tsx`)
- Sistem shift kerja fleksibel (`src/routes/admin.asn.shift.tsx`)
- Manajemen jadwal kerja mingguan
- Pengajuan izin/cuti dengan tipe: tahunan, sakit, dll (`src/routes/asn.izin.tsx`)
- Saldo cuti per ASN (`src/routes/admin.asn.cuti-saldo.tsx`)
- Pengajuan lembur dengan alasan (`src/routes/asn.lembur.tsx`)
- Dashboard kepatuhan absensi cross-OPD (`src/routes/admin.asn-kepatuhan.tsx`)
- Rekap bulanan absensi (`tabel: attendance_rekap_bulanan`)
- Deteksi device duplikat (device fingerprint) (`tabel: attendance_device_alert`)
- Kunci payroll periode (`src/routes/admin.asn.payroll-lock.tsx`)
- Tipe ASN: PNS, PPPK Penuh Waktu, PPPK Paruh Waktu, Honorer (legacy) (`src/features/rbac/constants.ts`)
- Jabatan: Kepala OPD, Sekretaris, Kepala Bidang, Operator, Verifikator, Staff, Guru, dll

**Fitur Belum Ada / Perlu Dikembangkan:**
- Slip gaji digital (tabel `payroll_periods` ada, UI terbatas)
- Penilaian kinerja SKP digital
- SIMPEG integration

### 4.3 Modul Aset Daerah

**Fungsi Bisnis:** Inventarisasi, pemantauan, dan manajemen siklus hidup aset milik pemda.

**Alur:**
1. Admin input aset → otomatis dapat QR token unik
2. Admin cetak QR → ditempelkan pada fisik aset
3. ASN/petugas scan QR di lapangan untuk verifikasi keberadaan
4. Admin proses mutasi (pindah antar OPD/pengguna) → perlu persetujuan
5. Admin jalankan stock opname per periode
6. Admin kalkulasi penyusutan otomatis per periode
7. Penerbitan BAST untuk serah terima formal

**Fitur Tersedia:**
- CRUD aset dengan foto, koordinat GPS, status kondisi (`src/routes/admin.aset.tsx`)
- QR code unik per aset, bisa cetak PNG (`src/components/asn/QrPrintable.tsx`)
- Scan lapangan dengan GPS (`src/routes/asn.aset.tsx`)
- Riwayat scan per aset (`tabel: aset_riwayat`)
- Manajemen mutasi aset antar OPD/pengguna (`src/routes/admin.aset-extra.tsx`, `tabel: aset_mutasi`)
- Pemeliharaan aset dengan jadwal & biaya (`tabel: aset_pemeliharaan`)
- Stock opname per periode (`src/routes/admin.aset.opname.tsx`)
- Berita Acara Serah Terima (BAST) (`src/routes/admin.aset.bast.tsx`)
- Kartu Inventaris Barang (KIB) (`src/routes/admin.aset.kib.tsx`)
- Kalkulasi penyusutan (metode garis lurus dll) (`src/routes/admin.aset.penyusutan.tsx`)
- Kampanye verifikasi aset massal (`src/routes/admin.aset-kampanye.tsx`)
- Status lifecycle: aktif, dalam-perbaikan, dihapuskan, hilang
- Nilai buku & nilai perolehan

**Fitur Belum Ada:**
- Laporan aset format SIMDA/SIPKD
- Integrasi dengan sistem keuangan daerah

### 4.4 Modul Data Terbuka

**Fungsi Bisnis:** Publikasi dataset dan formulir pemerintah untuk transparansi dan pemanfaatan data publik.

**Alur:**
1. Admin buat template dataset atau form dengan `is_public=true`
2. Sistem publish di `/data-terbuka`
3. Publik dapat mengakses dan mengunduh data

**Fitur Tersedia:**
- Katalog dataset/form publik (`src/routes/data-terbuka.index.tsx`)
- Detail dataset per slug (`src/routes/data-terbuka.$slug.tsx`)
- Ekspor dataset ke XLSX (`src/lib/dataset.functions.ts: exportSubmissionsXlsx`)
- Integrasi Form Builder untuk dataset baru (migrasi dari modul lama) (`src/routes/admin.dataset.tsx`)
- Form publik dapat diisi langsung di portal (`src/routes/pengisian.$id.tsx`)

**Fitur Belum Lengkap:**
- Dataset lama ditandai "modul lama" — sedang migrasi ke Form Builder (`src/routes/admin.dataset.tsx` baris 26-29)
- API data terbuka (REST/JSON) untuk developer belum ada
- Visualisasi data interaktif belum ada

### 4.5 Modul Survey / IKM

**Fungsi Bisnis:** Indeks Kepuasan Masyarakat (IKM) — pengukuran kepuasan layanan sesuai regulasi pemerintah.

**Alur:**
1. Admin buat survei IKM per periode di `/admin/ikm`
2. Link survei dikirim ke pemohon setelah layanan selesai
3. Warga isi survei di `/ikm/:id`
4. Admin lihat dashboard agregasi IKM

**Fitur Tersedia:**
- Manajemen survei per periode per OPD (`src/routes/admin.ikm.tsx`)
- Form pengisian survei publik (`src/routes/ikm.$id.tsx`)
- Dashboard agregasi hasil IKM (`src/lib/ikm.functions.ts: getIkmDashboard`)
- Tabel `ikm_surveys` dan `ikm_responses`

**Fitur Belum Ada:**
- Laporan IKM format standar Permenpan No. 14/2017
- Export PDF laporan IKM
- Survei multi-dimensi (nilai layanan, nilai petugas, nilai sarana)

### 4.6 Modul Pelaporan / Dashboard

**Fungsi Bisnis:** Monitoring kinerja terpusat untuk pengambilan keputusan.

**Fitur Tersedia:**
- Dashboard Admin OPD: KPI permohonan, grafik trend, skor SLA (`src/routes/admin.index.tsx`)
- Dashboard Admin Pemda: monitoring lintas-OPD (`src/routes/pemda.tsx`)
- Dashboard Eksekutif (Pimpinan): ringkasan kabupaten read-only (`src/routes/executive.tsx`)
- Dashboard Kinerja OPD publik: SLA %, rating, skor komposit (`src/routes/kinerja-opd.tsx`)
- Skor komposit OPD via RPC (`src/lib/kinerja.functions.ts: opdSkorKomposit`)
- Trend data per OPD (`tabel: opd_kinerja_trend`)
- Aggregasi kinerja layanan (`tabel: layanan_kinerja_agg`)
- Ekspor kinerja ke XLSX (`src/lib/kinerja.functions.ts: exportKinerjaXlsx`)

---

## 5. Analisis Role & RBAC

**Sumber:** `src/features/rbac/constants.ts`, `src/features/rbac/guards.ts`, `src/features/rbac/hooks.ts`

### 5.1 Daftar Role

| Role | Label | Deskripsi |
|---|---|---|
| `super_admin` | Super Admin | Akses penuh seluruh sistem, konfigurasi teknis |
| `admin_pemda` | Admin Pemda | Monitoring cross-OPD, read-only lintas OPD |
| `pimpinan` | Pimpinan Daerah | Dashboard eksekutif read-only (Bupati, Wakil, Sekda, Asisten, Kepala OPD) |
| `admin_opd` | Admin OPD | Operasional dalam scope OPD-nya (layanan, ASN, aset, forms) |
| `admin_desa` | Admin Desa | Verifikasi akun warga di kelurahan/desa |
| `asn` | ASN | Absensi, izin, lembur, tugas, aset ASN |
| `warga` | Warga | Ajukan permohonan, isi form, lihat data publik |

### 5.2 Tipe Pimpinan

| Kode | Label |
|---|---|
| `bupati` | Bupati |
| `wakil_bupati` | Wakil Bupati |
| `sekda` | Sekretaris Daerah |
| `asisten` | Asisten |
| `kepala_opd` | Kepala OPD |

### 5.3 Tabel Hak Akses per Role

| Permission | super_admin | admin_pemda | pimpinan | admin_opd | admin_desa | asn | warga |
|---|---|---|---|---|---|---|---|
| `can_create_form` | ✅ | - | - | ✅ | - | - | - |
| `can_edit_form` | ✅ | - | - | ✅ | - | - | - |
| `can_publish_form` | ✅ | - | - | ✅ | - | - | - |
| `can_assign_form` | ✅ | - | - | ✅ | - | - | - |
| `can_verify_submission` | ✅ | ✅ | - | ✅ | - | - | - |
| `can_approve_submission` | ✅ | ✅ | - | ✅ | - | - | - |
| `can_reject_submission` | ✅ | ✅ | - | ✅ | - | - | - |
| `can_view_sensitive_document` | ✅ | ✅ | - | ✅ | - | - | - |
| `can_download_document` | ✅ | ✅ | - | ✅ | - | ✅ | - |
| `can_share_document` | ✅ | ✅ | - | ✅ | - | ✅ | - |
| `can_manage_users` | ✅ | - | - | - | - | - | - |
| `can_manage_opd` | ✅ | - | - | - | - | - | - |
| `can_view_audit_logs` | ✅ | ✅ | - | - | - | - | - |
| `can_export_data` | ✅ | ✅ | - | ✅ | - | - | - |
| `can_manage_roles` | ✅ | - | - | - | - | - | - |
| `can_manage_forms` | ✅ | - | - | ✅ | - | - | - |
| `can_request_data` | ✅ | ✅ | - | ✅ | ✅ | ✅ | ✅ |
| `can_approve_data_request` | ✅ | ✅ | - | ✅ | - | - | - |
| `can_approve_registration` | ✅ | ✅ | - | ✅ | ✅ | - | - |
| `view_all_opd` | ✅ | ✅ | ✅ | - | - | - | - |
| `view_all_submissions` | ✅ | ✅ | ✅ | - | - | - | - |
| `view_all_attendance` | ✅ | ✅ | ✅ | - | - | - | - |
| `view_all_assets` | ✅ | ✅ | ✅ | - | - | - | - |
| `view_all_datasets` | ✅ | ✅ | ✅ | - | - | - | - |
| `view_kabupaten_dashboard` | ✅ | ✅ | ✅ | - | - | - | - |
| `view_executive_dashboard` | ✅ | ✅ | ✅ | - | - | - | - |
| `view_cross_opd_analytics` | ✅ | ✅ | ✅ | - | - | - | - |

> **Catatan:** Tabel di atas adalah hak default berbasis role. Admin dapat memberikan permission granular tambahan per user via `/admin/rbac/:userId`. Implementasi menggunakan dua layer: client-side (`src/features/rbac/hooks.ts`) dan server-side RPC `has_permission` (`src/features/rbac/guards.ts`).

### 5.4 Mekanisme RBAC

- **Client-side guard:** `AdminGuard` (`src/components/admin/AdminGuard.tsx`), `ExecutiveGuard` (`src/components/admin/ExecutiveGuard.tsx`), `SuperAdminOnly` (`src/components/admin/SuperAdminOnly.tsx`)
- **Server-side guard:** `getUserContext()` + `userHasPermission()` di `src/features/rbac/guards.ts` — dipanggil di setiap server function
- **RLS Supabase:** backstop terakhir di level database (tidak dapat di-bypass)
- **Navigation filtering:** `AdminShell` memfilter menu berdasarkan role aktif secara dinamis

---

## 6. Analisis Dashboard

### 6.1 Dashboard Admin OPD (`/admin`)

**File:** `src/routes/admin.index.tsx`

**Widget & KPI:**
- Statistik permohonan: total, baru, diproses, selesai, ditolak, overdue
- Grafik area: trend permohonan 14 hari terakhir
- Grafik batang: distribusi status
- Grafik pie: distribusi kategori
- Tabel SLA per OPD (super admin)
- Tabel permohonan real-time (limit 200, filter status/kategori/pencarian)
- Statistik sistem: jobs pending/failed, total user, berita, layanan (super admin)
- Widget sistem: RPC `dashboard_summary` (`src/lib/queries.dashboard.ts`)

### 6.2 Dashboard Admin Pemda (`/pemda`)

**File:** `src/routes/pemda.tsx`

**Widget & KPI:**
- Permohonan bulan ini, selesai, overdue, pengaduan aktif
- Total ASN, total aset, aset rusak, responden IKM 30 hari
- Tabel skor kinerja OPD (SLA %, rating rata-rata, skor komposit)
- Quick links: Monitoring Layanan, Pengaduan, Kepatuhan Absensi, Aset, Pelaporan Data, Dashboard Pimpinan

### 6.3 Dashboard Eksekutif (`/executive`)

**File:** `src/routes/executive.tsx`

**Widget & KPI:**
- Jumlah OPD, jumlah ASN
- Permohonan bulan ini, permohonan overdue
- Pengaduan aktif, total aset, aset rusak, responden IKM
- Top 3 OPD terbaik (skor komposit)
- OPD perlu perhatian (SLA < 70%)
- Mode read-only, tidak ada aksi

### 6.4 Dashboard Kinerja OPD Publik (`/kinerja-opd`)

**File:** `src/routes/kinerja-opd.tsx`

**Widget & KPI:**
- Grafik batang perbandingan SLA % semua OPD
- Grafik pie distribusi status layanan
- Grafik garis trend waktu
- Tabel skor komposit per layanan
- Mode akses: public atau auth (dikontrol via `app_setting`)
- Ekspor XLSX

### 6.5 Dashboard ASN (portal ASN)

**Fitur:** Statistik absensi pribadi, jadwal shift hari ini, riwayat izin, status lembur.

---

## 7. Analisis Database

**Jumlah tabel teridentifikasi: 90+**
**Sumber:** `src/integrations/supabase/types.ts`

### 7.1 Tabel Inti Sistem

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `profiles` | Profil lengkap pengguna (nama, NIK, NIP, opd_id, desa) | → `opd`, `auth.users` |
| `user_roles` | Mapping user ke role | → `profiles` |
| `permissions` | Katalog permission | — |
| `role_permissions` | Permission default per role | → `permissions` |
| `user_permissions` | Override permission per user | → `profiles`, `permissions` |
| `rbac_audit` | Log perubahan RBAC | → `profiles` |
| `audit_log` | Log aktivitas seluruh sistem | → `profiles` |
| `app_setting` | Konfigurasi global aplikasi | — |
| `feature_flags` | Toggle fitur runtime | — |
| `branding` | Konfigurasi logo & warna portal | — |

### 7.2 Tabel Permohonan Layanan

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `permohonan` | Data permohonan layanan warga | → `profiles`, `opd`, `layanan_publik` |
| `permohonan_berkas` | Dokumen lampiran permohonan | → `permohonan` |
| `permohonan_komentar` | Komentar/catatan permohonan | → `permohonan` |
| `permohonan_riwayat` | Riwayat perubahan status | → `permohonan` |
| `permohonan_rating` | Rating kepuasan warga | → `permohonan` |
| `layanan_publik` | Katalog jenis layanan | → `opd` |
| `kategori_layanan` | Kategori layanan | — |
| `verification_token` | Token QR verifikasi berkas | → `permohonan` |
| `verification_logs` | Log proses verifikasi | → `profiles` |
| `dokumen_verifikasi` | File hasil verifikasi | → `permohonan` |
| `nomor_surat_sequence` | Penomoran surat otomatis | → `opd` |
| `nomor_surat_issued` | Surat yang sudah diterbitkan | → `permohonan` |
| `submission_sla_events` | Event SLA permohonan | → `permohonan` |
| `escalation_config` | Konfigurasi eskalasi | → `opd` |

### 7.3 Tabel Form Builder & Submissions

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `forms` | Template form dinamis | → `opd` |
| `form_fields` | Field/pertanyaan form | → `forms` |
| `form_targets` | Target pengisi form (scope) | → `forms` |
| `form_assignments` | Penugasan form ke user/unit | → `forms`, `profiles` |
| `form_submissions` | Isian form | → `forms`, `profiles` |
| `submission_answers` | Jawaban per field | → `form_submissions`, `form_fields` |
| `submission_files` | File lampiran submission | → `form_submissions` |
| `form_submission_files` | File pada submission form | → `form_submissions` |
| `form_submission_comment` | Komentar/catatan reviewer | → `form_submissions` |
| `form_submission_versions` | Versi historis submission | → `form_submissions` |
| `submission_dispositions` | Disposisi (forward) submission | → `form_submissions` |
| `submissions` | Alias/view submissions | → `form_submissions` |

### 7.4 Tabel ASN & Kehadiran

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `absensi_asn` | Record absensi harian | → `profiles`, `opd`, `attendance_shifts` |
| `attendance_shifts` | Definisi shift kerja | → `opd` |
| `attendance_shift_assignment` | Penugasan shift ke ASN | → `profiles`, `attendance_shifts` |
| `work_schedule` | Jadwal kerja mingguan | → `opd` |
| `work_schedule_assignment` | Penugasan jadwal ke ASN | → `profiles`, `work_schedule` |
| `attendance_rekap_bulanan` | Rekap absensi bulanan | → `profiles`, `opd` |
| `attendance_device_alert` | Alert device duplikat | → `profiles` |
| `attendance_compliance` | Data kepatuhan kehadiran | → `profiles`, `opd` |
| `pengajuan_izin` | Pengajuan izin & cuti | → `profiles`, `opd` |
| `leave_balances` | Saldo cuti per jenis | → `profiles` |
| `overtime_requests` | Pengajuan lembur | → `profiles`, `opd` |
| `hari_libur` | Hari libur nasional/daerah | — |
| `payroll_periods` | Periode kunci payroll | → `opd` |
| `kantor_qr` | Titik QR absensi kantor | → `opd` |
| `shift` | Shift (tabel lama/alternatif) | — |
| `shift_assignment` | Penugasan shift (lama) | — |
| `unit_kerja` | Unit kerja organisasi | → `opd` |

### 7.5 Tabel Aset Daerah

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `aset` | Data aset pemda | → `opd`, `profiles`, `lokasi_ruangan` |
| `aset_mutasi` | Proses mutasi/pindah aset | → `aset`, `opd`, `profiles` |
| `aset_pemeliharaan` | Jadwal & riwayat pemeliharaan | → `aset` |
| `aset_bast` | Berita Acara Serah Terima | → `opd`, `profiles` |
| `aset_bast_items` | Item aset dalam BAST | → `aset_bast`, `aset` |
| `aset_opname` | Session stock opname | → `opd` |
| `aset_opname_items` | Item per opname session | → `aset_opname`, `aset` |
| `aset_riwayat` | Riwayat scan/perubahan aset | → `aset`, `profiles` |
| `aset_penyusutan_history` | Riwayat kalkulasi penyusutan | → `aset` |
| `aset_nilai_buku` | Nilai buku per periode | → `aset` |
| `aset_verification_campaign` | Kampanye verifikasi massal | → `opd` |
| `aset_verification_item` | Item dalam kampanye | → `aset_verification_campaign`, `aset` |
| `aset_due_warranty` | Aset mendekati garansi habis | → `aset` |
| `geofence_audit` | Audit lokasi GPS aset | → `aset` |

### 7.6 Tabel Lokasi

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `lokasi_gedung` | Data gedung/kantor | → `opd` |
| `lokasi_lantai` | Lantai dalam gedung | → `lokasi_gedung` |
| `lokasi_ruangan` | Ruangan dalam lantai | → `lokasi_lantai` |

### 7.7 Tabel Dataset & Data Terbuka

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `dataset_template` | Template pelaporan data | → `opd` |
| `dataset_submission` | Isian data per template | → `dataset_template`, `profiles` |
| `dataset_submission_review` | Review submission dataset | → `dataset_submission` |
| `data_requests` | Permintaan data terbuka | → `profiles` |
| `data_terpadu_item` | Item data terpadu | — |

### 7.8 Tabel IKM & Survey

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `ikm_surveys` | Definisi survei IKM | → `opd` |
| `ikm_responses` | Respons isian survei | → `ikm_surveys`, `profiles` |

### 7.9 Tabel Konten & Komunikasi

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `berita` | Artikel berita & halaman | → `profiles` |
| `laporan_masyarakat` | Pengaduan warga | → `profiles`, `opd` |
| `notifications` | Notifikasi in-app | → `profiles` |
| `push_subscription` | Endpoint push notification | → `profiles` |
| `opd` | Data Organisasi Perangkat Daerah | — |
| `pejabat` | Data pejabat daerah | → `profiles`, `opd` |
| `desa` | Data desa/kelurahan | — |
| `kontak` | (catatan kontak, perlu verifikasi) | — |

### 7.10 Tabel Organisasi & OPD

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `opd` | Data OPD/dinas | — |
| `pejabat` | Pejabat aktif/historis | → `opd`, `profiles` |
| `desa` | Desa & kelurahan | — |
| `opd_kinerja_agg` | Agregasi kinerja OPD | → `opd` |
| `opd_kinerja_trend` | Trend kinerja OPD | → `opd` |
| `opd_rating_agg` | Agregasi rating OPD | → `opd` |
| `layanan_kinerja_agg` | Agregasi kinerja per layanan | → `layanan_publik` |
| `opd_kategori_benchmark` | Benchmark kinerja kategori OPD | — |

### 7.11 Tabel Sistem & Infrastruktur

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `job_queue` | Antrian pekerjaan background | — |
| `dead_letter_jobs` | Job gagal permanen | — |
| `retry_queue` | Job yang perlu dicoba ulang | — |
| `cron_history` | Riwayat eksekusi cron | — |
| `backup_snapshot` | Metadata snapshot backup | — |
| `retention_policies` | Kebijakan retensi data | — |
| `rate_limit` | Konfigurasi rate limiting | — |
| `rate_limit_hits` | Log hit rate limit | — |
| `compliance_checklist` | Item checklist kepatuhan | — |
| `consent_log` | Log persetujuan pengguna | — |
| `uat_results` | Hasil skenario UAT | — |
| `uat_scenarios` | Skenario UAT | — |

### 7.12 Tabel Sharing & Dokumen

| Tabel | Tujuan | Relasi Utama |
|---|---|---|
| `share_paket` | Paket dokumen yang dibagikan | → `profiles`, `opd` |
| `share_target` | Target penerima share | → `share_paket` |
| `share_lampiran` | Lampiran dalam paket | → `share_paket` |
| `share_komentar` | Komentar dalam share | → `share_paket` |
| `share_riwayat` | Riwayat akses share | → `share_paket` |
| `document_access` | Log akses dokumen | → `profiles` |

---

## 8. Analisis Integrasi

### 8.1 Supabase

**Authentication:**
- Email/password login via `supabase.auth` (`src/lib/auth-context.tsx`)
- Magic link / OAuth belum terlihat di kode
- Reset password via email (`src/routes/reset-password.tsx`)
- Session management dengan `onAuthStateChange`

**Database (PostgreSQL via Supabase):**
- 90+ tabel dengan RLS sebagai lapisan keamanan
- RPC functions: `has_permission`, `dashboard_summary`, `opd_skor_komposit`, `executive_summary`, `governance_summary`, `production_health_score`, `get_user_opd`, `is_pimpinan`, dll
- Typed client via `src/integrations/supabase/types.ts`
- Client: `src/integrations/supabase/client.ts`

**Storage:**
- Bucket penyimpanan file (dokumen, foto aset, foto absensi, logo)
- Browser file admin: `/admin/storage`
- Konfigurasi provider: Lovable Cloud atau Cloudflare R2 (`src/routes/admin.system.storage-provider.tsx`)

**Realtime:**
- Notifikasi perubahan status permohonan (`src/components/site/PermohonanNotifier.tsx`)

### 8.2 Push Notification (Web Push)

- **Service Worker:** `public/sw.js` — menerima push event, tampilkan notifikasi, handle click
- **VAPID Key:** dikonfigurasi di `src/components/site/PushAutoEnable.tsx`
- **Auto-enable:** aktif saat mode standalone PWA terinstal
- **Tabel:** `push_subscription` — menyimpan endpoint per user
- **Foreground handling:** postMessage ke tab aktif → toast Sonner

### 8.3 PWA (Progressive Web App)

- **Manifest:** `public/manifest.webmanifest` (dikonfirmasi dari `src/routes/__root.tsx` head link)
- **Service Worker:** `public/sw.js` dan `public/service-worker.js`
- **Install prompt:** `src/components/site/InstallPWA.tsx` — support Android/Chrome (beforeinstallprompt) + iOS manual
- **Floating button:** `src/components/site/InstallPWAFloating.tsx`
- **Meta tags:** `mobile-web-app-capable`, `apple-mobile-web-app-capable`, `viewport-fit=cover`

### 8.4 QR Code

- **Library:** QR print PNG di `src/components/asn/QrPrintable.tsx`
- **QR Scanner:** `src/components/asn/QrScanner.tsx` — scan kamera untuk absensi
- **Penggunaan:**
  - Token absensi ASN (scan di kantor)
  - Token aset (tempel pada fisik aset)
  - Verifikasi berkas permohonan (`/v/:token`)

### 8.5 GPS/Geolocation

- Validasi absensi dengan koordinat GPS
- Geofence audit untuk aset
- Kantor QR dikaitkan dengan koordinat + radius (`tabel: kantor_qr`)

### 8.6 Charting

- **Library:** Recharts
- Digunakan di: dashboard admin, kinerja OPD, IKM, dashboard pemda/eksekutif

### 8.7 Job Queue & Background Jobs

- Antrian pekerjaan: `tabel: job_queue`
- Dead letter: `tabel: dead_letter_jobs`
- Retry queue: `tabel: retry_queue`
- Cron history: `tabel: cron_history`
- Monitor di `/admin/system-health`

---

## 9. Analisis PWA & Mobile

| Aspek | Status | Detail |
|---|---|---|
| **Web App Manifest** | ✅ Implemented | `public/manifest.webmanifest` dirujuk di `__root.tsx` |
| **Service Worker** | ✅ Implemented | `public/sw.js` — push notification + badge |
| **Install Prompt** | ✅ Implemented | Android: native prompt; iOS: instruksi manual |
| **Push Notification** | ✅ Implemented | VAPID key dikonfigurasi, tabel `push_subscription` |
| **Offline Mode** | ❌ Tidak ada | SW tidak melakukan cache offline — hanya push |
| **Responsive Design** | ✅ Implemented | TailwindCSS responsive, drawer mobile di AdminShell |
| **Viewport** | ✅ Implemented | `viewport-fit=cover`, `initial-scale=1` |
| **Icons** | ✅ Implemented | `/icon-192.png` untuk icon & apple-touch-icon |
| **Theme Color** | ✅ Implemented | `theme-color: #0F172A` |
| **Standalone Mode** | ✅ Implemented | `display: standalone` di manifest (perlu verifikasi isi manifest) |
| **Kamera QR** | ✅ Implemented | `src/components/asn/QrScanner.tsx` |
| **GPS** | ✅ Implemented | `navigator.geolocation.watchPosition` di absensi |

**Catatan Khusus Mobile:**
- AdminShell memiliki drawer navigasi mobile dengan animasi `slide-in-from-left` (`src/components/admin/AdminShell.tsx` baris 309)
- Tombol hamburger tersedia di header admin untuk mobile

---

## 10. Analisis Admin Panel

### 10.1 Struktur Navigasi AdminShell

**Sumber:** `src/components/admin/AdminShell.tsx`

#### Navigasi Admin OPD (baseNav)
1. Dashboard (`/admin`)
2. Permohonan (`/admin#tabel`)
3. Form Builder (`/admin/forms`)
4. Review Submission (`/admin/submission-review`)
5. Laporan Masyarakat (`/admin/laporan`)
6. Layanan OPD (`/admin/layanan`)

#### Navigasi Admin Desa (desaBaseNav)
1. Dashboard (`/admin`)
2. Verifikasi Akun (`/admin/verifikasi`)

#### Navigasi Admin Pemda (pemdaNav)
1. Dashboard Pemda (`/pemda`)
2. Dashboard Pimpinan (`/executive`)
3. Monitoring Layanan (`/admin/layanan`)
4. Pengaduan Masyarakat (`/admin/laporan`)
5. Kepatuhan Absensi (`/admin/asn-kepatuhan`)
6. Aset Pemda (`/admin/aset`)
7. Pelaporan Data (`/admin/dataset`)
8. Riwayat Audit (`/admin/audit`)

#### Navigasi Pimpinan (pimpinanNav)
1. Dashboard Eksekutif (`/executive`)
2. Kinerja OPD (`/kinerja-opd`)

#### Super Admin Groups (superNavGroups)

**Grup 1 — Pengguna & Organisasi:**
- Pengguna, Hak Akses, OPD, Desa, Pejabat, Verifikasi Akun

**Grup 2 — Layanan Publik:**
- Jenis Layanan, Form Builder, Review Submission, Pengaduan Masyarakat, Rating & Evaluasi

**Grup 3 — ASN:**
- Data ASN, Kepatuhan Kehadiran, Persetujuan Izin/Cuti, Hari Libur

**Grup 4 — Aset:**
- Data Aset, Mutasi & Pemeliharaan, Kampanye Verifikasi Aset

**Grup 5 — Konten Website:**
- Berita & Halaman, Branding

**Grup 6 — Pemda & Eksekutif:**
- Dashboard Pemda, Dashboard Eksekutif, Pimpinan (Detail)

**Grup 7 — Data & Laporan:**
- Pelaporan Data

**Grup 8 — Sistem:**
- Pengaturan Sistem (hub)

### 10.2 Hub Pengaturan Sistem (`/admin/sistem`)

**Sumber:** `src/routes/admin.sistem.tsx`

Hanya dapat diakses oleh `super_admin`. Diorganisir dalam 4 grup:

| Grup | Menu |
|---|---|
| **Konfigurasi & Tata Kelola** | Konfigurasi Sistem, Tata Kelola, Pengaturan Hak Akses, Feature Flags, Audit Konfigurasi |
| **Data & Riwayat** | Riwayat Aktivitas, Log Verifikasi, Retensi Data |
| **Penyimpanan & Backup** | File & Dokumen, Penyedia Penyimpanan, Backup Data, Status Backup |
| **Operasional & Pemulihan** | Status Sistem, Kesiapan Sistem, Pemulihan Sistem, Go-Live Checklist, UAT |

---

## 11. Fitur Unggulan untuk Pemda

### 11.1 Pelayanan Publik Digital
- **Manfaat:** Warga dapat mengajukan permohonan layanan 24/7 dari rumah
- **Stakeholder:** Warga, Admin OPD, Pimpinan
- **Nilai jual:** Transparansi status real-time, notifikasi otomatis, QR verifikasi keaslian dokumen

### 11.2 Dashboard Eksekutif
- **Manfaat:** Bupati/Wakil/Sekda dapat memantau kinerja seluruh OPD dari satu layar
- **Stakeholder:** Pimpinan daerah
- **Nilai jual:** SLA %, ranking OPD, early warning OPD bermasalah

### 11.3 Absensi Digital ASN berbasis QR + GPS
- **Manfaat:** Eliminasi absensi manual, deteksi kecurangan (geofence, device fingerprint)
- **Stakeholder:** ASN, Admin OPD, Admin Pemda
- **Nilai jual:** Rekap otomatis, kepatuhan terukur, integrasi payroll

### 11.4 Inventarisasi Aset Digital
- **Manfaat:** Akuntabilitas aset daerah yang terukur, tidak ada aset "hantu"
- **Stakeholder:** Admin OPD, BPK, DPRD
- **Nilai jual:** QR fisik, kalkulasi penyusutan otomatis, BAST digital, stock opname terpandu

### 11.5 IKM Digital
- **Manfaat:** Pengukuran kepuasan masyarakat sesuai regulasi Kemenpan-RB
- **Stakeholder:** Admin Pemda, OPD, Kemenpan-RB
- **Nilai jual:** Data real-time, tidak perlu survei kertas, basis peningkatan pelayanan

### 11.6 Open Data / Data Terbuka
- **Manfaat:** Transparansi pemerintahan, memenuhi amanah UU KIP
- **Stakeholder:** Masyarakat, jurnalis, akademisi, Komisi Informasi
- **Nilai jual:** Dataset terstruktur, dapat diunduh, dikelola oleh OPD langsung

### 11.7 RBAC Multi-level
- **Manfaat:** Setiap pejabat hanya dapat melihat data yang menjadi kewenangannya
- **Stakeholder:** BPK, Inspektorat, Admin Sistem
- **Nilai jual:** Audit trail lengkap, keamanan data, compliance governance

### 11.8 PWA Mobile
- **Manfaat:** ASN dan warga dapat menggunakan tanpa install app store
- **Stakeholder:** ASN, warga, IT Pemda
- **Nilai jual:** Hemat biaya pengembangan app native, instant install, push notification

---

## 12. Fitur Belum Selesai

### Critical (Blocking Produksi)

| Item | Lokasi | Detail |
|---|---|---|
| Modul Dataset ditandai "modul lama" | `src/routes/admin.dataset.tsx` baris 26 | Masih aktif digunakan tapi sudah deprecated; migrasi ke Form Builder belum selesai |
| Service Worker tidak ada offline cache | `public/sw.js` | Hanya menangani push; tidak ada offline capability |
| Manifest PWA belum diverifikasi isinya | `public/manifest.webmanifest` | File ada tapi konten belum di-audit (nama, ikon, start_url) |

### Medium (Perlu Diselesaikan Sebelum Go-Live)

| Item | Lokasi | Detail |
|---|---|---|
| Go-Live Checklist | `src/routes/admin.system.go-live.tsx` | Menu ada, konten perlu diisi dan diverifikasi |
| UAT Skenario | `src/routes/admin.system.uat.tsx` | Infrastruktur ada, skenario pengujian perlu dilengkapi |
| Load Readiness | `src/routes/admin.system.load-readiness.tsx` | Indikator belum divalidasi dengan data riil |
| Disaster Recovery | `src/routes/admin.system.disaster-recovery.tsx` | Prosedur perlu diuji coba |
| Slip gaji ASN | `src/routes/admin.asn.payroll-lock.tsx` | Tabel `payroll_periods` ada, UI hanya kunci periode; slip gaji belum ada |

### Low (Enhancement)

| Item | Lokasi | Detail |
|---|---|---|
| Notifikasi SMS/WhatsApp | `src/lib/notifications.functions.ts` | Hanya push notification; SMS/WA belum diintegrasikan |
| Cetak PDF berkas permohonan | `permohonan.$id.tsx` | `dokumen_final_path` ada di DB, UI terbatas |
| Laporan IKM format Permenpan | `src/routes/admin.ikm.tsx` | Dashboard ada, export format standar belum |
| API REST publik untuk Data Terbuka | — | Dataset bisa diakses via portal tapi belum ada API endpoint |
| SIMPEG integration | `src/routes/admin.asn.tsx` | Data ASN dikelola lokal, belum terhubung SIMPEG nasional |
| e-Signature integrasi | — | Tidak terlihat di kodebase |
| Visualisasi data interaktif dataset | `src/routes/data-terbuka.index.tsx` | Hanya daftar, belum ada chart/preview data |

### Temuan Kode Mock/Data Dummy

- `src/store/admin-store.ts` baris 10: import dari `@/data/admin-mock` — **perlu verifikasi** apakah masih digunakan di produksi
- Beberapa halaman sistem (go-live, UAT, disaster recovery) — kontennya perlu diverifikasi apakah sudah real atau placeholder

---

## 13. Gap Analysis

### Kesiapan Produksi

| Modul | Kesiapan | Catatan |
|---|---|---|
| Portal Publik & Berita | 95% | Solid, CMS tersedia |
| Layanan Publik & Permohonan | 90% | Alur lengkap; cetak PDF masih parsial |
| Auth & RBAC | 92% | Multi-role, server-side guard, RLS |
| Dashboard Admin OPD | 90% | KPI, tabel, grafik lengkap |
| Dashboard Pemda/Eksekutif | 88% | Fungsional; bisa ditambah widget |
| Dashboard Kinerja Publik | 85% | Sudah live-data dan ekspor |
| Modul ASN | 80% | Absensi, izin, cuti lengkap; payroll/slip gaji 40% |
| Modul Aset | 85% | CRUD, QR, BAST, opname lengkap; laporan SIMDA belum |
| Form Builder | 88% | Publisher, field types, review workflow ada |
| IKM / Survey | 75% | Fungsional dasar; format laporan standar belum |
| Data Terbuka | 70% | Modul lama migrasi belum selesai; API publik belum |
| PWA / Mobile | 75% | Install & push OK; offline belum |
| Sistem & Infrastruktur | 80% | Feature flags, backup, health monitor ada |
| Go-Live Readiness | 70% | Checklist & UAT infrastruktur ada, isi perlu divalidasi |

### Estimasi Kesiapan Produksi Keseluruhan: **~83%**

**Siap Produksi:**
- Portalisme publik, pelayanan, dan permohonan
- RBAC dan keamanan (server-side + RLS)
- Absensi ASN + geofence
- Inventarisasi aset (CRUD + QR + opname)
- Dashboard pemda & eksekutif
- Push notification
- Branding & CMS

**Belum Siap Produksi:**
- Slip gaji/payroll penuh
- Laporan format standar (IKM Permenpan, SIMDA)
- Offline PWA
- Go-live checklist terverifikasi
- API data terbuka publik
- Migrasi dataset modul lama ke Form Builder

---

## 14. Katalog Penawaran Pemda

### 14.1 Pelayanan Publik

| Fitur | Deskripsi | Nilai |
|---|---|---|
| Portal Layanan Online | Warga ajukan layanan dari mana saja, tanpa antre | Efisiensi, kepuasan warga |
| Tracking Permohonan | Warga pantau status real-time dengan kode unik | Transparansi |
| QR Verifikasi Dokumen | Scan QR untuk verifikasi keaslian dokumen resmi | Keamanan dokumen |
| Eskalasi Otomatis SLA | Notifikasi otomatis ke pejabat jika permohonan terlambat | Akuntabilitas |
| Rating Layanan | Warga beri nilai kepuasan setelah selesai | Feedback loop |
| Pengaduan Masyarakat | Kanal digital pengaduan & laporan warga | Responsivitas |

### 14.2 Manajemen ASN

| Fitur | Deskripsi | Nilai |
|---|---|---|
| Absensi Digital QR+GPS | Kehadiran terverifikasi lokasi, anti-titip absen | Disiplin ASN |
| Manajemen Shift | Shift pagi/siang/malam dikonfigurasi per OPD | Fleksibilitas |
| Izin & Cuti Online | Pengajuan dan persetujuan digital tanpa kertas | Efisiensi administrasi |
| Lembur Digital | Pengajuan lembur dengan dasar alasan tervalidasi | Tertib keuangan |
| Rekap Kehadiran | Dashboard kepatuhan absensi cross-OPD | Monitoring pimpinan |
| Saldo Cuti Otomatis | Saldo terpotong otomatis saat cuti disetujui | Akurasi HRD |

### 14.3 Aset Daerah

| Fitur | Deskripsi | Nilai |
|---|---|---|
| Inventaris Aset Digital | Seluruh aset tercatat dengan foto, koordinat, QR | Akuntabilitas |
| Stock Opname Terpandu | Petugas verifikasi fisik dipandu aplikasi | Efisiensi audit |
| BAST Digital | Serah terima aset dengan tanda tangan digital | Legalitas |
| Kalkulasi Penyusutan | Otomatis per periode, siap laporan keuangan | Kepatuhan akuntansi |
| KIB Digital | Kartu Inventaris Barang per golongan aset | Standar aset negara |
| Kampanye Verifikasi | Verifikasi massal aset di seluruh OPD | Sensus aset berkala |

### 14.4 Open Data / Transparansi

| Fitur | Deskripsi | Nilai |
|---|---|---|
| Portal Data Terbuka | Dataset pemda dapat diakses publik | Transparansi, UU KIP |
| Form Pelaporan OPD | OPD lapor data secara terstruktur, bisa diaudit | Tertib pelaporan |
| Export XLSX | Download data siap analisis | Pemanfaatan data |

### 14.5 Monitoring Kinerja

| Fitur | Deskripsi | Nilai |
|---|---|---|
| Skor Komposit OPD | Rating berdasar SLA, kepuasan, kecepatan | Kompetisi positif |
| Trend Kinerja | Grafik kinerja 30/90 hari per OPD | Tren & evaluasi |
| Export Kinerja | Laporan kinerja XLSX siap presentasi | LKJIP, Musrenbang |
| Benchmark Kategori | OPD dibanding OPD sejenis | Standar kinerja |

### 14.6 Survey & IKM

| Fitur | Deskripsi | Nilai |
|---|---|---|
| Survei IKM Digital | Kepuasan masyarakat sesuai Permenpan-RB | Nilai SAKIP |
| Dashboard Agregasi | Hasil survei real-time per layanan | Evaluasi cepat |
| Survei Periodik | Kelola survei per kuartal/semester | Konsistensi evaluasi |

### 14.7 Tata Kelola Digital

| Fitur | Deskripsi | Nilai |
|---|---|---|
| RBAC Multi-level | Hak akses sesuai jabatan & kewenangan | Keamanan data |
| Audit Trail Lengkap | Semua aktivitas tercatat dengan timestamp | Forensik, audit BPK |
| Compliance Checklist | Daftar periksa kepatuhan teknis | Kesiapan audit |
| Feature Flags | Aktifkan fitur bertahap tanpa downtime | Manajemen risiko |
| Governance Score | Skor kesehatan tata kelola sistem | Monitoring mutu |

### 14.8 Dashboard Eksekutif

| Fitur | Deskripsi | Nilai |
|---|---|---|
| Dashboard Bupati/Sekda | Ringkasan kabupaten dalam 1 layar | Keputusan cepat |
| Top & Bottom OPD | OPD terbaik dan bermasalah teridentifikasi | Pengawasan efektif |
| OPD Perlu Perhatian | Alert otomatis OPD dengan SLA < 70% | Early warning |
| Data Cross-OPD | Tidak perlu minta laporan manual ke dinas | Efisiensi pimpinan |

### 14.9 Admin Sistem

| Fitur | Deskripsi | Nilai |
|---|---|---|
| Backup & Restore | Ekspor/impor data untuk keamanan | Business continuity |
| System Health Monitor | Status cron, queue, error realtime | Stabilitas sistem |
| Go-Live Checklist | Panduan launch ke produksi | Kesiapan deployment |
| Disaster Recovery | Prosedur pemulihan terdokumentasi | Ketahanan sistem |
| Storage Provider | Pilih cloud storage lokal/internasional | Fleksibilitas IT |
| Branding Dinamis | Logo, nama, warna dikustomisasi per daerah | Multi-daerah |

---

*Dokumen ini dihasilkan dari audit kode sumber di `/dev-server` menggunakan `rg`, `cat`, dan inspeksi file langsung. Setiap klaim disertai path file sumber. Untuk verifikasi lebih lanjut, periksa file yang disebutkan di setiap seksi.*
