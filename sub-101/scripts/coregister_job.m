%PS 2018 Coregistration
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[MPRAGE_file ',1']};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[root_dir,'nii/',runHead,'1',runTail,'00001.nii' ',1']};

OtherFiles = dir([runHead '*' runTail '*.nii']);
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {OtherFiles(2:end).name}';
for k = 1:length(matlabbatch{1}.spm.spatial.coreg.estwrite.other)
    matlabbatch{1}.spm.spatial.coreg.estwrite.other(k) = strcat(matlabbatch{1}.spm.spatial.coreg.estwrite.other(k),',1');
end

%%
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

% Run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch)
catch me
    rethrow(me);
end

disp('Completed coregistration of functionals to MPRAGE.');
