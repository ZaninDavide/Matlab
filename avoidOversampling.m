function [new_datax, new_datay, new_s_datay] = avoidOversampling(datax, datay, sigmay)
    % safety check
    assert(length(datax) == length(datay),  "datax and datay should have the same length but length(datax) = '" + length(datax) + "' and length(datay) = '" + length(datay) + "'");
    assert(length(datay) == length(sigmay), "datay and sigmay should have the same length but length(datay) = '" + length(datay) + "' and length(sigmay) = '" + length(sigmay) + "'");

    % we sort the data so that datax is a non-decreasing sequence
    [datax, order] = sort(datax);
    datay = datay(order);
    sigmay = sigmay(order);

    % we add a fake data point at the end of the array, by making his x-value 
    % bigger than the one of the last element we guaratee it won't end up
    % in the final data and at the same time force the algorithm to push the last
    % sequence of points with the same x-value.
    datax(length(datax) + 1)  = datax(length(datax)) + 1;
    datay(length(datay) + 1)  = 0;
    dataz(length(sigmay) + 1) = 0;

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
            if end_cur_list == start_cur_list 
                % one element alone
                new_datax(length(new_datax) + 1, 1) = last_x;
                new_datay(length(new_datay) + 1, 1) = datay(start_cur_list:end_cur_list);
                new_s_datay(length(new_s_datay) + 1, 1) = sigmay(start_cur_list:end_cur_list);
            else
                % more than one element with the same x coordinate but different y-values
                new_datax(length(new_datax) + 1, 1) = last_x;
                new_datay(length(new_datay) + 1, 1) = mean(datay(start_cur_list:end_cur_list));
                % uncertainty cannot be smaller than the smallest error given
                new_s_datay(length(new_s_datay) + 1, 1) = max(...
                    std(datay(start_cur_list:end_cur_list)), min(sigmay(start_cur_list:end_cur_list)) ...
                );
            end
            start_cur_list = ii;
            end_cur_list = ii;
            last_x = datax(ii);
        end
    end
end