function [f,fe,fx,s,d,p]=prec_PET_Lu2005(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Calculates the value of fe.PET.PET from the forcing variables
%
% Inputs:
%   - f.Tair: Air temperature
%   - f.Rn: Net radiation
%
% Outputs:
%   - fe.PET.PET: the value of PET for current time step
%
% Modifies:
%   - 
%
% References:
%   - Lu
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
Tair = f.Tair
Rn = f.Rn
% alfa is the calibration constant: alfa = 1.26 for wet or humid
% conditions 

alfa	= 1.26;

% slope of the saturation vapor pressure temperature curve (kPa/�C)
Delta	= 0.200 .* (0.00738 .* Tair + 0.8072) .^ 7 - 0.000116;

% cp is the specific heat of moist air at constant pressure
% (kJ/kg/�C) and where cp = 1.013 kJ/kg/�C =  0.0010 13 MJ/kg/�C; 
cp = 0.001013;

% and p is the atmospheric pressure (kPa) EL = elevation
EL	= 0;
atmp   = 101.3 - 0.01055 .* EL;

% lambda is the latent hear of vaporization (MJ/kg)
lambda	= 2.501 - 0.002361 .* Tair;

% gama is the the psychrometric constant modified by the ratio of
% canopy resistance to atmospheric resistance (kPa/�C). 
gama	= cp .* atmp ./ (0.622 .* lambda);

% and G is the heat flux density to the ground (MJ/m^2/day)
% G = 4.2(T(i+1)-T(i-1))/dt
% where Ti is the mean air temperature (�C) for the period i; and
% dt the difference of time (days)
Tair_ip1	= [Tair(2:end) Tair(end)];
Tair_im1	= [Tair(1) Tair(1:end-1)];
dt          = 2;
G           = 4.2 .* (Tair_ip1 - Tair_im1) ./ dt;

PET  = (alfa .* (Delta ./ (Delta + gama)) .* (Rn - G)) ./ lambda;
PET(PET<0) = 0;
fe.PET.PET = PET;

end