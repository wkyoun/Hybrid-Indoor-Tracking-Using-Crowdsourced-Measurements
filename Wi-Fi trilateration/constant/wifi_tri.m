clc;clear all;close all;
%%
tic
print_figures=0;
MCruns=100;
%%
load nondiffusing.mat P_floor1
%power=cat(3,P_floor1,P_floor2,P_floor3,P_floor4);
%%
load curvy_decimeters.mat X X1
%%
n_loss=4; % path loss coefficient
sigma=[2 4 6 8 10]; % mW std sigma
NUMBER_OF_OBS=100; %
NUMBER_OF_TRAJ=1000; %
seed_traj=1; % repeat the experiments
seed_kal=0; %
r=[2.5e-15 7.5e-16 2.5e-16 7.5e-17 2.5e-17 7.5e-18 2.5e-18 7.5e-19];
dt=0.01;
N_PART=500;
 % VLC channel noise
SIGMA_W=0.3; % process noise
MCruns=10;
%%

%%
[P_log_dB_map,d_est_2,d]=log_normal_path_loss(n_loss,sigma(1)); %% log normal shadowing
[P_log_dB_map,d_est_4,d]=log_normal_path_loss(n_loss,sigma(2)); %% log normal shadowing
[P_log_dB_map,d_est_6,d]=log_normal_path_loss(n_loss,sigma(3)); %% log normal shadowing
[P_log_dB_map,d_est_8,d]=log_normal_path_loss(n_loss,sigma(4)); %% log normal shadowing
[P_log_dB_map,d_est_10,d]=log_normal_path_loss(n_loss,sigma(5)); %% log normal shadowing

figure
surf(abs(d_est_2-d))

d_true=d(:);
[yy_power_25,xx_power_25,~,~,eid] = cdfcalc(d_true);
k = length(xx_power_25);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF_d_true    = [-Inf; xx_power_25(n); Inf];
yCDF_d_true  = [0; 0; yy_power_25(1+n)];
% 
d_est_sigma_2=abs(d_est_2(:)-d(:));
[yy_power_25,xx_power_25,~,~,eid] = cdfcalc(d_est_sigma_2);
k = length(xx_power_25);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF_d_est_sigma_2  = [-Inf; xx_power_25(n); Inf];
yCDF_d_est_sigma_2  = [0; 0; yy_power_25(1+n)];


d_est_sigma_4=abs(d_est_4(:)-d(:));
[yy_power_25,xx_power_25,~,~,eid] = cdfcalc(d_est_sigma_4);
k = length(xx_power_25);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF_d_est_sigma_4  = [-Inf; xx_power_25(n); Inf];
yCDF_d_est_sigma_4  = [0; 0; yy_power_25(1+n)];

d_est_sigma_6=abs(d_est_6(:)-d(:));
[yy_power_25,xx_power_25,~,~,eid] = cdfcalc(d_est_sigma_6);
k = length(xx_power_25);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF_d_est_sigma_6  = [-Inf; xx_power_25(n); Inf];
yCDF_d_est_sigma_6  = [0; 0; yy_power_25(1+n)];


d_est_sigma_8=abs(d_est_8(:)-d(:));
[yy_power_25,xx_power_25,~,~,eid] = cdfcalc(d_est_sigma_8);
k = length(xx_power_25);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF_d_est_sigma_8  = [-Inf; xx_power_25(n); Inf];
yCDF_d_est_sigma_8  = [0; 0; yy_power_25(1+n)];

d_est_sigma_10=abs(d_est_10(:)-d(:));
[yy_power_25,xx_power_25,~,~,eid] = cdfcalc(d_est_sigma_10);
k = length(xx_power_25);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF_d_est_sigma_10  = [-Inf; xx_power_25(n); Inf];
yCDF_d_est_sigma_10  = [0; 0; yy_power_25(1+n)];

figure
cdfplot(d_est_sigma_2(1:10:end))
hold on
cdfplot(d_est_sigma_4(1:10:end))
cdfplot(d_est_sigma_6(1:10:end))
cdfplot(d_est_sigma_8(1:10:end))
legend(...,
strcat(' \sigma=2 dB'),...
strcat(' \sigma=4 dB'),...
strcat(' \sigma=6 dB'),...
strcat(' \sigma=8 dB'),...
      'Location','Best');
  ylabel('CDF of distance RMSE (cm)')
  xlabel('RMSE (dm)')
set(gca,'Fontsize',20)

% % 
% % figure
% % set(gca,'Fontsize',18)
% % hold on
% % plot(xCDF_d_est_sigma_2,100*yCDF_d_est_sigma_2,'--b','LineWidth',2,'MarkerSize',8)
% % plot(xCDF_d_est_sigma_4,100*yCDF_d_est_sigma_4,'-.k','LineWidth',2,'MarkerSize',8)
% % plot(xCDF_d_est_sigma_6,100*yCDF_d_est_sigma_6,'-r','LineWidth',2,'MarkerSize',8)
% % %  plot(xCDF_d_est_sigma_8,yCDF_d_est_sigma_8,'-.r','LineWidth',1.5,'MarkerSize',8)
% % % plot(xCDF_d_est_sigma_10,yCDF_d_est_sigma_10,'--g','LineWidth',1,'MarkerSize',8)
% % 
% % xlabel('RMSE (dm)')
% % %ylabel({'$P(RMSE \leq \textbf{x})$'},'Interpreter','latex')
% % ylabel('CDF of distance estimation Error')
% % legend(...,
% % strcat(' \sigma=2 dB'),...
% % strcat(' \sigma=4 dB'),...
% % strcat(' \sigma=6 dB'),...
% % strcat(' \sigma=8 dB'),...
% %       'Location','Best');
% % grid on
% % %strcat(' \sigma=10 dB'),...
