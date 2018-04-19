function [fe,fx,d,p,f] = prec_cFlowfpSoil_CASA(f,fe,fx,s,d,p,info)

p.cFlowfpSoil.fSoil = zeros(numel(info.tem.model.nPix),numel(info.tem.model.nZix));

% ADJUSTMENTS FOR cTransfer BASED ON PARTICULAR TEXTURE PARAMETERS...
%    SOURCE,        TARGET,         FACTOR
aM	= {
    'cMicSoil',     'cSoilSlow',    p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (p.psoil.SILT + p.psoil.CLAY));
    'cMicSoil',     'cSoilOld',     p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (p.psoil.SILT + p.psoil.CLAY));
    'cSoilSlow',    'cMicSoil',     1 - (p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* p.psoil.CLAY));
    'cSoilSlow',    'cSoilOld',     p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* p.psoil.CLAY);
    'cMicSoil',     'cSoilSlow',    1 - (p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* p.psoil.CLAY));
    'cMicSoil',     'cSoilOld',     p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* p.psoil.CLAY);
    };

for ii = 1:size(aM,1)
    ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii,1});
    ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii,1});
    for iSrc = 1:numel(ndxSrc)
        for iTrg = 1:numel(ndxTrg)
            p.cFlowfpSoil.fSoil(ndxTrg(iTrg),ndxSrc(iSrc)) = aM{ii,3};
        end
    end
end


end %function
