function [f,fe,fx,s,d,p] = prec_gppfRdir_Maekelae2008(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : saturating light function
% 
% REFERENCES: Maekelae et al 2008 - Developing an empirical model of stand
% GPP with the LUE approach: analysis of eddy covariance data at five
% contrasting conifer sites in Europen
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% FAPAR     : fraction of absorbed photosynthetically active radiation [] 
%           (s.cd.fAPAR)
% PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
% gamma     : light response curve parameter to account for light
%           saturation [m2/MJ-1 of APAR]
%           (p.gppfRdir.gamma)
% 
% OUTPUT
% LightScGPP: light saturation scalar [] dimensionless
%           (d.gppfRdir.LightScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: gamma is between [0.007 0.05], median ~0.04 [m2/mol] in Maekelae
% et al 2008. The smaller gamma the smaller the effect; no effect if it
% becomes 0 (i.e. linear light response).
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% pgamma                      =   p.gppfRdir.gamma * info.tem.helpers.arrays.onestix;
% d.gppfRdir.LightScGPP       =   1 ./ (pgamma .* f.PAR .* s.cd.fAPAR + 1);

end