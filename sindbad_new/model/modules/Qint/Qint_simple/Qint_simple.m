function [fx,s,d] = Qint_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung
% 
% INPUT
% rc        : interflow runoff coefficient []
%           (p.Qint.rc)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% OUTPUT
% Qint      : interflow [mm/time]
%           (fx.Qint)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% NOTES:
% 
% #########################################################################

% simply assume that a fraction of the still available water runs off
fx.Qint(:,tix) = p.Qint.rc .* s.wd.WBP;
s.wd.WBP = s.wd.WBP - fx.Qint(:,tix);

end