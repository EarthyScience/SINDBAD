function [f,fe,fx,s,d,p] = prec_cFlowfpSoil_CASA(f,fe,fx,s,d,p,info)

% s.cd.p_cFlowfpSoil_fSoil = zeros(numel(info.tem.model.nPix),numel(info.tem.model.nZix));
% s.cd.p_cFlowfpSoil_fSoil = info.tem.helpers.arrays.zerospixzix.c.cEco;
% %sujan
s.cd.p_cFlowfpSoil_fSoil      =   repmat(info.tem.helpers.arrays.zerospixzix.c.cEco,1,1,...
                                        info.tem.model.variables.states.c.nZix.cEco);
% ADJUSTMENTS FOR cTransfer BASED ON PARTICULAR TEXTURE PARAMETERS...
%    SOURCE,        TARGET,         FACTOR
aM	= {...
    'cMicSoil',     'cSoilSlow',    p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (p.pSoil.SILT + p.pSoil.CLAY));...
    'cMicSoil',     'cSoilOld',     p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (p.pSoil.SILT + p.pSoil.CLAY));...
    'cSoilSlow',    'cMicSoil',     1 - (p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* p.pSoil.CLAY));...
    'cSoilSlow',    'cSoilOld',     p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* p.pSoil.CLAY);...
    'cMicSoil',     'cSoilSlow',    1 - (p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* p.pSoil.CLAY));...
    'cMicSoil',     'cSoilOld',     p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* p.pSoil.CLAY);...
    };

for ii = 1:size(aM,1)
    ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii,1});
    ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii,2}); %sujan : is it ii,2?
    for iSrc = 1:numel(ndxSrc)
        for iTrg = 1:numel(ndxTrg)
            s.cd.p_cFlowfpSoil_fSoil(:,ndxTrg(iTrg),ndxSrc(iSrc)) = aM{ii,3};
        end
    end
end


end %function
