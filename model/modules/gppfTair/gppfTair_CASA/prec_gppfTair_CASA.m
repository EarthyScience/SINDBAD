function [f,fe,fx,s,d,p] = prec_gppfTair_CASA(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the temperature stress for gppPot based on CASA and Potter
%
% Inputs:
%   - f.TairDay: daytime temperature [degC]
%   - p.gppfTair.Topt: Optimum temperature for GPP [(]degC]
%   - p.gppfTair.ToptA: % original = 0.2
%   - p.gppfTair.ToptB: % original = 0.3
%   
% Outputs:
%   - d.gppfRdir.LightScGPP: effect of light saturation on potential GPP
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
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% get air temperature during the day
AIRT    =   f.TairDay;

% make it varying in space
tmp     =   info.tem.helpers.arrays.onestix;

TOPT    =   p.gppfTair.Topt  .* tmp;
A       =   p.gppfTair.ToptA .* tmp;    
B       =   p.gppfTair.ToptB .* tmp;    

%--> CALCULATE T1: account for effects of temperature stress;
% reflects the empirical observation that plants in very
% cold habitats typically have low maximum rates
% T1 = 0.8 + 0.02 .* TOPT - 0.0005 .* TOPT .^ 2;
% this would make sense if TOPT would be the same everywhere.
T1      =   1;
    
%--> first half of the response curve
T2p1    =   1 ./ (1 + exp(A .* (-10))) ./ (1 + exp(A .* (- 10)));
T2C1    =   1 ./ T2p1;
T21     =   T2C1 ./ (1 + exp(A .* (TOPT - 10 - AIRT))) ./ ...
            (1 + exp(A .* (- TOPT - 10 + AIRT)));

%--> second half of the response curve
T2p2    =   1 ./ (1 + exp(B .* (-10))) ./ (1 + exp(B .* (- 10)));
T2C2    =   1 ./ T2p2;
T22     =   T2C2 ./ (1 + exp(B .* (TOPT - 10 - AIRT))) ./ ...
            (1 + exp(B .* (- TOPT - 10 + AIRT)));

%--> combine the response curves
v       =   AIRT >= TOPT;
T2      =   T21;
T2(v)   =   T22(v);

% assign it to the array
d.gppfTair.TempScGPP    =   T2 .* T1;

end