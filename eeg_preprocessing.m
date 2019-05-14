%% Add Fieldtrip functions

addpath '/home/renter/EEG Analysis/fieldtrip-20181209/fieldtrip-20181209/'
ft_defaults


%% Add default path and raw subject EEG data

subjects = {'sub1_eeg.vhdr','sub2_eeg.vhdr','sub3_eeg.vhdr','sub4_eeg.vhdr',...
            'sub5_eeg.vhdr','sub6_eeg.vhdr','sub7_eeg.vhdr','sub8_eeg.vhdr',...
            'sub9_eeg.vhdr','sub10_eeg.vhdr','sub11_eeg.vhdr','sub12_eeg.vhdr',...
            'sub13_eeg.vhdr','sub14_eeg.vhdr','sub15_eeg.vhdr','sub16_eeg.vhdr',...
            'sub17_eeg.vhdr','sub18_eeg.vhdr','sub19_eeg.vhdr','sub20_eeg.vhdr',...
            'sub21_eeg.vhdr','sub22_eeg.vhdr','sub23_eeg.vhdr','sub24_eeg.vhdr',...
            'sub25_eeg.vhdr','sub26_eeg.vhdr','sub27_eeg.vhdr','sub28_eeg.vhdr',...
            'sub29_eeg.vhdr','sub30_eeg.vhdr','sub31_eeg.vhdr','sub32_eeg.vhdr',...
            'sub33_eeg.vhdr','sub34_eeg.vhdr','sub_35.vhdr','sub36_eeg.vhdr',...
            'sub37.vhdr','sub38_eeg.vhdr','sub39_eeg.vhdr','sub40_eeg.vhdr'};
        
subjectFolder = {'sub1','sub2','sub3','sub4',...
                'sub5','sub6','sub7','sub8',...
                'sub9','sub10','sub11','sub12',...
                'sub13','sub14','sub15','sub16',...
                'sub17','sub18','sub19','sub20',...
                'sub21','sub22','sub23','sub24',...
                'sub25','sub26','sub27','sub28',...
                'sub29','sub30','sub31','sub32',...
                'sub33','sub34','sub35','sub36',...
                'sub37','sub38','sub39','sub40'};

subDirs = '/home/renter/EEG Analysis/Raw EEG Data/';
outFiles = '/home/renter/EEG Analysis/Results/';


%% Define the reference channels, add virtual reference channel

for a = 1:length(subjects)
    
    cfg                 = [];
    cfg.dataset         = fullfile(subDirs, subjects{a});
    cfg.reref           = 'yes';
    cfg.channel         = 'all';
    cfg.implicitref     = 'LM';
    cfg.refchannel      = {'LM' 'RM'};
    data_eeg{a}         = ft_preprocessing(cfg);

    cfg                 = [];
    cfg.channel         = [1:60 65]; % keep channels 1 to 61 and the newly inserted M1 channel
    cfg.hpfilter        = 'yes';
    cfg.hpfreq          = 0.1;
    cfg.hpfilttype      = 'firws';
    cfg.hpfiltdir       = 'onepass-zerophase';
    cfg.dftfilter       = 'yes';
    cfg.lpfilter        = 'yes';
    cfg.lpfreq          = 150;
    data_eeg{a}         = ft_preprocessing(cfg, data_eeg{a});
    
    disp(strcat('***   Re-reference: sub', int2str(a), '/', int2str(length(subjects)), '   ***'))
    
end


%% Define the horizontal and vertical eye electrodes

for b = 1:length(subjects)
    
    cfg                 = [];
    cfg.dataset         = fullfile(subDirs, subjects{b});
    cfg.channel         = {'LEOG', 'REOG'};
    cfg.reref           = 'yes';
    cfg.refchannel      = 'LEOG';
    data_eogh{b}        = ft_preprocessing(cfg);

    data_eogh{b}.label{2}  = 'EOGH';

    cfg                 = [];
    cfg.channel         = 'EOGH';
    cfg.lpfilter        = 'no';
    cfg.dftfilter       = 'no';
    data_eogh{b}        = ft_preprocessing(cfg, data_eogh{b});

    cfg                 = [];
    cfg.dataset         = fullfile(subDirs, subjects{b});
    cfg.channel         = {'LBEOG', 'LTEOG'};
    cfg.reref           = 'yes';
    cfg.refchannel      = 'LBEOG';
    data_eogv{b}        = ft_preprocessing(cfg);

    data_eogv{b}.label{2}  = 'EOGV';

    cfg                 = [];
    cfg.channel         = 'EOGV';
    cfg.lpfilter        = 'no';
    cfg.dftfilter       = 'no';
    data_eogv{b}        = ft_preprocessing(cfg, data_eogv{b});
    
    disp(strcat('***   Define EOG: sub', int2str(b), '/', int2str(length(subjects)), '   ***'))

end


%% Combine the eog data with the rest of the data

for c = 1:length(subjects)
    
    cfg                 = [];
    data_all{c}         = ft_appenddata(cfg, data_eeg{c}, data_eogh{c}, data_eogv{c});
    
    % Strip out the 'C' to make the used layout comparable to the template layout
    for stripRun = 1:length(data_all{c}.label)

        if contains(data_all{c}.label{stripRun}, 'C')
            data_all{c}.label{stripRun} = data_all{c}.label{stripRun}(2:length(data_all{c}.label{stripRun}));
        end

    end
    
    disp(strcat('***   Append Data: sub', int2str(c), '/', int2str(length(subjects)), '   ***'))

end

keep data_all subDirs subjects subjectFolder outFiles


%% Define congruency trials, save data per subject

for d = 1:length(subjects)
    
    % Select critical window
    cfg                     = [];
    cfg.dataset             = fullfile(subDirs, subjects{d});
    cfg.trialdef.eventtype  = 'Stimulus';
    cfg.trialdef.eventvalue = {'S  1' 'S  7'  'S  8' 'S  9' 'S 27' 'S 28' 'S 29'}; %trigger codes congruent
    cfg.trialdef.prestim    = 2.5; % take 1000ms before stimulus onset
    cfg.trialdef.poststim   = 2.5; % take 2000ms after stimulus onset
    cfg                     = ft_definetrial(cfg);

    data_preproc            = ft_redefinetrial(cfg, data_all{d});
    
    % Redefine trial identity which allows identification of trial position
    countTR = 1;
    for trname = 1:2:length(data_preproc.trialinfo)
        
        new_basename                        = strcat(num2str(countTR), '1');
        
        critname                            = num2str(data_preproc.trialinfo(trname+1));
        new_critname                        = strcat(num2str(countTR), critname);
        
        data_preproc.trialinfo(trname + 1)  = str2double(new_critname);
        data_preproc.trialinfo(trname)      = str2double(new_basename);
        
        countTR = countTR + 1;
      
    end
    
    mkdir(fullfile(outFiles, subjectFolder{d}))
    disp('Saving data...')
    save(fullfile(outFiles, subjectFolder{d}, 'data_preproc.mat'), 'data_preproc')
    
    clear data_preproc cfg data_time data_concat time_struc trial_struc
    
    disp(strcat('***   Define Trial: sub', int2str(d), '/', int2str(length(subjects)), '   ***'))
    
end


% *********************************************************************** %
%                                                                         %
% *********************************************************************** %
%% Define congruency trials, save data per subject
% Combine baseline and critical epochs into one.

for d = 1:length(subjects)
    
    % Select critical window
    cfg                     = [];
    cfg.dataset             = fullfile(subDirs, subjects{d});
    cfg.trialdef.eventtype  = 'Stimulus';
    cfg.trialdef.eventvalue = {'S  7'  'S  8' 'S  9' 'S 27' 'S 28' 'S 29'}; %trigger codes congruent
    cfg.trialdef.prestim    = 2.5; % take 1000ms before stimulus onset
    cfg.trialdef.poststim   = 2.0; % take 2000ms after stimulus onset
    cfg_crit                = ft_definetrial(cfg);
    
    % Select baseline
    cfg.trialdef.eventvalue = {'S  1'};
    cfg.trialdef.prestim    = 1.0; % take 1000ms before stimulus onset
    cfg.trialdef.poststim   = 2.5; % take 1000ms after stimulus onset
    cfg_base                = ft_definetrial(cfg);
    
    data_crit               = ft_redefinetrial(cfg_crit, data_all{d});
    data_base               = ft_redefinetrial(cfg_base, data_all{d});
    
    % Redefine trial identity which allows identification of trial position
    for trname = 1:length(data_base.trialinfo)
        
        critname = num2str(data_crit.trialinfo(trname));
        
        new_critname = strcat(num2str(trname), critname);
        
        data_crit.trialinfo(trname) = str2double(new_critname);
      
    end
    
    % Manually append data such that each trial includes a baseline period
    % Prepare data time structure that holds baseline and critical
    % time-lines
    data_time   = zeros(1, length(data_crit.time{1}) + length(data_base.time{1}));
    
    time_begin  = data_base.time{1}(1) + data_crit.time{1}(1) - cfg.trialdef.poststim;
    time_end    = data_crit.time{1}(length(data_crit.time{1}));
    time_step   = data_base.time{1}(2) - data_base.time{1}(1);
    
    data_time(1, :) = [time_begin:time_step:time_end + time_step];
    
    % Sort trial data based on new structure
    for trl = 1:length(data_crit.trial)
        
        data_concat = zeros(length(data_crit.label), length(data_time));
        data_concat(:, 1:length(data_base.time{trl}))       = data_base.trial{trl};
        data_concat(:, (length(data_base.time{trl})+1):end) = data_crit.trial{trl};
        
        time_struc{1, trl}  = data_time;
        trial_struc{1, trl} = data_concat;
        
    end
    
    % Calculate how many samples have been taken in total
    base_sample = (data_base.sampleinfo(1,2)-data_base.sampleinfo(1,1));
    crit_sample = (data_crit.sampleinfo(1,2)-data_crit.sampleinfo(1,1));
    total_sample = base_sample + crit_sample;
    
    % Create new sample info structure that matches length of new epoch
    my_sampleinfo = ones(length(data_crit.sampleinfo), 2);
    for sam = 1:length(data_crit.sampleinfo)
        if sam == 1
            my_sampleinfo(sam, 2) = my_sampleinfo(sam, 1) + total_sample;
        else
            my_sampleinfo(sam, 1) = my_sampleinfo(sam - 1, 2) + 500;
            my_sampleinfo(sam, 2) = my_sampleinfo(sam, 1) + total_sample;
        end
    end
    
    % Apply new time and trial data to preprocessed structure
    % New structure now has a baseline period: -3.0s to -1.0s
    % New structure now has a critical period: -1.0s to 2.0s
    data_preproc            = data_crit;
    data_preproc.trial      = trial_struc;
    data_preproc.time       = time_struc;
    data_preproc.sampleinfo = my_sampleinfo;
    trl2                    = data_preproc.cfg.trl(:, 3:end);
    data_preproc.cfg.trl    = [my_sampleinfo, trl2];
    data_preproc.cfg.trialdef.prestim = 6.0;
    
    cfg = [];
     cfg.eventtype   = {'Stimulus'};
   cfg.eventvalue  = {'S  7'  'S  8' 'S  9' 'S 27' 'S 28' 'S 29'};
    testnew= ft_recodeevent(cfg, data_preproc);
    
    mkdir(fullfile(outFiles, subjectFolder{d}))
    disp('Saving data...')
    save(fullfile(outFiles, subjectFolder{d}, 'data_preproc.mat'), 'data_preproc')
    
    clear data_preproc cfg data_time data_concat time_struc trial_struc
    
    disp(strcat('***   Define Trial: sub', int2str(d), '/', int2str(length(subjects)), '   ***'))
    
end

