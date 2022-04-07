function [f,fe,fx,s,d,p] = prec_roSat_BergstroemLinVegFrFroSoil(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates land surface runoff and infiltration to different soil layers
% using 
%
% Inputs:
%   - f.fracFrozen       : daily frozen soil fraction (0-1)
%   - p.fracFrozen.scale : scaling parameter for frozen soil fraction
%
% Outputs:
%   - fe.roSat.fracFrozen : scaled frozen soil fraction 
%
% Modifies:
%   - s.wd.WBP     : water balance pool [mm]
%
% References:
%   - Bergstroem, S. (1992). The HBV model–its structure and applications. SMHI.
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% scale the input frozen soil fraction, maximum is 1
fe.roSat.fracFrozen  = min(f.frozenFrac .* p.roSat.scaleFro, 1);

end
