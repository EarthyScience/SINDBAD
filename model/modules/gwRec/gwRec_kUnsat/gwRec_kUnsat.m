function [f,fe,fx,s,d,p] = gwRec_kUnsat(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates GW recharge as the unsaturated hydraulic conductivity of
% lowermost soil layer
%
% Inputs: 
%   - p.pSoil.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
%   - s.w.wSoil: soil moisture
%   - s.wd.p_wSoilBase_wSat: moisture at saturation
%
% Outputs:
%   - fx.gwRec 
%
% Modifies:
%   - s.w.wSoil
%   - s.w.wGW
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): clean up
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% index of the last soil layer
wSoilend                =   info.tem.model.variables.states.w.nZix.wSoil;
wSoilExc                =   max(s.w.wSoil(:,wSoilend) - ...
                            s.wd.p_wSoilBase_wSat(:,wSoilend),0);
s.w.wSoil(:,wSoilend)   =   s.w.wSoil(:,wSoilend)-wSoilExc;

%--> get the drainage
% kSat                    =   s.wd.p_wSoilBase_kSat(:,wSoilend);
% Beta                    =   s.wd.p_wSoilBase_Beta(:,wSoilend);

% soilDOS                 =   s.w.wSoil(:,wSoilend) ./ s.wd.p_wSoilBase_wSat(:,wSoilend);
k_unsat                 =   feval(p.pSoil.kUnsatFuncH,s,p,info,wSoilend);    
drain                   =   min(k_unsat,s.w.wSoil(:,wSoilend));
fx.gwRec(:,tix)         =   drain;

% update storages
s.w.wSoil(:,wSoilend)   =   s.w.wSoil(:,wSoilend)-fx.gwRec(:,tix);
fx.gwRec(:,tix)         =   fx.gwRec(:,tix) + wSoilExc ;
s.w.wGW                 =   s.w.wGW + fx.gwRec(:,tix);

end
