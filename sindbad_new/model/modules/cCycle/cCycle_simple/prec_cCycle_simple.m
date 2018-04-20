function [p] = prec_cCycle_simple(f,fe,fx,s,d,p,info)
% NUMBER OF TIME STEPS PER YEAR
TSPY        = info.tem.model.time.stepsPerYear;

% CALCULATE DECAY RATES FOR THE ECOSYSTEM C POOLS AT APPROPRIATE TIME STEPS
s.cd.p_cCycleBase_k	= 1 - (exp(-s.cd.p_cCycleBase_annk) .^ (1 / TSPY));

end % function