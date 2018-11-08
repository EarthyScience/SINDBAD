function [f,fe,fx,s,d,p] = dyna_totalQ_FastSurf(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: create array for total runoff
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% Q       : total runoff [mm/time]
%           (fx.Q)%
% OUTPUT
% Q       : total runoff [mm/time]
%           (fx.Q)
%
% NOTES:
%
% #########################################################################

fx.Q = info.tem.helpers.arrays.nanpixtix;



end
