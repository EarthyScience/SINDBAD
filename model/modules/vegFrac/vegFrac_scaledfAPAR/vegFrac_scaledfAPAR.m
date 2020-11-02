function [f,fe,fx,s,d,p]=vegFrac_scaledfAPAR(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of vegFrac by scaling the fAPAR value 
% Inputs:
%	- s.cd.fAPAR      : current fAPAR value
%	- p.vegFrac.fAPARscale : scaling parameter for fAPAR
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
s.cd.vegFrac = min(s.cd.fAPAR .* p.vegFrac.fAPARscale,1);    
end