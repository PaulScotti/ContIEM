%PS 2018 Estimate

for color = startColor:numColors
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {[root_dir 'Color' num2str(color) '/SPM_Color_' num2str(color) '.mat']};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    % Run batch
    try
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch)
    catch me
        rethrow(me)
    end

    disp(['Model estimation for color ' num2str(color) ' SPM.mat completed.']);
end