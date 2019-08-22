%Paul Scotti 2018 1st Level SPM

% load onsets and durations for subject (contains trial_onset_list)
load([root_dir,'Color_Encoder_scripts.mat']);

matlabbatch{1}.spm.stats.fmri_spec.dir = {pwd};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16; %check these are the correct defaults using the GUI (these are correct for 2 s TR)
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

cd([root_dir 'nii']);

for run = 1:numRuns
    
    fmri_dir = dir(['srra' runName '_' num2str(run) '*.nii']);
    for i = 1:length(fmri_dir)
        fmri_images{i} = fmri_dir(i).name;
        fmri_images(i) = strcat(fmri_images(i),',1');
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = fmri_images;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans';

    %%
    for condition = 1:numConds
        if condition == 1 
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = 'Color';
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).onset = [block_onset_list{run}(block_type_list{run}==2)];
        elseif condition == 2 
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = 'Grayscale';
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).onset = [block_onset_list{run}(block_type_list{run}==3)];
        elseif condition == 3 
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = 'Fixation';
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).onset = [block_onset_list{run}(block_type_list{run}==1)];
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).duration = 15.5; %0 if event-related, otherwise time from onset to offset of stim
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).orth = 1;
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress = struct('name', {}, 'val', {});
    motion_regressors = dir(['rp_a' runName '_' num2str(run) '*.txt']);
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg = {motion_regressors.name};
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
