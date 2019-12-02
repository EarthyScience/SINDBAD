function [f,fe,fx,s,d,p]=prec_vegFrac_constant(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of vegFrac as a constant 
% Inputs:
%	- info helper for array 
%	- p.vegFrac.constantvegFrac
%
% Outputs:
%   - s.cd.vegFrac: an extra forcing that creates a time series of constant vegFrac
%
% Modifies:
% 	- None
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.vegFrac = info.tem.helpers.arrays.onespix .* p.vegFrac.constantVegFrac;    
end