% PS 2018, originally adapted from Andrew Jahn

Conds = {'1','2','3','4','5','6','7','8','9'};
MapNames = {'RedPink' 'RedOrange' 'Orange' 'Olive' 'Green' 'Teal' 'Blue' 'Purple' 'HotPink'};
% Conds = {'1','2','3','4','5','6','7','8','9','NaN'};
% MapNames = {'RedPink' 'RedOrange' 'Orange' 'Olive' 'Green' 'Teal' 'Blue' 'Purple' 'HotPink' 'Blank'};

% load onsets and durations for subject (contains trial_onset_list)
load([root_dir runName '_scripts.mat']);

for nROI = 1:length(roi_file)
    mydata.betas=[];mydata.runs=[];mydata.conds=[];mydata.condName=[];mydata.color=[];

    % load subject's ROI
    seedroi = [roi_dir roi_file{nROI} '.nii'];
    fprintf('ROI: %s \n',roi_file{nROI});

    %Find XYZ coordinates of ROI
    Y = spm_read_vols(spm_vol(seedroi),1);
    indx = find(Y>0);
    [x,y,z] = ind2sub(size(Y),indx);
    XYZ = [x y z]';

    fprintf('num voxels: %i \n',length(XYZ));

    for r = 1:numRuns
        for j = 1:numColors %for every color
            %load SPM.mat
            load([root_dir 'Color' num2str(j) '/SPM.mat']);
            cd([root_dir 'Color' num2str(j)]);

            Betas=[];
            which = find(contains({SPM.Vbeta.descrip},['Sn(' num2str(r) ') Color']));
            
            if isempty(which)
                continue;
            end
            
            condID = j*40-40;

            Betas = strvcat(Betas,SPM.Vbeta(which).fname);
            mydata.color = [mydata.color; j];
            mydata.runs = [mydata.runs; r];
            mydata.conds = [mydata.conds; condID];
            mydata.condName = [mydata.condName; {MapNames{j}}];

            %Extract beta series time course from ROI
            %This will be correlated with every other voxel in the brain
            if ischar(Betas)
                P = spm_vol(Betas);
            end

            est = spm_get_data(P,XYZ);
            est = est(~isnan(est));

            mydata.betas = [mydata.betas; est];
        end
    end
    cd(root_dir)
    save([roi_file{nROI} '_color_betas'],'mydata');
end