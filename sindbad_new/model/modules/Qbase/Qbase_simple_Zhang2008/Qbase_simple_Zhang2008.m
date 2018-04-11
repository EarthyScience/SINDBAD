function [fx,s,d] = Qbase_simple_Zhang2008(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% bc        : baseflow coefficient [1/time]
%           (p.Qbase.bc)
% wGW       : ground water pool [mm] 
%           (s.w.wGW)
% 
% OUTPUT
% Qb        : base flow [mm/time]
%           (fx.Qb)
% wGW       : ground water pool [mm] 
%           (s.w.wGW)
% 
% NOTES:
% 
% #########################################################################

% np = (1-(1-p).^time_res); % time resolution is in days
% scale: p.Qbase.bc

% simply assume that a fraction of the GW pool is baseflow
fx.Qb(:,tix) = p.Qbase.bc .* s.w.wGW;

% update the GW pool
s.w.wGW = s.w.wGW - fx.Qb(:,tix);
end