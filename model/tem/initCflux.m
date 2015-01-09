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
% initial value for pools
S = zeros(info.forcing.size);
SN = NaN(info.forcing.size);

% pool names
% oldpoolname	= {'ROOT',          'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD', 'LiRoot'};
% oldpoolid     = [      1               2       3         4         5         6         7        8            9          10      11     12        13];
poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
% newpoolid     = [      1       2       3       4         5         6         7         8         9        10          11          12      13     14];
startvalues     = repmat({S},1,numel(poolname));
fx.cEfflux      = struct('value', startvalues,'maintenance',startvalues,'growth',startvalues);
fx.gpp          = SN;
startvalues     = repmat({SN},1,4);
fx.npp          = struct('value', startvalues);


% % pool names
% % oldpoolname	= {'ROOT',          'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD', 'LiRoot'};
% % oldpoolid     = [      1               2       3         4         5         6         7        8            9          10      11     12        13];
% poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};
% % newpoolid     = [      1       2       3       4         5         6         7         8         9        10          11          12      13     14];
% 
% % initial value for pools
% S   = zeros([info.forcing.size numel(poolname)]);
% S2	= zeros([info.forcing.size 4]); % for vegetation pools
% 
% fx.cEfflux       = S;
% fx.cEfflux_main	= S2;
% fx.cEfflux_grow	= S2;
% fx.ECO.cOUT         = S;


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
