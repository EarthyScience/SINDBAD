function [fx,s,d] = RunoffInt_simple(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung
% 
% INPUT
% rc        : interflow runoff coefficient []
%           (p.RunoffInt.rc)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% OUTPUT
% Qint      : interflow [mm/time]
%           (fx.Qint)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES:
% 
% #########################################################################

% simply assume that a fraction of the still available water runs off
fx.Qint(:,i) = p.RunoffInt.rc .* d.Temp.WBP;
d.Temp.WBP = d.Temp.WBP - fx.Qint(:,i);

end