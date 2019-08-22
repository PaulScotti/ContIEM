clc; clear all; close all;
home = '/lab/Paul/ContIEM/';
addpath(genpath(home)) % add subfolders to path
cd(home);
SubjNum=101;

ROI = {'rh_LOC_cluster'};

fprintf('ROI: %s \n',ROI{1});

% load ROIs
mprage = niftiread(strcat(home,num2str(SubjNum),'/Session_1/MPRAGE/sub-101_desc-preproc_T1w.nii'));
% constrainroi = niftiread([home num2str(SubjNum) '/Session_1/ROIs/retinotopic_rois/lh.V4v.nii']);
% constrainroi=double(constrainroi);
seedroi = niftiread(strcat(home,num2str(SubjNum),'/Session_1/ROIs/',ROI{1},'.nii'));
infofile = niftiinfo(strcat(home,num2str(SubjNum),'/Session_1/ROIs/',ROI{1},'.nii'));

fprintf('Voxels before: %i \n',length(seedroi(seedroi>0)))

%% Remove voxels
seedroi(:,:,73:size(seedroi,3))=0;

fprintf('Voxels after: %i \n',length(seedroi(seedroi>0)))
fprintf('Saving... \n');
niftiwrite(seedroi,strcat(home,num2str(SubjNum),'/Session_1/ROIs/rh_LOC.nii'),infofile);
fprintf('Done! \n');