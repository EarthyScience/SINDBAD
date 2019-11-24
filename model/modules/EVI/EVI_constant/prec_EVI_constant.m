function [f,fe,fx,s,d,p]=prec_EVI_constant(f,fe,fx,s,d,p,info)
% sets the value of EVI as a constant 
% Inputs:
%	- info helper for array 
%	- p.EVI.constantEVI
%
% Outputs:
%   - s.cd.EVI: an extra forcing that creates a time series of constant EVI
%
% Modifies:
% 	- None
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): cleaned up the code
%
%% 
s.cd.EVI = info.tem.helpers.arrays.onespix .* p.EVI.constantEVI;    
end