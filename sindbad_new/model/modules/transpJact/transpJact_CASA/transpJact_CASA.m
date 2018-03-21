function [fx,s,d] = transpJact_CASA(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: estimate transpiration from GPP
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% gpp       : actual GPP [gC/m2/time]
%           (fx.gpp)
% AoE       : water use efficiency - ratio of assimilation and
%           transpiration fluxes [gC/mmH2O]
%           (d.wue.AoE)
% 
% OUTPUT
% transpJact    : transpiration [mm/m2/time]
%           (fx.transpJact)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% calculate transpiration
fx.transpJact(:,tix)	= d.transpFwsoil.transpJactS(:,tix);

end