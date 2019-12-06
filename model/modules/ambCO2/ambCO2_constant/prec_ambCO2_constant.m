function [f,fe,fx,s,d,p]=prec_ambCO2_constant(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of ambCO2 as a constant 
%
% Inputs:
%    - p.ambCO2.constantambCO2
%
% Outputs:
%   - s.cd.ambCO2: a constant state of ambient CO2
%
% Modifies:
%     - None
%
% References:
%    - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala):
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.ambCO2 = info.tem.helpers.arrays.onespix .* p.ambCO2.constantambCO2;    
end