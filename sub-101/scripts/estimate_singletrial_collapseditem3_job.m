%PS 2018 Estimate

for object = fliplr(startObject:36)
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {[root_dir 'Object' num2str(object) '/SPM_Object_' num2str(object) '.mat']};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    % Run batch
    try
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch)
    catch me
        rethrow(me)
    end

    disp(['Model estimation for object ' num2str(object) ' SPM.mat completed.']);
end