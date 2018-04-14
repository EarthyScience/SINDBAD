function [f,fe,fx,s,d,p] = prec_cCycle_CASA(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: prec_cCycle_CASA
% 
% PURPOSE	: pre compute the time step scalars that control carbon flows
%           between vegetation and soil and within the soil that depend on
%           parameters and model forcing.
% 
% REFERENCES:
% Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
% Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
% production: A process model based on global satellite and surface data. 
% Global Biogeochemical Cycles. 7: 811-841. 
% 
% CONTACT	: Nuno
% 
% INPUT
% #########################################################################

%% CALCULATE THE TURNOVER RATES OF EACH POOL AT ANNUAL AND TIME STEP SCALES
% NUMBER OF TIME STEPS PER YEAR
TSPY        = info.tem.model.time.stepsPerYear;

% CALCULATE DECAY RATES FOR THE ECOSYSTEM C POOLS AT APPROPRIATE TIME STEPS
for zix = info.tem.model.variables.states.c.cEco.zix
    annk            = p.cCycle.annk(zix);
    p.cCycle.k(zix)	= 1 - (exp(-annk) .^ (1 / TSPY));
end


end % function
