function [fe,fx,d,p,f] = prec_cTaufpVeg_CASA(f,fe,fx,s,d,p,info)
% initialize to ones
d.cd.cTaufpVeg_kfVeg(:) = 1;
p.cTaufpVeg.kfVeg   = ones(nPix,nZix);

% feed the parameters that are pft dependent...
pftVec = unique(p.pVeg.PFT);
for pN = {'LITC2N','LIGNIN'}
    p.cTaufpVeg.(pN{:})	= zeros(nPix,1);
	for ij = 1:numel(pftVec)
		p.cTaufpVeg.(pN{:})(p.pVeg.PFT == pftVec(ij))	= p.cTaufpVeg.([pN{:} '_per_PFT'])(pftVec(ii));
	end
end

% CALCULATE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
% CALCULATE LIGNIN 2 NITROGEN SCALAR
L2N     = (p.cTaufpVeg.LITC2N .* p.cTaufpVeg.LIGNIN) .* p.cTaufpVeg.NONSOL2SOLLIGNIN;

% DETERMINE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
MTF             = p.cTaufpVeg.MTFA - (p.cTaufpVeg.MTFB .* L2N);
MTF(MTF < 0)    = 0;
p.cTaufpVeg.MTF = MTF;

% DETERMINE FRACTION OF C IN STRUCTURAL LITTER POOLS FROM LIGNIN
p.cTaufpVeg.SCLIGNIN    = (p.cTaufpVeg.LIGNIN .* p.cTaufpVeg.C2LIGNIN .* p.cTaufpVeg.NONSOL2SOLLIGNIN) ./ (1 - MTF);

% DETERMINE EFFECT OF LIGNIN CONTENT ON k OF cLitLeafS AND cLitRootFS
p.cTaufpVeg.LIGEFF = exp(-p.cTaufpVeg.LIGEFFA .* p.cTaufpVeg.SCLIGNIN);

% feed the output
p.cTaufpVeg.kfVeg(:,info.tem.model.variables.states.c.cLitLeafS.zix)	= p.cTaufpVeg.LIGEFF;
p.cTaufpVeg.kfVeg(:,info.tem.model.variables.states.c.cLitRootFS.zix)	= p.cTaufpVeg.LIGEFF;


end %function
