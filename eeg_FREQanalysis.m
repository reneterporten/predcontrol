%% Add Fieldtrip functions

addpath '/home/renter/EEG Analysis/fieldtrip-20181209/fieldtrip-20181209/'
addpath '/home/renter/EEG Analysis/'
ft_defaults


%% Add default path to pre-processed EEG data

subjectFolder = {'sub1','sub2','sub3','sub4',...
                'sub5','sub6','sub8',...
                'sub9','sub10','sub11','sub12',...
                'sub13','sub14','sub15','sub16',...
                'sub17','sub18','sub19','sub20',...
                'sub21','sub22','sub23','sub24',...
                'sub26','sub27','sub28',...
                'sub29','sub30','sub31','sub32',...
                'sub33','sub34','sub35','sub36',...
                'sub37','sub38','sub39','sub40'};
            
outFiles = '/home/renter/EEG Analysis/Results/';

% Postition of letter in list corresponds to subject
% Inc lists:    A, C, E -> a
% Congr lists:  B, D, F -> b

listCongruency = {'b' 'b' 'a' 'a' 'a' 'b' 'b' 'b' 'a' 'a' 'b' 'b' 'b'...
                'a' 'b' 'a' 'a' 'b' 'a' 'a' 'b' 'b' 'a' 'a' 'b' 'b'...
                'b' 'b' 'a' 'a' 'a' 'b' 'a' 'a' 'a' 'a' 'b' 'b'};
  
            
%% Time-Frequency analysis

for freq = 1:length(subjectFolder)
    
    % Frequency analysis
    disp('Loading clean data...')
    load(fullfile(outFiles, subjectFolder{freq}, 'data_clean.mat'))

    cfg             = [];
    cfg.output      = 'pow';
    cfg.channel     = {'all' '-EOGH' '-EOGV' '-RM' '-LM'};
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'hanning';
    cfg.foi         = [2:2:40];
    cfg.toi         = [-2.0 : 0.05 : 2.0];
    cfg.t_ftimwin   = ones(length(cfg.foi),1).*0.5;
    cfg.keeptrials  = 'yes';

    % Initiate freq analysis
    cfg.trials      = find(ismember(data_clean.trialinfo(:,1), [7, 27]) == 1);
    freq_high       = ft_freqanalysis(cfg, data_clean);

    cfg.trials      = find(ismember(data_clean.trialinfo(:,1), [8, 28]) == 1);
    freq_med        = ft_freqanalysis(cfg, data_clean);

    cfg.trials      = find(ismember(data_clean.trialinfo(:,1), [9, 29]) == 1);
    freq_low        = ft_freqanalysis(cfg, data_clean);

    cfg             = [];
    cfg.parameter   = 'powspctrm';
    cfg.operation   = 'log10';
    freq_high       = ft_math(cfg, freq_high);
    freq_med        = ft_math(cfg, freq_med);
    freq_low        = ft_math(cfg, freq_low );
    
    % Save according to list
    if listCongruency{freq} == 'a'
        
        disp('Saving incongruent list data...')
        save(fullfile(outFiles, subjectFolder{freq}, 'incList_freq_high.mat'), 'freq_high')
        save(fullfile(outFiles, subjectFolder{freq}, 'incList_freq_med.mat'), 'freq_med')
        save(fullfile(outFiles, subjectFolder{freq}, 'incList_freq_low.mat'), 'freq_low')

    elseif listCongruency{freq} == 'b'   
             
        disp('Saving congruent list data...')
        save(fullfile(outFiles, subjectFolder{freq}, 'conList_freq_high.mat'), 'freq_high')
        save(fullfile(outFiles, subjectFolder{freq}, 'conList_freq_med.mat'), 'freq_med')
        save(fullfile(outFiles, subjectFolder{freq}, 'conList_freq_low.mat'), 'freq_low')
        
    end
    
    disp(strcat('***   FREQ incl. task stats: sub', int2str(freq), '/', int2str(length(subjectFolder)), '   ***'))
    
    keep freq outFiles subjectFolder listCongruency
    
end


%% Descriptives and average over subjects

countA = 1;
countB = 1;
for desc = 1:length(subjectFolder)
    
    if listCongruency{desc} == 'a'

        load(fullfile(outFiles, subjectFolder{desc}, 'incList_freq_high.mat'))
        load(fullfile(outFiles, subjectFolder{desc}, 'incList_freq_med.mat'))
        load(fullfile(outFiles, subjectFolder{desc}, 'incList_freq_low.mat'))
        
        cfg                         = [];
        cfg.channel                 = {'all'};
        desc_freq_high              = ft_freqdescriptives(cfg, freq_high);
        desc_freq_med               = ft_freqdescriptives(cfg, freq_med);
        desc_freq_low               = ft_freqdescriptives(cfg, freq_low);

        incList_freq_high{countA}   = desc_freq_high;
        incList_freq_med{countA}    = desc_freq_med;
        incList_freq_low{countA}    = desc_freq_low;

        countA = countA + 1;

    elseif listCongruency{desc} == 'b'

        load(fullfile(outFiles, subjectFolder{desc}, 'conList_freq_high.mat'))
        load(fullfile(outFiles, subjectFolder{desc}, 'conList_freq_med.mat'))
        load(fullfile(outFiles, subjectFolder{desc}, 'conList_freq_low.mat'))
        
        cfg                         = [];
        cfg.channel                 = {'all'};
        desc_freq_high              = ft_freqdescriptives(cfg, freq_high);
        desc_freq_med               = ft_freqdescriptives(cfg, freq_med);
        desc_freq_low               = ft_freqdescriptives(cfg, freq_low);

        conList_freq_high{countB}   = desc_freq_high;
        conList_freq_med{countB}    = desc_freq_med;
        conList_freq_low{countB}    = desc_freq_low;

        countB = countB + 1;

    end
    
    disp(strcat('***   Descriptives: sub', int2str(desc), '/', int2str(length(subjectFolder)), '   ***'))
    
    keep desc countA countB outFiles subjectFolder listCongruency incList_freq_high incList_freq_med incList_freq_low conList_freq_high conList_freq_med conList_freq_low
    
end


%% Calculate contrasts and receive grand average

cfg             = [];
cfg.parameter   = 'powspctrm';
cfg.operation   = 'subtract';

countA = 1;
countB = 1;
for contr = 1:length(subjectFolder)
    
    if listCongruency{contr} == 'a'
    
        inconList_freq_HvsL{countA} = ft_math(cfg, incList_freq_high{countA}, incList_freq_low{countA});
        inconList_freq_HvsM{countA} = ft_math(cfg, incList_freq_high{countA}, incList_freq_med{countA});
        inconList_freq_MvsL{countA} = ft_math(cfg, incList_freq_med{countA}, incList_freq_high{countA});

        countA = countA + 1;
    
    elseif listCongruency{contr} == 'b'
        
        conList_freq_HvsL{countB}   = ft_math(cfg, conList_freq_high{countB}, conList_freq_low{countB});
        conList_freq_HvsM{countB}   = ft_math(cfg, conList_freq_high{countB}, conList_freq_med{countB});
        conList_freq_MvsL{countB}   = ft_math(cfg, conList_freq_med{countB}, conList_freq_high{countB});

        countB = countB + 1;
    
    end
    
end

cfg                     = [];
inconList_freq_HvsL_avg = ft_freqgrandaverage(cfg, inconList_freq_HvsL{:});
inconList_freq_HvsM_avg = ft_freqgrandaverage(cfg, inconList_freq_HvsM{:});
inconList_freq_MvsL_avg = ft_freqgrandaverage(cfg, inconList_freq_MvsL{:});

conList_freq_HvsL_avg   = ft_freqgrandaverage(cfg, conList_freq_HvsL{:});
conList_freq_HvsM_avg   = ft_freqgrandaverage(cfg, conList_freq_HvsM{:});
conList_freq_MvsL_avg   = ft_freqgrandaverage(cfg, conList_freq_MvsL{:});

conList_freq_high_avg = ft_freqgrandaverage(cfg, conList_freq_high{:});
conList_freq_med_avg = ft_freqgrandaverage(cfg, conList_freq_med{:});
conList_freq_low_avg = ft_freqgrandaverage(cfg, conList_freq_low{:});

incList_freq_high_avg = ft_freqgrandaverage(cfg, incList_freq_high{:});
incList_freq_med_avg = ft_freqgrandaverage(cfg, incList_freq_med{:});
incList_freq_low_avg = ft_freqgrandaverage(cfg, incList_freq_low{:});


%% Plot results

% Multiplot TFR
cfg         = [];
cfg.xlim    = [-1.0 1.0];
%cfg.ylim    = [2 30];
cfg.layout  = 'mpi_customized_acticap64.mat';
figure; ft_multiplotTFR(cfg,conList_freq_MvsL_avg );

% Single Topoplot
cfg         = [];
cfg.xlim    = [-0.5 0];
cfg.ylim    = [8 12];
cfg.layout  = 'mpi_customized_acticap64.mat';
figure; ft_topoplotTFR(cfg,conList_freq_MvsL_avg); colorbar
ft_hastoolbox('brewermap', 1);
colormap(brewermap(64, 'RdBu'))


%% Plot power over time

cfg = [];
cfg.channel = 'all';
%cfg.avgoverchan = 'yes';
cfg.avgoverfreq = 'yes';
cfg.avgovertime = 'no';
cfg.frequency = [8 12];
cfg.latency = [-1.0 1.0];

alpha_conList_high = ft_selectdata(cfg, conList_freq_high_avg);
alpha_conList_med = ft_selectdata(cfg, conList_freq_med_avg);
alpha_conList_low = ft_selectdata(cfg, conList_freq_low_avg);

alpha_conList_HvsL = ft_selectdata(cfg, conList_freq_HvsL_avg);
alpha_conList_MvsL = ft_selectdata(cfg, conList_freq_MvsL_avg);
alpha_conList_HvsM = ft_selectdata(cfg, conList_freq_HvsM_avg);

alpha_incList_high = ft_selectdata(cfg, incList_freq_high_avg);
alpha_incList_med = ft_selectdata(cfg, incList_freq_med_avg);
alpha_incList_low = ft_selectdata(cfg, incList_freq_low_avg);

cfg = [];
cfg.baseline = [-1.2 -.800];
cfg.baselinetype = 'relchange';
cfg.parameter = 'powspctrm';
alpha_conList_high_base = ft_freqbaseline(cfg, alpha_conList_high);
alpha_conList_med_base = ft_freqbaseline(cfg, alpha_conList_med);
alpha_conList_low_base = ft_freqbaseline(cfg, alpha_conList_low);

cfg = [];
cfg.parameter = 'powspctrm';
cfg.xlim = [-1.0 1.0];
cfg.layout  = 'mpi_customized_acticap64.mat';
%ft_singleplotER(cfg, alpha_power_high, alpha_power_med, alpha_power_low)
ft_multiplotER(cfg, alpha_conList_high_base, alpha_conList_med_base, alpha_conList_low_base);
%ft_multiplotER(cfg, conList_freq_HvsL_avg , conList_freq_HvsM_avg , conList_freq_MvsL_avg );

