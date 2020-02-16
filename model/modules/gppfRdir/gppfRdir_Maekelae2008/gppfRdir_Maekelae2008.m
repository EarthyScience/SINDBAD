function [f,fe,fx,s,d,p] = dyna_gppfRdir_Maekelae2008(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the light saturation scalar (light effect) on gppPot
%
% Inputs:
%   - s.cd.fAPAR: fraction of absorbed photosynthetically active radiation [] 
%   - f.PAR: photosynthetically active radiation [MJ/m2/time]
%   - p.gppfRdir.gamma: light response curve parameter to account for light
%           saturation [m2/MJ-1 of APAR]. The smaller gamma the smaller 
%           the effect; no effect if it becomes 0 (i.e. linear light response)
%
% Outputs:
%   - d.gppfRdir.LightScGPP: effect of light saturation on potential GPP
%
% Modifies:
%   - 
%
% References:
%    - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008). 
%       Developing an empirical model of stand GPP with the LUE approach: 
%       analysis of eddy covariance data at five contrasting conifer sites in Europe. 
%       Global change biology, 14(1), 92-108. 
%
% Notes: 
%   - gamma is between [0.007 0.05], median ~0.04 [m2/mol] in Maekelae
%       et al 2008. 
%
% Created by:
%   - Martin Jung (mjung)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up (changed the output to nPix, nTix)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
d.gppfRdir.LightScGPP(:,tix)       =   1 ./ (p.gppfRdir.gamma .* f.PAR(:,tix) .* s.cd.fAPAR + 1);
end