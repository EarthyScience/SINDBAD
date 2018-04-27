function [fe,fx,d,p,f] = prec_cTaufpVeg_CASA(f,fe,fx,s,d,p,info)
% effect of vegetation type on turnover rates of c...
s.cd.p_cCycleBase_annk = p.cCycleBase.annk;
% initialize the outputs to ones
s.cd.p_cTaufpVeg_kfVeg	= ones(nPix,nZix);
%% adjust the annk that are pft dependent directly on the p matrix
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
    s.cd.p_cCycleBase_annk(:,zix)    = annk;
end

% feed the parameters that are pft dependent...
pftVec = unique(p.pVeg.PFT);
s.cd.p_cTaufpVeg_LITC2N	= zeros(nPix,1);
s.cd.p_cTaufpVeg_LIGNIN	= zeros(nPix,1);
for ij = 1:numel(pftVec)
    s.cd.p_cTaufpVeg_LITC2N(p.pVeg.PFT == pftVec(ij))	= p.cTaufpVeg.LITC2N(pftVec(ii));
    s.cd.p_cTaufpVeg_LIGNIN(p.pVeg.PFT == pftVec(ij))	= p.cTaufpVeg.LIGNIN(pftVec(ii));
end

% CALCULATE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
% CALCULATE LIGNIN 2 NITROGEN SCALAR
L2N     = (s.cd.p_cTaufpVeg_LITC2N .* s.cd.p_cTaufpVeg_LIGNIN) .* p.cTaufpVeg.NONSOL2SOLLIGNIN;

% DETERMINE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
MTF                     = p.cTaufpVeg.MTFA - (p.cTaufpVeg.MTFB .* L2N);
MTF(MTF < 0)            = 0;
s.cd.p_cTaufpVeg_MTF    = MTF;

% DETERMINE FRACTION OF C IN STRUCTURAL LITTER POOLS FROM LIGNIN
s.cd.p_cTaufpVeg_SCLIGNIN    = (s.cd.p_cTaufpVeg_LIGNIN .* s.cd.p_cTaufpVeg_C2LIGNIN .* p.cTaufpVeg.NONSOL2SOLLIGNIN) ./ (1 - MTF);

% DETERMINE EFFECT OF LIGNIN CONTENT ON k OF cLitLeafS AND cLitRootFS
s.cd.p_cTaufpVeg_LIGEFF = exp(-p.cTaufpVeg.LIGEFFA .* s.cd.p_cTaufpVeg_SCLIGNIN);

% feed the output
s.cd.p_cTaufpVeg_kfVeg(:,info.tem.model.variables.states.c.cLitLeafS.zix)	= s.cd.p_cTaufpVeg_LIGEFF;
s.cd.p_cTaufpVeg_kfVeg(:,info.tem.model.variables.states.c.cLitRootFS.zix)	= s.cd.p_cTaufpVeg_LIGEFF;


end %function
