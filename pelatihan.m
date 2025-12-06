clc; clear; close all; warning off all;

% MEMBACA DATA ASLI DARI EXCEL
data_asli = xlsread('Book1.xlsx',1,'E6:P8');

%Transpose data Asli
data_asli = data_asli';

%Mengubah matriks menjadi bentuk Vektor
data_asli = data_asli(:);

%mencari nilai minimum dan maksimum dari data asli
min_data = min(data_asli);
max_data = max(data_asli);

%normalisasi data 
[m,n] = size(data_asli);
data_norm = zeros (m,n);
for x = 1:m
    for y = 1:n
        data_norm(x,y) = (data_asli(x,y) - min_data)/(max_data - min_data);
    end
end

% menyiapkan data latih normaliasi
tahun_latih = 2; %tahun 2021 - 2022
jumlah_bulan = 12;
data_latih_norm = zeros (jumlah_bulan * tahun_latih - jumlah_bulan,jumlah_bulan);

% Menyusun data latih normalisasi
for m = 1:jumlah_bulan * tahun_latih - jumlah_bulan
    for n = 1: jumlah_bulan
        data_latih_norm(m,n) = data_norm(m+n-1);
    end
end

% Menyiapkan target latih normalisasi
target_latih_norm = zeros(jumlah_bulan * tahun_latih - jumlah_bulan, 1);
for m = 1:jumlah_bulan * tahun_latih-jumlah_bulan
    target_latih_norm(m) = data_norm(jumlah_bulan+m); %tahun 2022
end

% Transpose Data latih normalisasi dan target latih
% Normalisasi
data_latih_norm = data_latih_norm';
target_latih_norm = target_latih_norm';

% Menetapkan Parameter ANN
jumlah_neuron1 = 50;
jumlah_neuron2 = 25;
fungsi_aktifasi1 = 'logsig';
fungsi_aktifasi2 = 'logsig';
fungsi_pelatihan = 'trainlm';

% Membangun Arsitektur ANN Backpropagation
rng ('default')
jaringan = newff(minmax(data_latih_norm), [jumlah_neuron1 jumlah_neuron2 1], ...
    {fungsi_aktifasi1, fungsi_aktifasi1, fungsi_aktifasi2}, fungsi_pelatihan);

% Melakukan Pelatihan jaringan
jaringan = train(jaringan,data_latih_norm,target_latih_norm);

% membaca hasil pelatihan
hasil_latih_norm = sim(jaringan, data_latih_norm);

% melakukan denormalisasi terhadap hasil latih normalisasi
hasil_latih_asli = round (hasil_latih_norm * (max_data-min_data)+ min_data);

% Membaca Target Latih asli
target_latih_asli = data_asli (jumlah_bulan+1:jumlah_bulan*tahun_latih); % Tahun 2022

% Menghitung nilai MSE (Mean Square Error)
nilai_error = hasil_latih_norm - target_latih_norm;
error_MSE = (1/n) * sum(nilai_error.^2);

% Menampilkan Grafik Hasil Pelatihan
figure
plot(hasil_latih_asli, 'bo-', 'LineWidth',2)
hold on
plot(target_latih_asli, 'ro-', 'LineWidth',2)
grid on
title (['Grafik Keluaran ANN VS Target Dengan Nilai MSE = ', num2str(error_MSE)])
xlabel('Tahun 2022')
ylabel('Curah Hujan (mm/Bulan)')
legend ('Keluaran ANN', 'Target')
hold off

% Menyimpan Arsitektur ANN hasil pelatihan
save jaringan jaringan 