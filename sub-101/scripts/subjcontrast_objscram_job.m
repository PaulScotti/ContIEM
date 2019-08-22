%Paul Scotti 2018 1st Level SPM

% load onsets and durations for subject (contains trial_onset_list)
load([root_dir,'funcLoc_scripts.mat']);

matlabbatch{1}.spm.stats.fmri_spec.dir = {pwd};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16; %check these are the correct defaults using the GUI (these are correct for 2 s TR)
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

cd([root_dir 'nii']);

for run = 1:numRuns
    
    fmri_dir = dir(['sr' runHead num2str(run) runTail '*.nii']);
    for i = 1:length(fmri_dir)
        fmri_images{i} = strcat(fmri_dir(i).folder,filesep,fmri_dir(i).name);
        fmri_images(i) = strcat(fmri_images(i),',1');
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = fmri_images;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans';

    %%
    for condition = 1:numConds
        if condition == 1 
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = 'Intact';
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).onset = [BLOCK_ONSET{run}(BLOCK_ORDER{2}(run,:)==1)];
        elseif condition == 2 
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = 'Scrambled';
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).onset = [BLOCK_ONSET{run}(BLOCK_ORDER{2}(run,:)==2)];
        elseif condition == 3 
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = 'Fixation';
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).onset = [BLOCK_ONSET{run}(BLOCK_ORDER{2}(run,:)==0)];
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).duration = 15.5; %0 if event-related, otherwise time from onset to offset of stim
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).orth = 1;
    end
    confounds_file = dir([runHead num2str(run) '*regressors.tsv']);
    cstruct = tdfread(confounds_file.name);
    confounds = [ ...
        cstruct.trans_x,cstruct.trans_y,cstruct.trans_z, ...
        cstruct.rot_x,cstruct.rot_y,cstruct.rot_z];
    % make it a txt file so that spm can interpret it
    save(strcat(confounds_file.folder,filesep,confounds_file.name(:,1:end-4),'.txt'),'confounds','-ascii');
        
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg = {strcat(confounds_file.folder,filesep,confounds_file.name(:,1:end-4),'.txt')};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf = 128;
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

disp('Completed 1st level contrast for single subject.');
