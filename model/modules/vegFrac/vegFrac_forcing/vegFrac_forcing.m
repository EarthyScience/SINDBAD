function [f,fe,fx,s,d,p]=vegFrac_forcing(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.vegFrac from the forcing in every time step
%
% Inputs:
%	- tix  
%	- f.vegFrac read from the forcing data set
%
% Outputs:
%   - s.cd.vegFrac: the value of vegFrac for current time step
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
%   - 1.0 on 11.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.vegFrac = f.vegFrac(:,tix);
end