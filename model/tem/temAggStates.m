function d = temAggStates(info,d)

cPools2agg	= {'cVeg','cLitter','cSoil','cLeaf','cWood','cRoot','cMisc','cCwd','cLitterAbove','cLitterBelow','cSoilFast','cSoilMedium','cSoilSlow','cTotal'};

for ii = 1:numel(info.variables.aggStates)
    if isempty(strmatch(info.variables.aggStates{ii},cPools2agg,'exact'))
        continue
    end
    x	= info.helper.zeros2d;
    for ij = info.helper.cPoolsID4.(info.variables.aggStates{ii})
        x	= x + d.statesOut.cPools(ij).value;
    end
    d.statesOut.(info.variables.aggStates{ii})  = x;
end

end%function
