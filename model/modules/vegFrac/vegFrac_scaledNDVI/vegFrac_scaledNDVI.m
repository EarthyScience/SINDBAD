function [f,fe,fx,s,d,p]=vegFrac_scaledNDVI(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of vegFrac by scaling the NDVI value 
% Inputs:
%	- s.cd.NDVI      : current NDVI value
%	- p.vegFrac.NDVIscale : scaling parameter for NDVI
%
% Outputs:
%   - s.cd.vegFrac: current vegetation fraction 
%
% Modifies:
% 	- None
%
% References:
%	- 
%
% Created by:
%   - Simon Besnard (sbesnard)
%
% Versions:
%   - 1.1 on 29.04.2020 (sbesnard): new module
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.vegFrac = min(s.cd.NDVI .* p.vegFrac.NDVIscale,1);    
end