function [fe,fx,d,p,f] = prec_cFlowfpSoil_CASA(f,fe,fx,s,d,p,info)

% CALCULATE MICROBIAL CARBON FLUX PARTICULAR TRANSFERS DEPENDENT ON SOIL
% TEXTURE...
for pN = {'SLOW','OLD'}
    ndxSrc = strcmp('SOIL_MIC',p.cCycle.cEcoNames);
    ndxTrg = strcmp(pN{1},p.cCycle.cEcoNames);
    if sum(ndxSrc)~=1||sum(ndxTrg)~=1||max(ndxSrc+ndxTrg)>1
        error('calcEffFlux : ')
    else
        p.cCycle.cTransfer(ndxTrg,ndxSrc) = ...
            p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (p.psoil.SILT + p.psoil.CLAY));
    end
end









% ADJUST cTransfer BASED ON PARTICULAR PARAMETERS...
%   SOURCE,TARGET,FACTOR
aM	= {
	
    'SLOW',     'SOIL_MIC', 1 - (p.cFlowfpSoil.effCLAYSLOWA + (p.cFlowfpSoil.effCLAYSLOWB .* p.psoil.CLAY));
    'SLOW',     'OLD',      p.cFlowfpSoil.effCLAYSLOWA + (p.cFlowfpSoil.effCLAYSLOWB .* p.psoil.CLAY);
    'SOIL_MIC', 'SLOW',     1 - (p.cFlowfpSoil.effCLAYSOIL_MICA + (p.cFlowfpSoil.effCLAYSOIL_MICB .* p.psoil.CLAY));
    'SOIL_MIC', 'OLD',      p.cFlowfpSoil.effCLAYSOIL_MICA + (p.cFlowfpSoil.effCLAYSOIL_MICB .* p.psoil.CLAY);
	
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
