function [fx,s,d] = qCsat_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: compute saturation runoff
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% frSat     : saturated fraction of soil [] (from 0 to 1)
%           (s.wFrSat)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% OUTPUT
% Qsat      : saturation runoff [mm/time]
%           (fx.Qsat)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES: is supposed to work over multiple time scales
% 
% #########################################################################


% this is a dummy
fx.Qsat(:,tix) = d.Temp.WBP .* s.wFrSat;

% update the WBP
d.Temp.WBP = d.Temp.WBP - fx.Qsat(:,tix);

end