function K = calcKSaxton1986(s,p,info,sl)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate conductivity from soil moisture 
% based on saxton 1986, equation 10
% [Alpha,Beta,K,Theta,Psi] = calcSoilParams(p,fe,info,WT)
% 
% soilm_parm    : soil moisture parameter output array
% CLAY          : clay array
% SAND          : sand array
% WT            : Psi : water tension (kPa)
%               : wilting point     : 'WP'      : WT = 1500
%               : field capacity    : 'FC'      : WT = 33
%               : saturation        : 'Sat'     : WT = 10
%               : alpha             : 'alpha'
%               : beta              : 'beta'
% 
% Reference:
% Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
% Estimating generalized soil-water characteristics from texture. 
% Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
% http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% CONVERT SAND AND CLAY TO PERCENTAGES
if p.wSoilBase.makeLookup
    
    CLAY    = s.wd.p_wSoilBase_CLAY(:,sl) .* 100;
    SAND    = s.wd.p_wSoilBase_SAND(:,sl)  .* 100;
    soilD   = s.wd.p_wSoilBase_soilDepths(sl);
    
    % -------------------------------------------------------------------------
    % WATER CONDUCTIVITY (mm/day)
    Theta   = s.w.wSoil(:,sl) ./ soilD;
    K   = 2.778E-6 .*(exp(p.pSoil.p + p.pSoil.q .* SAND + ...
        (p.pSoil.r + p.pSoil.t .* SAND + p.pSoil.u .* CLAY + p.pSoil.v .*...
        CLAY .^ 2) .* (1 ./ Theta))) .* 1000 * 3600 * 24;
    % -------------------------------------------------------------------------
else
    soilD                                       =   s.wd.p_wSoilBase_soilDepths(sl);
    Theta                                       =   s.w.wSoil(:,sl) ./ soilD;
    Theta(Theta<0) = 0;
    Theta(imag(Theta)~=0) = 0;
    lkDat                                       =   squeeze(s.wd.p_wSoilBase_kLookUp(:,sl,:));
    if size(lkDat,2) == 1
        lkDat       = lkDat';
    end
    
    lkInd                                       =   floor(Theta .* p.wSoilBase.nLookup);
    lkInd(lkInd==0)                             =   1;
    lkInd(lkInd>p.wSoilBase.nLookup)            =   p.wSoilBase.nLookup;
    idxArray= zeros(size(lkDat));
    for i = 1: length(lkDat)
        idxArray(i,lkInd(i)) = 1;
    end
    K                                           =   lkDat(idxArray ==1);
    K                                           =   K(:,1);
    
%     lkInd                                       =   floor(Theta_dos .* p.wSoilBase.nLookup);
%     K                                           =   lkInd;
%     lkInd(lkInd==0)                             =   1;
%     lkInd(lkInd>p.wSoilBase.nLookup)            =   p.wSoilBase.nLookup;
%     K = lkDat(:,lkInd);
%     for lk=1:numel(lkInd)
%         K(lk) = lkDat(lk,lkInd(lk));
%     end
end

end
