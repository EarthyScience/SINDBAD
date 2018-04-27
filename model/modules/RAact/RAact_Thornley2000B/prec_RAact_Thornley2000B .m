function [f,fe,fx,s,d,p] = prec_RAact_Thornley2000B(f,fe,fx,s,d,p,info)
cpNames                 =   {'cVegRootF','cVegRootC','cVegWood','cVegLeaf'};
s.cd.p_RAact_C2N        =   zeros(info.tem.helpers.sizes.nPix,numel(info.tem.model.variables.states.c.zix.cVeg)); %sujan

for cpn = 1:numel(cpNames)
    zix                 =   info.tem.model.variables.states.c.zix.(cpNames{cpn});
    s.cd.p_RAact_C2N(:,zix)	=   p.RAact.C2N(cpn);
end

end % function
