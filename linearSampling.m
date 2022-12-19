function ysamples = linearSampling(datax, datay, xsamples)
    % function ysamples = LinearSampling(datax, datay, xsamples)
    %
    % Fornite coppie di dati (datax, datay) restituisce i valori 'ysamples'
    % corrispondenti a entrate 'xsamples' interpolando linearmente tra i dati.
    % La funzione suppone che datax abbia valori in ordine crescente.


    % SAFETY CHECKS
    if (length(datax) ~= length(datay)) 
        throw("datax and datay should have the same length");
    end
    if (max(xsamples) > max(datax) || min(xsamples) < min(datay)) 
        throw("xsamples should have values inside the interval [min(datax), max(datax)]");
    end

    % LINEAR INTERPOLATION (lerp)
    ysamples = [];
    for x = xsamples
        id_before = 1;
        id_after = 1;
        for kk = 1:length(datax)
            if(datax(kk) > x)
                id_before = kk - 1;
                id_after = kk;
                break;
            end
        end
        y = 0;  
        if x >= max(datax)
            y = datay(length(datay));
        elseif x <= min(datax)
            y = datay(1);
        else
            y = datay(id_before) + (datay(id_after) - datay(id_before))*(x - datax(id_before))/(datax(id_after) - datax(id_before))
        end
        ysamples = [ysamples, y];
    end
  end