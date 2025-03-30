function [f,fe,fx,s,d,p] = roSat_Bergstroem(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates infiltration excess runoff and infiltration to different soil layers
%
% Inputs:
%   - p.roSat.berg       : shape parameter of runoff-infiltration curve []
%
% Outputs:
%   - fx.roSat      : runoff from land [mm/time]
%
% Modifies:
%   - s.wd.WBP     : water balance pool [mm]
%
% References:
%   - Bergström, S. (1992). The HBV model–its structure and applications. SMHI.
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%   - 1.1 on 27.11.2019: skoirala: changed to handle any number of soil layers
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
tmp_smaxVeg         = sum(s.wd.p_wSoilBase_wSat,2);
tmp_SoilTotal       = sum(s.w.wSoil, 2);

% calculate land runoff from incoming water and current soil moisture
tmp_InfExFrac       =   min(exp(p.roSat.berg .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);

% tmp_InfExFrac       =   min(exp(p.roSat.berg .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);
fx.roSat(:,tix)     =   s.wd.WBP .* tmp_InfExFrac;

% update water balance
s.wd.WBP            =   s.wd.WBP - fx.roSat(:,tix);


end

