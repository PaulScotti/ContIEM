% PS 2018 Contrast weights

matlabbatch{1}.spm.stats.con.spmmat = {[root_dir '/SPM.mat']};
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'All_vs_Fix';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0 0 0 0 0]; %6 0s for motion regressors, then 0 for constant
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
matlabbatch{1}.spm.stats.con.delete = 0;

% Run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch)
catch me
    rethrow(me)
end

% Rename the SPM.mat file so you know what it is 
% movefile([root_dir '/scripts/SPM.mat'],[root_dir '/scripts/All_vs_Fix_SPM.mat']);

disp('Model estimation for SPM.mat (contrast) completed.');