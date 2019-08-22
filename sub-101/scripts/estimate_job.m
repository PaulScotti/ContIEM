%PS 2018 Esimate

cd(root_dir);
cd ..;
matlabbatch{1}.spm.stats.fmri_est.spmmat = {[root_dir '/SPM.mat']};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

% Run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch)
catch me
    rethrow(me)
end

disp('Model estimation for SPM.mat completed.');