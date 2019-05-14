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
        cfg.keeptrials = 'yes';
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
        cfg.keeptrials = 'yes';
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


%% Extract average alpha power for interaction analysis

cfg             = [];
cfg.channel     = {'1', '2', '7', '24', '30', '33', '34', '58'};
cfg.avgoverchan = 'yes';
cfg.avgoverfreq = 'yes';
cfg.avgovertime = 'yes';
cfg.frequency   = [8 12];
cfg.latency     = [-0.5 0];

countA = 1;
countB = 1;
countSub = 1;
pow_data = [];
for allo = 1:length(subjectFolder)
    
    if listCongruency{allo} == 'a'
        
        data_incList_high   = ft_selectdata(cfg, inconList_freq_HvsL{countA});
        data_incList_med    = ft_selectdata(cfg, inconList_freq_HvsM{countA});
        data_incList_low    = ft_selectdata(cfg, inconList_freq_MvsL{countA});
        

        pow_data            = [pow_data; countSub, 1, 2, data_incList_high.powspctrm];

        pow_data            = [pow_data; countSub, 2, 2, data_incList_med.powspctrm];

        pow_data            = [pow_data; countSub, 3, 2, data_incList_low.powspctrm];        

        
        countA = countA + 1;
    
    elseif listCongruency{allo} == 'b'
        
        data_conList_high 	= ft_selectdata(cfg, conList_freq_HvsL{countB});
        data_conList_med    = ft_selectdata(cfg, conList_freq_HvsM{countB});
        data_conList_low    = ft_selectdata(cfg, conList_freq_MvsL{countB});
        
        pow_data            = [pow_data; countSub, 1, 1, data_conList_high.powspctrm];         
        
        pow_data            = [pow_data; countSub, 2, 1, data_conList_med.powspctrm];
        
        pow_data            = [pow_data; countSub, 3, 1, data_conList_low.powspctrm];       
        
        countB = countB + 1;
        
    end
    
    countSub = countSub + 1;
    
end

myTable = table(pow_data(:,1), pow_data(:,2), pow_data(:,3), pow_data(:,4),'VariableNames', {'subID','constraint', 'list', 'pow'});
writetable(myTable, '/home/renter/EEG Analysis/alphapower_data.txt')


%% Extract average alpha power for interaction analysis

cfg             = [];
cfg.channel     = {'1', '2', '7', '24', '30', '33', '34', '58'};
cfg.avgoverchan = 'yes';
cfg.avgoverfreq = 'yes';
cfg.avgovertime = 'yes';
cfg.frequency   = [8 12];
cfg.latency     = [-0.5 0];

countA = 1;
countB = 1;
countSub = 1;
pow_data = [];
for allo = 1:length(subjectFolder)
    
    if listCongruency{allo} == 'a'
        
        trialsHigh  = length(inconList_freq_HvsL{countA}.trialinfo);
        trialsMed   = length(inconList_freq_HvsM{countA}.trialinfo);
        trialsLow   = length(inconList_freq_MvsL{countA}.trialinfo);
        
        data_incList_high   = ft_selectdata(cfg, inconList_freq_HvsL{countA});
        data_incList_med    = ft_selectdata(cfg, inconList_freq_HvsM{countA});
        data_incList_low    = ft_selectdata(cfg, inconList_freq_MvsL{countA});
        
        for trH = 1:trialsHigh
            pow_data            = [pow_data; countSub, str2double(strcat(num2str(countSub), num2str(trH), num2str(1))), 1, 2, data_incList_high.powspctrm(trH)];
        end
        
        for trM = 1:trialsMed
            pow_data            = [pow_data; countSub, str2double(strcat(num2str(countSub), num2str(trM), num2str(2))), 2, 2, data_incList_med.powspctrm(trM)];
        end
        
        for trL = 1:trialsLow
            pow_data            = [pow_data; countSub, str2double(strcat(num2str(countSub), num2str(trL), num2str(3))), 3, 2, data_incList_low.powspctrm(trL)];        
        end
        
        countA = countA + 1;
    
    elseif listCongruency{allo} == 'b'
        
        trialsHigh  = length(conList_freq_HvsL{countB}.trialinfo);
        trialsMed   = length(conList_freq_HvsM{countB}.trialinfo);
        trialsLow   = length(conList_freq_MvsL{countB}.trialinfo);
        
        data_conList_high 	= ft_selectdata(cfg, conList_freq_HvsL{countB});
        data_conList_med    = ft_selectdata(cfg, conList_freq_HvsM{countB});
        data_conList_low    = ft_selectdata(cfg, conList_freq_MvsL{countB});
        
        for trH = 1:trialsHigh
            pow_data            = [pow_data; countSub, str2double(strcat(num2str(countSub), num2str(trH), num2str(1))), 1, 1, data_conList_high.powspctrm(trH)];         
        end
        
        for trM = 1:trialsMed
            pow_data            = [pow_data; countSub, str2double(strcat(num2str(countSub), num2str(trM), num2str(2))), 2, 1, data_conList_med.powspctrm(trM)];
        end
        
        for trL = 1:trialsLow
            pow_data            = [pow_data; countSub, str2double(strcat(num2str(countSub), num2str(trL), num2str(3))), 3, 1, data_conList_low.powspctrm(trL)];       
        end
        
        countB = countB + 1;
        
    end
    
    countSub = countSub + 1;
    
end

myTable = table(pow_data(:,1), pow_data(:,2), pow_data(:,3), pow_data(:,4), pow_data(:,5),'VariableNames', {'subID', 'trial', 'constraint', 'list', 'pow'});
writetable(myTable, '/home/renter/EEG Analysis/alphapower_data.txt')
