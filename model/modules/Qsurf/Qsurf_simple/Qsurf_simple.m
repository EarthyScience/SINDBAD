function [f,fe,fx,s,d,p] = Qsurf_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	:
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% dc        : delayed surface runoff coefficient [1/time]
%           (p.Qsurf.dc)
% wGW       : surface water pool [mm]
%           (s.w.wSurf)
%
% OUTPUT
% Qsurf     : slow surface runoff [mm/time]
%           (fx.Qsurf)
% wSurf       : surface water pool [mm]
%           (s.w.wSurf)
%
% NOTES:
%
% #########################################################################

% np = (1-(1-p).^time_res); % time resolution is in days

% simply assume that a fraction of the surface water pool is slow runoff
fx.Qsurf (:,tix) = p.Qsurf.dc .* s.w.wSurf;

% update the surface water pool
s.w.wSurf = s.w.wSurf - fx.Qsurf(:,tix);

end
