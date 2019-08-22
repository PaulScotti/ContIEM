%PS 2018 Smoothing

SmoothFiles = dir(['r*.nii']);
matlabbatch{1}.spm.spatial.smooth.data = {SmoothFiles.name}';

%%
matlabbatch{1}.spm.spatial.smooth.fwhm = [4 4 4];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

% Run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch)
catch me
    rethrow(me);
end

disp('Completed smoothing of all functional images.');