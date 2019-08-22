%% Paul Scotti 2018 Full Pipeline ContLTM_IEM %%
close all; clear all; 
spm fmri;
SubjNum = 101;
TR = 2;
TA = 0;

% home = '/Volumes/Passport/ContLTM_IEM/';
home = '/users/PAS1098/osu10161/ContLTM_IEM/';
addpath(genpath(home)) % add subfolders to path

%% Session 1 Processing %%

% % Color Encoder %
runHead = 'sub-101_ses-1_task-colorencoder_run-00';
runTail = '_space-MNI152NLin2009cAsym_desc-preproc_bold_';
runName = 'ColorEncoder';
root_dir = [home num2str(SubjNum) '/Session_1/' runName filesep];
numRuns = 6;
numVols = 121;
nSlices = 72;
numTrials = 40;
startTrial = 1;
numConds = 2; %for All Vs. Fix

cd([root_dir,'nii'])

unzipfmri(runHead,runTail(1:end-1),numRuns)

MPRAGE_file = [home num2str(SubjNum) '/Session_1/MPRAGE/sub-101_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii'];
coregister_job

clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols nSlices numTrials startTrial numConds MPRAGE_file

% % for all vs fix
% run smooth_fmriprep_job 
% run subjcontrast_allvsfix_job
% run estimate_job
% run contrast_weights_allvsfix_job
% % % %

% % for single trial betas
subjcontrast_mumford_fmriprep_job

clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols nSlices numTrials startTrial numConds MPRAGE_file

estimate_singletrial_job

% roi_dir = [home num2str(SubjNum) '/Session_1/ROIs/'];
% roi_file = {'ColorROIs'};
% run DoBetaSeries
% %%%
% roi_dir = [home num2str(SubjNum) '/Session_1/ROIs/'];
% roi_file = {'ColorROIs'};
% run DoBetaSeries2 % for all vs fix constrained ROI mybetas
% 
% %% Session 2 Processing %%
% % Size Judgment %
% runName = 'SizeJudge';
% root_dir = [home num2str(SubjNum) '/Session_2/' runName filesep];
% numRuns = 8;
% numVols = 151;
% nSlices = 72;
% numTrials = 40;
% numObjects = 72;
% 
% run slice_timing_job
% run realign_reslice_job
% MPRAGE_file = [home num2str(SubjNum) '/Session_1/MPRAGE/MPRAGE.nii'];
% run coregister_job
% 
% % for single trial betas
% run subjcontrast_mumford_job
% % run subjcontrast_mumford_collapseditem_job
% run estimate_singletrial_job
% roi_dir = [home num2str(SubjNum) '/Session_1/ROIs/'];
% roi_file = {'ColorROIs'};
% run DoBetaSeries
% 
quit;