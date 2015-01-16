function [fx,s,d]=BaseFlow_simple(f,fe,fx,s,d,p,info,i);
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% bc        : baseflow coefficient [1/time]
%           (p.BaseFlow.bc)
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
% scale: p.BaseFlow.bc

% simply assume that a fraction of the GW pool is baseflow
fx.Qb(:,i) = p.BaseFlow.bc .* s.wGW(:,i);

% update the GW pool
s.wGW(:,i) = s.wGW(:,i) - fx.Qb(:,i);
end