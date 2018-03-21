function [fx,s,d] = qCbase_simple_Zhang2008(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% bc        : baseflow coefficient [1/time]
%           (p.qCbase.bc)
% wGW       : ground water pool [mm] 
%           (s.wGW)
% 
% OUTPUT
% Qb        : base flow [mm/time]
%           (fx.Qb)
% wGW       : ground water pool [mm] 
%           (s.wGW)
% 
% NOTES:
% 
% #########################################################################

% np = (1-(1-p).^time_res); % time resolution is in days
% scale: p.qCbase.bc

% simply assume that a fraction of the GW pool is baseflow
fx.Qb(:,tix) = p.qCbase.bc .* s.wGW;

% update the GW pool
s.wGW = s.wGW - fx.Qb(:,tix);
end