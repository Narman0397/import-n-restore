CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE public.app_role AS ENUM ('warga','admin_opd','super_admin','admin_desa','asn');
CREATE TYPE public.job_status AS ENUM ('pending','running','success','failed','dead');
CREATE TYPE public.status_permohonan AS ENUM ('baru','diproses','selesai','ditolak');

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    nama_lengkap text DEFAULT ''::text NOT NULL,
    nik text, no_hp text, opd_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    desa text, verified_at timestamp with time zone, verified_by uuid,
    nip text, jabatan text, username text,
    CONSTRAINT profiles_status_check CHECK ((status = ANY (ARRAY['active'::text, 'suspended'::text])))
);
ALTER TABLE ONLY public.profiles REPLICA IDENTITY FULL;

CREATE TABLE public.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL, role public.app_role NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.opd (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nama text NOT NULL, singkatan text NOT NULL,
    kategori text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.desa (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nama text NOT NULL, kecamatan text,
    aktif boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.pejabat (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nama text NOT NULL, jabatan text NOT NULL, foto_url text,
    urutan integer DEFAULT 0 NOT NULL,
    aktif boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.kategori_layanan (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nama text NOT NULL, slug text NOT NULL,
    sla_hari integer DEFAULT 7 NOT NULL,
    deskripsi text, aktif boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT kategori_layanan_sla_hari_check CHECK (((sla_hari > 0) AND (sla_hari <= 365)))
);

CREATE TABLE public.layanan_publik (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    judul text NOT NULL, slug text NOT NULL,
    deskripsi text, ikon text, opd_id uuid,
    persyaratan text, alur text,
    aktif boolean DEFAULT true NOT NULL,
    urutan integer DEFAULT 0 NOT NULL,
    sla_hari integer DEFAULT 14 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.permohonan (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kode text NOT NULL,
    pemohon_id uuid NOT NULL, opd_id uuid NOT NULL,
    judul text NOT NULL, kategori text NOT NULL, deskripsi text,
    status public.status_permohonan DEFAULT 'baru'::public.status_permohonan NOT NULL,
    petugas_id uuid,
    tanggal_masuk timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    prioritas text DEFAULT 'normal'::text NOT NULL,
    tenggat timestamp with time zone, ringkasan text,
    untuk_orang_lain boolean DEFAULT false NOT NULL,
    atas_nama_nama text, atas_nama_nik text, atas_nama_hp text,
    wakil_ambil_nama text, wakil_ambil_nik text,
    CONSTRAINT permohonan_prioritas_check CHECK ((prioritas = ANY (ARRAY['rendah'::text, 'normal'::text, 'tinggi'::text])))
);

CREATE TABLE public.permohonan_rating (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    permohonan_id uuid NOT NULL, user_id uuid NOT NULL,
    skor integer NOT NULL, komentar text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT permohonan_rating_skor_check CHECK (((skor >= 1) AND (skor <= 10)))
);

CREATE TABLE public.permohonan_riwayat (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    permohonan_id uuid NOT NULL, oleh uuid,
    aksi text NOT NULL, catatan text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.laporan_masyarakat (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nama text NOT NULL, nik text, email text NOT NULL, no_hp text,
    kategori text NOT NULL, lokasi text, uraian text NOT NULL,
    status text DEFAULT 'baru'::text NOT NULL,
    opd_id uuid, tindak_lanjut text, ditangani_oleh uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.berita (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    judul text NOT NULL, slug text NOT NULL, ringkasan text,
    isi text DEFAULT ''::text NOT NULL, gambar_url text,
    status text DEFAULT 'draft'::text NOT NULL,
    published_at timestamp with time zone, penulis_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT berita_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'terbit'::text])))
);

CREATE TABLE public.data_terpadu_item (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kategori text NOT NULL, label text NOT NULL,
    nilai_teks text, nilai_num numeric, nilai_num2 numeric,
    satuan text, trend text, ikon text, format text, ukuran text, url text, opd text,
    aktif boolean DEFAULT true NOT NULL,
    urutan integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT data_terpadu_item_kategori_check CHECK ((kategori = ANY (ARRAY['kpi'::text, 'chart_layanan'::text, 'penduduk'::text, 'anggaran'::text, 'dataset'::text])))
);

CREATE TABLE public.app_setting (
    key text NOT NULL,
    value jsonb DEFAULT '{}'::jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.aset (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kode text NOT NULL, nama text NOT NULL, kategori text,
    kondisi text DEFAULT 'baik'::text NOT NULL,
    lokasi text, opd_id uuid, pemegang_user_id uuid,
    nilai_perolehan numeric DEFAULT 0, tanggal_perolehan date,
    deskripsi text, foto_url text, merk text, nomor_seri text,
    lokasi_terkini text, lat numeric, lng numeric,
    status text DEFAULT 'aktif'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    catatan text
);

CREATE TABLE public.aset_riwayat (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    aset_id uuid NOT NULL, aksi text NOT NULL, catatan text,
    oleh uuid, data jsonb, lat numeric, lng numeric, lokasi_text text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.absensi_asn (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL, opd_id uuid, tipe text NOT NULL,
    waktu timestamp with time zone DEFAULT now() NOT NULL,
    lokasi text, lat numeric, lng numeric, foto_url text, catatan text, device_info text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.kantor_qr (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    opd_id uuid NOT NULL, token text NOT NULL,
    label text, lokasi text, lat numeric, lng numeric,
    radius_m integer DEFAULT 100 NOT NULL,
    aktif boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.push_subscription (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL, endpoint text NOT NULL,
    p256dh text NOT NULL, auth text NOT NULL, user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.verification_token (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL, token text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '30 days'::interval) NOT NULL,
    used_at timestamp with time zone, used_by uuid
);

CREATE TABLE public.audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid, user_email text,
    aksi text NOT NULL, entitas text NOT NULL, entitas_id text,
    data_sebelum jsonb, data_sesudah jsonb,
    ip_address text, user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.job_queue (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    job_type text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.job_status DEFAULT 'pending'::public.job_status NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 3 NOT NULL,
    scheduled_at timestamp with time zone DEFAULT now() NOT NULL,
    started_at timestamp with time zone, finished_at timestamp with time zone,
    error text, result jsonb, created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.backup_snapshot (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    label text NOT NULL,
    tipe text DEFAULT 'manual'::text NOT NULL,
    size_bytes bigint DEFAULT 0 NOT NULL,
    table_counts jsonb DEFAULT '{}'::jsonb NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_by uuid
);

CREATE TABLE public.rate_limit (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    identifier text NOT NULL, bucket text NOT NULL,
    window_start timestamp with time zone DEFAULT now() NOT NULL,
    count integer DEFAULT 1 NOT NULL
);

-- Primary keys, unique constraints
ALTER TABLE ONLY public.absensi_asn ADD CONSTRAINT absensi_asn_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.app_setting ADD CONSTRAINT app_setting_pkey PRIMARY KEY (key);
ALTER TABLE ONLY public.aset ADD CONSTRAINT aset_kode_key UNIQUE (kode);
ALTER TABLE ONLY public.aset ADD CONSTRAINT aset_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.aset_riwayat ADD CONSTRAINT aset_riwayat_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.audit_log ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.backup_snapshot ADD CONSTRAINT backup_snapshot_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.berita ADD CONSTRAINT berita_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.berita ADD CONSTRAINT berita_slug_key UNIQUE (slug);
ALTER TABLE ONLY public.data_terpadu_item ADD CONSTRAINT data_terpadu_item_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.desa ADD CONSTRAINT desa_nama_key UNIQUE (nama);
ALTER TABLE ONLY public.desa ADD CONSTRAINT desa_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.job_queue ADD CONSTRAINT job_queue_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.kantor_qr ADD CONSTRAINT kantor_qr_opd_id_key UNIQUE (opd_id);
ALTER TABLE ONLY public.kantor_qr ADD CONSTRAINT kantor_qr_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.kantor_qr ADD CONSTRAINT kantor_qr_token_key UNIQUE (token);
ALTER TABLE ONLY public.kategori_layanan ADD CONSTRAINT kategori_layanan_nama_key UNIQUE (nama);
ALTER TABLE ONLY public.kategori_layanan ADD CONSTRAINT kategori_layanan_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.kategori_layanan ADD CONSTRAINT kategori_layanan_slug_key UNIQUE (slug);
ALTER TABLE ONLY public.laporan_masyarakat ADD CONSTRAINT laporan_masyarakat_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.layanan_publik ADD CONSTRAINT layanan_publik_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.layanan_publik ADD CONSTRAINT layanan_publik_slug_key UNIQUE (slug);
ALTER TABLE ONLY public.opd ADD CONSTRAINT opd_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.pejabat ADD CONSTRAINT pejabat_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.permohonan ADD CONSTRAINT permohonan_kode_key UNIQUE (kode);
ALTER TABLE ONLY public.permohonan ADD CONSTRAINT permohonan_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.permohonan_rating ADD CONSTRAINT permohonan_rating_permohonan_id_user_id_key UNIQUE (permohonan_id, user_id);
ALTER TABLE ONLY public.permohonan_rating ADD CONSTRAINT permohonan_rating_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.permohonan_riwayat ADD CONSTRAINT permohonan_riwayat_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profiles ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.push_subscription ADD CONSTRAINT push_subscription_endpoint_key UNIQUE (endpoint);
ALTER TABLE ONLY public.push_subscription ADD CONSTRAINT push_subscription_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.rate_limit ADD CONSTRAINT rate_limit_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.user_roles ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.user_roles ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role);
ALTER TABLE ONLY public.verification_token ADD CONSTRAINT verification_token_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.verification_token ADD CONSTRAINT verification_token_token_key UNIQUE (token);
ALTER TABLE ONLY public.verification_token ADD CONSTRAINT verification_token_user_id_key UNIQUE (user_id);

-- Indexes
CREATE INDEX idx_audit_log_created ON public.audit_log USING btree (created_at DESC);
CREATE INDEX idx_audit_log_entitas ON public.audit_log USING btree (entitas, entitas_id);
CREATE INDEX idx_audit_log_user ON public.audit_log USING btree (user_id);
CREATE INDEX idx_backup_snapshot_created_at ON public.backup_snapshot USING btree (created_at DESC);
CREATE INDEX idx_berita_status_pub ON public.berita USING btree (status, published_at DESC);
CREATE INDEX idx_data_terpadu_kat_urut ON public.data_terpadu_item USING btree (kategori, urutan);
CREATE INDEX idx_job_queue_status_scheduled ON public.job_queue USING btree (status, scheduled_at) WHERE (status = ANY (ARRAY['pending'::public.job_status, 'failed'::public.job_status]));
CREATE INDEX idx_laporan_created ON public.laporan_masyarakat USING btree (created_at DESC);
CREATE INDEX idx_laporan_opd ON public.laporan_masyarakat USING btree (opd_id);
CREATE INDEX idx_laporan_status ON public.laporan_masyarakat USING btree (status);
CREATE INDEX idx_permohonan_opd ON public.permohonan USING btree (opd_id);
CREATE INDEX idx_permohonan_pemohon ON public.permohonan USING btree (pemohon_id);
CREATE INDEX idx_permohonan_status ON public.permohonan USING btree (status);
CREATE INDEX idx_push_subscription_user ON public.push_subscription USING btree (user_id);
CREATE INDEX idx_rate_limit_lookup ON public.rate_limit USING btree (identifier, bucket, window_start DESC);
CREATE INDEX idx_riwayat_permohonan ON public.permohonan_riwayat USING btree (permohonan_id);
CREATE INDEX idx_verification_token_token ON public.verification_token USING btree (token);
CREATE UNIQUE INDEX profiles_username_lower_uidx ON public.profiles USING btree (lower(username)) WHERE (username IS NOT NULL);

-- Foreign keys
ALTER TABLE ONLY public.absensi_asn ADD CONSTRAINT absensi_asn_opd_id_fkey FOREIGN KEY (opd_id) REFERENCES public.opd(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.absensi_asn ADD CONSTRAINT absensi_asn_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.aset ADD CONSTRAINT aset_opd_id_fkey FOREIGN KEY (opd_id) REFERENCES public.opd(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.aset ADD CONSTRAINT aset_pemegang_user_id_fkey FOREIGN KEY (pemegang_user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.aset_riwayat ADD CONSTRAINT aset_riwayat_aset_id_fkey FOREIGN KEY (aset_id) REFERENCES public.aset(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.aset_riwayat ADD CONSTRAINT aset_riwayat_oleh_fkey FOREIGN KEY (oleh) REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.kantor_qr ADD CONSTRAINT kantor_qr_opd_id_fkey FOREIGN KEY (opd_id) REFERENCES public.opd(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.laporan_masyarakat ADD CONSTRAINT laporan_masyarakat_opd_id_fkey FOREIGN KEY (opd_id) REFERENCES public.opd(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.layanan_publik ADD CONSTRAINT layanan_publik_opd_id_fkey FOREIGN KEY (opd_id) REFERENCES public.opd(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.permohonan ADD CONSTRAINT permohonan_opd_id_fkey FOREIGN KEY (opd_id) REFERENCES public.opd(id) ON DELETE RESTRICT;
ALTER TABLE ONLY public.permohonan ADD CONSTRAINT permohonan_pemohon_id_fkey FOREIGN KEY (pemohon_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.permohonan ADD CONSTRAINT permohonan_petugas_id_fkey FOREIGN KEY (petugas_id) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.permohonan_rating ADD CONSTRAINT permohonan_rating_permohonan_id_fkey FOREIGN KEY (permohonan_id) REFERENCES public.permohonan(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.permohonan_rating ADD CONSTRAINT permohonan_rating_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.permohonan_riwayat ADD CONSTRAINT permohonan_riwayat_oleh_fkey FOREIGN KEY (oleh) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.permohonan_riwayat ADD CONSTRAINT permohonan_riwayat_permohonan_id_fkey FOREIGN KEY (permohonan_id) REFERENCES public.permohonan(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.profiles ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.profiles ADD CONSTRAINT profiles_opd_id_fkey FOREIGN KEY (opd_id) REFERENCES public.opd(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.push_subscription ADD CONSTRAINT push_subscription_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.user_roles ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- GRANTs untuk Data API (PostgREST)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT SELECT ON public.opd, public.desa, public.pejabat, public.kategori_layanan, public.layanan_publik, public.berita, public.data_terpadu_item, public.app_setting, public.permohonan_rating TO anon;
GRANT INSERT ON public.laporan_masyarakat TO anon;