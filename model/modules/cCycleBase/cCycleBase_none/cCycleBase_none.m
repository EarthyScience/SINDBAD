function [f,fe,fx,s,d,p] = cCycleBase_none(f,fe,fx,s,d,p,info,tix)
s.cd.p_cCycleBase_k              = info.tem.helpers.arrays.onespixzix.c.cEco;
s.cd.p_cCycleBase.cTransfer      = info.tem.helpers.arrays.onespixzix.c.cEco;
s.cd.p_cCycleBase_annk           = info.tem.helpers.arrays.onespixzix.c.cEco;
end % function
