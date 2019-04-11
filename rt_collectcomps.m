function [ind_comp] = rt_collectcomps(sub, comps)

    disp('***')
    disp('Enter single component number. Terminate by writing "done".')
    disp(strcat('Indicate rejectable components', ' (', 'Subject:', int2str(sub), ')', ':'))

    n = 1;
    ncounter = 1;
    ind_comp = [];
    while n == 1
        comps = input(strcat('Comp', int2str(ncounter), ':'), 's');
        if strcmp(comps, 'done')
            n = n + 1;
        else
            ncounter = ncounter + 1;
            comps = str2double(comps);
            if ~isnan(comps)
                ind_comp = [ind_comp, comps];
            else
                disp('Invalid input! No number or "done" entered.')
            end
        end   
    end

    disp('ICA run done.')
    disp('***')
    
end