function K = calcKSaxton1986(s,p,info,sl)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the soil hydraulic conductivity for a given moisture based on Saxton, 1986
%
% Inputs:
%	- s.w.wSoil(:,sl)  
%	- s.wd.p_wSoilBase_[CLAY/SAND]: clay and sand content (is converted to percentage)
%   - Depth of soil layer (to get volumetric water content): Theta
%
% Outputs:
%   - K: the hydraulic conductivity at unsaturated s.w.wSoil [in mm/day]
%       - is calculated using original equation if info.tem.model.flags.useLookupK == 0
%       - uses precomputed lookup table if info.tem.model.flags.useLookupK ==  1
%
% Modifies:
% 	- None
%
% Notes:
%   - This function is a part of pSoil, but making the looking up table and setting the soil
%     properties is handled by wSoilBase (by calling this function)
%   - is also used by all approaches depending on kUnsat within time loop of coreTEM
%
% References:
%    - Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
%       Estimating generalized soil-water characteristics from texture. 
%       Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
%       http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
% 
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala):
%   - 1.1 on 03.12.2019 (skoirala): included the option to handle lookup table when set to true
%     from modelRun.json
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
%--> if useLookUp is set to true in modelRun.json, run the original non-linear equation
if p.wSoilBase.makeLookup
    
    CLAY    = s.wd.p_wSoilBase_CLAY(:,sl) .* 100;
    SAND    = s.wd.p_wSoilBase_SAND(:,sl)  .* 100;
    soilD   = s.wd.p_wSoilBase_soilDepths(sl);
    Theta   = s.w.wSoil(:,sl) ./ soilD;
    K   = 2.778E-6 .*(exp(p.pSoil.p + p.pSoil.q .* SAND + ...
        (p.pSoil.r + p.pSoil.t .* SAND + p.pSoil.u .* CLAY + p.pSoil.v .*...
        CLAY .^ 2) .* (1 ./ Theta))) .* 1000 .* 3600 .* 24;

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
    idx                                         =   sub2ind(size(lkDat),rowArray',lkInd); %subscript for all rows and the selected columns
    K                                           =   lkDat(idx);    
end
end
