function s = initCpools(s,info)
% #########################################################################
% FUNCTION	: initCpools
% 
% PURPOSE	: initialize the variable that holds the ecosystem carbon pools 
% 
% REFERENCES:
% 
% CONTACT	: Nuno
% 
% #########################################################################
% initial value for pools
S = ones(info.forcing.size(1),1) .* 1E-10;
S0 = zeros(info.forcing.size);

% pool names
% oldpoolname	= {'ROOT',          'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD', 'LiRoot'};
% oldpoolid     = [      1               2       3         4         5         6         7        8            9          10      11     12        13];
poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
% newpoolid     = [      1       2       3       4         5         6         7         8         9        10          11          12      13     14];
startvalues     = repmat({S},1,numel(poolname));
startvalues0    = repmat({S0},1,numel(poolname));
s.cPools        = struct('value', startvalues, 'ts',startvalues0);

end % function

% pool id transfer
% 4->5
% 5->6
% 6->7
% 7->8
% 8->9
% 9->11
% 10->12
% 11->13
% 12->14
% 13->10
