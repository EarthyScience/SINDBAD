function [f,fe,fx,s,d,p]=dyna_wSoilUpflow_VanDijk(f,fe,fx,s,d,p,info,tix)

% index of the last soil layer


wSoilend                =   info.tem.model.variables.states.w.nZix.wSoil;

% degree of saturation of the lowermost soil layer

for sl=wSoilend:-1:2
    dosSoilLower                  =  s.w.wSoil(:,sl) ./ fe.wSoilBase.sSat(:,sl);
    k_unsatfrac_soil_lower        =  min((dosSoilLower) .^ (2 .* fe.wSoilBase.Beta(:,sl) + 3),1);
    k_unsat_lower                 =   fe.wSoilBase.kSat(:,sl) .* k_unsatfrac_soil_lower;
    
    dosSoilUpper                  =  s.w.wSoil(:,sl-1) ./ fe.wSoilBase.sSat(:,sl-1);
    k_unsatfrac_soil_upper        =  min((dosSoilUpper) .^ (2.* fe.wSoilBase.Beta(:,sl-1) + 3),1);
    k_unsat_upper                 =  fe.wSoilBase.kSat(:,sl) .* k_unsatfrac_soil_upper;
    c_flux                        =  sqrt(k_unsat_lower .* k_unsat_upper) .* (1 - dosSoilUpper);
    c_flux                        =  min(c_flux,s.w.wSoil(:,sl));
%     c_flux                        = 0;
% 
% % update storages
    s.w.wSoil(:,sl)   =   s.w.wSoil(:,sl)-c_flux;
    s.w.wSoil(:,sl-1)   =   s.w.wSoil(:,sl-1)+c_flux;
end
end % function