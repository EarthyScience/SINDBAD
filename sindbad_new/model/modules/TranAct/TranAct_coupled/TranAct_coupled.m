function [fx,s,d,f] = TranAct_coupled(f,fe,fx,s,d,p,info,tix)
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
% TranAct    : transpiration [mm/m2/time]
%           (fx.TranAct)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% calculate transpiration
fx.TranAct(:,tix)	= fx.gpp(:,tix) ./ d.WUE.AoE(:,tix);

end