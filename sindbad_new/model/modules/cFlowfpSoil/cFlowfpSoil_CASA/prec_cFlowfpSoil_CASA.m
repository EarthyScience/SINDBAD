function [fe,fx,d,p,f] = prec_cFlowfpSoil_CASA(f,fe,fx,s,d,p,info)

p.cFlowfpSoil.fSoil = zeros(numel(info.tem.model.c.nZix));

% CALCULATE MICROBIAL CARBON FLUX PARTICULAR TRANSFERS DEPENDENT ON SOIL
% TEXTURE...
for pN = {'cSoilSlow','cSoilOld'}
    ndxSrc = strcmp('cMicSoil',p.cCycle.cEcoNames);
    ndxTrg = strcmp(pN{1},p.cCycle.cEcoNames);
    if sum(ndxSrc)~=1||sum(ndxTrg)~=1||max(ndxSrc+ndxTrg)>1
        error('calcEffFlux : ')
    else
        p.cFlowfpSoil.fSoil(ndxTrg,ndxSrc) = ...
            p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (p.psoil.SILT + p.psoil.CLAY));
    end
end

% ADJUST cTransfer BASED ON PARTICULAR PARAMETERS...
%   SOURCE,TARGET,FACTOR
aM	= {
    'cSoilSlow',    'cMicSoil',     1 - (p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* p.psoil.CLAY));
    'cSoilSlow',    'cSoilOld',     p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* p.psoil.CLAY);
    'cMicSoil',     'cSoilSlow',    1 - (p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* p.psoil.CLAY));
    'cMicSoil',     'cSoilOld',     p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* p.psoil.CLAY);
    };

for ii = 1:size(aM,1)
    ndxSrc = strcmp(aM{ii,1},p.cCycle.cEcoNames);
    ndxTrg = strcmp(aM{ii,2},p.cCycle.cEcoNames);
    if sum(ndxSrc)~=1||sum(ndxTrg)~=1||max(ndxSrc+ndxTrg)>1
        error(['ERR : prec_cFlowfpSoil_CASA : ADJUST cTransfer : ' ...
            'bad index      : ' aM{ii,1} ' -> ' aM{ii,2}])
    elseif p.cCycle.cTransfer(ndxTrg,ndxSrc) <= 0
        error(['ERR : prec_cFlowfpSoil_CASA : ADJUST cTransfer : ' ...
            'cTranfer <= 0  : ' aM{ii,1} ' -> ' aM{ii,2}])
    else
        p.cFlowfpSoil.fSoil(ndxTrg,ndxSrc) = aM{ii,3};
    end
end


end %function
