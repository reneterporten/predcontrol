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


%% Statistics on erf data using T-Test

cfg                         = [];
cfg.method                  = 'template'; 
cfg.template                = 'mpi_59_channels_neighb.mat';               
cfg.layout                  = 'mpi_customized_acticap64.mat';                     
cfg.feedback                = 'yes';                            
neighbours                  = ft_prepare_neighbours(cfg, grandAvg_congr); 

cfg = [];
cfg.channel                 = {'all'};
cfg.neighbours              = neighbours;
cfg.latency                 = [0.250 0.600];
cfg.method                  = 'montecarlo';
cfg.statistic               = 'depsamplesT';
cfg.correctm                = 'cluster';
cfg.avgovertime             = 'yes';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.minnbchan               = 2;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 5000;

subj = length(all_ERP_congr);
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end 
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;


cfg.design = design;
cfg.uvar  = 1;
cfg.ivar  = 2;

stat_con_vs_incon = ft_timelockstatistics(cfg, all_ERP_congr{:}, all_ERP_incongr{:});  


%% Statistics on ERP data using F-Test - Congruent Task Statistics

cfg                         = [];
cfg.method                  = 'template'; 
cfg.template                = 'mpi_59_channels_neighb.mat';               
cfg.layout                  = 'mpi_customized_acticap64.mat';                     
cfg.feedback                = 'yes';                            
neighbours                  = ft_prepare_neighbours(cfg, conList_grandAvg_congr_high);

cfg = [];
cfg.channel                 = {'all'};
cfg.neighbours              = neighbours;
cfg.latency                 = [0.250 0.600];
cfg.method                  = 'montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.avgovertime             = 'no';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.minnbchan               = 2;
cfg.tail                    = 1;
cfg.clustertail             = 1;
cfg.alpha                   = 0.05;
cfg.numrandomization        = 5000;

subj = length(conList_ERP_congr_high);
design = zeros(2,3*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
for i = 1:subj
    design(1,2*subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;
design(2,2*subj+1:3*subj) = 3;

cfg.design = design;
cfg.uvar  = 1;
cfg.ivar  = 2;

 
stat_conList = ft_timelockstatistics(cfg, conList_ERP_congr_high{:}, conList_ERP_congr_med{:}, conList_ERP_congr_low{:}); 
stat_inconList = ft_timelockstatistics(cfg, incList_ERP_incongr_high{:}, incList_ERP_incongr_med{:}, incList_ERP_incongr_low{:}); 


%% Statistics on erp data using T-Test - Post-hoc contrasts

cfg                         = [];
cfg.method                  = 'template'; 
cfg.template                = 'mpi_59_channels_neighb.mat';               
cfg.layout                  = 'mpi_customized_acticap64.mat';                     
cfg.feedback                = 'yes';                            
neighbours                  = ft_prepare_neighbours(cfg, conList_grandAvg_congr_high); 

cfg = [];
cfg.channel                 = {'all'};
cfg.neighbours              = neighbours;
cfg.latency                 = [0.250 0.600];
cfg.method                  = 'montecarlo';
cfg.statistic               = 'depsamplesT';
cfg.correctm                = 'cluster';
cfg.avgovertime             = 'yes';
cfg.avgoverchan             = 'no';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.minnbchan               = 2;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 5000;

subj = length(conList_ERP_congr_high);
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end 
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;


cfg.design = design;
cfg.uvar  = 1;
cfg.ivar  = 2;

stat_HvsL = ft_timelockstatistics(cfg, conList_ERP_congr_high{:}, conList_ERP_congr_low{:}); 
stat_HvsM = ft_timelockstatistics(cfg, conList_ERP_congr_high{:}, conList_ERP_congr_med{:}); 
stat_MvsL = ft_timelockstatistics(cfg, conList_ERP_congr_med{:}, conList_ERP_congr_low{:}); 


%%

cfg = [];
cfg.highlightsymbolseries = ['*','*','.','.','.'];
cfg.layout = 'mpi_customized_acticap64.mat';
cfg.contournum = 0;
cfg.markersymbol = '.';
cfg.alpha = 0.05;
cfg.parameter='stat';
cfg.zlim = [-5 5];

ft_clusterplot(cfg,stat_conList);