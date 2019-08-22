%% Paul Scotti 2018 Full Pipeline ContLTM_IEM %%
close all; clear all; 
SubjNum = 101;
TR = 2;
TA = 0;

home = '/lab/Paul/ContIEM/';
% home = '/users/PAS1098/osu10161/ContLTM_IEM/';
addpath(genpath(home)) % add subfolders to path
% addpath(genpath('users/PAS1098/osu10161/spm12'));
cd(home);

spm fmri

%% Session 1 Processing %%`

% Color Localizer %
% runHead = 'sub-101_ses-1_task-colorgray_run-00';
% runTail = '_space-T1w_desc-preproc_bold_';
% runName = 'ColorGrayContrast';
% root_dir = [home num2str(SubjNum) '/Session_1/ColorLocalizer' filesep];
% numRuns = 2;
% numVols = 121;
% numConds = 3; %color, grayscale, or fixation
% 
% cd([root_dir,'nii'])
% unzipfmri 
% MPRAGE_file = [home num2str(SubjNum) '/Session_1/MPRAGE/sub-101_desc-preproc_T1w.nii'];
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% 
% coregister_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% 
% smooth_fmriprep_job 
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% 
% subjcontrast_colorgraycontrast_fmriprep_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% 
% estimate_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% 
% contrast_weights_colorgraycontrast_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% 
% sprintf('Need to use MarsBar, rename SPM.mat, and manually create color ROIs')

% % Functional LOC %
% runName = 'FuncLoc_ObjectScram';
% runHead = 'sub-101_ses-1_task-objectscram_run-00';
% runTail = '_space-T1w_desc-preproc_bold_';
% root_dir = [home num2str(SubjNum) '/Session_1/ObjScram' filesep];
% numRuns = 2;
% numVols = 121;
% numConds = 3; % intact scrambled fixation

% cd([root_dir,'nii'])
% unzipfmri 
% MPRAGE_file = [home num2str(SubjNum) '/Session_1/MPRAGE/sub-101_desc-preproc_T1w.nii'];

% coregister_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% smooth_fmriprep_job 
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% subjcontrast_objscram_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file

% estimate_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file

% contrast_weights_objscram_job
% contrast_weights_objscram_allvsblank_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file

% sprintf('Need to use MarsBar, rename SPM.mat, and manually create LOC ROIs')

%% Color Encoder %%
% runHead = 'sub-101_ses-1_task-colorencoder_run-00';
% runTail = '_space-T1w_desc-preproc_bold_';
% runName = 'ColorEncoder';
% root_dir = [home num2str(SubjNum) '/Session_1/' runName filesep];
% numRuns = 6;
% numVols = 151;
% numTrials = 40; %40
% startTrial = 1; %1
% numConds = 2; %for All Vs. Fix
% numColors=9; %9 not including nans
% startColor=1;

% cd([root_dir,'nii'])
% unzipfmri
% MPRAGE_file = [home num2str(SubjNum) '/Session_1/MPRAGE/sub-101_desc-preproc_T1w.nii'];
% coregister_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file

% % for all vs fix
% smooth_fmriprep_job 
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% subjcontrast_allvsfix_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% estimate_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% contrast_weights_allvsfix_job

% % for different colors
% subjcontrast_colors_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% estimate_job

% % for different columns GLM
% subjcontrast_columns_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% estimate_ctrial_job

%%%%
% for single trial betas

% sanity_subjcontrast_mumford_fmriprep_job
% rmpath(genpath('oldTrials'))
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds numObjects startObject numColors startColor MPRAGE_file
% estimate_singletrial_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds numObjects startObject numColors startColor MPRAGE_file

% subjcontrast_mumford_collapsedcolor_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds numObjects startObject numColors startColor MPRAGE_file
% estimate_singletrial_collapsedcolor_job

% roi_dir = [home num2str(SubjNum) '/Session_1/ROIs/'];
% roi_file = "LOCs.nii";
% DoBetaSeries
% DoBetaSeries2 % for all vs fix constrained ROI mybetas

%% Session 2 Processing %%
% Size Judgment %
runHead = 'sub-101_ses-2_task-sizejudge_run-00';
runTail = '_space-T1w_desc-preproc_bold_';
runName = 'SizeJudge';
root_dir = [home num2str(SubjNum) '/Session_2/' runName filesep];
numRuns = 8;
numVols = 151;
numTrials = 40;
startTrial = 1;
numObjects = 80; % 72 + 8 blank GLMs
startObject= 1;

cd([root_dir,'nii'])
% unzipfmri 
MPRAGE_file = [home num2str(SubjNum) '/Session_1/MPRAGE/sub-101_desc-preproc_T1w.nii'];
% coregister_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds numObjects startObject numColors startColor MPRAGE_file

% % for all vs fix
% smooth_fmriprep_job 
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% subjcontrast_allvsfix_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% estimate_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% contrast_weights_allvsfix_job

% for single trial betas
% sanity_subjcontrast_mumford_fmriprep_job
% rmpath(genpath('oldTrial'))
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds numObjects startObject numColors startColor MPRAGE_file

% sanity_subjcontrast_mumford_collapseditem_job
% rmpath(genpath('oldObject'))
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds numObjects startObject numColors startColor MPRAGE_file

% estimate_singletrial_job
% estimate_singletrial_collapseditem_job %CHANGED TO START AT 73

% % for different colors
% subjcontrast_colors_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% estimate_job

% % for different columns GLM
% subjcontrast_columns_job
% clearvars -except SubjNum TR TA home runHead runTail runName root_dir numRuns numVols  numTrials startTrial numConds MPRAGE_file
% estimate_ctrial_job

roi_dir = [home num2str(SubjNum) '/Session_1/ROIs/'];
roi_file = "LOCs.nii";
DoBetaSeries
% DoBetaSeries_Obj

