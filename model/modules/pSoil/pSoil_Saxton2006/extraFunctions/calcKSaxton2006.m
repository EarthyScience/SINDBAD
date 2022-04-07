function K = calcKSaxton2006(s,p,info,sl)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the soil hydraulic conductivity for a given moisture based on Saxton, 2006
%
% Inputs:
%	- s.w.wSoil(:,sl)  
%	- s.wd.p_wSoilBase_[wSat/Beta/kSat]: hydraulic parameters for each soil layer
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
%  - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by 
%       texture and organic matter for hydrologic solutions. 
%       Soil science society of America Journal, 70(5), 1569-1578.
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
wSat            =   s.wd.p_wSoilBase_wSat(:,sl);
Theta_dos       =   s.w.wSoil(:,sl) ./ wSat;
if p.wSoilBase.makeLookup
    % takes 2.37 seconds
    %     Beta            =   s.wd.p_wSoilBase_Beta(:,sl);
    %     kSat            =   s.wd.p_wSoilBase_kSat(:,sl);
    %     lambda          =   1 ./ Beta;
    %     K               =   kSat .* ((Theta_dos) .^ (3 + (2 ./ lambda)));
    %
    % takes 1.370 seconds
    kPow            =   s.wd.p_wSoilBase_kPow(:,sl);
    logkSat         =   s.wd.p_wSoilBase_logkSat(:,sl);
    K               =   exp(kPow .* log(Theta_dos) + logkSat);
    
else
    Theta_dos(Theta_dos<0)                      =   0;
    Theta_dos(imag(Theta_dos)~=0)               =   0;
    lkDat                                       =   s.wd.p_wSoilBase_kLookUp{sl};
    lkInd                                       =   fix(Theta_dos .* p.wSoilBase.nLookup);
    lkInd(lkInd==0)                             =   1;
    lkInd(lkInd>p.wSoilBase.nLookup)            =   p.wSoilBase.nLookup;
    rowArray                                    =   1:info.tem.helpers.sizes.nPix;
    idx                                         =   sub2ind(size(lkDat),rowArray',lkInd); %subscript for all rows and the selected columns
    K                                           =   lkDat(idx);        
    % loop method
    % k2 = info.tem.helpers.arrays.zerospix;
    %     for rw = 1:info.tem.helpers.sizes.nPix
    %         k2(rw) = lkDat(rw,lkInd(rw));
    %     end
    % table method
    % fn = @(A,x) A(x);
    %     lt=table(lkDat, lkInd);
    %     K2s = rowfun(fn,lt,'OutputVariableName','K');
    %     K2 = K2s.K;
end
end
