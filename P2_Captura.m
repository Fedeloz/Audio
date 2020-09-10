% Primer script, captura y normalizaciones varias

close all;

                % Captura de audio

CapturaMuestras = [50000 320000];       % Capturo solo la parte útil
[onda, Fs] = audioread("audio_original.wav", CapturaMuestras);   % Con límite para que no capture todo
% El archivo está en mono así que 'Onda' tendrá una columna sin valor útil
ondaorig = onda(:,1)';                  % Donde se guarda el audio de las grabaciones en mono
NumMuestras = length(ondaorig);          % N de muestras del audio

                % Normalización
                
MaxAbs = max(abs(ondaorig));            % Valor absoluto max para normalizar
ondaAjust = ondaorig/MaxAbs;            % Onda limitada a +-11

                % Representación

Ejetiempo = (0:NumMuestras - 1)/Fs;     % Eje expresado en segundo

figure(1);
plot(Ejetiempo, ondaorig, 'b')          % Onda original en azul
axis([0 Inf  -1 1]);                    % Eje x sin límite, eje Y entre +-1
xlabel('Tiempo[s]'); ylabel('Valor digital original');
grid on;

                % Audio ajustado (onda e histograma)
                
figure(2);
plot(Ejetiempo, ondaAjust, 'b')         %Onda normalizadaa
axis([0 Inf -1 +1]);                    % Ajustamos ejes
xlabel('Tiempo[s]'); ylabel('Valor digital normalizado');
grid on;

figure(3);
BinEdges = 0:1/20:1;                    % Limites del histograma
h1 = histogram(abs(ondaAjust), BinEdges, 'FaceColor', 'b', 'faceAlpha', 0.6); % Configuramos histograma
xlabel('Valor abs(onda)');

figure(4);
bar3(h1.Values');                       % Barras tridimensionales
legend('Ajustada');
ylabel('bines'); xlabel('onda');

                % Normalización Sobrepasada
                
cteSobrepasada  = 0.4;                  % Constante de sobrepasamiento (Al 40%)
ondaSobrepasada = ondaAjust/cteSobrepasada;

figure(2);
hold on;                                % Se dibuja sobre la onda ajustada
plot(Ejetiempo, ondaSobrepasada, 'r');
legend('Ajustada','Sobrepasada');

figure(3);                              % Se dibuja sobre el histograma de antes
hold on;
h2 = histogram(abs(ondaSobrepasada), BinEdges, 'FaceColor','r','FaceAlpha', 0.6);
legend('Ajustada','Sobrepasada');


figure(4);
bar3([h1.Values' h2.Values']);
legend('Ajustada','Sobrepasada');
xlabel('onda'); ylabel('bines');

                % Normalización con p = 10^-4
                % Probabilidad de sobrepasamiento de 10^-4

ProbPasarOndaOrig = sum((ondaSobrepasada > 1) + (ondaSobrepasada < -1)) / NumMuestras;
ProbPasarFin = ProbPasarOndaOrig;
ProbObjetivo = 10e-4;
CoefNorm = 1;
ondaRecorteMax = ondaSobrepasada;

if ProbPasarFin > ProbObjetivo          % No sobrepasar recorte max
    while ProbPasarFin > ProbObjetivo
        CoefNorm = CoefNorm * 1.005;    % Señal se atenua al recortar más de lo debido
        ondaRecorteMax = ondaRecorteMax / CoefNorm;
        ProbPasarFin = sum((ondaRecorteMax > 1) + (ondaRecorteMax < -1)) / NumMuestras;
    end
    
elseif ProbPasarFin < ProbObjetivo
    while ProbPasarFin < ProbObjetivo
        CoefNorm = CoefNorm * 0.995;    % Debemos amplificar la señal
        ondaRecorteMax = ondaRecorteMax / CoefNorm;
        ProbPasarOndaFin = sum((ondaRecorteMax > 1) + (ondaRecorteMax < -1)) / NumMuestras;
    end
end                                     % Si ambas prob son iguales no entra

figure(2);
hold on;                                % Se dibuja sobre la figure 2
plot(Ejetiempo, ondaRecorteMax, 'g');   % Onda con recorte minimo admisible
legend('Ajustada', 'Sobrepasada', 'RecorteMax');

figure(3);
hold on;
h3 = histogram(abs(ondaRecorteMax), BinEdges, 'FaceColor', 'g', 'FaceAlpha', 0.6); % Se dibuja sobre la misma figura
legend('Ajustada', 'Sobrepasada', 'RecorteMax');

figure(4);
bar3([h1.Values' h2.Values' h3.Values']);
legend('Ajustada', 'Sobrepasada', 'RecorteMax');
ylabel('bines'); xlabel('onda');

save OndaRecorte ondaRecorteMax Fs -mat