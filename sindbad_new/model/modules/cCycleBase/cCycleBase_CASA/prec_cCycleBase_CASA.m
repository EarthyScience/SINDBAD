function [f,fe,fx,s,d,p] = prec_cCycleBase_CASA(f,fe,fx,s,d,p,info)

% feed the parameters that are pft dependent...
pftVec  = unique(p.pVeg.PFT);
for cpN = {'cVegRootF','cVegRootC','cVegWood','cVegLeaf'}
    % get average age from parameters
    AGE	= info.tem.helpers.arrays.zerospix;
	for ij = 1:numel(pftVec)
		AGE(p.pVeg.PFT == pftVec(ij))	= p.cCycleBase.([cpN{:} '_AGE_per_PFT'])(pftVec(ii));
	end
    % compute annk based on age
    annk            = 1e-40 .* ones(size(AGE));
    annk(AGE > 0)   = 1 ./ AGE(AGE > 0);
    % feed it to the new annual turnover rates
    zix                         = info.tem.model.variables.states.c.(cpN{:}).zix;
    p.cCycleBase.annk(:,zix)    = annk;
end

end %function 