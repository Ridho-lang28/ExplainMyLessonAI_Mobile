# ExplainMyLesson AI — Mobile Edukasi Pintar Siswa SD 📱✨

Aplikasi mobile pembelajaran adaptif berbasis AI untuk siswa Sekolah Dasar (**Pendidikan Pancasila / PKn** dan **Bahasa Jawa** Kurikulum Merdeka). Dibuat menggunakan **Flutter** dengan tampilan modern bertema aplikasi populer Indonesia seperti **DANA & GoPay** serta sistem **Gamifikasi Lengkap**.

---

## 🎯 Pembaruan Fitur Terbaru

### 1. ✏️ Edit Profil Siswa Interaktif (Mirip Web)
* **Formulir Edit Lengkap**: Siswa dapat mengedit Nama Lengkap, Alamat Email, NISN, Tingkat Kelas (Kelas 3–6 SD), dan Nama Sekolah.
* **Pemilih Karakter Avatar Lucu**: Pilihan avatar kartun interaktif (👦, 👧, 🧒, 🧑, 🎓, 🚀, 🌟, 🦁, 🤖, 🎨, 🐼, 🦊) dengan preview langsung.
* **Reward Gamifikasi**: Setiap kali siswa berhasil memperbarui data profilnya, siswa dihadiahi **+10 ⭐ Poin Prestasi**!
* **Penyimpanan Persisten**: Perubahan profil disimpan ke memori lokal (*SharedPreferences*) sehingga data profil tidak hilang saat aplikasi ditutup.

### 2. 🔐 Autentikasi Siswa (Login & Register + Menu Demo 1-Klik)
* **Halaman Masuk & Daftar**:
  * Pilihan tab **Masuk Akun** atau **Daftar Siswa Baru**.
  * Input Nama Lengkap, Email Siswa, Kata Sandi (dengan tombol intip sandi), Tingkat Kelas, dan Nama Sekolah.
  * Siswa yang baru mendaftar langsung mendapatkan bonus pendaftaran **+100 ⭐ Poin Prestasi**.
* **Tombol Akses Cepat Demo Siswa (Mirip Web)**:
  * Tombol 1-klik `Demo Siswa SD 👧` untuk langsung masuk ke akun pengujian tanpa harus mengetik kata sandi, persis seperti pada versi web.
  * Dilengkapi fitur *Auto-Isi* akun demo `ghandur@sd1madiun.sch.id` untuk simulasi login form biasa.

### 3. 🚪 Navigasi Keluar Fitur & Keluar Akun
* **Keluar dari Fitur (Kembali ke Awal/Beranda)**:
  * Setiap fitur (Ruang Belajar, Kuis Adaptif, Prestasi & Juara Kelas) memiliki tombol kembali/keluar (`←` / `✕`) di pojok kiri atas untuk langsung kembali ke Beranda.
* **Keluar dari Akun (Logout)**:
  * Terletak secara terpusat dan aman khusus di **Profil Siswa** dengan kartu merah dan konfirmasi ramah anak.

---

## 🌟 Fitur Utama & Gamifikasi

1. **🏠 Beranda Gamifikasi (DANA / GoPay Style)**: Kartu saldo melayang (*floating balance*), poin prestasi (⭐), peringkat kelas, dan 4 tombol aksi instan (*Kuis Seru*, *Materi Bab*, *Lencana*, *Suara AI*).
2. **🎯 Misi Harian Belajar**: 5 misi harian dengan *progress bar* real-time (0% - 100%) dan klaim reward.
3. **📚 Ruang Belajar AI (PKn & Bahasa Jawa)**: 8 Bab kurikulum lengkap dengan teks ramah anak dan **Narasi Suara AI (Text-to-Speech)**.
4. **🎮 Kuis Adaptif 3 Tingkat**: Level 1 (Pemula), Level 2 (Menengah), Level 3 (Ksatria Pintar) dengan petunjuk (*hint*), feedback instan, dan selebrasi gelar juara.
5. **🏆 Koleksi Lencana Kehormatan & 👑 Juara Kelas**: Lencana kurikulum resmi dengan audio pesan motivasi dan podium Top 3.
6. **👤 Profil & Diagnostik Remedial**: Pemantauan status pemahaman siswa (Tuntas vs Remedial) dengan saran pembelajaran.

---

## 🚀 Cara Menjalankan Aplikasi

1. Masuk ke direktori mobile:
   ```powershell
   cd "d:\MATKUL SEMESTER 3\APLIKASI MOBILE\explainmylessonai_mobile"
   ```

2. Jalankan aplikasi di target yang diinginkan:
   * **Chrome / Browser**:
     ```powershell
     flutter run -d chrome
     ```
   * **Android Emulator / HP Android**:
     ```powershell
     flutter run -d android
     ```
   * **Windows Desktop**:
     ```powershell
     flutter run -d windows
     ```
