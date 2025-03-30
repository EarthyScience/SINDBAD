function [f,fe,fx,s,d,p] = prec_WUE_Medlyn2011(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the WUE/AOE ci/ca as a function of daytime mean VPD 
%
% Inputs:
%    - p.WUE.g1: stomatal conductance parameter[kPA^0.5] ranging
%           between [0.9 7]; median ~3.5; from Sven Boese
%    - f.VPDDay: daytime mean VPD [kPa] 
%    - f.PsurfDay: daytime mean atmospheric pressure [kPa] 
%
% Outputs:
%   - fe.WUE.AoENoCO2: precomputed A/E [gC/mmH2O] without ambient co2
%   - fe.WUE.ciNoCO2: precomputed internal co2 scalar without ambient co2
%
% Modifies:
%     - None
%
% References:
%    - MEDLYN, B.E., DUURSMA, R.A., EAMUS, D., ELLSWORTH, D.S., PRENTICE, I.C., 
%       BARTON, C.V.M., CROUS, K.Y., DE ANGELIS, P., FREEMAN, M. and WINGATE, 
%       L. (2011), Reconciling the optimal and empirical approaches to 
%       modelling stomatal conductance. Global Change Biology, 17: 2134-2144. 
%       doi:10.1111/j.1365-2486.2010.02375.x
%    - Medlyn, B.E., Duursma, R.A., Eamus, D., Ellsworth, D.S., Colin Prentice, 
%       I., Barton, C.V.M., Crous, K.Y., de Angelis, P., Freeman, M. and
%       Wingate, L. (2012), Reconciling the optimal and empirical approaches to 
%       modelling stomatal conductance. Glob Change Biol, 18: 3476-3476. 
%       doi:10.1111/j.1365-2486.2012.02790.
%    - Knauer J, El-Madany TS, Zaehle S, Migliavacca M (2018) Bigleaf—An R 
%       package for the calculation of physical and physiological ecosystem 
%       properties from eddy covariance data. PLoS ONE 13(8): e0201114. https://%       doi.org/10.1371/journal.pone.0201114
%
% Notes:
%   - unit conversion: C_flux[gC m-2 d-1] <- CO2_flux[(umol CO2 m-2 s-1)] * 
%      1e-06 [umol2mol] * 0.012011 [Cmol] * 1000 [kg2g] * 86400 [days2seconds]
%      from Knauer, 2019 
%   - water: mmol m-2 s-1: /1000 [mol m-2 s-1] * .018015 [Wmol in kg/mol] * 84600
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2020 (skoirala):
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
g_one                         =   p.WUE.g1 .* info.tem.helpers.arrays.onestix;

VPDDay                      =   f.VPDDay;
VPDDay(f.VPDDay < 5E-2)     =   5E-2;

umol_to_gC                  = 6.6667e-004;
% umol_to_gC                  =   1e-06 .* 0.012011 .* 1000 .* 86400 ./ (86400 .* 0.018015); %/(86400 = s to day .* .018015 = molecular weight of water) for a guessed fix of the units of water... not sure what it should be because the unit of A/E is not clear...if A is converted to gCm-2d-1 E should be converted from kg to g?
% umol_to_gC                  =   12 .* 100/(18 .* 1000);
fe.WUE.ciNoCO2              =   g_one ./ (g_one + sqrt(VPDDay)); % RHS eqn 13 in corrigendum
fe.WUE.AoENoCO2             =   umol_to_gC .* f.PsurfDay ./ (1.6 .* (VPDDay + g_one .* sqrt(VPDDay))); % eqn 14 %?  gC/mol of H2o?
end