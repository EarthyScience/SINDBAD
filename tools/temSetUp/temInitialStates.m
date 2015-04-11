function info = temInitialStates(info)

% cpools
info.iniStates.cPools	= zeros(info.forcing.size(1),1);

% water pools: fraction of AWC -> should this be a parameter?
info.iniStates.smFrac   = 1;

% generic helpers... maybe this should go someplace else...
info.helper.zeros2d	= zeros(info.forcing.size);
info.helper.zeros1d	= zeros(info.forcing.size(1),1);
info.helper.ones2d  = ones(info.forcing.size);
info.helper.ones1d  = ones(info.forcing.size(1),1);
info.helper.nan2d   = nan(info.forcing.size);
info.helper.nan1d   = nan(info.forcing.size(1),1);

end % function