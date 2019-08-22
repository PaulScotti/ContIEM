%Paul Scotti 2018 1st Level SPM

% load onsets and durations for subject (contains trial_onset_list)
if (runName=="SizeJudge")
    load([root_dir,'SizeJudge_scripts.mat']);
else
    load([root_dir,'Color_Encoder_scripts.mat']);
end

matlabbatch{1}.spm.stats.fmri_spec.dir = {pwd};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16; %check these are the correct defaults using the GUI (these are correct for 2 s TR)
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

cd([root_dir 'nii']);

for run = 1:numRuns
    
    fmri_dir = dir(['sr' runHead num2str(run) runTail '*.nii']);
    for i = 1:length(fmri_dir)
        fmri_images{i} = fmri_dir(i).name;
        fmri_images(i) = strcat(fmri_images(i),',1');
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = fmri_images;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans';
    
    for con = 1:10
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(con).onset = [];
    end
    
    for trial = 1:numTrials
        if isnan(trial_type_list{run}(trial))
            condition = 10;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = 'None';
        elseif trial_type_list{run}(trial) == 1
            condition = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '1';
        elseif trial_type_list{run}(trial) == 2
            condition = 2;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '2';
        elseif trial_type_list{run}(trial) == 3
            condition = 3;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '3';
        elseif trial_type_list{run}(trial) == 4
            condition = 4;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '4';
        elseif trial_type_list{run}(trial) == 5
            condition = 5;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '5';
        elseif trial_type_list{run}(trial) == 6
            condition = 6;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '6';
        elseif trial_type_list{run}(trial) == 7
            condition = 7;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '7';
        elseif trial_type_list{run}(trial) == 8
            condition = 8;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '8';
        elseif trial_type_list{run}(trial) == 9
            condition = 9;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).name = '9';
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).onset = [matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).onset; trial_onset_list{run}(trial)];
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(condition).duration = 0; %0 if event-related, otherwise time from onset to offset of stim
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

movefile([root_dir,'nii','/SPM.mat'],[root_dir])

disp('Completed 1st level contrast for single subject.');
