function [f,fe,fx,s,d,p] = Qbase_fraction(f,fe,fx,s,d,p,info,tix)
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


% simply assume that a fraction of the GW pool is baseflow
fx.Qb(:,tix) = p.Qbase.kbase .* s.w.wGW;

% update the GW pool
s.w.wGW = s.w.wGW - fx.Qb(:,tix);

end
