%% Add Fieldtrip functions

addpath '/home/renter/EEG Analysis/fieldtrip-20181209/fieldtrip-20181209/'
addpath '/home/renter/EEG Analysis/'
ft_defaults


%% Add default path to pre-processed EEG data

% Subject 25 is excluded
subjectFolder = {'sub1','sub2','sub3','sub4',...
                'sub5','sub6','sub7','sub8',...
                'sub9','sub10','sub11','sub12',...
                'sub13','sub14','sub15','sub16',...
                'sub17','sub18','sub19','sub20',...
                'sub21','sub22','sub23','sub24',...
                'sub26','sub27','sub28',...
                'sub29','sub30','sub31','sub32',...
                'sub33','sub34','sub35','sub36',...
                'sub37','sub38','sub39','sub40'};
            
outFiles = '/home/renter/EEG Analysis/Results/';


%% Check the validity of the data: are all lists included?

% Postition of letter in list corresponds to subject
% Inc lists:    A, C, E -> a
% Congr lists:  B, D, F -> b

listCongruency = {'b' 'b' 'a' 'a' 'a' 'b' 'b' 'b' 'b' 'a' 'a' 'b' 'b' 'b'...
                'a' 'b' 'a' 'a' 'b' 'a' 'a' 'b' 'b' 'a' 'a' 'b' 'b'...
                'b' 'b' 'a' 'a' 'a' 'b' 'a' 'a' 'a' 'a' 'b' 'b'};
            
% If list == a then there should be more inc. items
% If list == b then there should be more congr. items

for a = 1:length(subjectFolder)
    
    disp('Loading preprocessed data...')
    load(fullfile(outFiles, subjectFolder{a}, 'data_preproc.mat'))
    
    cfg         = [];
    cfg.trials  = data_preproc.trialinfo <= 9;
    data_congr  = ft_redefinetrial(cfg, data_preproc);
    
    cfg         = [];
    cfg.trials  = data_preproc.trialinfo >= 27;
    data_inc    = ft_redefinetrial(cfg, data_preproc);

    
    % Create list with trial numbers per subject
    % trialList{subj}(1) = Congruent
    % trialList{subj}(2) = Incongruent
    trialList{a} = [length(data_congr.trial), length(data_inc.trial)];
    
    keep trialList listCongruency outFiles subjectFolder a
    
    disp(strcat('***   Trial List: sub', int2str(a), '/', int2str(length(subjectFolder)), '   ***'))
    
end

% If the trial list satisfies the condition above then checkList returns 1
for check = 1:length(trialList)
   
    if listCongruency{check} == 'a' &&  trialList{check}(1) < trialList{check}(2)
        
        checkList{check} = 1;
        
    elseif listCongruency{check} == 'b' &&  trialList{check}(1) > trialList{check}(2)
        
        checkList{check} = 1;
    
    else
        
        checkList{check} = 0;
        
    end
    
end

% The structure checkList returns only 1's, indicating conditional
% satisfaction.


%% Starting artifact rejection procedure
% Summary method first to terminate spike artifacts

for b = 1:length(subjectFolder)
    
    disp('Loading data...')
    load(fullfile(outFiles, subjectFolder{b}, 'data_preproc.mat'))
    
    % Counting trials before rejections
    trials          = length(data_preproc.trialinfo);
    
    cfg             = [];
    cfg.method      = 'summary';
    cfg.layout      = 'mpi_customized_acticap64.mat';
    data_rough      = ft_rejectvisual(cfg,data_preproc);
    
    % Counting rejected trials
    trials_rej      = trials - length(data_rough.trial);
    
    disp('Saving data...')
    save(fullfile(outFiles, subjectFolder{b}, 'data_rough.mat'), 'data_rough')
    disp('Saving trials rejected...')
    save(fullfile(outFiles, subjectFolder{b}, 'trials_rejected.mat'), 'trials_rej')
    
    clear data_rough trials_rej
    
    disp(strcat('***   Rough Rejection: sub', int2str(b), '/', int2str(length(subjectFolder)), '   ***'))

end


%% ICA - Identifying and saving components that relate to eye-heart artifacts

for sub = 1:length(subjectFolder)
    
    disp('Loading rough data...')
    load(fullfile(outFiles, subjectFolder{sub}, 'data_rough.mat'))

    cfg             = [];
    cfg.channel     = rt_channelselect(subjectFolder, sub);
    cfg.method      = 'fastica'; % this is the default and uses the implementation from EEGLAB

    comp            = ft_componentanalysis(cfg, data_rough);

    cfg             = [];
    cfg.layout      = 'mpi_customized_acticap64.mat'; % specify the layout file that should be used for plotting
    cfg.viewmode    = 'component';
    cfg.channel     = 1:10;
    cfg.compscale   = 'local';
    waitfor(ft_databrowser(cfg, comp));

    ind_comp        = rt_collectcomps(sub, comp);
    
    disp('Saving data...')
    save(fullfile(outFiles, subjectFolder{sub}, 'comp.mat'), 'comp')
    save(fullfile(outFiles, subjectFolder{sub}, 'ind_comp.mat'), 'ind_comp')
    
    keep sub outFiles subjectFolder listCongruency
    
    disp(strcat('***   Rough Rejection: sub', int2str(sub), '/', int2str(length(subjectFolder)), '   ***'))
    
end


%% Reject components previously identified

for rej = 1:length(subjectFolder)
    
    load(fullfile(outFiles, subjectFolder{rej}, 'data_rough.mat'))
    load(fullfile(outFiles, subjectFolder{rej}, 'comp.mat'))
    load(fullfile(outFiles, subjectFolder{rej}, 'ind_comp.mat'))

    cfg             = [];
    cfg.keepchannel = 'yes';
    cfg.keeptrials  = 'yes';
    cfg.component   = ind_comp;
    data_ica        = ft_rejectcomponent(cfg, comp, data_rough);
    
    disp('Saving...')
    save(fullfile(outFiles, subjectFolder{rej}, 'data_ica.mat'), 'data_ica')
    
    disp(strcat('***   Comp Rejection: sub', int2str(rej), '/', int2str(length(subjectFolder)), '   ***'))
  
    keep rej outFiles subjectFolder listCongruency

end

%% Repairing channels
% For subjects: 8, 11, 30; channel: 3, 6, 11 respectively

for rep = 1:length(subjectFolder)
    
    load(fullfile(outFiles, subjectFolder{rep}, 'data_ica.mat'))
    %load('/home/renter/EEG Analysis/fieldtrip-20181209/fieldtrip-20181209/template/layout/mpi_customized_acticap64.mat')
    
    %data_rough.pos = lay.pos;
    
    cfg_prepNeighbours          = [];
    cfg_prepNeighbours.layout   = 'mpi_customized_acticap64.mat'; %reads in 64 channel layout but notices only 32 are present
    cfg_prepNeighbours.template = 'mpi_59_neighb.mat';
    cfg_prepNeighbours.method   = 'triangulation';
    cfg_prepNeighbours.feedback = 'yes'; %change to 'yes' if you want to verify your layout is correct!
    
    neighbours                  = ft_prepare_neighbours(cfg_prepNeighbours, data_ica);

    cfg = [];
    if strcmp(subjectFolder{rep}, 'sub8')
        cfg.badchannel = {'3'};
    elseif strcmp(subjectFolder{rep}, 'sub11')
        cfg.badchannel = {'6'};
    elseif strcmp(subjectFolder{rep}, 'sub30')
        cfg.badchannel = {'11'};
    else
        cfg.badchannel = {};
    end
    
    
    cfg.method         = 'average';
    cfg.neighbours     = neighbours;
    %cfg.layout = 'mpi_customized_acticap64.mat';
    cfg.elecfile = 'customMPI_elec.txt';

    data_rep           = ft_channelrepair(cfg, data_ica);
    
    disp('Saving...')
    save(fullfile(outFiles, subjectFolder{rep}, 'data_rep.mat'), 'data_rep')
    
    disp(strcat('***   Channel repair: sub', int2str(rep), '/', int2str(length(subjectFolder)), '   ***'))

    keep rep outFiles subjectFolder listCongruency
    
end

close all

%% Trial based rough artifact rejection by visual inspection

for trrej = 1:length(subjectFolder)
    
    load(fullfile(outFiles, subjectFolder{trrej}, 'data_rep.mat'))
    
    % Only do rough rejection on critical time window
    cfg                 = [];
    cfg.method          = 'summary';
    cfg.layout          = 'mpi_customized_acticap64.mat';
    cfg.latency         = [-1.0 1.0];
    cfg.keeptrial       = 'nan';
    data_rough          = ft_rejectvisual(cfg,data_rep);
    
    % Reject previous identified artifacts from whole segment of data
    cfg                             = [];
    cfg.artfctdef.visual.artifact   = data_rough.cfg.artfctdef.summary.artifact;
    cfg.artfctdef.reject            = 'complete';
    data_roughclean                 = ft_rejectartifact(cfg, data_rep);
    
    disp('Saving...')
    save(fullfile(outFiles, subjectFolder{trrej}, 'data_roughclean.mat'), 'data_roughclean')
    
    disp(strcat('***   Artifact Rejection: sub', int2str(trrej), '/', int2str(length(subjectFolder)), '   ***'))

    keep trrej outFiles subjectFolder listCongruency
    
end


%% Per trial thorough artifact rejection
% Subject 8 remains noisy after artifact rejection. Subject 8 will get
% excluded from further analyses.

for clea = 1:length(subjectFolder)
    
    load(fullfile(outFiles, subjectFolder{clea}, 'data_roughclean.mat'))

    cfg             = [];
    cfg.channel     = 'all';
    cfg.viewmode    = 'vertical';
    cfg.xlim        = [-1.0 1.0];
    cfg.position    = [0 0 1400 1050];
    artf            = ft_databrowser(cfg,data_roughclean);

    cfg                             = [];
    cfg.artfctdef.visual.artifact   = artf.artfctdef.visual.artifact;
    cfg.artfctdef.reject            = 'complete';
    data_clean                      = ft_rejectartifact(cfg, data_roughclean);
    
    disp('Saving...')
    save(fullfile(outFiles, subjectFolder{clea}, 'data_clean.mat'), 'data_clean')
    
    disp(strcat('***   Final Data Cleaning: sub', int2str(clea), '/', int2str(length(subjectFolder)), '   ***'))

    keep clea outFiles subjectFolder listCongruency
    
end
