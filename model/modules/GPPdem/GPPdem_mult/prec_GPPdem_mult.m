function [f,fe,fx,s,d,p] = prec_GPPdem_mult(f,fe,fx,s,d,p,info)
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
%           (d.GPPpot.rueGPP)
% PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.GPPfTair.TempScGPP)
% VPDScGPP  : VPD effect on GPP [] dimensionless, between 0-1
%           (d.GPPfVPD.VPDScGPP)
% LightScGPP: light saturation scalar [] dimensionless
%           (d.GPPfRdir.LightScGPP)
% 
% OUTPUT
% gppE      : demand GPP [gC/m2/time]
%           (d.GPPdem.gppE)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% make 3D matrix 
scall                   =   repmat(info.tem.helpers.arrays.onespixtix,1,1,3);
scall(:,:,1)            =   d.GPPfTair.TempScGPP;
scall(:,:,2)            =   d.GPPfVPD.VPDScGPP;
scall(:,:,3)            =   d.GPPfRdir.LightScGPP;

% compute the product of all the scalars
d.GPPdem.AllDemScGPP    =   prod(scall,3);

% compute demand GPP
d.GPPdem.gppE           =   f.FAPAR .* f.PAR .* d.GPPpot.rueGPP .* d.GPPdem.AllDemScGPP;

end