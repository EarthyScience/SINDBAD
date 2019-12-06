function [f,fe,fx,s,d,p] = prec_raAct_Thornley2000A(f,fe,fx,s,d,p,info)
cpNames                 =   {'cVegRootF','cVegRootC','cVegWood','cVegLeaf'};
s.cd.p_raAct_C2N        =   zeros(info.tem.helpers.sizes.nPix,numel(info.tem.model.variables.states.c.zix.cVeg)); %sujan

for cpn = 1:numel(cpNames)
    zix                 =   info.tem.model.variables.states.c.zix.(cpNames{cpn});
    s.cd.p_raAct_C2N(:,zix)    =   p.raAct.C2N(cpn);
end

end
