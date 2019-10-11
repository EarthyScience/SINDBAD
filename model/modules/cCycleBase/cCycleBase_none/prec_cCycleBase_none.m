function [f,fe,fx,s,d,p] = prec_cCycleBase_none(f,fe,fx,s,d,p,info)
% @nc: I think the none should not make these guys 
s.cd.p_cCycleBase_k              = info.tem.helpers.arrays.onespixzix.c.cEco;
s.cd.p_cCycleBase.cFlowE         = info.tem.helpers.arrays.onespixzix.c.cEco;
s.cd.p_cCycleBase.cFlowF         = info.tem.helpers.arrays.onespixzix.c.cEco;
s.cd.p_cCycleBase_annk           = info.tem.helpers.arrays.onespixzix.c.cEco;
end % function
