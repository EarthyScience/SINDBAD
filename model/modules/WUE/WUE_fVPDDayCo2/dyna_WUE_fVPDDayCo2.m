function [f,fe,fx,s,d,p] = dyna_WUE_VPDDayCo2(f,fe,fx,s,d,p,info,tix)
    fCO2_CO2                    = 1 + (s.cd.ambCO2 - p.WUE.Ca0) ./ (s.cd.ambCO2 - p.WUE.Ca0 + p.WUE.Cm);
    d.WUE.AoE(:,tix)            =   fe.WUE.AoENoCO2(:,tix) .* fCO2_CO2; 
end