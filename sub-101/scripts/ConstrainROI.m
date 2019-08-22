clear all; close all;
home = '/lab/Paul/ContIEM/';
addpath(genpath(home)) % add subfolders to path
cd(home);
SubjNum=101;

ROI = { ...
    'retinotopic_rois/lh.V1v.nii','retinotopic_rois/lh.V1d.nii', 'retinotopic_rois/rh.V1d.nii', 'retinotopic_rois/rh.V1v.nii', ...
    'retinotopic_rois/lh.V2v.nii','retinotopic_rois/lh.V2d.nii', 'retinotopic_rois/rh.V2d.nii', 'retinotopic_rois/rh.V2v.nii', ...
    'retinotopic_rois/lh.V3v.nii','retinotopic_rois/lh.V3d.nii', 'retinotopic_rois/rh.V3d.nii', 'retinotopic_rois/rh.V3v.nii', ...
    'retinotopic_rois/lh.V3a.nii','retinotopic_rois/rh.V3a.nii', 'retinotopic_rois/lh.V7.nii', 'retinotopic_rois/rh.V7.nii', ...
    'retinotopic_rois/lh.V4v.nii', 'retinotopic_rois/rh.V4v.nii',};

for r = 1:length(ROI)
    fprintf('ROI: %s \n',ROI{r});

    % load SPM.mat and contrast (uses MarsBaR)
    spm_mat = '/lab/Paul/ContIEM/101/Session_1/ObjScram/SPM.mat';
    sess_model = mardo(spm_mat);

%     % Get t threshold of uncorrected p < 0.001
%     p_thresh = .001;
%     erdf = error_df(sess_model);
%     t_thresh = spm_invTcdf(1-p_thresh, erdf);

    % load ROIs
    constrainroi = niftiread([home num2str(SubjNum) '/Session_1/ObjScram/spmT_allvsblank.nii']);
    seedroi = niftiread(strcat(home,num2str(SubjNum),'/Session_1/ROIs/',ROI{r}));
    infofile = niftiinfo(strcat(home,num2str(SubjNum),'/Session_1/ROIs/',ROI{r}));
    
    % all voxels from t image below threshold are excluded from mask (_2)
    % all voxels that were more activated for all compared to blank
    newroi = seedroi;
    newroi(constrainroi<=0) = 0;
    
    length(seedroi(seedroi>0))
    length(newroi(newroi>0))
    
    niftiwrite(seedroi,strcat(home,num2str(SubjNum),'/Session_1/ROIs/',ROI{r}(1:end-4),'_3.nii'),infofile);
end
