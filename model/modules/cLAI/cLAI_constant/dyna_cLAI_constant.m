function [f,fe,fx,s,d,p]=dyna_cLAI_constant(f,fe,fx,s,d,p,info,tix)
% sets the value of d.cLAI.LAI from the fe forcing in every time step
%
% Inputs:
%	- tix  
%	- fe.cLAI.LAI time series
%
% Outputs:
%   - d.cLAI.LAI: an extra forcing that creates a time series of constant LAI
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
d.cLAI.LAI(:,tix)       =   fe.cLAI.LAI(:,tix)
end