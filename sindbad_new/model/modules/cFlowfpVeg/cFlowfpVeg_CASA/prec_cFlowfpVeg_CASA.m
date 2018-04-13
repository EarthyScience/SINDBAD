function [fe,fx,d,p,f] = prec_cFlowfpVeg_CASA(f,fe,fx,s,d,p,info)








% ADJUST cTransfer BASED ON PARTICULAR PARAMETERS...
%   SOURCE,TARGET,FACTOR
aM	= {
    'S_LEAF',   'SLOW',     p.cCycle.SCLIGNIN;
    'S_LEAF',   'LEAF_MIC', 1 - p.cCycle.SCLIGNIN;
    'S_ROOT',   'SLOW',     p.cCycle.SCLIGNIN;
    'S_ROOT',   'SOIL_MIC', 1 - p.cCycle.SCLIGNIN;
    'LiWOOD',   'SLOW',     p.cCycle.WOODLIGFRAC;
    'LiWOOD',   'LEAF_MIC', 1 - p.cCycle.WOODLIGFRAC;
    'LiROOT',   'SLOW',     p.cCycle.WOODLIGFRAC;
    'LiROOT',   'SOIL_MIC', 1 - p.cCycle.WOODLIGFRAC;
    'OLD',      'SOIL_MIC', 1;
    'M_LEAF',   'LEAF_MIC', 1;
    'M_ROOT',   'SOIL_MIC', 1;
    'LEAF_MIC', 'SLOW',     1;
	
	
    };

for ii = 1:size(aM,1)
    ndxSrc = strcmp(aM{ii,1},p.cCycle.cEcoNames);
    ndxTrg = strcmp(aM{ii,2},p.cCycle.cEcoNames);
    if sum(ndxSrc)~=1||sum(ndxTrg)~=1||max(ndxSrc+ndxTrg)>1
        error(['calcEffFlux : ADJUST cTransfer : bad index      : ' aM{ii,1} ' -> ' aM{ii,2}])
    elseif p.cCycle.cTransfer(ndxTrg,ndxSrc) <= 0
        error(['calcEffFlux : ADJUST cTransfer : cTranfer <= 0  : ' aM{ii,1} ' -> ' aM{ii,2}])
    else
        p.cCycle.cTransfer(ndxTrg,ndxSrc) = p.cCycle.cTransfer(ndxTrg,ndxSrc) .* aM{ii,3};
    end
end














end %function
