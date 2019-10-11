function [cost] = calcCostBaseline2(f,fe,fx,s,d,p,obs,info)
% cost function used for the baseline model
% cost      = costTWS + costSWE + costET + costSM + costQ
% costTWS   = wMEF(TWS)
% costSWE   = wMEF(SWE)
% costET    = wMEF(ET)
% costSM    = sign(cor(SM))*cor(SM)^2
% costQ     = wMEF(MSC_Q)
% [costTotal,costTWS,costSWE,costET,costSM,costQ]=calcCostBaseline2(f,fe,fx,s,d,p,obs,info)


%% calculate tVec
% needs to go somewhere else
days        = length(info.tem.helpers.dates.day);
months      = length(info.tem.helpers.dates.month);
xMonth      = info.tem.helpers.dates.month;
[~,tVec,~]  = datevec(xMonth);

%% get constraints, their uncertainties and simulations
% except for TWS all uncertainties are still calculated within this
% function
try
    TWSobs          = obs.TWS.data;
    TWSobs_uncert   = obs.TWS.unc;
    SWEobs          = obs.SWE.data;
    ETobs           = obs.Evap.data;
    ETobs_uncert    = obs.Evap.unc;
    SMobs           = obs.wSoil.data;
    SMobs_uncert    = obs.wSoil.unc;
    Qobs            = obs.Q.data;
catch
    warning('ERR: TWS, SWE, ET, SM, Q or TWS, ET, SM uncertainty missing in observational constraints!');
end


%% get the modelled fluxes
% TWS
if isfield(d.storedStates,'wTWS')
    TWSmod_d = squeeze(d.storedStates.wTWS);
else
    error('ERR: wTWS  missing in model output!');
end

% SWE
if isfield(d.storedStates,'wSnow')
    SWEmod_d  = squeeze(d.storedStates.wSnow);
else
    error('ERR: wSnow  missing in model output!');
end

% ET
if isfield(fx,'ET')
    ETmod_d =  fx.ET;
else
    error('ERR: ET  missing in model output!');
end

% SM
if isfield(d.storedStates,'wSoil')
    SMmod_d  = squeeze(d.storedStates.wSoil(:,1,:));
else
    error('ERR: wSoil  missing in model output!');
end

% Q
if isfield(fx,'Q')
    Qmod_d =  fx.Q;
else
    error('ERR: Q  missing in model output!');
end

% Monthly Aggregation of simulations
TWSmod      = aggDay2Mon(TWSmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
SWEmod      = aggDay2Mon(SWEmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
ETmod       = aggDay2Mon(ETmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
SMmod       = aggDay2Mon(SMmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
Qmod        = aggDay2Mon(Qmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate costs
%  not needed to check obs ~isnan before absRes
% valid data points
v_sm    = find(~isnan(SMobs));

% TWS as time mean
TWSmod(isnan(TWSobs)) = NaN;
m       = nanmean(TWSmod,2);
TWSmod  = TWSmod-repmat(m,1,months);

% only for obs not NaN & excluding 95th percentile
absResTWS   =   abs(TWSobs-TWSmod);
pct95TWS    =   prctile(absResTWS(:), 95);
v_tws       =   find(absResTWS < pct95TWS);

absResSWE   =   abs(SWEobs-SWEmod);
pct95SWE    =   prctile(absResSWE(:), 95);
v_swe       =   find(absResSWE < pct95SWE);

absResET    =   abs(ETobs-ETmod); 
pct95ET     =   prctile(absResET(:), 95);
v_et        =   find(absResET < pct95ET);

absResQ     =   abs(Qobs-Qmod); 
pct95Q      =   prctile(absResQ(:), 95);
v_q         =   find(absResQ < pct95Q);



%%%%% weighted MEF for TWS
sq_resid    =   sum((TWSobs(v_tws)-TWSmod(v_tws)).^2./(TWSobs_uncert(v_tws).^2));
sq_var      =   sum((TWSobs(v_tws)-mean(TWSobs(v_tws))).^2./(TWSobs_uncert(v_tws).^2));

costTWS     =   sq_resid/sq_var;

%%%%% weighted MEF for SWE, with maximum SWE = threshold
swe_thresh                  =   100; % saturation threshold SWEobs = 100 mm
SWEobs                      =   SWEobs(v_swe);
SWEmod                      =   SWEmod(v_swe);
SWEobs(SWEobs>swe_thresh)   =   swe_thresh;
SWEmod(SWEmod>swe_thresh)   =   swe_thresh;
sig                         =   (SWEobs.*0+35).^2; % 35 mm uncertainty
sq_resid                    =   sum((SWEobs(:)-SWEmod(:)).^2./sig(:));
sq_var                      =   sum((SWEobs(:)-mean(SWEobs(:))).^2./sig(:));

costSWE     =   sq_resid/sq_var;

%%%%% weighted MEF for ET with ET uncertainty
ETobs          =   ETobs(v_et);
ETobs_uncert   =   ETobs_uncert(v_et);
ETmod          =   ETmod(v_et);

sq_resid    =   sum((ETobs(:)-ETmod(:)).^2 ./ ETobs_uncert(:).^2);
sq_var      =   sum((ETobs(:)-mean(ETobs(:))).^2 ./ ETobs_uncert(:).^2);

costET      =   sq_resid/sq_var;

%%%%% correlation for SM
corSM       = corr(SMobs(v_sm),SMmod(v_sm));
costSM      = 1-sign(corSM)*corSM^2; %because the lower the better

%%%%% weighted MEF for MSC of Q with 10 % uncertainty
% only use data > 95th Pct and Qmod where Qobs exists
Qobs_v          =   NaN(size(Qobs));
Qmod_v          =   NaN(size(Qmod));
Qobs_v(v_q)     =   Qobs(v_q);
Qmod_v(v_q)     =   Qmod(v_q);

% calculate MSC
Qobs_MSC        =   calcMSC(Qobs_v,tVec);
Qmod_MSC        =   calcMSC(Qmod_v,tVec);

% remove pixel with NaN in Qobs
v_q2        =   find(~isnan(Qobs_MSC));

sig         =   max((0.1.*Qobs_MSC).^2,0.1^2); % 0.1 relative uncertainty, if Qobs = 0 0.1 mm
sq_resid    =   sum((Qobs_MSC(v_q2)-Qmod_MSC(v_q2)).^2./sig(v_q2));
sq_var      =   sum((Qobs_MSC(v_q2)-mean(Qobs_MSC(v_q2))).^2./sig(v_q2));

costQ       =   sq_resid/sq_var;

%% total costs
% one value if in opti mode, all values if not
costTotal        =   costTWS+costSWE+costET+costSM+costQ;

% complex?
if ~isreal(costTotal)
    error(['comlex costs!'])
end

%%% added by sujan to avoid having more than one output argument in the cost
%%% function
if info.tem.model.flags.runOpti
    cost            =   costTotal;
else
    cost            =   struct;
    cost.Total      =   costTotal;
    cost.TWS        =   costTWS;
    cost.SWE        =   costSWE;
    cost.ET         =   costET;
    cost.SM         =   costSM;
    cost.Q          =   costQ;
end
end
