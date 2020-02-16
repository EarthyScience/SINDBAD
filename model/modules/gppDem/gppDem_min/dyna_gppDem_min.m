function [f,fe,fx,s,d,p] = dyna_gppDem_min(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% compute the demand GPP as minimum of all stress scalars (most limited)
%
% Inputs:
%   - s.cd.fAPAR: fraction of absorbed photosynthetically active radiation
%           [-] (equivalent to "canopy cover" in Gash and Miralles) 
%   - d.gppPot.gppPot: maximum potential GPP based on radiation use efficiency
%   - d.gppfTair.TempScGPP: temperature effect on GPP [-], between 0-1
%   - d.gppfVPD.VPDScGPP: VPD effect on GPP [-], between 0-1
%   - d.gppfRdir.LightScGPP: light saturation scalar [-], between 0-1
%   - d.gppfRdiff.CloudScGPP: cloudiness scalar [-], between 0-1
% 
% Outputs:
%   - d.gppDem.gppE: demand GPP [gC/m2/time]
%   - d.gppDem.AllDemScGPP (effective scalar, 0-1)
%
% Modifies:
%   - s.cd.scall
%
% References:
%   - 
%
% Notes:
%   -
% 
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% update 3d scalar matrix with current scalars
s.cd.scall(:,1)             =   d.gppfTair.TempScGPP(:,tix);
s.cd.scall(:,2)             =   d.gppfVPD.VPDScGPP(:,tix);
s.cd.scall(:,3)             =   d.gppfRdir.LightScGPP(:,tix);
s.cd.scall(:,4)             =   d.gppfRdiff.CloudScGPP(:,tix);

% compute the minumum of all the scalars
d.gppDem.AllDemScGPP(:,tix) =   min(scall,[],2);

% compute demand GPP
d.gppDem.gppE(:,tix)        =   s.cd.fAPAR .* d.gppPot.gppPot(:,tix) .* d.gppDem.AllDemScGPP(:,tix);
end