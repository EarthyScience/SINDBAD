function [f,fe,fx,s,d,p]=prec_NDVI_constant(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of NDVI as a constant 
%
% Inputs:
%   - p.NDVI.constantNDVI
%
% Outputs:
%   - s.cd.NDVI: an extra forcing that creates a time series of constant NDVI
%
% Modifies:
%   - s.cd.NDVI
%
% References:
%   - 
%
% Created by:
%   - Simon Besnard (sbesnard)
%
% Versions:
%   - 1.0 on 29.04.2020 (sbesnard): new module
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.NDVI = info.tem.helpers.arrays.onespix .* p.NDVI.constantNDVI;    
end