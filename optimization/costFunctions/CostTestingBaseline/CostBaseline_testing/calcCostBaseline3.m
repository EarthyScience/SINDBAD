function [cost] = calcCostBaseline3(f,fe,fx,s,d,p,obs,info)
% cost function used for the baseline model
% cost      = costTWS + costSWE + costET + costSM + costQ
% costTWS   = wMEF(TWS)
% costSWE   = wMEF(SWE)
% costET    = wMEF(MSC_ET)
% costSM    = lagtime(SM)
% costQ     = wMEF(MSC_Q)
% [costTotal,costTWS,costSWE,costET,costSM,costQ]=calcCostBaseline1(f,fe,fx,s,d,p,obs,info)


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
    SMobsLag        = obs.wSoilLag.data;
    SMobsLag_idx    = obs.wSoilLagIdx.unc;
    Qobs            = obs.Q.data;
catch
    warning('ERR: TWS, SWE, ET, SM, Q or TWS, ET, SM uncertainty missing in observational constraints!');
end


%% get the modelled fluxes
twsComps = {'wTWS'};
TWSmod_d = info.tem.helpers.arrays.nanpixtix;
for twsC = 1:numel(twsComps)
    compName = char(twsComps{twsC});
    if isfield(d.storedStates,compName)
        TWSmod_d = TWSmod_d + squeeze(d.storedStates.(compName));
    end
end
if isnan(sum(TWSmod_d(:)))
    error('ERR: TWS  missing in model output!');
end

sweComps = {'wSnow'};
SWEmod_d = info.tem.helpers.arrays.nanpixtix;
for sweC = 1:numel(sweComps)
    compName = char(sweComps{sweC});
    if isfield(d.storedStates,compName)
        SWEmod_d = SWEmod_d + squeeze(d.storedStates.(compName));
    end
end
if isnan(sum(SWEmod_d(:)))
    error('ERR: SWE  missing in model output!');
end

etComps = {'ET'};
ETmod_d = info.tem.helpers.arrays.nanpixtix;
for etC = 1:numel(etComps)
    compName = char(etComps{etC});
    if isfield(fx,compName)
        ETmod_d = ETmod_d + fx.(compName);
    end
end
if isnan(sum(ETmod_d(:)))
    error('ERR: ET  missing in model output!');
end

smComps = {'wSoil'};
SMmod_d = info.tem.helpers.arrays.nanpixtix;
for smC = 1:numel(smComps)
    compName = char(smComps{smC});
    if isfield(d.storedStates,compName)
        SMmod_d = SMmod_d + squeeze(d.storedStates.(compName)(:,1,:));
    end
end
if isnan(sum(SMmod_d(:)))
    error('ERR: wSoil  missing in model output!');
end

QComps = {'Q'};
Qmod_d = info.tem.helpers.arrays.nanpixtix;
for etC = 1:numel(QComps)
    compName = char(QComps{etC});
    if isfield(fx,compName)
        Qmod_d = Qmod_d + fx.(compName);
    end
end
if isnan(sum(Qmod_d(:)))
    error('ERR: Q  missing in model output!');
end


% Monthly Aggregation of simulations
TWSmod      = aggDay2Mon(TWSmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
SWEmod      = aggDay2Mon(SWEmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
ETmod       = aggDay2Mon(ETmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);
Qmod        = aggDay2Mon(Qmod_d,info.tem.model.time.sDate,info.tem.model.time.eDate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate costs
%  not needed to check obs ~isnan before absRes

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

%%%%% time lag for SM
% compare the number of pixels
if size(SMmod_d,1) ~= size(SMobsLag,1)
    error('cost function: the number of pixels of modelled Soil Moisture and observational constraints do not agree!')
end
% loop over pixel
nPix            = size(SMmod_d,1);
SMmodLag        = NaN(nPix,1);
SMmodR          = NaN(nPix,1);
for pix=1:nPix
    [r,l]                 = xcorr(SMmod_d(pix,SMobsLag_idx(npix)),'coeff',30);
    [SMmodLag(pix), idx]  = min(l(r>exp(-1)));
    SMmodR(pix)           = r(idx);
end

% R2 of the lags
corSM   = corr(SMobsLag, SMmodLag);
%r2SM    = corSM^2 .* sign(corSM);
costSM  = 1-corSM; 

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
