function [f,fe,fx,s,d,p] = cAllocfTreeCover_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)

% adjust the allocation coefficients according to the fraction of
% trees to herbaceous and fine to coarse root partitioning

% TreeCover and fine to coarse root ratio
tc      = p.pveg.TreeCover;
rf2rc	= p.cAllocfTreeCover.Rf2Rc;

% the allocation fractions according to the partitioning to root/wood/leaf
% - represents plant level allocation
r0	= sum(s.cd.cAlloc(:,info.tem.model.variables.states.c.cVegRoot.zix),2); % this is to below ground root fine+coarse
s0	= sum(s.cd.cAlloc(:,info.tem.model.variables.states.c.cVegWood.zix),2);
l0	= sum(s.cd.cAlloc(:,info.tem.model.variables.states.c.cVegLeaf.zix),2);

% adjust for spatial consideration of TreeCover and plant level
% partitioning between fine and coarse roots
cF.cVegRootF	= tc .* rf2rc + (r0 + s0 .* (r0 ./ (r0 + l0))) .* (1 - tc);
cF.cVegRootC    = tc .* (1 - rf2rc);
cF.cVegRoot     = cF.cVegRootF + cF.cVegRootC;
cF.cVegWood     = tc;
cF.cVegLeaf     = tc + (l0 + s0 .* (l0 ./ (r0 + l0))) .* (1 - tc);

% check if there are fine and coarse root pools...
if isfield(info.tem.model.variables.states.c,'cVegWoodC') && ...
        isfield(info.tem.model.variables.states.c,'cVegWoodF')
    cpNames = {'cVegRootF','cVegRootC','cVegWood','cVegLeaf'};
else
    cpNames = {'cVegRoot','cVegWood','cVegLeaf'};
end

% adjust the allocation parameters
for cpn = 1:numel(cpnames)
    zix                 = info.tem.model.variables.states.c.(cpNames{cpn}).zix;
    s.cd.cAlloc(:,zix)	= cF.(cpNames{cpn}) .* s.cd.cAlloc(:,zix);
end
end % function
