function [f,fe,fx,s,d,p]=prec_NDWI_constant(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of NDWI as a constant 
%
% Inputs:
%   - p.NDWI.constantNDWI
%
% Outputs:
%   - s.cd.NDWI: an extra forcing that creates a time series of constant NDWI
%
% Modifies:
%   - s.cd.NDWI
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
s.cd.NDWI = info.tem.helpers.arrays.onespix .* p.NDWI.constantNDWI;    
end