close all;
load OndaRecorte ondaRecorteMax Fs -mat

                % Audio^2
                
Xm = 2;                 % Suponemos que '1' digital son 'Xm' Voltios
ondaRecorteMaxAnalog = ondaRecorteMax * Xm;
EnergAudio = (ondaRecorteMaxAnalog).^2; % Energía (Onda^2)
L_audio = length(EnergAudio); % Duracion audio analogico

                % Media móvil de las muestras de 100ms

N_s = Fs * 0.1;         % Ventana = 100ms
Ventana = ones(1, N_s)/N_s;     % La ventana es un array de ls
EnergiaFiltradaVu = conv(Ventana,EnergAudio);       % Convolución con el filtro
EnergiaFiltradaVu = EnergiaFiltradaVu(1:L_audio);   % Cogemos solo las primeras muestras
tiempo = 0:1/Fs:(L_audio-1)/Fs;                     % Eje temporal
ValorEficazVu = sqrt(EnergiaFiltradaVu(1:L_audio));
ValordBu = 20*log(sqrt(EnergAudio)/0.775);          % Escala a dBus 
ValordBuVu = 20*log(ValorEficazVu/0.775); % Escala a dBuVUs
ValorVuinst = ValordBu - 4;     % 4dBu = 0 VU
ValorVUFiltrado = ValordBuVu - 4;

                % Representaciones

figure;
plot(tiempo, EnergAudio, 'b'); hold on; grid on;
plot(tiempo, EnergiaFiltradaVu, 'r');
legend('Energia RecorteMax', 'Energia Filtrada');
xlabel('Tiempo[s]'); ylabel('Energia[V^2]');

figure;
plot(tiempo,ondaRecorteMaxAnalog,'b'); hold on; grid on;
plot(tiempo, ValorEficazVu, 'r');
legend('Onda RecorteMax', 'valor eficaz filtrado');
xlabel('Tiempo[s]'), ylabel('Voltios [V]');

figure;
plot(tiempo, ValordBu, 'b'); hold on; grid on;
plot(tiempo,ValordBuVu, 'r');
legend('dBu RecorteMax','dBu filtrado');
xlabel('Tiempo[s]'), ylabel('dBu');
axis([0 Inf -30 20])

figure;
plot(tiempo, ValorVuinst, 'b'); hold on; grid on;
plot(tiempo,ValorVUFiltrado, 'r');
legend('VuRecorteMax', 'VuFiltrado');
xlabel('Tiempo[s]'); ylabel('VU');
axis([0 Inf -34 16]); %Límites de los ejes para valor instantáneo VU

save OndaRecorte ondaRecorteMax EnergiaFiltradaVu ValorEficazVu ValordBuVu ValordBu Fs -mat -append
