function [f,fe,fx,s,d,p] = roInt_residual(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates interflow as a fraction of the available water
%
% Inputs:
%   - p.roInt.rc:    interflow runoff coefficient (fraction of WBP)
%
% Outputs:
%   - fx.roInt:      interflow [mm/time]
%
% Modifies:
%   - s.wd.WBP:     water balance pool [mm]
%
% References:
%   - 
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% simply assume that a fraction of the still available water runs off
fx.roInt(:,tix) = p.roInt.rc .* s.wd.WBP;

% update the WBP
s.wd.WBP = s.wd.WBP - fx.roInt(:,tix);

end