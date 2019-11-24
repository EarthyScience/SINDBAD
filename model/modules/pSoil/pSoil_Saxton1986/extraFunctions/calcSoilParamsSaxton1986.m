function [Alpha,Beta,K,Theta,Psi] = calcSoilParamsSaxton1986(p,info,WT)
% #########################################################################
% CALCULATE psoil MOISTURE PARAMETERS
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
% #########################################################################

% CONVERT SAND AND CLAY TO PERCENTAGES
CLAY            =   p.soilTexture.CLAY;
SAND            =   p.soilTexture.SAND;

% Equations
A               =   exp(p.pSoil.a + p.pSoil.b .* CLAY + p.pSoil.c .* SAND .^ 2 + p.pSoil.d1 .* SAND .^ 2 .* CLAY) * 100;
B               =   p.pSoil.e + p.pSoil.f1 .* CLAY .^ 2 + p.pSoil.g .* SAND .^ 2 .* CLAY;

% WATER POTENTIAL, Psi, kPa
Psi             =   WT .* info.tem.helpers.arrays.onespix;

% WATER CONTENT AT SATURATION (m^3/m^3)
Theta_s         =   p.pSoil.h + p.pSoil.j .* SAND + p.pSoil.k .* log10(CLAY);

% WATER POTENTIAL AT AIR ENTRY (kPa)
Psi_e           =   100 .* (p.pSoil.m + p.pSoil.n .* Theta_s);

Theta           =   zeros(size(CLAY));
ndx     = find(Psi >= 10 & Psi <= 1500);
if ~isempty(ndx)
    % ---------------------------------------------------------------------
    % Psi(ndx) = A(ndx) .* Theta(ndx) .^ B(ndx);
    % ---------------------------------------------------------------------
    Theta(ndx)  =   (Psi(ndx) ./ A(ndx)) .^ (1 ./ B(ndx));
end
clear ndx

ndx = find(Psi >= Psi_e & Psi < 10);
if ~isempty(ndx)
    % WATER CONTENT AT 10 kPa (m^3/m^3)
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

% -------------------------------------------------------------------------
% WATER CONDUCTIVITY (mm/day)
K               =   calcKSaxton1986(p,info,Theta);

% K   = 2.778E-6 .*(exp(p.pSoil.p + p.pSoil.q .* SAND + ...
%     (p.pSoil.r + p.pSoil.t .* SAND + p.pSoil.u .* CLAY + p.pSoil.v .*...
%     CLAY .^ 2) .* (1 ./ Theta))) .* 1000 * 3600 * 24;
% -------------------------------------------------------------------------

Alpha           =   A;
Beta            =   B;

end % function
