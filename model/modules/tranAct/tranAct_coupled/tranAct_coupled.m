function [f,fe,fx,s,d,p] = tranAct_coupled(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the actual transpiration as function of gppAct and WUE
%
% Inputs:
%   - d.WUE.AoE: water use efficiency in gC/mmH2O
%   - fx.gppAct: GPP based on a minimum of demand and stressors (except water 
%        limitation) out of gppAct_coupled in which tranSup is used to get 
%        supply limited GPP
%
% Outputs:
%   - fx.tranAct: actual transpiration 
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Notes:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> calculate actual transpiration coupled with GPP
AoE                     =   d.WUE.AoE(:,tix);
fx.tranAct(:,tix)	    =   fx.gpp(:,tix) ./ AoE;
end