%% Add Fieldtrip functions

addpath '/home/renter/EEG Analysis/fieldtrip-20181209/fieldtrip-20181209/'
addpath '/home/renter/EEG Analysis/'
ft_defaults


%% Add default path to pre-processed EEG data

% Subject 8 & 25 is excluded
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


%% Calculate Event-Related Potentials - Irrespective of Task Statistics

for erp = 1:length(subjectFolder)
    
    disp('Loading clean data...')
    load(fullfile(outFiles, subjectFolder{erp}, 'data_clean.mat'))

    cfg                         = [];
    cfg.demean                  = 'yes';
    cfg.baselinewindow          = [-0.3 0];
    cfg.lpfilter                = 'yes';        % apply lowpass filter
    cfg.lpfreq                  = 10;           % lowpass at 10 Hz.
    data_clean_ERP              = ft_preprocessing(cfg, data_clean);
    
    % Define congruent trials
    
    cfg             = [];
    cfg.trials      = find(ismember(data_clean_ERP.trialinfo(:,1), [7, 8, 9]) == 1);
    data_congr      = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials      = find(ismember(data_clean_ERP.trialinfo(:,1), 7) == 1);
    data_congr_high = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials      = find(ismember(data_clean_ERP.trialinfo(:,1), 8) == 1);
    data_congr_med  = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials      = find(ismember(data_clean_ERP.trialinfo(:,1), 9) == 1);
    data_congr_low  = ft_redefinetrial(cfg, data_clean_ERP);
    
    % Define incognruent trials
    
    cfg.trials          = find(ismember(data_clean_ERP.trialinfo(:,1), [27, 28, 29]) == 1);
    data_incongr        = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials          = find(ismember(data_clean_ERP.trialinfo(:,1), 27) == 1);
    data_incongr_high   = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials          = find(ismember(data_clean_ERP.trialinfo(:,1), 28) == 1);
    data_incongr_med    = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials          = find(ismember(data_clean_ERP.trialinfo(:,1), 29) == 1);
    data_incongr_low    = ft_redefinetrial(cfg, data_clean_ERP);
    

    % Calculate ERP
    cfg             = [];
    cfg.channel     = {'all' '-EOGH' '-EOGV' '-RM' '-LM'};
    cfg.trials      = 'all';
    ERP_congr       = ft_timelockanalysis(cfg, data_congr );
    ERP_congr_high  = ft_timelockanalysis(cfg, data_congr_high );
    ERP_congr_med   = ft_timelockanalysis(cfg, data_congr_med );
    ERP_congr_low   = ft_timelockanalysis(cfg, data_congr_low );
    
    ERP_incongr         = ft_timelockanalysis(cfg, data_incongr );
    ERP_incongr_high    = ft_timelockanalysis(cfg, data_incongr_high );
    ERP_incongr_med     = ft_timelockanalysis(cfg, data_incongr_med );
    ERP_incongr_low     = ft_timelockanalysis(cfg, data_incongr_low );
    
    disp('Saving congruent data...')
    save(fullfile(outFiles, subjectFolder{erp}, 'ERP_congr.mat'), 'ERP_congr')
    save(fullfile(outFiles, subjectFolder{erp}, 'ERP_congr_high.mat'), 'ERP_congr_high')
    save(fullfile(outFiles, subjectFolder{erp}, 'ERP_congr_med.mat'), 'ERP_congr_med')
    save(fullfile(outFiles, subjectFolder{erp}, 'ERP_congr_low.mat'), 'ERP_congr_low')
    
    disp('Saving incongruent data...')
    save(fullfile(outFiles, subjectFolder{erp}, 'ERP_incongr.mat'), 'ERP_incongr')
    save(fullfile(outFiles, subjectFolder{erp}, 'ERP_incongr_high.mat'), 'ERP_incongr_high')
    save(fullfile(outFiles, subjectFolder{erp}, 'ERP_incongr_med.mat'), 'ERP_incongr_med')
    save(fullfile(outFiles, subjectFolder{erp}, 'ERP_incongr_low.mat'), 'ERP_incongr_low')
    
    disp(strcat('***   ERP timelock: sub', int2str(erp), '/', int2str(length(subjectFolder)), '   ***'))
    
    keep erp outFiles subjectFolder listCongruency
    
end


%% Calculate Event-Related Potentials - Per Task Statistik Group

for erp = 1:length(subjectFolder)
    
    disp('Loading clean data...')
    load(fullfile(outFiles, subjectFolder{erp}, 'data_clean.mat'))

    cfg                         = [];
    cfg.demean                  = 'yes';
    cfg.baselinewindow          = [-0.3 0];
    cfg.lpfilter                = 'yes';        % apply lowpass filter
    cfg.lpfreq                  = 10;           % lowpass at 10 Hz.
    data_clean_ERP              = ft_preprocessing(cfg, data_clean);
    
    % Define congruent trials
    
    cfg             = [];
    cfg.trials      = find(ismember(data_clean_ERP.trialinfo(:,1), [7, 8, 9]) == 1);
    data_congr      = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials      = find(ismember(data_clean_ERP.trialinfo(:,1), 7) == 1);
    data_congr_high = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials      = find(ismember(data_clean_ERP.trialinfo(:,1), 8) == 1);
    data_congr_med  = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials      = find(ismember(data_clean_ERP.trialinfo(:,1), 9) == 1);
    data_congr_low  = ft_redefinetrial(cfg, data_clean_ERP);
    
    % Define incognruent trials
    
    cfg.trials          = find(ismember(data_clean_ERP.trialinfo(:,1), [27, 28, 29]) == 1);
    data_incongr        = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials          = find(ismember(data_clean_ERP.trialinfo(:,1), 27) == 1);
    data_incongr_high   = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials          = find(ismember(data_clean_ERP.trialinfo(:,1), 28) == 1);
    data_incongr_med    = ft_redefinetrial(cfg, data_clean_ERP);
    
    cfg.trials          = find(ismember(data_clean_ERP.trialinfo(:,1), 29) == 1);
    data_incongr_low    = ft_redefinetrial(cfg, data_clean_ERP);  

    % Calculate ERP
    cfg             = [];
    cfg.channel     = {'all' '-EOGH' '-EOGV' '-RM' '-LM'};
    cfg.trials      = 'all';
    ERP_congr       = ft_timelockanalysis(cfg, data_congr );
    ERP_congr_high  = ft_timelockanalysis(cfg, data_congr_high );
    ERP_congr_med   = ft_timelockanalysis(cfg, data_congr_med );
    ERP_congr_low   = ft_timelockanalysis(cfg, data_congr_low );
    
    ERP_incongr         = ft_timelockanalysis(cfg, data_incongr );
    ERP_incongr_high    = ft_timelockanalysis(cfg, data_incongr_high );
    ERP_incongr_med     = ft_timelockanalysis(cfg, data_incongr_med );
    ERP_incongr_low     = ft_timelockanalysis(cfg, data_incongr_low );
    
    % Save according to list
    if listCongruency{erp} == 'a'
        
        disp('Saving congruent data...')
        save(fullfile(outFiles, subjectFolder{erp}, 'incList_ERP_congr.mat'), 'ERP_congr')
        save(fullfile(outFiles, subjectFolder{erp}, 'incList_ERP_congr_high.mat'), 'ERP_congr_high')
        save(fullfile(outFiles, subjectFolder{erp}, 'incList_ERP_congr_med.mat'), 'ERP_congr_med')
        save(fullfile(outFiles, subjectFolder{erp}, 'incList_ERP_congr_low.mat'), 'ERP_congr_low')

        disp('Saving incongruent data...')
        save(fullfile(outFiles, subjectFolder{erp}, 'incList_ERP_incongr.mat'), 'ERP_incongr')
        save(fullfile(outFiles, subjectFolder{erp}, 'incList_ERP_incongr_high.mat'), 'ERP_incongr_high')
        save(fullfile(outFiles, subjectFolder{erp}, 'incList_ERP_incongr_med.mat'), 'ERP_incongr_med')
        save(fullfile(outFiles, subjectFolder{erp}, 'incList_ERP_incongr_low.mat'), 'ERP_incongr_low')
    
    elseif listCongruency{erp} == 'b'   
             
        disp('Saving congruent data...')
        save(fullfile(outFiles, subjectFolder{erp}, 'conList_ERP_congr.mat'), 'ERP_congr')
        save(fullfile(outFiles, subjectFolder{erp}, 'conList_ERP_congr_high.mat'), 'ERP_congr_high')
        save(fullfile(outFiles, subjectFolder{erp}, 'conList_ERP_congr_med.mat'), 'ERP_congr_med')
        save(fullfile(outFiles, subjectFolder{erp}, 'conList_ERP_congr_low.mat'), 'ERP_congr_low')

        disp('Saving incongruent data...')
        save(fullfile(outFiles, subjectFolder{erp}, 'conList_ERP_incongr.mat'), 'ERP_incongr')
        save(fullfile(outFiles, subjectFolder{erp}, 'conList_ERP_incongr_high.mat'), 'ERP_incongr_high')
        save(fullfile(outFiles, subjectFolder{erp}, 'conList_ERP_incongr_med.mat'), 'ERP_incongr_med')
        save(fullfile(outFiles, subjectFolder{erp}, 'conList_ERP_incongr_low.mat'), 'ERP_incongr_low')
     
    end
    
    disp(strcat('***   ERP timelock incl. task stats: sub', int2str(erp), '/', int2str(length(subjectFolder)), '   ***'))
    
    keep erp outFiles subjectFolder listCongruency
    
end


%% Load all data into structure - All constraints

for loading = 1:length(subjectFolder)

    load(fullfile(outFiles, subjectFolder{loading}, 'ERP_congr.mat'))
    load(fullfile(outFiles, subjectFolder{loading}, 'ERP_incongr.mat'))

    all_ERP_congr{loading}      = ERP_congr;
    all_ERP_incongr{loading}    = ERP_incongr;
    
    keep loading outFiles subjectFolder all_ERP_congr all_ERP_incongr listCongruency
        
    disp(strcat('***   Loaded: sub', int2str(loading), '/', int2str(length(subjectFolder)), '   ***'))
    
end

cfg                 = [];
cfg.parameter       = 'avg';
cfg.channel         = 'all';
cfg.method          = 'across';

grandAvg_congr      = ft_timelockgrandaverage(cfg, all_ERP_congr{:});
grandAvg_incongr    = ft_timelockgrandaverage(cfg, all_ERP_incongr{:});


%% Load all data into structure - Per constraint (Congruent only)

for loadcon = 1:length(subjectFolder)

    load(fullfile(outFiles, subjectFolder{loadcon}, 'ERP_congr_high.mat'))
    load(fullfile(outFiles, subjectFolder{loadcon}, 'ERP_congr_med.mat'))
    load(fullfile(outFiles, subjectFolder{loadcon}, 'ERP_congr_low.mat'))

    all_ERP_congr_high{loadcon}     = ERP_congr_high;
    all_ERP_congr_med{loadcon}      = ERP_congr_med;
    all_ERP_congr_low{loadcon}      = ERP_congr_low;

    keep loadcon outFiles subjectFolder listCongruency all_ERP_congr_high all_ERP_congr_med all_ERP_congr_low
        
    disp(strcat('***   Loaded: sub', int2str(loadcon), '/', int2str(length(subjectFolder)), '   ***'))
    
end

cfg                 = [];
cfg.parameter       = 'avg';
cfg.channel         = 'all';
cfg.method          = 'across';

grandAvg_congr_high     = ft_timelockgrandaverage(cfg, all_ERP_congr_high{:});
grandAvg_congr_med      = ft_timelockgrandaverage(cfg, all_ERP_congr_med{:});
grandAvg_congr_low      = ft_timelockgrandaverage(cfg, all_ERP_congr_low{:});


%% Load all data into structure - Per constraint (Incongruent only)

for loadincon = 1:length(subjectFolder)

    load(fullfile(outFiles, subjectFolder{loadincon}, 'ERP_incongr_high.mat'))
    load(fullfile(outFiles, subjectFolder{loadincon}, 'ERP_incongr_med.mat'))
    load(fullfile(outFiles, subjectFolder{loadincon}, 'ERP_incongr_low.mat'))

    all_ERP_incongr_high{loadincon}     = ERP_incongr_high;
    all_ERP_incongr_med{loadincon}      = ERP_incongr_med;
    all_ERP_incongr_low{loadincon}      = ERP_incongr_low;

    keep loadincon outFiles listCongruency subjectFolder all_ERP_incongr_high all_ERP_incongr_med all_ERP_incongr_low
        
    disp(strcat('***   Loaded: sub', int2str(loadincon), '/', int2str(length(subjectFolder)), '   ***'))
    
end

cfg                 = [];
cfg.parameter       = 'avg';
cfg.channel         = 'all';
cfg.method          = 'across';

grandAvg_incongr_high     = ft_timelockgrandaverage(cfg, all_ERP_incongr_high{:});
grandAvg_incongr_med      = ft_timelockgrandaverage(cfg, all_ERP_incongr_med{:});
grandAvg_incongr_low      = ft_timelockgrandaverage(cfg, all_ERP_incongr_low{:});


%% Load all data into structure - Per constraint (Congruent only - Congruent List)

countA = 1;
countB = 1;
for loadcon = 1:length(subjectFolder)
    
    if listCongruency{loadcon} == 'a'
        
        load(fullfile(outFiles, subjectFolder{loadcon}, 'incList_ERP_incongr_high.mat'))
        load(fullfile(outFiles, subjectFolder{loadcon}, 'incList_ERP_incongr_med.mat'))
        load(fullfile(outFiles, subjectFolder{loadcon}, 'incList_ERP_incongr_low.mat'))

        incList_ERP_incongr_high{countA}     = ERP_incongr_high;
        incList_ERP_incongr_med{countA}      = ERP_incongr_med;
        incList_ERP_incongr_low{countA}      = ERP_incongr_low;
        
        countA = countA + 1;
    
    elseif listCongruency{loadcon} == 'b'
        
        load(fullfile(outFiles, subjectFolder{loadcon}, 'conList_ERP_congr_high.mat'))
        load(fullfile(outFiles, subjectFolder{loadcon}, 'conList_ERP_congr_med.mat'))
        load(fullfile(outFiles, subjectFolder{loadcon}, 'conList_ERP_congr_low.mat'))

        conList_ERP_congr_high{countB}     = ERP_congr_high;
        conList_ERP_congr_med{countB}      = ERP_congr_med;
        conList_ERP_congr_low{countB}      = ERP_congr_low;
        
        countB = countB + 1;
    
    end
    
    keep loadcon outFiles subjectFolder listCongruency countA countB incList_ERP_incongr_high incList_ERP_incongr_med incList_ERP_incongr_low conList_ERP_congr_high conList_ERP_congr_med conList_ERP_congr_low
        
    disp(strcat('***   Loaded: sub', int2str(loadcon), '/', int2str(length(subjectFolder)), '   ***'))
    
end

cfg                 = [];
cfg.parameter       = 'avg';
cfg.channel         = 'all';
cfg.method          = 'across';

incList_grandAvg_incongr_high     = ft_timelockgrandaverage(cfg, incList_ERP_incongr_high{:});
incList_grandAvg_incongr_med      = ft_timelockgrandaverage(cfg, incList_ERP_incongr_med{:});
incList_grandAvg_incongr_low      = ft_timelockgrandaverage(cfg, incList_ERP_incongr_low{:});

conList_grandAvg_congr_high     = ft_timelockgrandaverage(cfg, conList_ERP_congr_high{:});
conList_grandAvg_congr_med      = ft_timelockgrandaverage(cfg, conList_ERP_congr_med{:});
conList_grandAvg_congr_low      = ft_timelockgrandaverage(cfg, conList_ERP_congr_low{:});


%% Multiplot results

cfg             = [];
cfg.layout      = 'mpi_customized_acticap64.mat';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
cfg.ylim        = [-5 5];
%ft_multiplotER(cfg,grandAvg_congr, grandAvg_incongr)
ft_multiplotER(cfg, conList_grandAvg_congr_high, conList_grandAvg_congr_med, conList_grandAvg_congr_low)

