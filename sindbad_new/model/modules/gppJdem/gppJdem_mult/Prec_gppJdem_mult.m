function [fe,fx,d,p] = Prec_gppJdem_mult(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute the demand GPP: stress scalars are in a
% multiplicative way 
% 
% REFERENCES: SINDABD ;)
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
%           (d.MaxRUE.rueGPP)
% PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.TempEffectGPP.TempScGPP)
% VPDScGPP  : VPD effect on GPP [] dimensionless, between 0-1
%           (d.VPDEffectGPP.VPDScGPP)
% LightScGPP: light saturation scalar [] dimensionless
%           (d.LightEffectGPP.LightScGPP)
% 
% OUTPUT
% gppE      : demand GPP [gC/m2/time]
%           (d.DemandGPP.gppE)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% make 3D matrix 
scall           = zeros(info.forcing.size(1),info.forcing.size(2),3);
scall(:,:,1)    = d.TempEffectGPP.TempScGPP;
scall(:,:,2)    = d.VPDEffectGPP.VPDScGPP;
scall(:,:,3)    = d.LightEffectGPP.LightScGPP;

% compute the product of all the scalars
d.DemandGPP.AllDemScGPP    = prod(scall,3);

% compute demand GPP
d.DemandGPP.gppE        = f.FAPAR .* f.PAR .* d.MaxRUE.rueGPP .* d.DemandGPP.AllDemScGPP;

end