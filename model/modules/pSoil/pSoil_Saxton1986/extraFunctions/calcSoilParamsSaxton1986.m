function [Alpha,Beta,K,Theta,Psi] = calcSoilParamsSaxton1986(s,p,info,sl,WT)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the soil hydraulic properties based on Saxton 1986
%
% Inputs:
%	- info  
%	- s.wd.p_soilTexture_[CLAY/SAND]: is converted from fraction input to percentage 
%   - p.pSoil.: texture-based parameters
%
% Outputs:
%   - properties of moisture-retention curves: (Alpha and Beta)
%   - hydraulic conductivity (k), matric potention (psi) and porosity
%   (theta) at saturation (Sat), field capacity (FC), and wilting point
%   (WP)
%
% Modifies:
% 	- None
%
% References:
%    - Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
%       Estimating generalized soil-water characteristics from texture. 
%       Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
%       http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
% 
% Created by:
%   - Sujan Koirala (skoirala)
%   - Nuno Carvalhais (ncarval):
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala):
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%-->  CONVERT SAND AND CLAY TO PERCENTAGES
CLAY            =   s.wd.p_soilTexture_CLAY(:,sl) .* 100;
SAND            =   s.wd.p_soilTexture_SAND(:,sl) .* 100;

%-->  Equations
A               =   exp(p.pSoil.a + p.pSoil.b .* CLAY + p.pSoil.c .* SAND .^ 2 + p.pSoil.d1 .* SAND .^ 2 .* CLAY) .* 100;
B               =   p.pSoil.e + p.pSoil.f1 .* CLAY .^ 2 + p.pSoil.g .* SAND .^ 2 .* CLAY;

%-->  soil matric potential, Psi, kPa
Psi             =   WT .* info.tem.helpers.arrays.onespix;

%--> soil moisture content at saturation (m^3/m^3)
Theta_s         =   p.pSoil.h + p.pSoil.j .* SAND + p.pSoil.k .* log10(CLAY);

%--> air entry pressure (kPa)
Psi_e           =   abs(100 .* (p.pSoil.m + p.pSoil.n .* Theta_s));

Theta           =   zeros(size(CLAY));
ndx     = find(Psi >= 10 & Psi <= 1500);
if ~isempty(ndx)
    Theta(ndx)  =   (Psi(ndx) ./ A(ndx)) .^ (1 ./ B(ndx));
end
clear ndx

ndx = find(Psi >= Psi_e & Psi < 10);
if ~isempty(ndx)
    % theta at 10 kPa (m^3/m^3)
    Theta_10    =   exp((2.302 - log(A(ndx))) ./ B(ndx));
    % ---------------------------------------------------------------------
    % Psi(ndx) = 10.0 - (Theta(ndx) - Theta_10(ndx)) .* (10.0 - ...
    %     Psi_e(ndx)) ./ (Theta_s(ndx) - Theta_10(ndx));
    % ---------------------------------------------------------------------
    Theta(ndx)  =   Theta_10 + (10.0 - Psi(ndx)) .* ...
        (Theta_s(ndx) - Theta_10) ./ (10.0 - Psi_e(ndx));
end
clear ndx

ndx = find(Psi >= 0 & Psi < Psi_e);
if ~isempty(ndx)
    Theta(ndx)  =   Theta_s(ndx);
end
clear ndx

%--> hydraulic conductivity (mm/day): original equation for mm/s
K   = 2.778E-6 .*(exp(p.pSoil.p + p.pSoil.q .* SAND + ...
    (p.pSoil.r + p.pSoil.t .* SAND + p.pSoil.u .* CLAY + p.pSoil.v .*...
    CLAY .^ 2) .* (1 ./ Theta))) .* 1000 .* 3600 .* 24;

Alpha           =   A;
Beta            =   B;

end
