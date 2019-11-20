function [f,fe,fx,s,d,p] = dyna_roInf_Jung(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% compute the runoff from infiltration excess
%
% Inputs:
%   - fx.roInf: infiltration excess runoff [mm/time] - what runs off because
%           the precipitation intensity is to high for it to inflitrate in
%           the soil
%
% Outputs:
%   - 
%
% Modifies:
% 	- s.wd.WBP: water balance pool [mm]
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
%% 
% #########################################################################
% everything is precomputed
s.wd.WBP = s.wd.WBP - fx.roInf(:,tix);
end