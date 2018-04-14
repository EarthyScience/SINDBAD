function [p] = prec_cCycle_simple(f,fe,fx,s,d,p,info)
% NUMBER OF TIME STEPS PER YEAR
TSPY        = info.tem.model.time.stepsPerYear;

% CALCULATE DECAY RATES FOR THE ECOSYSTEM C POOLS AT APPROPRIATE TIME STEPS
for zix = info.tem.model.variables.states.c.cEco.zix
    annk            = p.cCycle.annk(zix);
    p.cCycle.k(zix)	= 1 - (exp(-annk) .^ (1 / TSPY));
end

end % function