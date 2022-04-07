function [cost, costComps] = CostBaseline_Area_2xET_05xSM(f,fe,fx,s,d,p,obs,info)
% baseline cost function using robust metrics, data uncertainty and area
% weights
% tVec      = vector with month (M)
% cost      = costTWS + costSWE + costSM + costET + costQ
% costTWS   = weighted robust MEF(TWS)
% costSWE   = weighted robust MEF(SWE)
% costSM    = 'robust' correlation (SM), weighted by factor of 0.5
% costET    = weighted robust MEF(ET), weighted by factor of 2
% costQ     = robust MEF(MSC_Q)
% [cost, costComps]    = calcCostBaseline([],[],fx,[],d,[],obs,info)


%%  ----------- time & area  stuff ----------- 
% needs to go somewhere else
days        = length(info.tem.helpers.dates.day);
months      = length(info.tem.helpers.dates.month);
xMonth      = info.tem.helpers.dates.month;
[~,tVec,~]  = datevec(xMonth);

gridArea    = repmat(info.tem.helpers.dimension.space.areaPix,1,days);
gridArea_m  = repmat(info.tem.helpers.dimension.space.areaPix,1,months);

% threshold for SWE
swe_thrs    = 100;

%%  ----------- get constraints  ----------- 

try
    TWSobs          = obs.TWS.data;
    TWSobs_uncert   = obs.TWS.unc .* gridArea_m;
%     TWS_days        = obs.TWS.qflag;
    SWEobs          = obs.SWE.data;
    SWEobs(SWEobs>swe_thrs)  =   100;
    SWEobs          = SWEobs .* gridArea_m; % SWE threshold
    SWEobs_uncert   = obs.SWE.unc .* gridArea_m;
    SWE_days        = obs.SWE.qflag;
    ETobs           = obs.Evap.data .* gridArea_m;
    ETobs_uncert    = obs.Evap.unc .* gridArea_m;
    Qobs            = obs.Q.data .* gridArea_m;
    Qobs_uncert     = obs.Q.unc .* gridArea_m;
    SMobs           = obs.wSoil.data .* gridArea_m;
    SMobs_uncert    = obs.wSoil.unc .* gridArea_m;
    SM_days         = obs.wSoil.qflag;
catch
    warning('ERR: TWS, SWE, SM, ET, Q, their uncertainty or days used to calculate monthly values are missing in observational constraints!');
end


%%  ----------- get the modelled fluxes  ----------- 
% TWS
if isfield(d.storedStates,'wTotal')
    TWSmod_d = reshape(d.storedStates.wTotal, info.tem.helpers.sizes.nPix, info.tem.helpers.sizes.nTix) .* gridArea;
    %TWSmod_d = squeeze(d.storedStates.wTotal).* gridArea;
else
    error('ERR: wTotal  missing in model output!');
end

% SWE
if isfield(d.storedStates,'wSnow')
    SWEmod_d  = reshape(d.storedStates.wSnow, info.tem.helpers.sizes.nPix, info.tem.helpers.sizes.nTix);
    %squeeze(d.storedStates.wSnow); % for SWE .* gridArea after monthly aggregation and removing of the threshold
else
    error('ERR: wSnow  missing in model output!');
end

% ET
if isfield(fx,'evapTotal')
    ETmod_d =  fx.evapTotal.* gridArea;
else
    error('ERR: evapTotal  missing in model output!');
end

% SM
if isfield(d.storedStates,'wSoil')
    SMmod_d = reshape(d.storedStates.wSoil(:,1,:), info.tem.helpers.sizes.nPix, info.tem.helpers.sizes.nTix).* gridArea;
    %SMmod_d  = squeeze(d.storedStates.wSoil(:,1,:)).* gridArea;
else
    error('ERR: wSoil  missing in model output!');
end

% Q
if isfield(fx,'roTotal')
    Qmod_d =  fx.roTotal.* gridArea;
else
    error('ERR: roTotal  missing in model output!');
end

%%  ----------- Preparations  ----------- 
% set TWSobs <= -500mm and >= 500mm to NaN
TWSobs(TWSobs<=-500) = NaN;
TWSobs(TWSobs>=500)  = NaN;
m       = nanmean(TWSobs,2);
TWSobs  = TWSobs-repmat(m,1,months);

TWSobs  = TWSobs .* gridArea_m;


% Monthly aggregation of TWS
%TWSmod      = agg2qflag(TWSmod_d,TWS_days); %seems to still have a bug...
TWSmod      = aggDay2Mon(TWSmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);

% TWS as time mean
TWSmod(isnan(obs.TWS.data)) = NaN;
m       = nanmean(TWSmod,2);
TWSmod  = TWSmod-repmat(m,1,months);

% apply the quality flag for daily values
SWEmod_d(isnan(SWE_days)) = NaN;
SMmod_d(isnan(SM_days))   = NaN;

% Monthly Aggregation of simulations
SWEmod      = aggDay2Mon(SWEmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
SWEmod(SWEmod>swe_thrs)  =   100;
SWEmod      = SWEmod.* gridArea_m;

SMmod       = aggDay2Mon(SMmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
ETmod       = aggDay2Mon(ETmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
Qmod        = aggDay2Mon(Qmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);

% not if obs = NaN
vTWS    = find(isnan(obs.TWS.data));
vSWE    = find(isnan(obs.SWE.data));
vSM     = find(isnan(obs.wSoil.data));
vET     = find(isnan(obs.Evap.data));
vQ      = find(isnan(obs.Q.data));

TWSmod(vTWS)= NaN;
SWEmod(vSWE)= NaN;
SMmod(vSM)  = NaN;
ETmod(vET)  = NaN;
Qmod(vQ)    = NaN;    

% calculate MSC of Q
Q_MSCobs        = calcMSC(Qobs,tVec);
Q_MSCmod        = calcMSC(Qmod,tVec);
Q_MSCobs_uncert = calcMSC(Qobs_uncert,tVec);


%% ----------- Calculate costs ----------- 
% should also work with (:) instead of (vTWS),..
vTWS    = find(~isnan(TWSobs));
vSWE    = find(~isnan(SWEobs));
vSM     = find(~isnan(SMobs));
vET     = find(~isnan(ETobs));
vQ      = find(~isnan(Q_MSCobs));

%%%%% weighted robust MEF for TWS
tws_resid   =   sum( abs(TWSobs(vTWS)-TWSmod(vTWS)) ./ abs(TWSobs_uncert(vTWS)) );
tws_var     =   sum( abs(TWSobs(vTWS)-mean(TWSobs(vTWS))) ./ abs(TWSobs_uncert(vTWS)) );

costTWS     =   tws_resid/tws_var;

%%%%% weighted robust MEF for SWE
if ~isempty(SWEobs(vSWE))
    swe_resid   =   sum( abs(SWEobs(vSWE)-SWEmod(vSWE)) ./ abs(SWEobs_uncert(vSWE)) );
    swe_var     =   sum( abs(SWEobs(vSWE)-mean(SWEobs(vSWE))) ./ abs(SWEobs_uncert(vSWE)) );
    
    costSWE     =   swe_resid/swe_var;
else
    costSWE     =   0;
end
%%%%% correlation for SM
if ~isempty(SMobs(vSM))
    corSM       =   corr(SMobs(vSM),SMmod(vSM), 'rows', 'pairwise');
    costSM      =   1-sign(corSM ) .* abs(corSM); % just: 1 - corSM ?
    costSM      =   costSM .* 0.5;
else
    costSM     =   0;
end
%%%%% weighted MEF for ET
et_resid    =   sum( abs(ETobs(vET)-ETmod(vET)) ./ abs(ETobs_uncert(vET)) );
et_var      =   sum( abs(ETobs(vET)-mean(ETobs(vET))) ./ abs(ETobs_uncert(vET)) );

costET      =   et_resid/et_var;
costET      =   costET .* 2;

%%%%% weighted MEF for MSC of Q 
q_resid     =   sum( abs(Q_MSCobs(vQ)-Q_MSCmod(vQ)) ./ abs(Q_MSCobs_uncert(vQ)) );
q_var       =   sum( abs(Q_MSCobs(vQ)-mean(Q_MSCobs(vQ))) ./ abs(Q_MSCobs_uncert(vQ)) );

% q_resid     =   sum( abs(Q_MSCobs(vQ)-Q_MSCmod(vQ)) );
% q_var       =   sum( abs(Q_MSCobs(vQ)-mean(Q_MSCobs(vQ))) );

costQ       =   q_resid/q_var;


%% total costs
% what variables to sum up
costTotal   = 0;
costComp    = info.opti.costFun.variables2constrain;
for cn = 1:numel(costComp)
    costTotal   =   costTotal + eval(char(['cost' costComp{cn} ';']));
end

%costTotal = costTWS + costSWE + costSM + costET + costQ

% complex?
if ~isreal(costTotal)
    error(['complex costs!'])
end

%% output
cost                 =   costTotal;

costComps            =   struct;
costComps.Total      =   costTotal;
costComps.TWS        =   costTWS;
costComps.SWE        =   costSWE;
costComps.SM         =   costSM;
costComps.ET         =   costET;
costComps.Q          =   costQ;


end
