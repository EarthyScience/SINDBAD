function [f,fe,fx,s,d,p]=prec_vegFrac_forcingMean(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.vegFrac as the temporal mean from the forcing
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
s.cd.vegFrac = nanmean(f.vegFrac, 2);
end