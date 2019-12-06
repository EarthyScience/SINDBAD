function [f,fe,fx,s,d,p] = prec_gppDem_min(f,fe,fx,s,d,p,info)
% % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% % PURPOSE    : compute the demand GPP: stress scalars are combined as the
% %           minimum (which limits most)
% % 
% % REFERENCES: SINDABD ;)
% % 
% % CONTACT    : mjung, ncarval
% % 
% % INPUT
% % rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
% %           (d.gppPot.rueGPP)
% % PAR       : photosynthetically active radiation [MJ/m2/time]
% %           (f.PAR)
% % FAPAR     : fraction of absorbed photosynthetically active radiation
% %           [] (equivalent to "canopy cover" in Gash and Miralles)
% %           (s.cd.fAPAR)
% % TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
% %           (d.gppfTair.TempScGPP)
% % VPDScGPP  : VPD effect on GPP [] dimensionless, between 0-1
% %           (d.gppfVPD.VPDScGPP)
% % LightScGPP: light saturation scalar [] dimensionless
% %           (d.gppfRdir.LightScGPP)
% % 
% % OUTPUT
% % gppE      : demand GPP [gC/m2/time]
% %           (d.gppDem.gppE)
% % 
% % DEPENDENCIES  :
% % 
% % NOTES:
% % 
% % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% % make 3D matrix 
% scall           = repmat(info.tem.helpers.arrays.onespixtix,1,1,3);
% scall(:,:,1)    = d.gppfTair.TempScGPP;
% scall(:,:,2)    = d.gppfVPD.VPDScGPP;
% scall(:,:,3)    = d.gppfRdir.LightScGPP;

% % compute the minumum of all the scalars
% d.gppDem.AllDemScGPP = min(scall,[],3);

% % compute demand GPP
% d.gppDem.gppE    = s.cd.fAPAR .* f.PAR .* d.gppPot.rueGPP .* d.gppDem.AllDemScGPP;

end