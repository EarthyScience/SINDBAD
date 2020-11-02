function [f,fe,fx,s,d,p] = roInf_kUnsat(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the infiltration excess runoff based on unstaurated hydraulic conductivity
%
% Inputs:
%   - s.w.wSoil of first layer
%   - p.p.pSoil.kUnsatFuncH: function to calculate unsaturated K: out of pSoil (Saxtion1986 or Saxton2006)
%
% Outputs:
%   - fx.evapSoil
%   - fe.evapSoil.PETSoil
%
% Modifies:
%   - s.w.wSoil(:,1): bare soil evaporation is only allowed from first soil layer
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 23.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
%-->  get the unsaturared hydraulic conductivity based on soil properties for the first soil layer
k_unsat                 =   feval(p.pSoil.kUnsatFuncH,s,p,info,1);    

%--> minimum of the conductivity and the incoming water
fx.roInf(:,tix)         =   max(s.wd.WBP-k_unsat,0);

%--> update the remaining water
s.wd.WBP                =  s.wd.WBP - fx.roInf(:,tix);
end
