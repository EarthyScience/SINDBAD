function K = calcKSaxton2006(s,p,sl)
% calculates the soil hydraulic conductivity for a given moisture content based on Saxton 2006
%
% Inputs:
%	- info  
%	- p.pSoil.sand, p.soilTexture.silt and other soil texture-based properties
%
% Outputs:
%   - properties of moisture-retention curves (Alpha and Beta)
%   - hydraulic conductivity (k), matric potention (psi) and porosity
%   (theta) at saturation (Sat), field capacity (FC), and wilting point
%   (WP)
%
% Modifies:
% 	- None
%
% References:
%  - Saxton, K. E., & Rawls, W. J. (2006). Soil water characteristic estimates by texture and organic matter
%      for hydrologic solutions. Soil science society of America Journal, 70(5), 1569-1578.
% 
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala):
%
%% 
% #########################################################################
Beta            =   s.wd.p_wSoilBase_Beta(:,sl);
kSat            =   s.wd.p_wSoilBase_kSat(:,sl);
wSat            =   s.wd.p_wSoilBase_wSat(:,sl);
lambda          =   1 ./ Beta;
Theta_dos       =   s.w.wSoil(:,sl) ./ wSat;

% -------------------------------------------------------------------------
% WATER CONDUCTIVITY (mm/day)       
K               =   kSat .* ((Theta_dos) .^ (3 + (2 ./ lambda)));
% -------------------------------------------------------------------------


end % function
