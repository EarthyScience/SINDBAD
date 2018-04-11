function [fx,s,d] = Qsat_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: compute saturation runoff
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% frSat     : saturated fraction of soil [] (from 0 to 1)
%           (s.wd.wFrSat)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% OUTPUT
% Qsat      : saturation runoff [mm/time]
%           (fx.Qsat)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% NOTES: is supposed to work over multiple time scales
% 
% #########################################################################


% this is a dummy
fx.Qsat(:,tix) = s.wd.WBP .* s.wd.wFrSat;

% update the WBP
s.wd.WBP = s.wd.WBP - fx.Qsat(:,tix);

end