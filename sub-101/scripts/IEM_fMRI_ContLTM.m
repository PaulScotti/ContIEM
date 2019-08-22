% PS IEM ContLTM 2018/2019, with much help thanks to Emma Wu Dowd, Julie Golomb, and Tommy Sprague
close all;
clear all;
subjID = 101;

%% Load betas from ROI 
% loads in mydata, a struct containing betas (numTrials x numVoxels), every trial's run number, 
% condition (multiply by 40 for degrees in color space), condName, and trial number

load('/Volumes/Passport/ContLTM_IEM/101/Session_1/MPRAGE/S1_mydata.mat');
MPRAGE = niftiread('/Volumes/Passport/ContLTM_IEM/101/Session_1/MPRAGE/sub-101_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii');
indx = find(MPRAGE>0);
mask = niftiread('/Volumes/Passport/ContLTM_IEM/101/Session_1/ROIs/ColorROIs.nii');
indx2 = find(mask>0);
indx(ismember(indx,indx2)) = -999;
mydata.betas = mydata.betas(:,indx==-999);

try
    mydata.runs = mydata.object;
end
mydata2 = mydata;

% how many voxels are in this ROI?
fprintf('num voxels: %i \n',size(mydata.betas,2));

% ColorROIs_betas.mat is an ROI combining LH and RH largest cluster of voxels that responded more to color
% than grayscale during color localizer

%% Create basis set
n_ori_chans = 9;
nChanPow = n_ori_chans-1;
make_basis_function = @(xrad,mu) (cos(xrad-mu)).^(nChanPow);

xrad = linspace(pi/360,pi,360); %convert everything to radians to work with 180 point sinusoid over feature space
basis_set = nan(360,n_ori_chans);
chan_center_rad = linspace(pi/n_ori_chans,pi,n_ori_chans);

% create basis set composed of 360 color space x 9 channels
for cc = 1:n_ori_chans
    basis_set(:,cc) = make_basis_function(xrad,chan_center_rad(cc));
end

figure
subplot(1,2,1);plot(rad2deg(xrad),basis_set);
xlabel('Color (\circ) reduced to 180 point space');
ylabel('Filter amplitude');
title('Basis set');

% sum channels, should be a single constant value, if not change nChanPow
subplot(1,2,2);plot(xrad,sum(basis_set,2));

%% Build stimulus mask
%convert conditions into respective degrees in color space (note: never using blank trials)
mydata.conds = mydata.conds*40;
mydata.conds(mydata.conds==0) = 360;
mydata2.conds = mydata2.conds*40;
mydata2.conds(mydata2.conds==0) = 360;

figure
hold off; 
plot(mydata.conds,'o'); 
xlabel('Trial'); ylabel('Color (deg)'); title('Color Labels');

stim_mask = zeros(size(mydata.conds,1),length(xrad));
for tt = 1:size(stim_mask,1)  % loop over trials
    if ~isnan(mydata.conds(tt))
        stim_mask(tt,mydata.conds(tt))=1;
    end
end

figure
imagesc(stim_mask);title('Stimulus mask');xlabel('Color (\circ)');ylabel('Trial');

% for sess 2
stim_mask2 = zeros(size(mydata2.conds,1),length(xrad));
for tt = 1:size(stim_mask2,1)  % loop over trials
    if ~isnan(mydata2.conds(tt))
        stim_mask2(tt,mydata2.conds(tt))=1;
    end
end

%% Generate design matrix
desMat = stim_mask*basis_set;

desMat2 = stim_mask2*basis_set;

% Plot predicted channel response for sample trial 
tr_num = 1;
figure
plot(rad2deg(chan_center_rad),desMat(tr_num,:),'k-');
hold on;
for cc = 1:n_ori_chans
    plot(rad2deg(chan_center_rad(cc)),desMat(tr_num,cc),'o','MarkerSize',8,'LineWidth',3);
end
xlabel('Channel center (\circ)');
title(['Predicted channel response for trial ' num2str(tr_num)]);

% Plot design matrix across trials
figure
imagesc(rad2deg(chan_center_rad),1:size(desMat(:,:),1),desMat(:,:));
colormap(gray);
xticks([0:180/n_ori_chans:180]); 
title('Design matrix');
xlabel('Channel center (\circ)');ylabel('Trial'); 

%% Cross-validate and train/test encoding model
vox_prctile = 100; % use top x% of voxels
ru = unique(mydata.runs);
n_runs = length(ru);

chan_resp = nan(size(desMat));
chan_resp2 = nan(size(desMat2));

for rr = 1:n_runs
    % identify the training & testing halves of the data: leave-one-run-out cross-validation
    trnIdx = mydata.runs~=ru(rr);
%     tstIdx = mydata.runs==ru(rr);
    
    % identify the training & testing halves of the data: leave-two-runs-out cross-validation
    ru2 = circshift(ru,-1);
    trnIdx = mydata.runs ~= ru(rr) & mydata.runs ~= ru2(rr);
    tstIdx = mydata.runs == ru(rr) | mydata.runs == ru2(rr);
    
    % voxel selection - compute ANOVA on each voxel, rank them, select top n% of voxels
    ps = nan(size(mydata.betas,2),1);
    for ii = 1:size(mydata.betas,2)
        ps(ii) = anova1(mydata.betas(trnIdx,ii),mydata.conds(trnIdx),'off');
    end
    
    % only use voxels that were top x%, determined by one-way anova
    which_vox = ps <= prctile(ps,vox_prctile);
    
    trnX = mydata.betas(trnIdx,which_vox);
    tstX = mydata.betas(tstIdx,which_vox);
    
    weights = desMat(trnIdx,:)\trnX;
    
    % compare trained channel weights to actual beta weights for each test trial
    chan_resp(tstIdx,:) = (inv(weights*weights')*weights*tstX').';
    
%     % Session Two processing
%     tstx2 = mydata2.betas(:,which_vox);
%     chan_resp2(:,:) = (inv(weights*weights')*weights*tstx2').';
end

figure
% plot weights for 3 voxels
subplot(3,1,1)
plot(weights(:,1:3),'o-')
xlabel('Channel'); ylabel('Weight');
title('Sample trained channel weights for 3 voxels');

% plot reconstructed channel response for sample trial 
subplot(3,1,2)
plot(chan_resp(tr_num,:))
xlabel('Channel'); 
ylabel('BOLD Z-score'); 
title(['Reconstructed channel response for sample trial ' num2str(tr_num)]);

% how well did it do? compare to predicted channel response (design matrix) 
subplot(3,1,3)
plot(desMat(tr_num,:),'k-');
xlabel('Channel center'); 
ylabel('Sensitivity'); 
title(['Predicted (true) channel response for sample trial ' num2str(tr_num)]);

%% Combine across channel response functions
ou = unique(mydata.conds); 
ou = ou(~isnan(ou));
targ_chan = ceil(n_ori_chans/2);

chan_resp_shift = [];
for ii = 1:size(chan_resp,1)
    if ~isnan(mydata.conds(ii))
        chan_resp_shift(end+1,:) = circshift(chan_resp(ii,:),targ_chan-find(ou==mydata.conds(ii)),2);
    end
end

%% Plot average reconstructed response for all trials
ground_truth_basis = basis_set(:,5);
ground_truth_basis = ground_truth_basis(1:2:length(ground_truth_basis));

figure
plot(rad2deg(chan_center_rad),mean(chan_resp_shift),'LineWidth',5);
hold on;
plot([rad2deg(chan_center_rad(targ_chan)) rad2deg(chan_center_rad(targ_chan))],[0 1],':c','LineWidth',5)
xlabel('Color channel (\circ)','FontSize',14);
ylabel('Channel response (BOLD Z-Score)','FontSize',14);
% sinusoid basis function goes from 0 to 180, need to convert back over to color space
xticklabels({'-180','-120','-80','-40','0','40','80','120','180'}) 
title('Average reconstructions','FontSize',14);
% ylim([0 round(max(mean(chan_resp_shift))+.01,2)]);
plot(ground_truth_basis)
ylim([0 1]);
xlim([20 180]);
legend('Model Reconstruction','Aligned, Correct Color','Perfect Reconstruction')

S1 = [mean([chan_resp_shift(:,1);chan_resp_shift(:,9)]),
    mean([chan_resp_shift(:,2);chan_resp_shift(:,8)]),
    mean([chan_resp_shift(:,3);chan_resp_shift(:,7)]),
    mean([chan_resp_shift(:,4);chan_resp_shift(:,6)]),
    mean([chan_resp_shift(:,5)])];
slope1 = polyfit(S1',min(S1):(max(S1)-min(S1))/4:max(S1),1);
slope1 = slope1(1);
% print('Recon_ColorROI_RH_e15.png','-dpng');

% %% Combine channel resp and plot avg reconstruction for session 2 data
% ou2 = unique(mydata2.conds); 
% ou2 = ou2(~isnan(ou2));
% targ_chan = ceil(n_ori_chans/2);
% 
% chan_resp_shift2 = [];
% for ii = 1:size(chan_resp2,1)
%     if ~isnan(mydata2.conds(ii))
%         chan_resp_shift2(end+1,:) = circshift(chan_resp2(ii,:),targ_chan-find(ou2==mydata2.conds(ii)),2);
%     end
% end
% 
% figure
% plot(rad2deg(chan_center_rad),mean(chan_resp_shift2),'LineWidth',5);
% hold on;
% plot([rad2deg(chan_center_rad(targ_chan)) rad2deg(chan_center_rad(targ_chan))],[0 1],':c','LineWidth',5)
% xlabel('Color channel (\circ)','FontSize',14);
% ylabel('Channel response (BOLD Z-Score)','FontSize',14);
% % sinusoid basis function goes from 0 to 180, need to convert back over to color space
% xticklabels({'-180','-120','-80','-40','0','40','80','120','180'}) 
% title('Average reconstructions','FontSize',14);
% % ylim([0 round(max(mean(chan_resp_shift2))+.01,2)]);
% plot(ground_truth_basis)
% ylim([0 1]);
% xlim([20 180]);
% legend('Model Reconstruction','Aligned, Correct Color','Perfect Reconstruction')
% 
% S2 = [mean([chan_resp_shift2(:,1);chan_resp_shift2(:,9)]),
%     mean([chan_resp_shift2(:,2);chan_resp_shift2(:,8)]),
%     mean([chan_resp_shift2(:,3);chan_resp_shift2(:,7)]),
%     mean([chan_resp_shift2(:,4);chan_resp_shift2(:,6)]),
%     mean([chan_resp_shift2(:,5)])];
% slope2 = polyfit(S2',min(S2):(max(S2)-min(S2))/4:max(S2),1);
% slope2 = slope2(1);
