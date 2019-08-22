function [avgest,sd] = AvgBetaInROI(id,SPM,roipath) 
    %Find XYZ coordinates of ROI
    Y = niftiread(roipath); % Y is an [x,y,z] matrix
    indx = find(Y>0);
    [x,y,z] = ind2sub(size(Y),indx);
    XYZ = [x y z]'; 
    
    betacols = find(contains({SPM.Vbeta.descrip},id));

    P=[];est=[];count=0;
    for which = betacols
        count=count+1;
        P{count} = spm_vol(SPM.Vbeta(which).fname);
        est{count} = spm_get_data(P{count},XYZ);
    end
    
    if count==2
        avgest = squeeze(nanmean(cat(3,est{1},est{2}),3));
    elseif count==6
        avgest = squeeze(nanmean(cat(3,est{1},est{2},est{3},est{4},est{5},est{6}),3));
    elseif count==6
        avgest = squeeze(nanmean(cat(3,est{1},est{2},est{3},est{4},est{5},est{6}),3));
    end
    
    sd = nanstd(avgest);
    avgest = nanmean(avgest);
end