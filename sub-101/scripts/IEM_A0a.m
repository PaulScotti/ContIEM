% PS IEM ContLTM 2018/2019, with much help thanks to Emma Wu Dowd, Julie Golomb, and Tommy Sprague
for ROI = ["V4vs","ColorROIs","LOCs"] %ColorROIs V4v LOC
close all;
clearvars -except ROI
subjID = 101;
home = '/lab/Paul/ContIEM/';
addpath(genpath(home)) % add subfolders to path
cd(home);
SubjNum=101;

%% Load betas from ROI (some functions require MATLAB 2019a or later!!)
% loads in whole-brain mydata, constrain voxels using ROI mask

load(strcat(home,num2str(SubjNum),'/Session_1/ColorEncoder/',ROI,'.nii_betas.mat'));

% how many voxels are in this ROI?
fprintf('num voxels: %i \n',size(mydata.betas,2));

%% Create basis set
mydata.conds = mydata.conds+40; %convert from 0-320 to 40-360 scale

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
imagesc(stim_mask);
title('Stimulus mask');
xlabel('Color');ylabel('Trial');

%% Generate design matrix
desMat = stim_mask*basis_set;

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
ru = unique(mydata.runs);
n_runs = length(ru);

chan_resp = nan(size(desMat));
mydata.betas(isnan(mydata.betas))=0;
for rr = 1:n_runs
    %% Cross-validation one-run-left-out %%
    trnIdx = mydata.runs~=ru(rr);
    tstIdx = mydata.runs==ru(rr);
    
    % identify the training & testing halves of the data: leave-two-runs-out cross-validation
%     ru2 = circshift(ru,-1);
%     trnIdx = mydata.runs ~= ru(rr) & mydata.runs ~= ru2(rr);
%     tstIdx = mydata.runs == ru(rr) | mydata.runs == ru2(rr);

    %% Voxel selection %%
    vox_prctile = 100;
    if vox_prctile < 100
        ps = nan(size(mydata.betas,2),1);
        for ii = 1:size(mydata.betas,2)
        % we have 9 groups, corresponding to each channel, and anova1 computes likelihood that all 
        % groups have the same values, and a smaller p-value roughly means that this null is less likely
            ps(ii) = anova1(mydata.betas(trnIdx,ii),mydata.conds(trnIdx),'off');
        end

        % only use voxels that were top x%, determined by one-way anova
        which_vox = ps <= prctile(ps,vox_prctile);
        trnX = mydata.betas(trnIdx,which_vox);
        tstX = mydata.betas(tstIdx,which_vox);
    else
        trnX = mydata.betas(trnIdx,:);
        tstX = mydata.betas(tstIdx,:);
    end
    %%%%%%
    
    B1=trnX';
    B2=tstX';
    C1=desMat(trnIdx,:)';
    
    W = B1*C1'*inv(C1*C1');
    
    chan_resp(tstIdx,:) = (pinv(W'*W)*W'*B2)';
end
weights=W;

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
    chan_resp_shift(end+1,:) = circshift(chan_resp(ii,:),targ_chan-find(ou==mydata.conds(ii)),2);
end

%% Reconstruction fidelity %%
% Cosine Approach %
close all;
figure()
for ang = 1:360
    x = ceil(ang/40); 
    xx = mean(chan_resp_shift);
    if x<size(xx,2)
        h = linspace(xx(x),xx(x+1),40);
    else
        h = linspace(xx(x),xx(1),40);
    end
    h_ind = mod(ang,40); 
    if h_ind==0
        h_ind = 40;
    end
    r(ang) = h(h_ind); %160 deg = ideal max point
    c(ang) = cos(abs(deg2rad(160)-deg2rad(ang)));
end
b = r .* c;
btxt = sprintf('%.3f',mean(b));
disp(strcat("Fidelity (cosine approach): ", num2str(mean(b))))

plot(b); hold on; plot(c);plot(r);
plot(160,mean(b),'b+');
title(strcat('Fidelity (mean of dot product) = ',num2str(mean(b))))
legend("Dot product","Cosine","Reconstruction")

% Gaussian Fitting Approach %
figure()

%normalize reconstruction's y-axis so that SSE can be on same scale
ydata = (r-min(r)) / (max(r)-min(r)); 
xdata=1:360;
mu=160;

% define function
fun = @(arg)arg(1)+arg(2)*exp(arg(3)*cos(deg2rad(xdata-mu)))-ydata;

% define arbitrary initial guesses for flexible parameters
yo=0;A=0;K=deg2rad(90);

%resnorm = residual sum of squares 
[out,resnorm,residual] = lsqnonlin(fun,[yo,A,K]);

plot(xdata,ydata,'b')
hold on;
plot(xdata,out(1)+out(2)*exp(out(3)*cos(deg2rad(xdata-mu))),'r')

sd = rad2deg(k2sd(out(3)));

disp(strcat("SD=", num2str(sd), " SSE=",num2str(resnorm)))

legend("Reconstruction","Gaussian Approx")
title(strcat("SD=", num2str(sd), ", SSE=",num2str(resnorm)))

fit=[mean(b),sd,resnorm];
save(strcat(home,num2str(SubjNum),'/Session_1/iem_plots/A0a_fit',ROI),'fit');

%% Plot average reconstructed response for all trials
ground_truth_basis = basis_set(:,5);
ground_truth_basis = ground_truth_basis(1:2:length(ground_truth_basis));

close all;
plot(rad2deg(chan_center_rad),mean(chan_resp_shift),'LineWidth',5);
hold on;
plot([rad2deg(chan_center_rad(targ_chan)) rad2deg(chan_center_rad(targ_chan))],[0 1],':c','LineWidth',5)
xlabel('Color channel (\circ)','FontSize',14);
ylabel('Channel response (a.u.)','FontSize',14);
% sinusoid basis function goes from 0 to 180, need to convert back over to color space
xticklabels({'-180','-120','-80','-40','0','40','80','120','180'}) 
title(strcat('Fidelity: ',btxt),'FontSize',14);
ylim([round(min(mean(chan_resp_shift))-.01,2) round(max(mean(chan_resp_shift))+.01,2)]);
% plot(ground_truth_basis)
% ylim([0 1]);
xlim([20 180]);
%legend('Model Reconstruction','Aligned, Correct Color','Perfect Reconstruction')
print(strcat(home,num2str(SubjNum),'/Session_1/iem_plots/A0a_',ROI),'-dpng');

end


