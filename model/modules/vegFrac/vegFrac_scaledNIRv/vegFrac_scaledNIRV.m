function [f,fe,fx,s,d,p]=vegFrac_scaledNIRv(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of vegFrac by scaling the NIRv value 
% Inputs:
%	- s.cd.NIRv      : current NIRv value
%	- p.vegFrac.NIRvscale : scaling parameter for NIRv
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
s.cd.vegFrac = min(s.cd.NIRv .* p.vegFrac.NIRvscale,1);    
end