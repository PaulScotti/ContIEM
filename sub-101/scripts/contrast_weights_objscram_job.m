% PS 2018 Contrast weights

matlabbatch{1}.spm.stats.con.spmmat = {[root_dir '/SPM.mat']};
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Intact vs Scrambled';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0 0 0 0 0 0]; %extra 0 in third position for fixation, then 6 0s for motion regressors, then 0 for constant
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
matlabbatch{1}.spm.stats.con.delete = 0;

% Run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch)
catch me
    rethrow(me)
end

disp('Model estimation for SPM.mat completed.');