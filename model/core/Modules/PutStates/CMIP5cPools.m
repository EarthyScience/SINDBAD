function x = CMIP5cPools(info,s,poolname)
switch poolname
    case 'cVeg'         , poolid	= 1:4;
    case 'cLitter'      , poolid	= 1:10;
    case 'cSoil'        , poolid	= 11:14;
    case 'cLeaf'        , poolid	= 4;
    case 'cWood'        , poolid	= 3;            %including sapwood and hardwood.
    case 'cRoot'        , poolid	= 1:2;          %including fine and coarse roots.
    case 'cMisc'        , poolid	= [];           %e.g., labile, fruits, reserves, etc.
    case 'cCwd'         , poolid	= 9;            %Carbon Mass in Coarse Woody Debris
    case 'cLitterAbove' , poolid	= 5:6;          %Carbon Mass in Above-Ground Litter
    case 'cLitterBelow' , poolid	= [7:8 10];     %Carbon Mass in Below-Ground Litter
    case 'cSoilFast'    , poolid	= 11:13;        %fast is meant as lifetime of less than 10 years for  reference climate conditions (20 C, no water limitations).
    case 'cSoilMedium'  , poolid	= [];           %medium is meant as lifetime of more than than 10 years and less than 100 years for  reference climate conditions (20 C, no water limitations)
    case 'cSoilSlow'    , poolid	= 14;           %fast is meant as lifetime of more than 100 years for  reference climate conditions (20 C, no water limitations)
    otherwise
        error(['CMIP5cPools : not a known poolname : ' poolname])
end
% poolname        = {'ROOT', 'ROOTC', 'WOOD', 'LEAF', 'M_LEAF', 'S_LEAF', 'M_ROOT', 'S_ROOT', 'LiWOOD', 'LiROOT', 'LEAF_MIC', 'SOIL_MIC', 'SLOW', 'OLD'};

x	= info.helper.zeros1d;
for ii = poolid
    x	= x + s.cPools(ii).value;
end

end%function