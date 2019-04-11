function [channels] = rt_channelselect(subjects, sub)

    if strcmp(subjects{sub}, 'sub8')
        channels = {'all', '-3'};
    elseif strcmp(subjects{sub}, 'sub11')
        channels = {'all','-6'};
    elseif strcmp(subjects{sub}, 'sub30')
        channels = {'all','-11'};
    else
        channels = {'all'};
    end

end