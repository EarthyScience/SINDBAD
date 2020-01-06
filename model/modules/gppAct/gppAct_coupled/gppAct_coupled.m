function [f,fe,fx,s,d,p] = gppAct_coupled(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate GPP based on transpiration supply and water use efficiency (coupled)
%
% Inputs:
%   - d.WUE.AoE: water use efficiency in gC/mmH2O
%   - d.tranSup.tranSup: supply limited transpiration
%   - d.gppDem.gppE: Demand-driven GPP with stressors except wSoil applied
%
% Outputs:
%   - fx.gpp: actual GPP 
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
fx.gpp(:,tix)           =   nanmin(d.tranSup.tranSup(:,tix) .* d.WUE.AoE(:,tix), d.gppDem.gppE(:,tix));

end