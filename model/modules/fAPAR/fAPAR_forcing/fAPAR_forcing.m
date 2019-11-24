function [f,fe,fx,s,d,p]=fAPAR_forcing(f,fe,fx,s,d,p,info,tix)
% sets the value of s.cd.fAPAR from the fe forcing in every time step
%
% Inputs:
%	- tix  
%	- f.fAPAR read from the forcing data set
%
% Outputs:
%   - s.cd.fAPAR: the value of fAPAR for current time step
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
%   - 1.0 on 23.11.2019 (skoirala): new function
%
%% 
s.cd.fAPAR = f.fAPAR(:,tix);
end