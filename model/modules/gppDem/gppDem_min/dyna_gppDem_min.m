function [f,fe,fx,s,d,p] = dyna_gppDem_min(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : compute the demand GPP: stress scalars are combined as the
%           minimum (which limits most)
% 
% REFERENCES: SINDABD ;)
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
%           (d.gppPot.rueGPP)
% PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (s.cd.fAPAR)
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.gppfTair.TempScGPP)
% VPDScGPP  : VPD effect on GPP [] dimensionless, between 0-1
%           (d.gppfVPD.VPDScGPP)
% LightScGPP: light saturation scalar [] dimensionless
%           (d.gppfRdir.LightScGPP)
% 
% OUTPUT
% gppE      : demand GPP [gC/m2/time]
%           (d.gppDem.gppE)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% make 3D matrix 
scall           = repmat(info.tem.helpers.arrays.onespix,1,3);
scall(:,:,1)    = d.gppfTair.TempScGPP(:,tix);
scall(:,:,2)    = d.gppfVPD.VPDScGPP(:,tix);
scall(:,:,3)    = d.gppfRdir.LightScGPP(:,tix);

% compute the minumum of all the scalars
d.gppDem.AllDemScGPP(:,tix) = min(scall,[],2);

% compute demand GPP
d.gppDem.gppE(:,tix)    = s.cd.fAPAR .* f.PAR(:,tix) .* d.gppPot.rueGPP(:,tix) .* d.gppDem.AllDemScGPP(:,tix);

end