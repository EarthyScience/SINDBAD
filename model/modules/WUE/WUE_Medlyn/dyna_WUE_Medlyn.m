function [f,fe,fx,s,d,p] = dyna_WUE_Medlyn(f,fe,fx,s,d,p,info,tix)

d.WUE.AoE(:,tix)            =   fe.WUE.AoENoCO2 .* s.cd.ambCO2; 
d.WUE.ci(:,tix)             =   fe.WUE.ciNoCO2 .* s.cd.ambCO2; 

end