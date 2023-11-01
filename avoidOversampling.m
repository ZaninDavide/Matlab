function [new_datax, new_datay, new_s_datay] = avoidOversampling(datax, datay)
    % safety check
    assert(length(datax) == length(datay), "datax and datay should have the same length but length(datax) = '" + length(datax) + "' and length(datay) = '" + length(datay) + "'");

    % vogliamo che i dati in X siano ordinati in modo crescente
    [datax, order] = sort(datax);
    datay = datay(order);

    new_datax = [];
    new_datay = [];
    new_s_datay = [];
    last_x = datax(1);
    start_cur_list = 1;
    end_cur_list = 1;
    for ii = 1:length(datax)
        assert(datax(ii) >= last_x, "sorted_datax should be a non-decreasing sequence.");
        if datax(ii) == last_x
        end_cur_list = ii;
        else
        new_datax(length(new_datax) + 1, 1) = last_x;
        new_datay(length(new_datay) + 1, 1) = mean(datay(start_cur_list:end_cur_list));
        new_s_datay(length(new_s_datay) + 1, 1) = std(datay(start_cur_list:end_cur_list));
        start_cur_list = ii;
        end_cur_list = ii;
        last_x = datax(ii);
        end
    end
    if start_cur_list ~= end_cur_list
        new_datax(length(new_datax) + 1) = last_x;
        new_datay(length(new_datay) + 1) = mean(datay(start_cur_list:end_cur_list));
        new_s_datay(length(new_s_datay) + 1) = std(datay(start_cur_list:end_cur_list));
    end
end