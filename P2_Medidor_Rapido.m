load OndaRecorte ondaRecorteMax EnergiaFiltradaVu ValorEficazVu ValordBuVu ValordBu Fs -mat

                % Energia del audio

Xm = 2;
ondaRecorteMaxAnalog = ondaRecorteMax * Xm;
ondaRecorteMaxAnalog = ondaRecorteMax * Xm;
EnergAudioInst = (ondaRecorteMaxAnalog).^2;
L_audio = length(EnergAudioInst);
tiempo = 0:1/Fs:(L_audio-1)/Fs;

                % Media con ventana móvil de perfil cuadrado

Ns_rise = round(0.01*Fs);           % Longitud de ventana : 10ms
Ns_down = round(2.8*Fs);            % Longitud de ventana: 2.8 s
VentanaRise = ones(1,Ns_rise);
VentanaDown = ones(1,Ns_down);      % Filtros

Energia_Up = (diff([0 EnergAudioInst])>=0);    % Cuándo sube o cuándo baja la energía instantánea

                % Convolución manual para ir cambiando de ventana
                
Ns_max = max(Ns_rise,Ns_down);
EnergAudioInstAmpl = [zeros(1,Ns_max-1) EnergAudioInst];
EnergFiltrada = zeros(1,Ns_max+L_audio-1);
EnerUpAmpl = [zeros(1,Ns_max-1) Energia_Up];
indFinal = Ns_max + L_audio-1;

for i = Ns_max:indFinal
    if EnergAudioInstAmpl(i) > EnergFiltrada(i-1) % Si la energía instantánea es mayor que la filtrada, entonces sí consideramos
        % subida que debe de ser seguida rápido
        EnergFiltrada(i) = EnergFiltrada(i-1)+(EnergAudioInstAmpl(i)-EnergAudioInstAmpl(i-Ns_rise+1))/  Ns_rise;
    
    else % Si Energía instantánea es menor que la filtrada entonces ventana lenta
        EnergFiltrada(i) = EnergFiltrada(i-1)+(EnergAudioInstAmpl(i)-EnergAudioInstAmpl(i-Ns_down+1))/Ns_down;
        
    end
end

EnergFiltrada = EnergFiltrada(Ns_max:end);

                % Resto de unidades

ValorEficaz = sqrt(EnergFiltrada);
ValordBuInst = 20*log(sqrt(EnergAudioInst)/0.775);
ValordBuFilt = 20*log(ValorEficaz/0.775);
ValorPPMInst = ValordBuInst/4;
ValorPPMFilt = ValordBuFilt/4;

                % Energias Instantaneas y Filtradas

figure
plot(tiempo, EnergAudioInst); hold on; grid on;
plot(tiempo, EnergFiltrada);
xlabel('Tiempo[s]'); ylabel('V^2');
legend('Instantanea', 'PPM');

                % Valor eficaz en Voltios
figure
plot(tiempo, ondaRecorteMaxAnalog); hold on; grid on;
plot(tiempo, ValorEficazVu);
plot(tiempo, ValorEficaz);
legend('OndaRecorteMax', 'ValorEficaz VU', 'Valor eficaz PPM');
xlabel('Tiempo[s]'); ylabel('Voltios[s]');

                % dBu
figure
plot(tiempo,ValordBuInst); hold on; grid on;
plot(tiempo,ValordBuVu);
plot(tiempo, ValordBuFilt);
legend('dBu RecorteMax', 'dBu Vu', 'dBu PPM');
xlabel('Tiempo[s]'); ylabel('dBu');
axis([0 Inf -30 20]);

                % PPM
figure
plot(tiempo, ValorPPMInst, 'b'); hold on; grid on;
plot(tiempo, ValorPPMFilt, 'r');
legend('RecorteMax', 'Filt');
xlabel('Tiempo[s]'); ylabel('PPM');
axis([0 Inf -5 10])





