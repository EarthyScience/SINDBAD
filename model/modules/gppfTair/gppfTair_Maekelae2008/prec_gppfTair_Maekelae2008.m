function [f,fe,fx,s,d,p] = prec_gppfTair_Maekelae2008(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the temperature stress on gppPot based on Maekelae2008 (eqn 3 and 4)
%
% Inputs:
%   - f.TairDay: daytime temperature [degC]
%   - p.gppfTair.TimConst: time constant of the delay process [days] (between 1 and 20
%           days; guessed median = 5)
%   - p.gppfTair.X0: a threshold value of the delayed temperature [degC], X0 [-15
%           1]; median ~-5
%   - p.gppfTair.Smax: determines the value of Sk at which the temperature modifier
%           attains its saturating level [degC],  between 11 and 30, median
%           ~20
%   
% Outputs:
%   - d.gppfRdir.LightScGPP: effect of light saturation on potential GPP
%
% Modifies:
%   - 
%
% References:
%    - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008). 
%       Developing an empirical model of stand GPP with the LUE approach: 
%       analysis of eddy covariance data at five contrasting conifer sites in Europe. 
%       Global change biology, 14(1), 92-108. 
%
% Notes: 
%   - Tmin < Tmax ALWAYS!!! 
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> create the arrays
tmp         =   info.tem.helpers.arrays.onestix;
TimConst    =   p.gppfTair.TimConst;
X0          =   p.gppfTair.X0    .* tmp;
Smax        =   p.gppfTair.Smax  .* tmp;

%--> calculate temperature acclimation
X           =   f.TairDay; %pix,tix
for ii  =   2:info.tem.helpers.sizes.nTix
    X(:,ii) =   X(:,ii-1) + (1 ./ TimConst) .* (f.TairDay(:,ii) - X(:,ii-1));
end

%--> calculate the stress and saturation
S           =   max(X - X0 ,0);
vsc         =   max(min(S ./ Smax,1),0);

%--> assign stressor
d.gppfTair.TempScGPP = vsc;
end
