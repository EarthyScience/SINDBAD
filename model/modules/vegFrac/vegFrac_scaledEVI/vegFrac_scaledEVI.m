function [f,fe,fx,s,d,p]=vegFrac_scaledEVI(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of vegFrac by scaling the EVI value 
% Inputs:
%	- s.cd.EVI      : current EVI value
%	- p.vegFrac.EVIscale : scaling parameter for EVI
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
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 06.02.2020 (ttraut)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.cd.vegFrac = s.cd.EVI .* p.vegFrac.EVIscale;    


end