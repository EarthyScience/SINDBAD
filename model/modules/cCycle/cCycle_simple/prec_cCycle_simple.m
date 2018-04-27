function [f,fe,fx,s,d,p] = prec_cCycle_simple(f,fe,fx,s,d,p,info)
% NUMBER OF TIME STEPS PER YEAR
TSPY                =   info.tem.model.time.nStepsYear;
% s.prev.cTaufwSoil_fwSoil=info.tem.helpers.arrays.onespixzix.c.cEco; %sujan
% CALCULATE DECAY RATES FOR THE ECOSYSTEM C POOLS AT APPROPRIATE TIME STEPS
s.cd.p_cCycleBase_k	=   1 - (exp(-s.cd.p_cCycleBase_annk) .^ (1 / TSPY));
s.cd.cEcoEfflux     =   info.tem.helpers.arrays.zerospixzix.c.cEco; %sujan moved from get states

end % function