function [f,fe,fx,s,d,p] = prec_GPPfTair_Maekelae2008(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : estimate temperature effect on GPP 
% 
% REFERENCES: Maekelae et al 2008 - Developing an empirical model of stand
% GPP with the LUE approach: analysis of eddy covariance data at five
% contrasting conifer sites in Europen
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% TairDay   : daytime temperature [?C]
%           (f.TairDay)
% TimConst  : time constant of the delay process [days] (between 1 and 20
%           days; guessed median = 5)
%           (p.GPPfTair.TimConst)
% X0        : is a threshold value of the delayed temperature [?C], X0 [-15
%           1]; median ~-5
%           (p.GPPfTair.X0)
% Smax      : determines the value of Sk at which the temperature modifier
%           attains its saturating level [?C],  between 11 and 30, median
%           ~20
%           (p.GPPfTair.Smax)
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.GPPfTair.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Tmax ALWAYS!!! can go in the consistency checks!
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


tmp         =   info.tem.helpers.arrays.onestix;


TimConst    =   p.GPPfTair.TimConst;
X0          =   p.GPPfTair.X0    * tmp;
Smax        =   p.GPPfTair.Smax  * tmp;

% acclimation
X           =   f.TairDay;
for ii  =   2:info.tem.helpers.sizes.nTix
    X(:,ii) =   X(:,ii-1) + 1 / TimConst .* (f.TairDay(:,ii) - X(:,ii-1));
end

S           =   maxsb(X - X0 ,0);
vsc         =   maxsb(minsb(S ./ Smax,1),0);

d.GPPfTair.TempScGPP = vsc;

end