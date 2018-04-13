function [p] = calcKcEco(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: calcKEco
% 
% PURPOSE	: calculate the turnover rates of the individual pools of the
%           ecosystem (soil and vegetation) from parameters of annual
%           turnover rates and mean age of the different vegetation
%           components.
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
% annk      : annual turnover rates of carbon for the different soil carbon
%           pools (yr-1). 
%           (p.cCycle.annk)
% LIGEFFA   : parameter to determine the effect of lignin content on
%           decomposition rates ([]) 
%           (p.cCycle.LIGEFFA) 
% LITC2N            :carbon-to-nitrogen ratio in litter (gC/gN)
%                   (p.cCycle.LITC2N)
% LIGNIN            : fraction of litter that is lignin ([])
%                   (p.cCycle.LIGNIN)
% MTFA              : parameter A - offset - to determine the MTF as a
%                   function of lignin to nitrogen ratios ([])
%                   (p.cCycle.MTFA)
% MTFB              : parameter B - negative slope - to determine the MTF
%                   as a function of lignin to nitrogen ratios ([])
%                   (p.cCycle.MTFB)
% C2LIGNIN          : carbon to lignin ratio (massC/massLignin)
%                   (p.cCycle.C2LIGNIN)
% NONSOL2SOLLIGNIN	: 
%                   (p.cCycle.NONSOL2SOLLIGNIN)

% 
% OUTPUT
% kpool     : turnover rate of the different ecosystem (vegetation and
%           soil) pools (deltaT-1). Structure array
% annkpool	: annual turnover rate of the different ecosystem (vegetation and
%           soil) pools (yr-1). Structure array
% #########################################################################

% NUMBER OF TIME STEPS PER YEAR
TSPY        = info.tem.model.time.stepsPerYear;

% CALCULATE DECAY RATES FOR THE ECOSYSTEM C POOLS AT APPROPRIATE TIME STEPS
for zix = info.tem.model.variables.states.c.cEco.zix
    annk            = p.cCycle.annk(zix);
    p.cCycle.k(zix)	= 1 - (exp(-annk) .^ (1 / TSPY));
end

end % function