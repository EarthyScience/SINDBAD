function [cost] = calcCostBaseline0(f,fe,fx,s,d,p,obs,info)
% cost function used in the TWS Paper (Trautmann et al. 2018)
% tVec      = vector with month (M)
% cost      = costTWS + costSWE + costET + costQ
% costTWS   = wMEF(TWS)
% costSWE   = wMEF(SWE)
% costET    = wMEF(MSC_ET)
% costQ     = wMEF(MSC_Q)
% [costTotal,costTWS,costSWE,costET, costQ]=calcCostBaseline0(tVec,TWSobs,TWSobs_uncert,TWSmod,SWEobs,SWEmod,ETobs,ETmod,Qobs,Qmod,v_tws,v_swe,v_q)


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
    TWS_days        = obs.TWS.qflag;
    SWEobs          = obs.SWE.data;
    SWE_days        = obs.SWE.qflag;
    ETobs           = obs.Evap.data;
    ETobs_uncert    = obs.Evap.unc;
    Qobs            = obs.Q.data;
catch
    warning('ERR: TWS, SWE, ET, Q or TWS, ET uncertainty missing in observational constraints!');
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

% Monthly aggregation of TWS
TWSmod      = agg2qflag(TWSmod_d,TWS_days);

% apply the quality flag for daily values
SWEmod_d(SWE_days==0) = NaN;

% Monthly Aggregation of simulations
SWEmod      = aggDay2Mon(SWEmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
ETmod       = aggDay2Mon(ETmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
Qmod        = aggDay2Mon(Qmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);



%% Calculate costs
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

%%%%% weighted MEF for MSC of ET with ET uncertainty
ETobs_v          =   NaN(size(ETobs));
ETobs_uncert_v   =   NaN(size(ETobs_uncert));
ETmod_v          =   NaN(size(ETmod));

ETobs_v(v_et)          =   ETobs(v_et);
ETobs_uncert_v(v_et)   =   ETobs_uncert(v_et);
ETmod_v(v_et)          =   ETmod(v_et);

ETobs_MSC           =   calcMSC(ETobs_v,tVec);
ETobs_uncert_MSC    =   calcMSC(ETobs_uncert_v,tVec);
ETmod_MSC           =   calcMSC(ETmod_v,tVec);

% remove pixel with NaN in ETobs
v_et2       =   find(~isnan(ETobs_MSC));

sq_resid    =   sum((ETobs_MSC(v_et2)-ETmod_MSC(v_et2)).^2 ./ ETobs_uncert_MSC(v_et2).^2);
sq_var      =   sum((ETobs_MSC(v_et2)-mean(ETobs_MSC(v_et2))).^2 ./ ETobs_uncert_MSC(v_et2).^2);

costET      =   sq_resid/sq_var;

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
costTotal        =   costTWS+costSWE+costET+costQ;

% complex?
if ~isreal(costTotal)
    error(['complex costs!'])
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
    cost.Q          =   costQ;
end
end
