function [f,fe,fx,s,d,p] = prec_cFlowfpSoil_CASA(f,fe,fx,s,d,p,info)

% s.cd.p_cFlowfpSoil_fSoil = zeros(numel(info.tem.model.nPix),numel(info.tem.model.nZix));
% s.cd.p_cFlowfpSoil_fSoil = info.tem.helpers.arrays.zerospixzix.c.cEco;
% %sujan
s.cd.p_cFlowfpSoil_E      =   repmat(info.tem.helpers.arrays.zerospixzix.c.cEco,1,1,...
                                        info.tem.model.variables.states.c.nZix.cEco);
s.cd.p_cFlowfpSoil_F      =   s.cd.p_cFlowfpSoil_E;

%sujan: moving clay and silt from p.soilTexture to s.wd.p_wSoilBase.
CLAY 					  =   mean(s.wd.p_wSoilBase_CLAY,2);
SILT 					  =   mean(s.wd.p_wSoilBase_SILT,2);

% CONTROLS FOR C FLOW TRANSFERS EFFICIENCY (E) AND FRACTION (F) BASED ON PARTICULAR TEXTURE PARAMETERS...
%    SOURCE,        TARGET,         VALUE (increment in E and F caused by soil properties)
aME	= {...
    'cMicSoil',     'cSoilSlow',    p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (SILT + CLAY));...
    'cMicSoil',     'cSoilOld',     p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (SILT + CLAY));...
	};
	
aMF = {...
    'cSoilSlow',    'cMicSoil',     1 - (p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* CLAY));...
    'cSoilSlow',    'cSoilOld',     p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* CLAY);...
    'cMicSoil',     'cSoilSlow',    1 - (p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* CLAY));...
    'cMicSoil',     'cSoilOld',     p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* CLAY);...
    };

	
for vn = {'E','F'}
%     switch vn{1}
%         case 'E', aM = aME;
%         case 'F', aM = aMF;
%     end
	eval(['aM = aM' vn{:} ';']);
	for ii = 1:size(aM,1)
		ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii,1});
		ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii,2});
		for iSrc = 1:numel(ndxSrc)
			for iTrg = 1:numel(ndxTrg)
				s.cd.(['p_cFlowfpSoil_' vn{1}])(:,ndxTrg(iTrg),ndxSrc(iSrc)) = aM{ii,3};
			end
		end
	end
end


end %function
