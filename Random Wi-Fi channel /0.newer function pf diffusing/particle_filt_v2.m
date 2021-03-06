function [mean_rmse_pf,rmse_pf,CI]=particle_filt_v2(fingerprint_map, power, X, X1,var_OBS, N_PART, SIGMA_W, dt, print_figures,MCruns)

%==========================================================================
% SMC [Sequential Monte Carlo ]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constant parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
New1=power;
New2=fliplr(flip(power));
New3=fliplr(power);
New4=flipud(power);

randn('seed',9999);
rand('seed',9999);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X_MIN  = 0;
X_MAX  = length(power(:,:,1));
X1_MIN = 0 ; % the state space domain
X1_MAX = length(power(:,:,1)); %          "
X2_MIN = 0 ; %          "
X2_MAX = length(power(:,:,1));  %          "

%%
SIGMA_OBS = sqrt(var_OBS); % standard deviation for the observation noise

% SIGMA2_OBS = SIGMA_OBS*SIGMA_OBS;

%N_PART  = 1000 ; % number of particles
%SIGMA_W = var_W; %bug std=var  % standard deviation for the state process noise

NUMBER_OF_OBS = length(X); % number of observations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp(' >>> STEP 1: interactive contruction of the geometry of the problem')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- the observation sites -----------------------------------------------
% clf;
% axis([X1_MIN X1_MAX X2_MIN X2_MAX ]);
% axis square;
% hold on;

x=length(New1);
y=length(New1);

X1_SITES = [x/4,x-x/4,x-x/4,x/4];
X2_SITES = [y/4,y-y/4,y/4,y-y/4];
N_SITES  = length(X1_SITES);


X1_TRAJ=X(1,:);
X2_TRAJ=X(2,:);
N_TRAJ  = length(X);

% plot(X1_TRAJ,X2_TRAJ,'r-',round(X1_TRAJ),round(X2_TRAJ),'g-.');

F = [0 0 1 0;
    0 0 0 1;
    0 0 0 0;
    0 0 0 0];
[A,Q] = lti_disc(F,[],diag([SIGMA_W SIGMA_W 0 0]),dt); % Discretization for state transition matrix A and noise matrix Q


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp(' >>> STEP 2: observation simulation')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% r1=5e-11; % variance of measurement noise

for j=1:N_TRAJ
    Newer1(1,j)=abs(New1(round(X1_TRAJ(j)),round(X2_TRAJ(j))));
end

%Measurement 2
for j=1:N_TRAJ
    Newer2(1,j)=abs(New2(round(X1_TRAJ(j)),round(X2_TRAJ(j))));
end

%Measurement 3
for j=1:N_TRAJ
    Newer3(1,j)=abs(New3(round(X1_TRAJ(j)),round(X2_TRAJ(j))));
end
%Measurement 4
for j=1:N_TRAJ
    Newer4(1,j)=abs(New4(round(X1_TRAJ(j)),round(X2_TRAJ(j))));
end
observation_true1=[Newer1;Newer2;Newer3;Newer4];
for v=1:MCruns
    
    observation_true=[Newer1;Newer2;Newer3;Newer4]...
        +[SIGMA_OBS 0 0 0;0 SIGMA_OBS 0 0;0 0 SIGMA_OBS 0;0 0 0 SIGMA_OBS] * randn(4,N_TRAJ);
    % observation_true(observation_true<0)=0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %disp(' >>> STEP 3:  filter');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % fprintf('           [press RETURN to proceed] ... ');
    % pause
    
    % --- particles initialization --------------------------------------------
    X= 25*A*[rand(4,N_PART)];
    
    
    kill_negatives=[X]';
    kill_negatives(kill_negatives(:,1)<(X_MIN+0.5),:)=[];
    kill_negatives(kill_negatives(:,2)<(X_MIN+0.5),:)=[];
    kill_negatives(kill_negatives(:,1)>(X_MAX-0.5),:)=[];
    kill_negatives(kill_negatives(:,2)>(X_MAX-0.5),:)=[];
    kill_negatives=kill_negatives';
    X=kill_negatives;
    N_PART_OUT=length(X);
    
    % --- iterations ----------------------------------------------------------
    X_alt=[X];
    
    for n=1:N_TRAJ % begining of the time loop
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % prediction
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        X = A * X + SIGMA_W * [randn(2,N_PART_OUT);
            zeros(2,N_PART_OUT)];
        for l=1:length(X)
            
            if  (X(1,l)<=(X_MIN+0.5))
                if (n==1)
                    X(1,l)=X_alt(1,l);
                else
                    X(1,l)=X_mean(1,n-1);
                end
            end
            
            if  (X(2,l)<=(X_MIN+0.5))
                if (n==1)
                    X(2,l)=X_alt(2,l);
                else
                    X(2,l)=X_mean(2,n-1);
                end
            end
            
            if (X(1,l)>=(X_MAX-0.5))
                if (n==1)
                    X(1,l)=X_alt(1,l);
                else
                    X(1,l)=X_mean(1,n-1);
                end
            end
            
            if  (X(2,l)>=(X_MAX-.5))
                if (n==1)
                    X(2,l)=X_alt(2,l);
                else
                    X(2,l)=X_mean(2,n-1);
                end
            end
        end
        finger1=fingerprint_map;
        finger2=flip(fliplr(fingerprint_map));
        finger3=fliplr(fingerprint_map);
        finger4=flipud(fingerprint_map);
        
        for ii=1:N_PART_OUT
            Pre1(ii)=abs(finger1(round(X(1,ii)),round(X(2,ii))));
            Pre2(ii)=abs(finger2(round(X(1,ii)),round(X(2,ii))));
            Pre3(ii)=abs(finger3(round(X(1,ii)),round(X(2,ii))));
            Pre4(ii)=abs(finger4(round(X(1,ii)),round(X(2,ii))));
        end
        observation_predicted=[Pre1;Pre2;Pre3;Pre4];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % likelihood
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        lklhd  = ones(1,N_PART_OUT);
        temp=1;
        for n_site=1:4
            
            %          for i=1:N_PART
            %               logl(1:N_PART) = observation_true(n_site,n) ...
            %                   - observation_predicted(n_site,1:N_PART);
            %               lklhd(1:N_PART) = ...
            %                  temp.* exp(-(1/SIGMA2_OBS)*logl(1:N_PART).*logl(1:N_PART));
            lklhd(1:N_PART_OUT)=temp.*normpdf(observation_true(n_site,n),observation_predicted(n_site,1:N_PART_OUT),SIGMA_OBS);
            temp=lklhd(1:N_PART_OUT);
            %          end
        end
        
        % normalization
        normalization = sum(lklhd);
        if normalization == 0
            lklhd = ones(1,N_PART_OUT)/N_PART_OUT;
            disp('  warning : null likelihood -> particles positions reset');
            X=A*X+SIGMA_W*[randn(2,N_PART_OUT);
                randn(2,N_PART_OUT)];
        else
            lklhd=lklhd/normalization;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % selection
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        offsprings = f_resample_comb_randshift(lklhd);
        indices    = f_resample_indices(offsprings);
        
        X=X(:,indices);
        X_alt_in=X;
       
        X_mean(:,n) = mean(X,2);
    end
    
    rmse_pf(v)=sqrt(mean(((X1_TRAJ(1,:)-X_mean(1,:)).^2)+((X2_TRAJ(1,:)-X_mean(2,:)).^2)));
end

mean_rmse_pf=mean(rmse_pf);

confi_int=rmse_pf;
SEM = std(confi_int)/sqrt(length(confi_int));               % Standard Error
ts = tinv([0.01  0.99],length(confi_int)-1);      % T-Score
CI = mean(confi_int) + ts*SEM;
CI(CI<=0)=0;

end
