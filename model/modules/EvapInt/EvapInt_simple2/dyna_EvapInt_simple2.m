function [f,fe,fx,s,d,p] = dyna_EvapInt_simple2(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: for canopy interception evaporation (EvapInt) everything is
% precomputed. This function only updates the WBP variable.
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% IntCap    : canopy interception capacity [mm]
%           (fe.EvapInt.IntCap)
% Rain      : rain fall [mm/time]
%           (f.Rain)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
%
% OUTPUT
% EvapInt    : canopy interception evaporation [mm/time]
%           (fx.ECanop)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
%
% NOTES:
%
% #########################################################################

% update the available water
fx.EvapInt(:,tix)      =   min(fe.EvapInt.IntCap(:,tix), fe.rainSnow.rain(:,tix));
s.wd.WBP               =   s.wd.WBP - fx.EvapInt(:,tix);

end
