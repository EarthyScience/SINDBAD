function s = initCpools(info,s)
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

% pool names
% oldpoolname	= {'ROOT',          'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD', 'LiRoot'};
% oldpoolid     = [      1               2       3         4         5         6         7        8            9          10      11     12        13];
poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
% newpoolid     = [      1       2       3       4         5         6         7         8         9        10          11          12      13     14];
startvalues     = repmat({info.helper.zeros1d},1,numel(poolname));
s.cPools        = struct('value', startvalues);

% if info.flags.saveStates >= 1
%     s.cVeg      = info.helper.zeros1d;
%     s.cLitter   = info.helper.zeros1d;
%     s.cSoil     = info.helper.zeros1d;
% end
% 
% if info.flags.saveStates == 3
%     s.cLeaf         = info.helper.zeros1d;
%     s.cWood         = info.helper.zeros1d;
%     s.cRoot         = info.helper.zeros1d;
%     s.cMisc         = info.helper.zeros1d;
%     s.cCwd          = info.helper.zeros1d;
%     s.cLitterAbove  = info.helper.zeros1d;
%     s.cLitterBelow  = info.helper.zeros1d;
%     s.cSoilFast     = info.helper.zeros1d;
%     s.cSoilMedium	= info.helper.zeros1d;
%     s.cSoilSlow     = info.helper.zeros1d;
% end




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
