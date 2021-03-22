function [f,fe,fx,s,d,p] = dyna_cTaufwSoil_gsi(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the moisture stress for cTau based on temperature stressor function of CASA and Potter
%
% Inputs:
%   - s.w.wSoil: soil temperature
%   - p.cTaufwSoil.Wopt: Optimum moisture
%   - p.cTaufwSoil.WoptA: % original = 0.2
%   - p.cTaufwSoil.WoptB: % original = 0.3
%   
% Outputs:
%   - s.cd.p_cTaufwSoil_fwSoil: effect of moisture on cTau for different pools
%
% Modifies:
%   - 
%
% References:
%   - Carvalhais, N., Reichstein, M., Seixas, J., Collatz, G. J., Pereira, J. S., Berbigier, P., 
%       ... & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for 
%       biogeochemical modeling performance and inverse parameter retrieval. Global Biogeochemical Cycles, 22(2).
%   - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., 
%       & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global 
%       satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.
%   - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003). 
%       Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data and ecosystem 
%       modeling 1982–1998. Global and Planetary Change, 39(3-4), 201-213.
%
% Notes: 
%  
% Created by:
%   - Sujan Koirala
%
% Versions:
%   - 1.0 on 12.02.2021 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% get the parameters
WOPT    =   p.cTaufwSoil.Wopt;
A       =   p.cTaufwSoil.WoptA;
B       =   p.cTaufwSoil.WoptB;

%% for the litter pools, only use the top layer's moisture
wSoil_top    =   100 .* s.w.wSoil(:,1) ./ s.wd.p_wSoilBase_wSat(:,1);


%--> first half of the response curve
W2p1    =   1 ./ (1 + exp(A .* (-10))) ./ (1 + exp(A .* (- 10)));
W2C1    =   1 ./ W2p1;
W21     =   W2C1 ./ (1 + exp(A .* (WOPT - 10 - wSoil_top))) ./ ...
            (1 + exp(A .* (- WOPT - 10 + wSoil_top)));

%--> second half of the response curve
W2p2    =   1 ./ (1 + exp(B .* (-10))) ./ (1 + exp(B .* (- 10)));
W2C2    =   1 ./ W2p2;
T22     =   W2C2 ./ (1 + exp(B .* (WOPT - 10 - wSoil_top))) ./ ...
            (1 + exp(B .* (- WOPT - 10 + wSoil_top)));

%--> combine the response curves
v       =   wSoil_top >= WOPT;
T2      =   W21;
T2(v)   =   T22(v);

% assign it to the array
wSoil1_sc    =   T2;

s.cd.p_cTaufwSoil_fwSoil(:,info.tem.model.variables.states.c.zix.cLit) = wSoil1_sc;

%% repeat for the soil pools, using all soil moisture layers
wSoil_all    =   100 .* sum(s.w.wSoil,2) ./ sum(s.wd.p_wSoilBase_wSat,2);

%--> first half of the response curve
W2p1    =   1 ./ (1 + exp(A .* (-10))) ./ (1 + exp(A .* (- 10)));
W2C1    =   1 ./ W2p1;
W21     =   W2C1 ./ (1 + exp(A .* (WOPT - 10 - wSoil_all))) ./ ...
            (1 + exp(A .* (- WOPT - 10 + wSoil_all)));

%--> second half of the response curve
W2p2    =   1 ./ (1 + exp(B .* (-10))) ./ (1 + exp(B .* (- 10)));
W2C2    =   1 ./ W2p2;
T22     =   W2C2 ./ (1 + exp(B .* (WOPT - 10 - wSoil_all))) ./ ...
            (1 + exp(B .* (- WOPT - 10 + wSoil_all)));

%--> combine the response curves
v       =   wSoil_all >= WOPT;
T2      =   W21;
T2(v)   =   T22(v);

% assign it to the array
wSoil_all_sc    =   T2;

s.cd.p_cTaufwSoil_fwSoil(:,info.tem.model.variables.states.c.zix.cSoil) = wSoil_all_sc;
d.cTaufwSoil.fwSoil(:, tix) = wSoil_all_sc;


end