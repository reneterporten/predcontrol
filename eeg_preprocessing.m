

addpath '/home/renter/EEG Analysis/Raw EEG Data'
addpath '/home/renter/EEG Analysis/fieldtrip-20181209/fieldtrip-20181209/'
ft_defaults



%%

cfg                 = [];
cfg.dataset         = '/home/renter/EEG Analysis/Raw EEG Data/p2_eeg.vhdr';
cfg.reref           = 'yes';
cfg.channel         = 'all';
cfg.implicitref     = 'LM';
cfg.refchannel      = {'LM' 'RM'};
data_eeg            = ft_preprocessing(cfg);

cfg                 = [];
cfg.channel         = [1:60 65];                      % keep channels 1 to 61 and the newly inserted M1 channel
data_eeg            = ft_preprocessing(cfg, data_eeg);

%%
cfg                 = [];
cfg.dataset         = '/home/renter/EEG Analysis/Raw EEG Data/p2_eeg.vhdr';
cfg.channel         = {'LEOG', 'REOG'};
cfg.reref           = 'yes';
cfg.refchannel      = 'LEOG';
data_eogh           = ft_preprocessing(cfg);

data_eogh.label{2}  = 'EOGH';

cfg                 = [];
cfg.channel         = 'EOGH';
data_eogh           = ft_preprocessing(cfg, data_eogh);

%%

cfg                 = [];
cfg.dataset         = '/home/renter/EEG Analysis/Raw EEG Data/p2_eeg.vhdr';
cfg.channel         = {'LBEOG', 'LTEOG'};
cfg.reref           = 'yes';
cfg.refchannel      = 'LBEOG';
data_eogv           = ft_preprocessing(cfg);

data_eogv.label{2}  = 'EOGV';

cfg                 = [];
cfg.channel         = 'EOGV';
data_eogv           = ft_preprocessing(cfg, data_eogv);

%%

cfg                 = [];
data_all            = ft_appenddata(cfg, data_eeg, data_eogh, data_eogv);

% Strip out the 'C' to make the used layout comparable to the template layout
for i = 1:length(data_all.label)
    
    if contains(data_all.label{i}, 'C')
        data_all.label{i} = data_all.label{i}(2:length(data_all.label{i}));
    end
    
end

%%
cfg                     = [];
cfg.dataset             = '/home/renter/EEG Analysis/Raw EEG Data/p2_eeg.vhdr';
cfg.trialdef.eventtype  = 'Stimulus';
cfg.trialdef.eventvalue = {'S  7'  'S  8'  'S  9'}; %trigger codes for the six conditions
cfg.trialdef.prestim    = 1.5; % take 200ms before stimulus onset
cfg.trialdef.poststim   = 1.5; % take 1000ms after stimulus onset
cfg_congr               = ft_definetrial(cfg); 

cfg.trialdef.eventvalue = {'S 27'  'S 28'  'S 29'};
cfg_inc                 = ft_definetrial(cfg); 

data_congr              = ft_redefinetrial(cfg_congr, data_all);
data_inc                = ft_redefinetrial(cfg_inc, data_all);

%%
cfg                 = [];
cfg.method          = 'summary';
cfg.layout          = 'mpi_customized_acticap64.mat';
data_congr_clean    = ft_rejectvisual(cfg,data_congr);
data_inc_clean      = ft_rejectvisual(cfg,data_inc);

%%
% downsample the data to speed up the next step
cfg             = [];
cfg.resamplefs  = 300;
cfg.detrend     = 'no';
data_res            = ft_resampledata(cfg, data_inc_clean);

cfg             = [];
cfg.channel     = 'all';
cfg.method      = 'fastica'; % this is the default and uses the implementation from EEGLAB

comp            = ft_componentanalysis(cfg, data_res);

%%

cfg = [];
cfg.layout = 'mpi_customized_acticap64.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
cfg.channel = [1:10];
ft_databrowser(cfg, comp)

%%

cfg = [];
cfg.component = [1 2 5]; % to be removed component(s)
data_inc_clean = ft_rejectcomponent(cfg, comp, data_inc_clean);

%%
cfg                 = [];
cfg.method          = 'trial';
cfg.layout          = 'mpi_customized_acticap64.mat';
data_inc_clean      = ft_rejectvisual(cfg,data_inc_clean);

%% ERPs

cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.2 0];

% Fitering options
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 100;

data_congr_erp = ft_preprocessing(cfg, data_congr_clean);

%% Timelockanalysis and plotting
cfg = [];
cfg.trials = find(data_congr_erp.trialinfo==7);
high = ft_timelockanalysis(cfg, data_congr_erp);

cfg = [];
cfg.trials = find(data_congr_erp.trialinfo==8);
med = ft_timelockanalysis(cfg, data_congr_erp);

cfg = [];
cfg.trials = find(data_congr_erp.trialinfo==9);
low = ft_timelockanalysis(cfg, data_congr_erp);

cfg = [];
cfg.layout = 'mpi_customized_acticap64.mat';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, high, med, low)