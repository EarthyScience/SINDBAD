function [fe,fx,d,p] = Prec_Interception_simple(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute canopy interception evaporation according to the Gash
% model.
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% Rain      : rain fall [mm/time]
%           (f.Rain)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% isp       : maximum storage capacity for a fully developed
%           canopy [mm] (warning: this is per rain event)
%           (p.Interception.isp)
% 
% OUTPUT
% ECanop    : canopy interception evaporation [mm/time]
%           (fx.ECanop)
% 
% NOTES: Works per rain event. Here we assume that we have one rain event
% per day - this approach should not be used for timeSteps very different
% to daily.
%        Parameters above, defaults in curly brackets from Mirales et al
%        2010
% 
% #########################################################################


% interception evaporation is simply the minimum of the fapar dependent
% storage and the rainfall
tmp         = (p.Interception.isp * ones(1,info.forcing.size(2))).* f.FAPAR;
fx.ECanop   = min(tmp,f.Rain);

end