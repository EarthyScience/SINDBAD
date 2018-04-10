function info = temHelpers(info)

% generic helpers... maybe this should go someplace else...
info.helper.zeros2d	= zeros(info.forcing.size);
info.helper.zeros1d	= zeros(info.forcing.size(1),1);
info.helper.ones2d  = ones(info.forcing.size);
info.helper.ones1d  = ones(info.forcing.size(1),1);
info.helper.nan2d   = nan(info.forcing.size);
info.helper.nan1d   = nan(info.forcing.size(1),1);

% for pools aggregation if necessary
info.helper.cPoolsID4.cVeg          = 1:4;
info.helper.cPoolsID4.cLitter       = 5:10;
info.helper.cPoolsID4.cSoil         = 11:14;
info.helper.cPoolsID4.cLeaf         = 4;
info.helper.cPoolsID4.cWood         = 3;            %including sapwood and hardwood.
info.helper.cPoolsID4.cRoot         = 1:2;          %including fine and coarse roots.
info.helper.cPoolsID4.cMisc         = [];           %e.g., labile, fruits, reserves, etc.
info.helper.cPoolsID4.cCwd          = 9;            %Carbon Mass in Coarse Woody Debris
info.helper.cPoolsID4.cLitterAbove	= 5:6;          %Carbon Mass in Above-Ground Litter
info.helper.cPoolsID4.cLitterBelow	= [7:8 10];     %Carbon Mass in Below-Ground Litter
info.helper.cPoolsID4.cSoilFast     = 11:13;        %fast is meant as lifetime of less than 10 years for  reference climate conditions (20 C, no water limitations).
info.helper.cPoolsID4.cSoilMedium	= [];           %medium is meant as lifetime of more than than 10 years and less than 100 years for  reference climate conditions (20 C, no water limitations)
info.helper.cPoolsID4.cSoilSlow     = 14;           %fast is meant as lifetime of more than 100 years for  reference climate conditions (20 C, no water limitations)
info.helper.cPoolsID4.cTotal        = 1:14;


end % function