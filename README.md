# KatyuStore  Flutter Shopping Application

KatyuStore adalah aplikasi katalog produk berbasis Flutter yang menggunakan DummyJSON API untuk menampilkan berbagai informasi produk secara dinamis.

Aplikasi ini memiliki desain modern dengan kombinasi warna pastel dan dikembangkan untuk dijalankan secara langsung pada perangkat mobile iOS.

## Fitur Aplikasi

- **Product Catalog:** Menampilkan seluruh produk yang tersedia melalui DummyJSON API.
- **Product Detail:** Menampilkan gambar, nama, harga, rating, stok, dan deskripsi produk.
- **Product Search:** Mencari produk berdasarkan kata kunci.
- **Product Navigation:** Membuka halaman detail dengan memilih produk.
- **Responsive Design:** Antarmuka menyesuaikan ukuran layar perangkat.
- **Pastel UI:** Menggunakan kombinasi warna pastel untuk memberikan tampilan yang bersih dan menarik.
- **Loading & Error Handling:** Menampilkan indikator pemuatan dan menangani kesalahan saat mengambil data.

## Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework pengembangan aplikasi |
| Dart | Bahasa pemrograman |
| HTTP Package | Mengambil data dari REST API |
| DummyJSON | Sumber data produk |
| Xcode | Build dan menjalankan aplikasi iOS |
| Visual Studio Code | Code editor |
| GitHub | Version control dan penyimpanan source code |

## API

API yang digunakan berasal dari DummyJSON.

Dokumentasi: https://dummyjson.com/docs/products

Endpoint:

- `GET /products` — Mengambil produk.
- `GET /products?limit=0` — Mengambil seluruh produk.
- `GET /products/{id}` — Mengambil detail produk.
- `GET /products/search?q={keyword}` — Mencari produk.

## Cara Menjalankan Aplikasi

1. Pastikan Flutter SDK dan Xcode sudah terinstal.
2. Clone repository:

   ```bash
   git clone https://github.com/FIRMANLINK/KatyuStore-Flutter.git
   ```

3. Masuk ke folder proyek:

   ```bash
   cd KatyuStore-Flutter
   ```

4. Instal dependencies:

   ```bash
   flutter pub get
   ```

5. Hubungkan perangkat iPhone melalui USB-C.
6. Aktifkan Developer Mode pada perangkat.
7. Konfigurasikan Signing & Capabilities melalui Xcode apabila diperlukan.
8. Jalankan aplikasi:

   ```bash
   flutter run
   ```

Pilih perangkat iPhone saat diminta.

## Hasil Pengujian

Aplikasi telah diuji pada perangkat iPhone fisik, dengan hasil:

| Pengujian | Hasil |
|---|---|
| Menampilkan katalog produk | Berhasil |
| Scroll daftar produk | Berhasil |
| Menampilkan gambar, harga, dan rating | Berhasil |
| Membuka halaman detail | Berhasil |
| Menampilkan informasi detail | Berhasil |
| Navigasi kembali ke Home | Berhasil |
| Mencari produk | Berhasil |
| Mengembalikan daftar setelah search dihapus | Berhasil |

**Hasil: 8 dari 8 pengujian berhasil.**

## Video Presentasi dan Demo

Video berisi penjelasan kode, implementasi API, tampilan aplikasi, serta demonstrasi penggunaan KatyuStore secara langsung melalui iPhone.

**Link YouTube:** [Tambahkan link video YouTube Public di sini]

## Developer

Dikembangkan sebagai tugas individu pengembangan aplikasi mobile menggunakan Flutter.