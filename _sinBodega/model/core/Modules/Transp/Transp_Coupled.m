function [fx,s,d] = Transp_Coupled(f,fe,fx,s,d,p,info,i)
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
%           (d.WUE.AoE)
% 
% OUTPUT
% Transp    : transpiration [mm/m2/time]
%           (fx.Transp)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% calculate transpiration
fx.Transp(:,i)	= fx.gpp(:,i) ./ d.WUE.AoE(:,i);

end