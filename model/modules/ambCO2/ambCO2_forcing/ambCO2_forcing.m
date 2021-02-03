function [f,fe,fx,s,d,p]=ambCO2_forcing(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.ambCO2 from the forcing in every time step
%
% Inputs:
%   - f.ambCO2 read from the forcing data set
%
% Outputs:
%   - s.cd.ambCO2: the value of LAI for current time step
%
% Modifies:
%   - s.cd.ambCO2
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.ambCO2 = f.ambCO2(:,tix) .* info.tem.helpers.arrays.onespix;
end
