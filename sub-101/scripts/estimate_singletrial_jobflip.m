%PS 2018 Esimate

for trial = fliplr(1:numTrials)
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {[root_dir 'Trial' num2str(trial) '/SPM_Trial_' num2str(trial) '.mat']};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    % Run batch
    try
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch)
    catch me
        rethrow(me)
    end

    disp(['Model estimation for trial ' num2str(trial) ' SPM.mat completed.']);
end