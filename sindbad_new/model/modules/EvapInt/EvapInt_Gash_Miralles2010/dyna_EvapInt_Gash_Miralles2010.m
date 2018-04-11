function [fx,s,d,f] = dyna_EvapInt_Gash_Miralles2010(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: for interception according to Gash everything (ECanop) is
% precomputed. This function only updates the WBP variable.
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% ECanop    : canopy interception evaporation [mm/time]
%           (fx.ECanop)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% OUTPUT
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% NOTES:
% 
% #########################################################################

% update the available water
s.wd.WBP = s.wd.WBP - fx.ECanop(:,tix);

end