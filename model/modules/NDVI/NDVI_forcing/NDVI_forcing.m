function [f,fe,fx,s,d,p]=NDVI_forcing(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.NDVI from the forcing in every time step
%
% Inputs:
%   - f.NDVI read from the forcing data set
%
% Outputs:
%   - s.cd.NDVI: the value of NDVI for current time step
%
% Modifies:
%   - s.cd.NDVI
%
% References:
%   - 
%
% Created by:
%   - Simon Besnard (sbesnard)
%
% Versions:
%   - 1.0 on 29.04.2020 (sbesnard): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.NDVI = f.NDVI(:,tix);

end