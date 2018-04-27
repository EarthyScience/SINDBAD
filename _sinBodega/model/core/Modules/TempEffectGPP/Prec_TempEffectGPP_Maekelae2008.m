function [fe,fx,d,p] = Prec_TempEffectGPP_Maekelae2008(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: estimate temperature effect on GPP 
% 
% REFERENCES: Maekelae et al 2008 - Developing an empirical model of stand
% GPP with the LUE approach: analysis of eddy covariance data at five
% contrasting conifer sites in Europen
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% TairDay   : daytime temperature [ºC]
%           (f.TairDay)
% TimConst  : time constant of the delay process [days] (between 1 and 20
%           days; guessed median = 5)
%           (p.TempEffectGPP.TimConst)
% X0        : is a threshold value of the delayed temperature [ºC], X0 [-15
%           1]; median ~-5
%           (p.TempEffectGPP.X0)
% Smax      : determines the value of Sk at which the temperature modifier
%           attains its saturating level [ºC],  between 11 and 30, median
%           ~20
%           (p.TempEffectGPP.Smax)
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.TempEffectGPP.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Tmax ALWAYS!!! can go in the consistency checks!
% 
% #########################################################################


tmp = ones(1,info.forcing.size(2));

TimConst    = p.TempEffectGPP.TimConst;
X0          = p.TempEffectGPP.X0    * tmp;
Smax        = p.TempEffectGPP.Smax  * tmp;

% acclimation
X = f.TairDay;
for ii=2:info.forcing.size(2)
    X(:,ii)=X(:,ii-1) + 1 / TimConst .* (f.TairDay(:,ii) - X(:,ii-1));
end

S   = max(X - X0 ,0);
vsc = max(min(S ./ Smax,1),0);

d.TempEffectGPP.TempScGPP = vsc;

end