function K = calcKSaxton1986(s,p,info,sl)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate hydraulic conductivity from soil moisture using Saxton 1986, equation 10
% 
% p.pSoil     : soil moisture parameter output array
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

%--> if useLookUp is set to true in modelRun.json, run the original non-linear equation
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
    rowArray                                    =   1:size(Theta,1);
    Theta(Theta<0)                              =   0;
    Theta(imag(Theta)~=0)                       =   0;
    lkDat                                       =   s.wd.p_wSoilBase_kLookUp{sl};
    lkInd                                       =   floor(Theta .* p.wSoilBase.nLookup);
    lkInd(lkInd==0)                             =   1;
    lkInd(lkInd>p.wSoilBase.nLookup)            =   p.wSoilBase.nLookup;
    idx                                         =   sub2ind(size(lkDat),rowArray',lkInd);
    K                                           =   lkDat(idx);    
end

end
