function [avgest,sd] = AvgSingleBetaInROI(yy,id,roipath) 
    numTrials = 40;
%     load('/lab/Paul/ContIEM/101/Session_2/SizeJudge/SizeJudge_scripts.mat');
    load('/lab/Paul/ContIEM/101/Session_2/SizeJudge/SizeJudge_scripts.mat');

    %Find XYZ coordinates of ROI
    Y = niftiread(roipath); % Y is an [x,y,z] matrix
    indx = find(Y>0);
    [x,y,z] = ind2sub(size(Y),indx);
    XYZ = [x y z]'; 
    
    t2 = 0;
    for t = 1:numTrials
        filedir = strcat('Trial',num2str(t));
        cd(filedir)
        load('SPM.mat')
        
        betacols = find(contains({SPM.Vbeta.descrip},id));
        
        for k = 1:length(betacols)
            if yy == 1
                if isnan(trial_type_list{k}(t))
                    betacols(k) = 999;
                end
            else
                if ~isnan(trial_type_list{k}(t))
                    betacols(k) = 999;
                end
            end
        end
        betacols(betacols==999) = [];

        P=[];est=[];count=0;
        for which = betacols
            count=count+1;
            P{count} = spm_vol(SPM.Vbeta(which).fname);
            est{count} = spm_get_data(P{count},XYZ);
        end
        
        if length(betacols) > 0 
            t2 = t2+1;
            if count==1
                est1 = squeeze(nanmean(cat(3,est{1}),3));
            elseif count==2
                est1 = squeeze(nanmean(cat(3,est{1},est{2}),3));
            elseif count==3
                est1 = squeeze(nanmean(cat(3,est{1},est{2},est{3}),3));
            elseif count==4
                est1 = squeeze(nanmean(cat(3,est{1},est{2},est{3},est{4}),3));
            elseif count==5
                est1 = squeeze(nanmean(cat(3,est{1},est{2},est{3},est{4},est{5}),3));
            elseif count==6
                est1 = squeeze(nanmean(cat(3,est{1},est{2},est{3},est{4},est{5},est{6}),3));
            elseif count==7
                est1 = squeeze(nanmean(cat(3,est{1},est{2},est{3},est{4},est{5},est{6},est{7}),3));
            elseif count==8
                est1 = squeeze(nanmean(cat(3,est{1},est{2},est{3},est{4},est{5},est{6}, ... 
                    est{7},est{8}),3));
            elseif count==12
                est1 = squeeze(nanmean(cat(3,est{1},est{2},est{3},est{4},est{5},est{6}, ...
                    est{7},est{8},est{9},est{10},est{11},est{12}),3));
            else
                error('count unspecified: %i',count);
            end

            est2{t2} = est1;
        end
        
        cd ..
    end
    
    avgest=[];
    numVox = length(est2{1});
    for v = 1:numVox
        avgest(v) = nanmean(cellfun(@(c) c(1,v), est2));
    end
    
    sd = nanstd(avgest);
    avgest = nanmean(avgest);
end