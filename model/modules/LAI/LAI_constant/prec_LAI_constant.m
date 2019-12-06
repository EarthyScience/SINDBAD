function [f,fe,fx,s,d,p]=prec_LAI_constant(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of LAI as a constant 
%
% Inputs:
%    - p.LAI.constantLAI
%
% Outputs:
%   - s.cd.LAI: an extra forcing that creates a time series of constant LAI
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
%   - 1.0 on 11.11.2019 (skoirala): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.LAI = info.tem.helpers.arrays.onespix .* p.LAI.constantLAI;    
end