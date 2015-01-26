function [fx,s,d] = RunoffSat_simple(f,fe,fx,s,d,p,info,i)
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
fx.Qsat(:,i) = d.Temp.WBP .* s.wFrSat;

% update the WBP
d.Temp.WBP = d.Temp.WBP - fx.Qsat(:,i);

end