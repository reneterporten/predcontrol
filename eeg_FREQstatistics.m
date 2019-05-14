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
    
            
%%

cfg                         = [];
cfg.method                  = 'template'; 
cfg.template                = 'mpi_59_channels_neighb.mat';               
cfg.layout                  = 'mpi_customized_acticap64.mat';                     
cfg.feedback                = 'yes';                            
neighbours                  = ft_prepare_neighbours(cfg, conList_freq_high{1});

cfg = [];
cfg.neighbours              = neighbours;
cfg.channel          = {'all'};
cfg.latency          = [-0.800 0.0];
cfg.frequency        = [8 20];
cfg.avgovertime      = 'no';
cfg.avgoverfreq      = 'no';
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;
cfg.numrandomization = 5000;

subj = length(conList_freq_high);
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

stat_alpha_con = ft_freqstatistics(cfg, conList_freq_high{:}, conList_freq_med{:}, conList_freq_low{:});
%stat_alpha_inc = ft_freqstatistics(cfg, incList_freq_high{:}, incList_freq_med{:}, incList_freq_low{:});


%% Visualize

cfg = [];
cfg.highlightsymbolseries = ['*','*','.','.','.'];
cfg.layout = 'mpi_customized_acticap64.mat';
cfg.contournum = 0;
cfg.markersymbol = '.';
cfg.alpha = 0.05;
cfg.parameter='stat';
cfg.zlim = [-5 5];

ft_clusterplot(cfg,stat_alpha_int);


%% Test interaction

% Descriptives and average over subjects

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


%%

cfg                         = [];
cfg.method                  = 'template'; 
cfg.template                = 'mpi_59_channels_neighb.mat';               
cfg.layout                  = 'mpi_customized_acticap64.mat';                     
cfg.feedback                = 'yes';                            
neighbours                  = ft_prepare_neighbours(cfg, conList_freq_MvsL{1});

cfg = [];
cfg.neighbours              = neighbours;
cfg.channel          = {'all'};
cfg.latency          = [-0.800 0.0];
cfg.frequency        = [8 12];
cfg.avgovertime      = 'no';
cfg.avgoverfreq      = 'yes';
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 5000;

subj = length(conList_freq_MvsL);
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

stat_alpha_int = ft_freqstatistics(cfg, conList_freq_MvsL{:}, inconList_freq_MvsL{:});


