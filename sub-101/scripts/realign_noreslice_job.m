% PS 2018 Realignment

cd([root_dir,'nii']);

for run = 1:numRuns
    RealignFiles = dir(['a' runName '_' num2str(run) '*.nii']);
    matlabbatch{1}.spm.spatial.realign.estwrite.data{run} = {RealignFiles.name}';
end
matlabbatch{1}.spm.spatial.realign.estwrite.data = matlabbatch{1}.spm.spatial.realign.estwrite.data';

%%
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.weight = '';

% Run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch)
catch me
    rethrow(me);
end

disp('Completed realignment (estimate) to first slice of each run.');