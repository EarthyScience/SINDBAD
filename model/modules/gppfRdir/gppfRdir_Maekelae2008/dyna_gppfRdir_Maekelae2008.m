function [f,fe,fx,s,d,p] = dyna_gppfRdir_Maekelae2008(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% saturating light function
%
% Inputs:
%   - FAPAR     : fraction of absorbed photosynthetically active radiation [] 
%           (s.cd.fAPAR)
%   - PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
%   - gamma     : light response curve parameter to account for light
%           saturation [m2/MJ-1 of APAR]
%           (p.gppfRdir.gamma)
%    
% Outputs:
%   - fx.roInf: infiltration excess runoff [mm/time] - what runs off because
%           the precipitation intensity is to high for it to inflitrate in
%           the soil
%
% Modifies:
%     - 
%
% References:
%    - Maekelae et al 2008 - Developing an empirical model of stand
% GPP with the LUE approach: analysis of eddy covariance data at five
% contrasting conifer sites in Europen
%
% Notes: 
%   - gamma is between [0.007 0.05], median ~0.04 [m2/mol] in Maekelae
% et al 2008. The smaller gamma the smaller the effect; no effect if it
% becomes 0 (i.e. linear light response).
%  Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%   - 1.1 on 22.11.2019 (skoirala): moved from prec to dyna to handle s.cd.fAPAR which is nPix,1
%
%% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
d.gppfRdir.LightScGPP(:,tix)       =   1 ./ (p.gppfRdir.gamma .* f.PAR(:,tix) .* s.cd.fAPAR + 1);
end