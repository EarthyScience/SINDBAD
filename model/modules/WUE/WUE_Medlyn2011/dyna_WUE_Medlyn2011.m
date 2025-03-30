function [f,fe,fx,s,d,p] = dyna_WUE_Medlyn2011(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the WUE/AOE ci/ca as a function of daytime mean VPD and ambient co2
%
% Inputs:
%   - fe.WUE.AoENoCO2: precomputed A/E [gC/mmH2O] without ambient co2
%   - fe.WUE.ciNoCO2: precomputed internal co2 scalar without ambient co2
%
% Outputs:
%   - d.WUE.AoE: water use efficiency A/E [gC/mmH2O] with ambient co2
%   - d.WUE.ci: internal co2 with ambient co2
%
% Modifies:
%     - None
%
% References:
%    - MEDLYN, B.E., DUURSMA, R.A., EAMUS, D., ELLSWORTH, D.S., PRENTICE, I.C., 
%       BARTON, C.V.M., CROUS, K.Y., DE ANGELIS, P., FREEMAN, M. and WINGATE, 
%       L. (2011), Reconciling the optimal and empirical approaches to 
%       modelling stomatal conductance. Global Change Biology, 17: 2134-2144. 
%       doi:10.1111/j.1365-2486.2010.02375.x
%    - Medlyn, B.E., Duursma, R.A., Eamus, D., Ellsworth, D.S., Colin Prentice, 
%       I., Barton, C.V.M., Crous, K.Y., de Angelis, P., Freeman, M. and
%       Wingate, L. (2012), Reconciling the optimal and empirical approaches to 
%       modelling stomatal conductance. Glob Change Biol, 18: 3476-3476. 
%       doi:10.1111/j.1365-2486.2012.02790.
%
% Notes:
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2020 (skoirala):
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
d.WUE.AoE(:,tix)            =   fe.WUE.AoENoCO2(:,tix) .* p.WUE.zeta .* s.cd.ambCO2; 
d.WUE.ci(:,tix)             =   fe.WUE.ciNoCO2(:,tix) .* s.cd.ambCO2; 

end