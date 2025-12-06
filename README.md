Mantap, script-nya sudah lengkap: satu untuk **pelatihan**, satu untuk **pengujian + prediksi** 👌
Sekarang gua gabungin semuanya jadi README yang lebih profesional untuk repo curah hujan lo.

---

## 📝 README.md (versi AI Engineer)

Silakan copy–paste ini sebagai `README.md` di repo curah hujan (misalnya `rainfall-ann-matlab`):

````markdown
# 🌧️ Prediksi Curah Hujan Bulanan Menggunakan ANN (MATLAB)

Repositori ini berisi implementasi **Artificial Neural Network (ANN)** untuk melakukan **prediksi curah hujan bulanan** berbasis deret waktu. Model dibangun dan dievaluasi menggunakan MATLAB dengan dua tahap utama:

1. **Pelatihan model** menggunakan data historis.
2. **Pengujian & prediksi** untuk tahun berikutnya.

---

## 📂 Struktur Proyek

```text
.
├── pelatihan.m               % Script pelatihan ANN
├── pengujian_dan_prediksi.m  % Script pengujian + prediksi satu tahun ke depan
├── Book1.xlsx                % Dataset curah hujan (mm/bulan)
└── README.md
````

---

## 📊 Dataset

File: `Book1.xlsx`
Range yang digunakan: `E6:P8`

* Data diambil dari beberapa baris dan kolom, kemudian:

  * Di-**transpose**
  * Di-flatten menjadi vektor (disusun per bulan)
* Data mencakup beberapa tahun curah hujan bulanan.
* Normalisasi dilakukan menggunakan **Min–Max scaling** ke rentang `[0, 1]`.

---

## 🧠 Arsitektur Model

Model ANN dibangun dengan pendekatan **time series forecasting**:

* Input  : 12 bulan curah hujan sebelumnya
* Output : Curah hujan bulan ke-13 (bulan berikutnya)
* Jaringan menggunakan:

  * 2 **hidden layer**:

    * Hidden Layer 1: 50 neuron (`logsig`)
    * Hidden Layer 2: 25 neuron (`logsig`)
  * Output Layer: 1 neuron (nilai curah hujan)
* Fungsi training: `trainlm` (Levenberg–Marquardt backpropagation)
* Fungsi aktivasi: `logsig` pada hidden layer

---

## 🔁 Alur Data

### Pelatihan (`pelatihan.m`)

1. **Load data** dari `Book1.xlsx`:

   ```matlab
   data_asli = xlsread('Book1.xlsx',1,'E6:P8');
   data_asli = data_asli';
   data_asli = data_asli(:);
   ```

2. **Normalisasi Min–Max**:

   ```matlab
   min_data = min(data_asli);
   max_data = max(data_asli);
   data_norm = (data_asli - min_data) / (max_data - min_data);
   ```

3. **Menyusun data latih** dengan sliding window (12 bulan → target bulan ke-13):

   ```matlab
   tahun_latih   = 2;   % contoh: 2021–2022
   jumlah_bulan  = 12;
   ```

4. **Membangun dan melatih ANN**:

   ```matlab
   jaringan = newff(minmax(data_latih_norm), [50 25 1], ...
       {'logsig','logsig','logsig'}, 'trainlm');
   jaringan = train(jaringan, data_latih_norm, target_latih_norm);
   ```

5. **Denormalisasi hasil dan evaluasi MSE**:

   ```matlab
   hasil_latih_asli   = round(hasil_latih_norm * (max_data-min_data) + min_data);
   target_latih_asli  = data_asli(jumlah_bulan+1:jumlah_bulan*tahun_latih);
   nilai_error        = hasil_latih_norm - target_latih_norm;
   error_MSE          = (1/n) * sum(nilai_error.^2);
   ```

6. **Visualisasi**:

   * Grafik Keluaran ANN vs Target (contoh: tahun 2022)
   * Kurva konvergensi error via MSE di judul grafik

7. **Menyimpan model**:

   ```matlab
   save jaringan jaringan
   ```

---

### Pengujian & Prediksi (`pengujian_dan_prediksi.m`)

1. **Load kembali dataset & model**:

   ```matlab
   data_asli = xlsread('Book1.xlsx', 1, 'E6:P8');
   ...
   load jaringan
   ```

2. **Normalisasi lagi dengan Min–Max yang sama** (menggunakan `min_data` dan `max_data` yang dihitung dari data asli).

3. **Menyusun data uji** untuk periode berikutnya (misal: 2022–2023):

   ```matlab
   tahun_latih  = 2; % 2021–2022
   tahun_uji    = 2; % 2022–2023
   jumlah_bulan = 12;
   ```

4. **Simulasi data uji**:

   ```matlab
   hasil_uji_norm = sim(jaringan, data_uji_norm);
   hasil_uji_asli = round(hasil_uji_norm * (max_data - min_data) + min_data);
   ```

5. **Perhitungan metrik evaluasi pada data uji**:

   * **MSE**:

     ```matlab
     nilai_error = hasil_uji_norm - target_uji_norm;
     error_MSE   = mean(nilai_error.^2);
     ```
   * **RMSE**:

     ```matlab
     error_RMSE = sqrt(mean(nilai_error.^2));
     ```
   * **MAE**:

     ```matlab
     error_MAE = mean(abs(nilai_error));
     ```

6. **Visualisasi hasil uji**:

   * Grafik Keluaran ANN vs Target (contoh: tahun 2023)
   * Plot regresi `plotregression(target_uji_norm, hasil_uji_norm, 'Regresi Data Uji')`

7. **Prediksi ke depan (contoh tahun 2024)**

   Menggunakan output terakhir sebagai input berikutnya (recursive forecasting):

   ```matlab
   data_prediksi_norm = hasil_uji_norm(end-11:end);
   data_prediksi_norm = data_prediksi_norm';

   hasil_prediksi_norm = sim(jaringan, data_prediksi_norm); % Januari 2024

   for n = 1:11
       data_prediksi_norm  = [data_prediksi_norm(end-10:end); hasil_prediksi_norm(end)];
       hasil_prediksi_norm = [hasil_prediksi_norm, sim(jaringan, data_prediksi_norm)];
   end

   hasil_prediksi_asli = round(hasil_prediksi_norm * (max_data - min_data) + min_data);
   ```

   Hasilnya divisualisasikan sebagai deret 12 bulan prediksi (Januari–Desember 2024).

> 💡 **Catatan:**
> Jika ingin menghitung error prediksi (MSE/RMSE) untuk tahun 2024, dibutuhkan data aktual tahun 2024 untuk dibandingkan. Saat ini script hanya menghitung error pada data uji (2023).

---

## 🚀 Cara Menjalankan

1. Buka folder proyek ini di MATLAB (set sebagai *Current Folder*).

2. Pastikan file berikut berada di direktori yang sama:

   * `pelatihan.m`
   * `pengujian_dan_prediksi.m`
   * `Book1.xlsx`

3. Jalankan pelatihan:

   ```matlab
   pelatihan
   ```

4. Setelah training selesai dan file `jaringan.mat` terbentuk, jalankan:

   ```matlab
   pengujian_dan_prediksi
   ```

---

## 🔍 Pengembangan Lanjutan

Beberapa ide pengembangan:

* Menambahkan:

  * Perbandingan dengan model lain (LSTM, GRU, ARIMA).
  * Cross-validation dengan lebih banyak kombinasi tahun latih/uji.
* Menyimpan model & konfigurasi dalam format yang mudah dipakai ulang (misalnya `.mat` dengan struktur konfigurasi).
* Membuat versi Python (TensorFlow / PyTorch) untuk replikasi.

---

## 👨‍💻 Pengembang

**Ilham Hafidz**
AI Engineer & Data Enthusiast
Email: `ilhamhafidz666@gmail.com`
