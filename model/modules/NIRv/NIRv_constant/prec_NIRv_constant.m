function [f,fe,fx,s,d,p]=prec_NIRv_constant(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of NIRv as a constant 
%
% Inputs:
%   - p.NIRv.constantNIRv
%
% Outputs:
%   - s.cd.NIRv: an extra forcing that creates a time series of constant NIRv
%
% Modifies:
%   - s.cd.NIRv
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
s.cd.NIRv = info.tem.helpers.arrays.onespix .* p.NIRv.constantNIRv;    
end