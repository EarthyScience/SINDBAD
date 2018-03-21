function [fe,fx,d,p] = prec_gppJdem_mult(f,fe,fx,s,d,p,info)
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
%           (d.gppJruemax.rueGPP)
% PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.gppFtemp.TempScGPP)
% VPDScGPP  : VPD effect on GPP [] dimensionless, between 0-1
%           (d.gppFvpd.VPDScGPP)
% LightScGPP: light saturation scalar [] dimensionless
%           (d.gppFrad.LightScGPP)
% 
% OUTPUT
% gppE      : demand GPP [gC/m2/time]
%           (d.gppJdem.gppE)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% make 3D matrix 
scall           = zeros(info.forcing.size(1),info.forcing.size(2),3);
scall(:,:,1)    = d.gppFtemp.TempScGPP;
scall(:,:,2)    = d.gppFvpd.VPDScGPP;
scall(:,:,3)    = d.gppFrad.LightScGPP;

% compute the product of all the scalars
d.gppJdem.AllDemScGPP    = prod(scall,3);

% compute demand GPP
d.gppJdem.gppE        = f.FAPAR .* f.PAR .* d.gppJruemax.rueGPP .* d.gppJdem.AllDemScGPP;

end