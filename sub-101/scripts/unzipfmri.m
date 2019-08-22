for j = 1:numRuns
    orig = strcat(runHead,num2str(j),runTail(1:end-1));
    try
        gunzip(strcat(orig,'.nii.gz'));
        V=strcat(orig,'.nii');
        [p,n,e] = spm_fileparts(V);
        V = spm_vol(fullfile(p,[n e]));
        spm_file_split(V);
        delete(strcat(orig,'.nii.gz'));
        delete(strcat(orig,'.nii'));
    catch
        fprintf('No .nii.gz, assuming it''s already unzipped...\n');
        break;
    end
end