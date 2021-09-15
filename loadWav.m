%% 
clear, clc, close all;

%697
%770
%852
%941
%1209
%1336
%1477
%1633

%lectura de archivo wav
%y = numero de muestras
%Fs = frecuencia de muestreo
[y, Fs] = audioread('audio1.wav');

ydft = fft(y);
% I'll assume y has even length
ydft = ydft(1:length(y)/2+1);
% create a frequency vector
freq = 0:Fs/length(y):Fs/2;
% plot magnitude
subplot(211);
plot(freq,abs(ydft));
% plot phase
subplot(212);
plot(freq,unwrap(angle(ydft))); 
xlabel('Hz');