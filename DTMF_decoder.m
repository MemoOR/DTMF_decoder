function [PressedButtons] = DTMF_decoder(y)
%   Matriz para almacenar cada boton apretado y su tiempo
    Pressed = [[]; []];
    %Resultado final
    PressedButtons = [];
    %Frecuencia de muestreo
    Fs = 8000;
    %Frecuencia de Nyquist
    Fn = Fs/2; 
    %Frecuencias DTMF
    DTMF = [697, 770, 852, 941, 1209, 1336, 1477, 1633];
    %combinacion de frecuencias
    DTMFcomb = [1 5;1 6;1 7;1 8;
                2 5;2 6;2 7;2 8;
                3 5;3 6;3 7;3 8;
                4 5;4 6;4 7;4 8];
    %Caracteres de telefono
    PhoneKeys = ['1'; '2'; '3'; 'A'; '4'; '5'; '6'; 'B'; '7'; '8'; '9';
        'C'; '*'; '0'; '#'; 'D'];

    for i = 1:8
        %frecuencias para filtro pasa bandas con tolerancia de +-1.8%
        fcDown(i) = (DTMF(i)-(DTMF(i)*0.018));      
        fcUp(i) = (DTMF(i)+(DTMF(i)*0.018));
        %Creacion de filtro
        [FilterNum(i,:), FilterDen(i,:)] = butter(5,[fcDown(i), fcUp(i)]/Fn,'bandpass');
    end

    %Datos para crear el espectrograma
    window=hamming(1024); 
    noverlap=900; 
    nfft=1024;

    %Filtrado de señal
    for i = 1:8
        y_filtered(i, :, :) = filter(FilterNum(i,:), FilterDen(i,:), y);
    end

    % Gráfica de espectrograma de cada señal filtrada
    % Eliminar comentario para mostrar
%     tiledlayout(2,4)
%     for i = 1:8
%         nexttile;
%         [S,F,T,P] = spectrogram(y_filtered(i,:,1), window, noverlap, nfft, Fs);
%         surf(T,F,10*log10(P),'edgecolor','none');
%         axis tight;
%         view(0,0);
%         xlabel('Time s');
%         ylabel('Frequency kHz');
%         title(DTMF(i));
%     end

    % Espectrograma de cada señal filtrada
    %obtencion de tiempo en que se detectó una señal
    for i = 1:8
        [~,F,T,P] = spectrogram(y_filtered(i,:,1), window, noverlap, nfft, Fs);
        Z = 10*log10(P);
        [row, col] = find(-25 <= Z);
        Fr = F(row);
        for j = 1:size(Fr)
            if Fr(j) - DTMF(i) <= 10
                Fr(j) = DTMF(i);
            end
        end
        Tc = unique(T(col)');
        Nkeep = size(Tc);
        Fr = Fr(1:Nkeep);
        %Matriz que guarda en que momentos se detectó una señal
        FT{i,:,:} = [Tc  Fr];
    end
%     Comprobar que botones se presionaron
    for i = 1:16
%         indices para recorrer las matrices de frecuencia y compararlas
        n = 1; m=1;
%         obtencion de la matriz de frecuencia de renglones
        FT1rows = FT(DTMFcomb(i,1),:,1);
        FT1rows = FT1rows{:};
%         obtencion de la matrix de frcuencia de columnas
        FT2rows = FT(DTMFcomb(i,2),:,1);
        FT2rows = FT2rows{:};
%         tamaño de las matrices para iterar en elleas
        [row1, ~] = size(FT1rows);
        [row2, ~] = size(FT2rows);
%         comparar cada valor de una fila con las 4 columnas
        while (n <= row1)
            while (m <= row2) 
                if abs(FT1rows(n,1) - FT2rows(m,1)) <= 0.025
                    button = [num2cell(FT1rows(n,1)); char(PhoneKeys(i))];
                    Pressed = [Pressed button];
                end
                m = m+1;
            end
            m = 1;
            n = n+1;
        end
    end
 
%   valida que se haya marcado algo
    if isempty(Pressed) ~= 1
        % ordena por tiempo los numeros marcados
        Pressed = sortrows(Pressed', 1);
    
%     Elimina botones repetidos en tiempo
        for i = size(Pressed(:,1)):-1:1
            if i-1 > 0
                if isequal(Pressed{i,2},Pressed{i-1,2})
                    if abs(Pressed{i,1}-Pressed{i-1,1}) < 0.025
                        Pressed(i,:) = [];
                    end
                end
            end
        end

    %     Crea el string final con los numeros marcados
        for i = 1:size(Pressed(:,2))
            PressedButtons = [PressedButtons Pressed{i,2}];
            PressedButtons = [PressedButtons ' '];
        end
    end
end
