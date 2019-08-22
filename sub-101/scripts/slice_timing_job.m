%Paul Scotti 2018 Slice Timing

load([root_dir,'scripts/dcmHeaders.mat']);

s = eval(['h.' runName '_1']); % field name is the same as nii file name
spm_ms = (0.5 - s.SliceTiming) * s.RepetitionTime;
%%
cd([root_dir,'nii']);

SliceFiles = dir([runName '*.nii']);
matlabbatch{1}.spm.temporal.st.scans = {{SliceFiles.name}'};

%%
matlabbatch{1}.spm.temporal.st.nslices = nSlices;
matlabbatch{1}.spm.temporal.st.tr = TR;
matlabbatch{1}.spm.temporal.st.ta = TA;
matlabbatch{1}.spm.temporal.st.so = spm_ms;
matlabbatch{1}.spm.temporal.st.refslice = 0;
matlabbatch{1}.spm.temporal.st.prefix = 'a';

% Run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch)
catch me
    rethrow(me);
end

disp('Completed slice timing.');


