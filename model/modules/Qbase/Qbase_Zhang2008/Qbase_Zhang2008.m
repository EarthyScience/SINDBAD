function [f,fe,fx,s,d,p] = Qbase_Zhang2008(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% computes baseflow from a linear ground water storage
%
% Inputs:
%	- p.Qbase.bc:   baseflow coefficient [1/time]
%
% Outputs:
%   - fx.Qbase:     base flow [mm/time]
%
% Modifies:
% 	- s.w.wGW:      ground water pool [mm]
%
% References:
%	- Zhang et al 2008
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################
% simply assume that a fraction of the GW pool is baseflow
fx.Qbase(:,tix) = p.Qbase.bc .* s.w.wGW;
% update the GW pool
s.w.wGW = s.w.wGW - fx.Qbase(:,tix);
end
