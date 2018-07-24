% PS 2018, originally adapted from Andrew Jahn
clear all;

subjects = [101];

rootdir = '/Users/scotti.5/Documents/OSU/fMRI/ContLTM_IEM/';
rootdir2 = '/Users/scotti.5/Dropbox/Shared Lab Folder/FMRI_Experiments/ContLTM_IEM/Session_One/encoder/s';

spmdir = 'ColorEncoder';
spm_file = 'Color_Encoder_scripts_s';
roi_file = 'RH_ColorROI';

Conds = {'1','2','3','4','5','6','7','8','9'};
MapNames = {'RedPink' 'RedOrange' 'Orange' 'Olive' 'Green' 'Teal' 'Blue' 'Purple' 'HotPink'};
% Conds = {'1','2','3','4','5','6','7','8','9','NaN'};
% MapNames = {'RedPink' 'RedOrange' 'Orange' 'Olive' 'Green' 'Teal' 'Blue' 'Purple' 'HotPink' 'Blank'};
numRuns = 6;
numTrials = 40;

for par = 1:length(subjects)
    subj = num2str(subjects(par));
    disp(['Loading subject ' subj]);
    mydata.betas=[];mydata.runs=[];mydata.conds=[];mydata.condName=[];mydata.trial=[];
    
    % load subject's ROI
    seedroi = ['/Users/scotti.5/Documents/OSU/fMRI/ContLTM_IEM/' num2str(subjects(par)) '/ROIs/' roi_file '.nii'];
    
    % load subject-specific contrast 
    load([rootdir2 num2str(subj) filesep spm_file num2str(subj) '.mat']);  
    
    %Find XYZ coordinates of ROI
    Y = spm_read_vols(spm_vol(seedroi),1);
    indx = find(Y>=1);
    [x,y,z] = ind2sub(size(Y),indx);
    XYZ = [x y z]';
    
    fprintf('num voxels: %i \n',length(XYZ));

    for r = 1:numRuns
        for j = 1:numTrials %for every trial in the run
            %Can change the following line of code to CD to the directory containing your SPM file, if your directory structure is different
            cd([rootdir subj filesep spmdir filesep 'Trial' num2str(j)]);
            load SPM;

            Betas=[];
            which = find(contains({SPM.Vbeta.descrip},['Sn(' num2str(r) ') Trial']));

            condID = trial_type_list{r}(j);
            if isnan(condID)
                continue;
            end
            Betas = strvcat(Betas,SPM.Vbeta(which).fname);
            mydata.trial = [mydata.trial; j];
            mydata.runs = [mydata.runs; r];
            mydata.conds = [mydata.conds; condID];
            mydata.condName = [mydata.condName; {MapNames{condID}}];
            
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
    cd ..
    save([subj '_' roi_file '_betas'],'mydata');
end