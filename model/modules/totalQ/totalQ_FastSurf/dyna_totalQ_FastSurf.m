function [f,fe,fx,s,d,p] = dyna_totalQ_FastSurf(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculate total runoff
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% Qfast      : fast runoff[mm]
%           (fx.Qfast)
% Qsurf      : slow runoff from surface water storage [mm]
%           (fx.Qsurf)
%
% OUTPUT
% Q       : total runoff [mm/time]
%           (fx.Q)
%
% NOTES:
%
% #########################################################################

fx.Q (:,tix) = fx.Qfast(:,tix) + fx.Qsurf(:,tix);



end
