function [f,fe,fx,s,d,p] = wSoilRec_kUnsat(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes the downward flow of moisture (drainage) in soil layers based on unsaturated
% hydraulic conductivity
%
% Inputs:
%	- s.w.wSoil: soil moisture in different layers
%   - p.pSoil.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
%
% Outputs:
%   - s.wd.wSoilFlow: drainage flux between soil layers (same as nZix, from percolation
%                  into layer 1 and the drainage to the last layer)
%        - drainage from the last layer is saved as groundwater recharge (gwRec)
%
% Modifies:
% 	- s.w.wSoil 
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> get the number of soil layers
nSoilLayers                 =   s.wd.p_wSoilBase_nsoilLayers;
s.wd.wSoilFlow(:,1)         =   fx.wSoilPerc(:,tix);
for sl=1:nSoilLayers-1
    %--> get the drainage flux
    dosSoil              =  s.w.wSoil(:,sl) ./ s.wd.p_wSoilBase_wSat(:,sl);

    drain                   =   ((dosSoil) .^ (p.wSoilRec.dos_exp .* s.wd.p_wSoilBase_Beta(:,sl))) .* s.w.wSoil(:,sl);

    % k_unsat                 =   feval(p.pSoil.kUnsatFuncH,s,p,info,sl);    
    % drain                   =   min(k_unsat,s.w.wSoil(:,sl));
    %--> store the drainage flux
    s.wd.wSoilFlow(:,sl+1)  =   drain;
    drain = min(drain, s.wd.p_wSoilBase_wSat(:,sl+1) - s.w.wSoil(:,sl+1));
    %--> update storages
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl) - drain;
    s.w.wSoil(:,sl+1)       =   s.w.wSoil(:,sl+1)+drain;
end
end
