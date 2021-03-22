function [f,fe,fx,s,d,p]=prec_PET_PriestleyTaylor1972(f,fe,fx,s,d,p,info)
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
%   - Priestley, C. H. B., & TAYLOR, R. J. (1972). On the assessment of surface heat
%       flux and evaporation using large-scale parameters.
%       Monthly weather review, 100(2), 81-92.
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 20.03.2020 (skoirala):
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
Tair = f.Tair
Rn = f.Rn

Delta	= 6.11 .* exp(17.26938818 .* Tair ./ (237.3 + Tair));;
Lhv     = (5.147 .* exp(-0.0004643 .* Tair) - 2.6466); % MJ kg-1
gama    = 0.4 ./ 0.622; % hPa C-1 (psychometric constant)
PET     = 1.26 .* Delta ./ (Delta + gama) .* Rn ./ Lhv;

PET(PET<0) = 0;
fe.PET.PET = PET;

end