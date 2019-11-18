function [f,fe,fx,s,d,p] = Qint_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% calculates interflow as a fraction of the available water
%
% Inputs:
%	- p.Qint.rc:    interflow runoff coefficient (fraction of WBP)
%
% Outputs:
%   - fx.Qint:      interflow [mm/time]
%
% Modifies:
% 	- s.wd.WBP:     water balance pool [mm]
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

% simply assume that a fraction of the still available water runs off
fx.Qint(:,tix) = p.Qint.rc .* s.wd.WBP;

% update the WBP
s.wd.WBP = s.wd.WBP - fx.Qint(:,tix);

end