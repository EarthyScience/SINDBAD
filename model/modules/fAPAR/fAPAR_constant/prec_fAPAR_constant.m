function [f,fe,fx,s,d,p]=prec_fAPAR_constant(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of fAPAR as a constant 
%
% Inputs:
%   - info helper for array 
%   - p.fAPAR.constantfAPAR
%
% Outputs:
%   - s.cd.fAPAR: an extra forcing that creates a time series of constant fAPAR
%
% Modifies:
%   - None
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.fAPAR = info.tem.helpers.arrays.onespix .* p.fAPAR.constantfAPAR;    
end