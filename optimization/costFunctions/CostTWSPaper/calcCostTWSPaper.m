function [cost, costComps] = calcCostTWSPaper(f,fe,fx,s,d,p,obs,info)
% cost function used in the TWS Paper (Trautmann et al. 2018)
% tVec      = vector with month (M)
% cost      = costTWS + costSWE + costET + costQ
% costTWS   = wMEF(TWS)
% costSWE   = wMEF(SWE)
% costET    = wMEF(MSC_ET)
% costQ     = wMEF(MSC_Q)
% [costTotal,costTWS,costSWE,costET, costQ]=calcCostTWSPaper(tVec,TWSobs,TWSobs_uncert,TWSmod,SWEobs,SWEmod,ETobs,ETmod,Qobs,Qmod,v_tws,v_swe,v_q)


%% calculate tVec
% needs to go somewhere else

days        = length(info.tem.helpers.dates.day);
months      = length(info.tem.helpers.dates.month);
xMonth      = info.tem.helpers.dates.month;
[~,tVec,~]  = datevec(xMonth);

etComps = {'evapSoil'};%{'EvapSoil'};
ETmod_d = info.tem.helpers.arrays.zerospixtix;
for etC = 1:numel(etComps)
    compName = char(etComps{etC});
    if isfield(fx,compName)
        ETmod_d = ETmod_d + fx.(compName);
    end
end
QComps = {'roTotal'};
Qmod_d = info.tem.helpers.arrays.zerospixtix;
for etC = 1:numel(QComps)
    compName = char(QComps{etC});
    if isfield(fx,compName)
        Qmod_d = Qmod_d + fx.(compName);
    end
end
%% get constraints, their uncertainties and simulations
% except for TWS all uncertainties are still calculated within this
% function
try
    TWSobs          = obs.TWS.data;
    TWSobs_uncert   = obs.TWS.unc; %sujan
    SWEobs          = obs.SWE.data;
    ETobs           = obs.Evap.data;
    Qobs            = obs.Q.data;
catch
    warning('ERR: TWS, SWE, ET, Q or TWS uncertainty missing in observational constraints!');
end

% Monthly Aggregation of simulations
try 
    if isfield(d.storedStates, 'wTotal')
    TWSmod_d    = squeeze(d.storedStates.wTotal);
    else
    TWSmod_d    = squeeze(d.storedStates.wSoil+d.storedStates.wSnow+d.storedStates.wSurf);
    end
    TWSmod      = aggDay2Mon(TWSmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
catch
    error('ERR: TWS  missing in model output!');
end
try
    SWEmod      = aggDay2Mon(squeeze(d.storedStates.wSnow),info.tem.model.time.sDate,info.tem.model.time.eDate);
catch
    error('ERR: SWE missing in model output!');
end
try
    ETmod       = aggDay2Mon(ETmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
catch
    error('ERR: Evap  missing in model output!');
end
try
    Qmod        = aggDay2Mon(Qmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
catch
    error('ERR: Q  missing in model output!');
end



%% Calculate costs
% valid data points
v_tws = find(~isnan(TWSobs));
v_swe = find(~isnan(SWEobs));
v_et  = find(~isnan(ETobs));
v_q   = find(~isnan(Qobs));

% TWS as time mean
TWSmod(isnan(TWSobs)) = NaN;
m       = nanmean(TWSmod,2);
TWSmod  = TWSmod-repmat(m,1,months);

% only for obs not NaN & excluding 95th percentile
absResTWS   =   abs(TWSobs(v_tws)-TWSmod(v_tws));
pct95TWS    =   prctile(absResTWS, 95);
v_tws2      =   v_tws(absResTWS < pct95TWS);

absResSWE   =   abs(SWEobs(v_swe)-SWEmod(v_swe));
pct95SWE    =   prctile(absResSWE, 95);
v_swe2      =   v_swe(absResSWE < pct95SWE);

absResET     =   abs(ETobs-ETmod); % in theory would not need to check Qobs ~isnan before
pct95ET      =   prctile(absResET(v_et), 95);
v_et2        =   find(absResET < pct95ET);

absResQ     =   abs(Qobs-Qmod); % in theory would not need to check Qobs ~isnan before
pct95Q      =   prctile(absResQ(v_q), 95);
v_q2        =   find(absResQ < pct95Q);

% set Qmod to NaN where Qobs = NaN
Qmod(isnan(Qobs))  = NaN;

%%%%% weighted MEF for TWS
sq_resid    =   sum((TWSobs(v_tws2)-TWSmod(v_tws2)).^2./(TWSobs_uncert(v_tws2).^2));
sq_var      =   sum((TWSobs(v_tws2)-mean(TWSobs(v_tws2))).^2./(TWSobs_uncert(v_tws2).^2));

% aa1=sum((TWSobs(v_tws2)-TWSmod(v_tws2)).^2);
% aa2=sum((TWSobs(v_tws2)-mean(TWSobs(v_tws2))).^2);

% aa=aa1/aa2;

costTWS     =   sq_resid/sq_var;

%%%%% weighted MEF for SWE, with maximum SWE = threshold
swe_thresh                  =   100; % saturation threshold SWEobs = 100 mm
SWEobs                      =   SWEobs(v_swe2);
SWEmod                      =   SWEmod(v_swe2);
SWEobs(SWEobs>swe_thresh)   =   swe_thresh;
SWEmod(SWEmod>swe_thresh)   =   swe_thresh;
sig                         =   (SWEobs.*0+35).^2; % 35 mm uncertainty
sq_resid                    =   sum((SWEobs(:)-SWEmod(:)).^2./sig(:));
sq_var                      =   sum((SWEobs(:)-mean(SWEobs(:))).^2./sig(:));

costSWE     =   sq_resid/sq_var;

%%%%% weighted MEF for MSC of ET with 10% uncertainty
ETobs_v          =   NaN(size(ETobs));
ETmod_v          =   NaN(size(ETmod));
ETobs_v(v_et2)   =   ETobs(v_et2);
ETmod_v(v_et2)   =   ETmod(v_et2);

ETobs_MSC   =   calcMSC(ETobs_v,tVec);
ETmod_MSC   =   calcMSC(ETmod_v,tVec);

% remove pixel with NaN in ETobs
v_et3       =   find(~isnan(ETobs_MSC)); 

sig         =   max((0.1.*ETobs_MSC(v_et3)).^2,0.1^2); % 0.1 relative uncertainty, if ETobs = 0 0.1 mm
sq_resid    =   sum((ETobs_MSC(v_et3)-ETmod_MSC(v_et3)).^2./sig(:));
sq_var      =   sum((ETobs_MSC(v_et3)-mean(ETobs_MSC(v_et3))).^2./sig(:));

costET      =   sq_resid/sq_var;

%%%%% weighted MEF for MSC of Q with 10 % uncertainty
% only use data > 95th Pct and Qmod where Qobs exists
Qobs_v          =   NaN(size(Qobs));
Qmod_v          =   NaN(size(Qmod));
Qobs_v(v_q2)    =   Qobs(v_q2);
Qmod_v(v_q2)    =   Qmod(v_q2);

% calculate MSC
Qobs_MSC        =   calcMSC(Qobs_v,tVec);
Qmod_MSC        =   calcMSC(Qmod_v,tVec);

% remove pixel with NaN in Qobs
v_q3        =   find(~isnan(Qobs_MSC));

sig         =   max((0.1.*Qobs_MSC).^2,0.1^2); % 0.1 relative uncertainty, if Qobs = 0 0.1 mm
sq_resid    =   sum((Qobs_MSC(v_q3)-Qmod_MSC(v_q3)).^2./sig(v_q3));
sq_var      =   sum((Qobs_MSC(v_q3)-mean(Qobs_MSC(v_q3))).^2./sig(v_q3));

costQ       =   sq_resid/sq_var;

%% total costs
% one value if in opti mode, all values if not
costTotal        =   costTWS+costSWE+costET+costQ;

% complex?
if ~isreal(costTotal)
    error(['comlex costs!'])
end

%% output
cost                 =   costTotal;

costComps            =   struct;
costComps.Total      =   costTotal;
costComps.TWS        =   costTWS;
costComps.SWE        =   costSWE;
costComps.ET         =   costET;
costComps.Q          =   costQ;

end
