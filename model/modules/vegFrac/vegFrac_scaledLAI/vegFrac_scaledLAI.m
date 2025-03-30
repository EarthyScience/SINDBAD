function [f,fe,fx,s,d,p]=vegFrac_scaledLAI(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of vegFrac by scaling the LAI value 
% Inputs:
%	- s.cd.LAI      : current LAI value
%	- p.vegFrac.LAIscale : scaling parameter for LAI
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
%   - 1.1 on 24.10.2020 (ttraut): new module
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.vegFrac = min(s.cd.LAI .* p.vegFrac.LAIscale,1);    
end