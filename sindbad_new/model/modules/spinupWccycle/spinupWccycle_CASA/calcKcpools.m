function [fe] = calcKcpools(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: calcKcpools
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
% annk?     : annual turnover rates of carbon for the different soil carbon
%           pools (yr-1). ? is the name of the pool
%           (p.CCycle.annk?)
%           example
%           p.CCycle.annkSLOW is the annual turnover rate of the slow pool
% ?_AGE     : average age of vegetation pools (yr). ? is the name of the
%           pool
%           (p.CCycle.?_AGE)
%           example
%           p.CCycle.ROOT_AGE is the mean age of the fine roots
% 
% OUTPUT
% kpool     : turnover rate of the different ecosystem (vegetation and
%           soil) pools (deltaT-1). Structure array
% annkpool	: annual turnover rate of the different ecosystem (vegetation and
%           soil) pools (yr-1). Structure array
% #########################################################################

% NUMBER OF TIME STEPS PER YEAR
TSPY        = info.timeScale.stepsPerYear;

% ECOSYSTEM CARBON POOLS
poolname	= {
    'ROOT', 'ROOTC', 'WOOD', 'LEAF',                            ... VEGETATION
    'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', ... LITTER
    'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};                     %   MICROBIAL AND SLOWER SOIL

% CALCULATE SOIL DECOMPOSITION SCALARS AT APPROPRIATE TIME STEP
for ii = 5:numel(poolname)
    annk                           = p.CCycle.(['annk' poolname{ii}]);
    fe.CCycle.annkpool(ii).value   = annk;
    fe.CCycle.kpool(ii).value      = 1 - (exp(-annk) .^ (1 / TSPY));
end

% CALCULATE DECAY RATES FOR THE VEGETATION POOLS AT APPROPRIATE TIME STEPS
for ii = 1:4
    AGE                            = p.CCycle.([poolname{ii} '_AGE']);
    annk                           = 1e-40 .* ones(size(AGE));
    annk(AGE > 0)                  = 1 ./ AGE(AGE > 0);
    fe.CCycle.annkpool(ii).value   = annk;
    fe.CCycle.kpool(ii).value      = 1 - (exp(-annk) .^ (1 / TSPY));
end

end % function