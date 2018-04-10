function fx = initCflux(fx,info)
% #########################################################################
% FUNCTION	: initCflux
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
startvalues     = repmat({info.helper.zeros2d},1,numel(poolname));
fx.cEfflux      = struct('value', startvalues,'maintenance',startvalues,'growth',startvalues);
fx.gpp          = info.helper.nan2d;
fx.npp          = info.helper.zeros2d;
fx.ra           = info.helper.zeros2d;
fx.rh           = info.helper.zeros2d;
startvalues     = repmat({info.helper.nan2d},1,4);
fx.cNpp         = struct('value', startvalues);

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
