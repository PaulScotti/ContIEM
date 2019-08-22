%Paul Scotti 2018 1st Level SPM

% load onsets and durations for subject (contains trial_onset_list)
load([root_dir runName '_scripts.mat']);

cd([root_dir 'scripts']);

%% Prepare Design Matrix in SPM    
cd ..

if ~(7 == exist('Color9','dir')) %does Color10 folder exist? if not, create the folders
    for i = 1:numColors %make folder for every color (adapted Mumford method)
        mkdir (['Color' num2str(i)])
    end
end

cd nii

matlabbatch{1}.spm.stats.fmri_spec.dir = {pwd};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16; % check these are the correct defaults using the GUI (these are correct for 2 s TR)
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

allcolors=[0:40:320];

for color = startColor:numColors
    [R,C] = find(imgcolor(:,:)==allcolors(color)); % find all trials with same color, combine betas across same color
    Rx = find(~any(R==[1:numRuns]));
    for run = 1:numRuns
        if any(run == R)
            indx = find(run==R);
            trial = C(indx);

            fmri_images = dir(['r' runHead num2str(run) runTail '*.nii']);
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = {fmri_images.folder,filesep,fmri_images.name}';

            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).name = ['Color_' num2str(color)];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).onset = trial_onset_list{run}(trial);
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(2).orth = 1;

            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).name = ['NotColor_' num2str(color)];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset=[];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).orth = 1;

            for trialx = 1:numTrials
                if trialx ~= trial % get onsets for all the trials that aren't the current trial of interest
                    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset; trial_onset_list{run}(trialx)];
                end
            end

            confounds_file = dir([runHead num2str(run) '*regressors.tsv']);
            cstruct = tdfread(confounds_file.name);
            confounds = [ ...
                cstruct.trans_x,cstruct.trans_y,cstruct.trans_z, ...
                cstruct.rot_x,cstruct.rot_y,cstruct.rot_z];
            % make it a txt file so that spm can interpret it
            save(strcat(confounds_file.folder,filesep,confounds_file.name(:,1:end-4),'.txt'),'confounds','-ascii');

            matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg = {strcat(confounds_file.folder,filesep,confounds_file.name(:,1:end-4),'.txt')};
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf = 128;
        elseif any(run == Rx)
            fmri_images = dir(['r' runHead num2str(run) runTail '*.nii']);
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = {fmri_images.folder,filesep,fmri_images.name}';

            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).name = ['NotColor_' num2str(color)];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset=[];
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).orth = 1;

            for trialx = 1:numTrials
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(1).onset; trial_onset_list{run}(trialx)];
            end
            
            confounds_file = dir([runHead num2str(run) '*regressors.tsv']);
            cstruct = tdfread(confounds_file.name);
            confounds = [ ...
                cstruct.trans_x,cstruct.trans_y,cstruct.trans_z, ...
                cstruct.rot_x,cstruct.rot_y,cstruct.rot_z];
            % make it a txt file so that spm can interpret it
            save(strcat(confounds_file.folder,filesep,confounds_file.name(:,1:end-4),'.txt'),'confounds','-ascii');

            matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg = {strcat(confounds_file.folder,filesep,confounds_file.name(:,1:end-4),'.txt')};
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf = 128;
        end
    end
    %spm finishing stuff
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    % Run batch
    try
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch)
    catch me
        rethrow(me);
    end
    
    %Rename SPM.mat
    movefile('SPM.mat',['SPM_Color_' num2str(color) '.mat'])
    %Move SPM.mat to suitable folder
    movefile(['SPM_Color_' num2str(color) '.mat'],[root_dir '/Color' num2str(color)])
    
    sprintf('Completed SPM for color %i',color)
end

disp('Completed 1st level contrast for single subject.');
cd(home)
