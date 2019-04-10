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
            'sub33_eeg.vhdr','sub34_eeg.vhdr','sub35_eeg.vhdr','sub36_eeg.vhdr',...
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
    
    cfg                     = [];
    cfg.dataset             = fullfile(subDirs, subjects{d});
    cfg.trialdef.eventtype  = 'Stimulus';
    cfg.trialdef.eventvalue = {'S  7'  'S  8'  'S  9'}; %trigger codes congruent
    cfg.trialdef.prestim    = 1.5; % take 1500ms before stimulus onset
    cfg.trialdef.poststim   = 1.5; % take 1500ms after stimulus onset
    cfg_congr               = ft_definetrial(cfg); 

    cfg.trialdef.eventvalue = {'S 27'  'S 28'  'S 29'}; %trigger codes incongruent
    cfg_inc                 = ft_definetrial(cfg); 

    data_congr              = ft_redefinetrial(cfg_congr, data_all{d});
    data_inc                = ft_redefinetrial(cfg_inc, data_all{d});
    
    mkdir(fullfile(outFiles, subjectFolder{d}))
    disp('Saving congr...')
    save(fullfile(outFiles, subjectFolder{d}, 'preproc_congr.mat'), 'data_congr')
    disp('Saving inc...')
    save(fullfile(outFiles, subjectFolder{d}, 'preproc_inc.mat'), 'data_inc')
    
    clear data_congr data_inc cfg_congr cfg_inc
    
    disp(strcat('***   Define Trial: sub', int2str(d), '/', int2str(length(subjects)), '   ***'))
    
end

