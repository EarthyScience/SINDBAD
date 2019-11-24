function [f,fe,fx,s,d,p]=dyna_wSoilUpflow_VanDijk2010(f,fe,fx,s,d,p,info,tix)

% index of the last soil layer


wSoilend                =   info.tem.model.variables.states.w.nZix.wSoil;

% degree of saturation of the lowermost soil layer

for sl=wSoilend:-1:2
    
%     dosSoilLower                  =   s.w.wSoil(:,sl) ./ s.wd.p_wSoilBase_wSat(:,sl);
    % kSat_lower                    =   s.wd.p_wSoilBase_kSat(:,sl);
    % Beta_lower                    =   s.wd.p_wSoilBase_Beta(:,sl);
    k_unsat_lower                 =   feval(p.pSoil.kUnsatFuncH,s,p,sl);    

    dosSoilUpper                  =   s.w.wSoil(:,sl-1) ./ s.wd.p_wSoilBase_wSat(:,sl-1);
    % kSat_upper                    =   s.wd.p_wSoilBase_kSat(:,sl-1);
    % Beta_upper                    =   s.wd.p_wSoilBase_Beta(:,sl-1);
    k_unsat_upper                 =   feval(p.pSoil.kUnsatFuncH,s,p,sl-1);    

    c_flux                        =   sqrt(k_unsat_lower .* k_unsat_upper) .* (1 - dosSoilUpper);
    c_flux                        =   min(c_flux,s.w.wSoil(:,sl));
% % update storages
    s.w.wSoil(:,sl)               =   s.w.wSoil(:,sl)-c_flux;
    s.w.wSoil(:,sl-1)             =   s.w.wSoil(:,sl-1)+c_flux;
end
end % function
