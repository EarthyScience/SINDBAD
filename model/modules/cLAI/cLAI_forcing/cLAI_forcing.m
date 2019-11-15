function [f,fe,fx,s,d,p]=cLAI_forcing(f,fe,fx,s,d,p,info,tix)
% sets the value of s.cd.LAI from the fe forcing in every time step
%
% Inputs:
%	- tix  
%	- f.LAI read from the forcing data set
%
% Outputs:
%   - s.cd.LAI: the value of LAI for current time step
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
%   - 1.0 on 11.11.2019 (skoirala): moved LAI from d.cLAI.LAI to s.cd.cLAI
%
%% 
s.cd.LAI = f.LAI(:,tix);    
end