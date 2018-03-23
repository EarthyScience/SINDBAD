function [fx,s,d] = dyna_EvapInt_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: for canopy interception evaporation (ECanop) everything is
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
%           (d.Temp.WBP)
% 
% OUTPUT
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES:
% 
% #########################################################################

% update the available water
d.Temp.WBP = d.Temp.WBP - fx.ECanop(:,tix);

end