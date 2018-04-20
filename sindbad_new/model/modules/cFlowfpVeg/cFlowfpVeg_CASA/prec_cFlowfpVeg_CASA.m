function [fe,fx,d,p,f] = prec_cFlowfpVeg_CASA(f,fe,fx,s,d,p,info)
% effect of vegetation on transfer rates between pools (Potter et al 1993)

p.cFlowfpVeg.fVeg = zeros(numel(info.tem.model.c.nZix));

% ADJUST cTransfer BASED ON PARTICULAR PARAMETERS...
%   SOURCE,TARGET,FACTOR
aM	= {
    'cVegLeaf',     'cLitLeafM',    p.cTaufpVeg.MTF;
    'cVegLeaf',     'cLitLeafS',    1 - p.cTaufpVeg.MTF;
    'cVegWood',     'cLitWood',     1;
    'cVegRootF',    'cLitRootFM',   p.cTaufpVeg.MTF;
    'cVegRootF',    'cLitRootFS',   1 - p.cTaufpVeg.MTF;
    'cVegRootC',    'cLitRootC',    1;
    'cLitLeafS',    'cSoilSlow',    p.cTaufpVeg.SCLIGNIN;
    'cLitLeafS',    'cMicSurf',     1 - p.cTaufpVeg.SCLIGNIN;
    'cLitRootFS',   'cSoilSlow',    p.cTaufpVeg.SCLIGNIN;
    'cLitRootFS',   'cMicSoil',     1 - p.cTaufpVeg.SCLIGNIN;
    'cLitWood',     'cSoilSlow',    p.cFlowfpVeg.WOODLIGFRAC;
    'cLitWood',     'cMicSurf',     1 - p.cFlowfpVeg.WOODLIGFRAC;
    'cLitRootC',    'cSoilSlow',    p.cFlowfpVeg.WOODLIGFRAC;
    'cLitRootC',    'cMicSoil',     1 - p.cFlowfpVeg.WOODLIGFRAC;
    'cSoilOld',     'cMicSoil',     1;
    'cLitLeafM',    'cMicSurf',     1;
    'cLitRootFM',   'cMicSoil',     1;
    'cMicSurf',     'cSoilSlow',    1;
    };

for ii = 1:size(aM,1)
    ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii,1});
    ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii,1});
    for iSrc = 1:numel(ndxSrc)
        for iTrg = 1:numel(ndxTrg)
            p.cFlowfpVeg.fVeg(ndxTrg(iTrg),ndxSrc(iSrc)) = aM{ii,3};
        end
    end
end

end %function
