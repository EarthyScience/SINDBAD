function [f,fe,fx,s,d,p] = QsurfIndir_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	:
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% dc        : delayed surface runoff coefficient [1/time]
%           (p.QsurfIndir.dc)
% wGW       : surface water pool [mm]
%           (s.w.wSurf)
%
% OUTPUT
% QsurfIndir     : slow surface runoff [mm/time]
%           (fx.QsurfIndir)
% wSurf       : surface water pool [mm]
%           (s.w.wSurf)
%
% NOTES:
%
% #########################################################################

% np = (1-(1-p).^time_res); % time resolution is in days

% simply assume that a fraction of the surface water pool is slow runoff
fx.QsurfIndir(:,tix) = p.QsurfIndir.dc .* s.w.wSurf;

% update the surface water pool
s.w.wSurf = s.w.wSurf - fx.QsurfIndir(:,tix);

end
