clc; clear; close all; warning off all;

% MEMBACA DATA ASLI DARI EXCEL
data_asli = xlsread('Book1.xlsx', 1, 'E6:P8');

% Transpose data Asli
data_asli = data_asli';

% Mengubah matriks menjadi bentuk Vektor
data_asli = data_asli(:);

% Mencari nilai minimum dan maksimum dari data asli
min_data = min(data_asli);
max_data = max(data_asli);

% Normalisasi data 
data_norm = (data_asli - min_data) / (max_data - min_data);

% Menyiapkan Data Uji Normalisasi
tahun_latih = 2; % tahun 2021 - 2022
tahun_uji = 2; % tahun 2022 - 2023
jumlah_bulan = 12;
data_uji_norm = zeros(jumlah_bulan * tahun_uji - jumlah_bulan, jumlah_bulan);

% Menyusun data uji normalisasi
for m = 1:jumlah_bulan * tahun_uji - jumlah_bulan
    for n = 1:jumlah_bulan
        data_uji_norm(m, n) = data_norm(m + n - 1 + (tahun_latih - 1) * jumlah_bulan); % tahun 2022 - 2023
    end
end

% Menyiapkan Target uji Normalisasi
target_uji_norm = zeros(jumlah_bulan * tahun_uji - jumlah_bulan, 1);
for m = 1:jumlah_bulan * tahun_uji - jumlah_bulan
    target_uji_norm(m) = data_norm(jumlah_bulan + m + (tahun_latih - 1) * jumlah_bulan); %tahun 2023
end

% Transpose Data uji normalisasi dan target uji
data_uji_norm = data_uji_norm';
target_uji_norm = target_uji_norm';

% Memanggil Arsitektur ANN Latih
load jaringan

% Membaca Hasil pengujian
hasil_uji_norm = sim(jaringan, data_uji_norm);

% Melakukan Denormalisasi terhadap hasil Uji Normalisasi
hasil_uji_asli = round(hasil_uji_norm * (max_data - min_data) + min_data);

% Membaca target uji asli
target_uji_asli = data_asli(jumlah_bulan + 1 + (tahun_latih - 1) * jumlah_bulan: ...
    jumlah_bulan * tahun_uji + (tahun_latih - 1) * jumlah_bulan);

% Menghitung nilai MSE
nilai_error = hasil_uji_norm - target_uji_norm;
error_MSE = mean(nilai_error.^2);

% Menampilkan Grafik Hasil Pengujian
figure;
plot(hasil_uji_asli, 'ko-', 'LineWidth', 2);
hold on;
plot(target_uji_asli, 'go-', 'LineWidth', 2);
grid on;
title(['Grafik Keluaran ANN VS Target Dengan Nilai MSE = ', num2str(error_MSE)]);
xlabel('Tahun 2023');
ylabel('Curah Hujan (mm/Bulan)');
legend('Keluaran ANN', 'Target');
hold off;

% Menampilkan Grafik Regresi Uji
figure;
plotregression(target_uji_norm, hasil_uji_norm, 'Regresi Data Uji');

% Menampilkan hasil error pada command window
fprintf('Nilai MSE pada data pengujian: %f\n', error_MSE);

% Menampilkan performa uji

% Root Mean Squared Error (RMSE)
error_RMSE = sqrt(mean(nilai_error.^2));
fprintf('Nilai RMSE pada data pengujian: %f\n', error_RMSE);

% Mean Absolute Error (MAE)
error_MAE = mean(abs(nilai_error));
fprintf('Nilai MAE pada data pengujian: %f\n', error_MAE);


% DATA PREDIKSI NORMALISASI
data_prediksi_norm = hasil_uji_norm(end - 11:end);

% Transpose Data Prediksi Normalisasi
data_prediksi_norm = data_prediksi_norm';

% MELAKUKAN PREDIKSI
hasil_prediksi_norm = sim(jaringan, data_prediksi_norm); % Januari 2024

for n = 1:11
    data_prediksi_norm = [data_prediksi_norm(end - 10:end); hasil_prediksi_norm(end)];
    hasil_prediksi_norm = [hasil_prediksi_norm, sim(jaringan, data_prediksi_norm)];
end

% MELAKUKAN DENORMALISASI TERHADAP HASIL PREDIKSI NORMALISASI
hasil_prediksi_asli = round(hasil_prediksi_norm * (max_data - min_data) + min_data);

% Menampilkan Grafik Hasil Prediksi
figure;
plot(hasil_prediksi_asli, 'mo-', 'LineWidth', 2);
grid on;
title(['Grafik Keluaran ANN Dengan MSE ', num2str(error_MSE)]);
xlabel('Tahun 2024');
ylabel('Curah Hujan (mm/Bulan)');
legend('Keluaran ANN', 'Target');

% Root Mean Squared Error (RMSE) untuk prediksi
error_RMSE_prediksi = sqrt(mean(nilai_error_prediksi.^2));
fprintf('Nilai RMSE pada data prediksi: %f\n', error_RMSE_prediksi);

