function [fe,fx,d,p,f] = prec_cFlowfpVeg_CASA(f,fe,fx,s,d,p,info)
% effect of vegetation on transfer rates between pools (Potter et al 1993)

p.cFlowfpVeg.fVeg = zeros(numel(info.tem.model.c.nZix));

% ADJUST cTransfer BASED ON PARTICULAR PARAMETERS...
%   SOURCE,TARGET,FACTOR
aM	= {
    'cVegLeaf',     'cLitLeafM',    p.cCycle.MTF;
    'cVegLeaf',     'cLitLeafM',    1-p.cCycle.MTF;
    'cVegWood',     'cLitWood',     1;
    'cVefRootF',    'cLitRootFM',   p.cCycle.MTF;
    'cVegRootF',    'cLitRootFS',   1 - p.cCycle.MTF;
    'cVegRootC',    'cLitRootC',    1;
    'cLitLeafS',    'cSoilSlow',    p.cCycle.SCLIGNIN;
    'cLitLeafS',    'cMicSurf',     1 - p.cCycle.SCLIGNIN;
    'cLitRootFS',   'cSoilSlow',    p.cCycle.SCLIGNIN;
    'cLitRootFS',   'cMicSoil',     1 - p.cCycle.SCLIGNIN;
    'cLitWood',     'cSoilSlow',    p.cCycle.WOODLIGFRAC;
    'cLitWood',     'cMicSurf',     1 - p.cCycle.WOODLIGFRAC;
    'cLitRootC',    'cSoilSlow',    p.cCycle.WOODLIGFRAC;
    'cLitRootC',    'cMicSoil',     1 - p.cCycle.WOODLIGFRAC;
    'cSoilOld',     'cMicSoil',     1;
    'cLitLeafM',    'cMicSurf',     1;
    'cLitRootFM',   'cMicSoil',     1;
    'cMicSurf',     'cSoilSlow',    1;
    };

for ii = 1:size(aM,1)
    ndxSrc = strcmp(aM{ii,1},p.cCycle.cEcoNames);
    ndxTrg = strcmp(aM{ii,2},p.cCycle.cEcoNames);
    if sum(ndxSrc)~=1||sum(ndxTrg)~=1||max(ndxSrc+ndxTrg)>1
        error(['ERR : prec_cFlowfpVeg_CASA : ADJUST cTransfer : ' ...
            'bad index      : ' aM{ii,1} ' -> ' aM{ii,2}])
    elseif p.cCycle.cTransfer(ndxTrg,ndxSrc) <= 0
        error(['ERR : prec_cFlowfpVeg_CASA : ADJUST cTransfer : ' ...
            'cTranfer <= 0  : ' aM{ii,1} ' -> ' aM{ii,2}])
    else
        p.cFlowfpVeg.fVeg(ndxTrg,ndxSrc) = aM{ii,3};
    end
end

end %function
