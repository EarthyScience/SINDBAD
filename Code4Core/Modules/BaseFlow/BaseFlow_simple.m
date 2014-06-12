function [fx,s,d]=BaseFlow_simple(f,fe,fx,s,d,p,info,i);

%simply assume that a fraction of the GW pool is baseflow
fx.Qb(:,i) = p.BaseFlow.bc .* s.wGW(:,i);

%update the GW pool
s.wGW(:,i) = s.wGW(:,i) - fx.Qb(:,i);
end