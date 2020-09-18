function [f,fe,fx,s,d,p]=NDWI_forcing(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the value of s.cd.NDWI from the forcing in every time step
%
% Inputs:
%   - f.NDWI read from the forcing data set
%
% Outputs:
%   - s.cd.NDWI: the value of NDWI for current time step
%
% Modifies:
%   - s.cd.NDWI
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
s.cd.NDWI = f.NDWI(:,tix);

end