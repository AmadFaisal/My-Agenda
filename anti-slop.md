# Agenda Liburku — ERD & UI Design Specification

Aplikasi mobile Flutter untuk eksplorasi hari libur nasional Indonesia (`date.nager.at/api/v3`) dan manajemen rencana liburan pribadi dengan backend Laravel REST API (Bearer Token).

---

## 1. Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    USERS {
        bigint id PK
        string name
        string email UK
        string password
        timestamp created_at
        timestamp updated_at
    }

    PERSONAL_ACCESS_TOKENS {
        bigint id PK
        string tokenable_type
        bigint tokenable_id FK
        string name
        string token UK
        text abilities
        timestamp last_used_at
        timestamp expires_at
        timestamp created_at
        timestamp updated_at
    }

    TRIP_TYPES {
        bigint id PK
        bigint user_id FK
        string name
        timestamp created_at
        timestamp updated_at
    }

    HOLIDAY_PLANS {
        bigint id PK
        bigint user_id FK
        bigint trip_type_id FK
        string title
        date holiday_date
        text notes
        timestamp created_at
        timestamp updated_at
    }

    PUBLIC_HOLIDAY_API {
        string date
        string localName
        string name
        string countryCode
        string_array types
    }

    USERS ||--o{ PERSONAL_ACCESS_TOKENS : "memiliki token"
    USERS ||--o{ TRIP_TYPES : "membuat kategori"
    USERS ||--o{ HOLIDAY_PLANS : "memiliki rencana"
    TRIP_TYPES ||--o{ HOLIDAY_PLANS : "mengelompokkan"
    PUBLIC_HOLIDAY_API ..> HOLIDAY_PLANS : "sumber data eksternal"
```

### Ringkasan API Endpoint
- **Auth:** `POST /api/register`, `POST /api/login`, `GET /api/user`, `POST /api/logout`
- **Trip Types (`trip_types`):** `GET/POST /api/trip-types`, `PUT/DELETE /api/trip-types/{id}`
- **Holiday Plans (`holiday_plans`):** `GET/POST /api/holiday-plans`, `GET /api/holiday-plans?trip_type_id={id}`, `PUT/DELETE /api/holiday-plans/{id}`
- **Public API:** `GET https://date.nager.at/api/v3/PublicHolidays/{year}/ID`

---

## 2. UI Design Direction (Figma)

### Palette & Token
- **Theme:** Dark Mode
- **Background (`scaffoldBackgroundColor`):** `#0F1115`
- **Surface / Card / Dialog:** `#1E2029`
- **Primary Accent:** `#FFC107` (Amber — tombol utama, tab aktif, badge, ikon sorotan)
- **Secondary Accent:** `#FF5722` (Deep Orange — ikon brand payung pantai)
- **Destructive:** `#FF5252` (Red Accent — tombol hapus & logout)
- **Text Primary:** `#FFFFFF`
- **Text Secondary:** `#9E9E9E`
- **Border Radius:**
  - Card & Input: `15px` – `20px`
  - Highlight Carousel Card & Detail Info Card: `25px`
  - Floating Bottom Nav Bar: `30px`

### Daftar Layar (Frame Mobile `390x844`)

1. **Splash Screen (`SplashScreen`)**
   - Ikon `beach_access` (`#FF5722`), teks **Agenda Liburku**, dan indikator loading.

2. **Login (`LoginScreen`)**
   - Ikon `beach_access`, judul **Login**, input `Email` dan `Password`, tombol **MASUK**, serta tautan `Belum punya akun? Daftar`.

3. **Register (`RegisterScreen`)**
   - AppBar **Daftar Akun**, input `Nama Lengkap`, `Email`, `Password (min. 6 karakter)`, dan tombol **DAFTAR**.

4. **Explore (`ExploreScreen` — Tab 1)**
   - Header sapaan `"Halo, Selamat Datang! 👋"` dan `"Mau Libur Kemana Tahun Ini?"` + tombol ikon notifikasi.
   - **Libur Terdekat:** Carousel horizontal (`280x200px`, radius `25px`) dengan gambar latar + gradient overlay gelap, badge `"Libur Nasional"` (`#FFC107`), ikon bintang, judul hari libur, dan tanggal.
   - **Semua Libur 2026:** List vertikal card `#1E2029` berisi ikon kalender, judul libur, tanggal, dan ikon panah kanan.
   - **Floating Bottom Nav Bar:** Container melayang (`#1E2029`, radius `30px`) dengan 3 item: `Explore`, `Koleksi`, `Profil`.

5. **Explore Detail (`ExploreDetailScreen`)**
   - Tombol kembali transparan, judul besar `localName`, subjudul `name` (`#FFC107`).
   - Card info `#1E2029` berisi baris **Tanggal**, **Kode Negara**, dan **Tipe**.
   - Tombol bawah **Simpan ke Koleksi** + variasi modal dialog dropdown **Pilih Kategori**.

6. **Koleksi Saya (`CollectionScreen` — Tab 2)**
   - TabBar berbentuk pill: **Jenis Liburan** dan **Rencana Libur**.
   - **Tab Jenis Liburan:** Daftar kategori dengan tombol edit (`#FFC107`) & hapus (`#FF5252`), FAB `+`, dan modal form **Tambah / Edit Kategori**.
   - **Tab Rencana Libur:** Dropdown filter `"Semua Kategori"`, card rencana (judul, kategori, tanggal, catatan, edit & hapus), FAB `+`, dan modal form **Tambah / Edit Rencana**.

7. **Profil & About (`ProfileScreen` — Tab 3)**
   - AppBar **Profil & About**.
   - Card akun user (avatar lingkaran, nama, email).
   - Card **Identitas Pembuat** (Nama, Kelas, Absen, sumber Public API `date.nager.at/api/v3`).
   - Tombol outlined merah **LOGOUT**.