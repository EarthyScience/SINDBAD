function [p] = prec_cCycle_simple(f,fe,fx,s,d,p,info)
% NUMBER OF TIME STEPS PER YEAR
TSPY        = info.tem.model.time.stepsPerYear;

% CALCULATE DECAY RATES FOR THE ECOSYSTEM C POOLS AT APPROPRIATE TIME STEPS
p.cCycle.k	= 1 - (exp(-p.cCycleBase.annk) .^ (1 / TSPY));

end % function