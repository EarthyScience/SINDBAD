function [f,fe,fx,s,d,p]=prec_cLAI_constant(f,fe,fx,s,d,p,info)
% sets the value of LAI as a constant 
% Inputs:
%	- info helper for array 
%	- p.cLAI.constantLAI
%
% Outputs:
%   - fe.cLAI.LAI: an extra forcing that creates a time series of constant LAI
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
s.cd.LAI = info.tem.helpers.arrays.onespix .* p.cLAI.constantLAI;    
end