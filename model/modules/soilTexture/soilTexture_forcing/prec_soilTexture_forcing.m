function [f,fe,fx,s,d,p] = prec_soilTexture_forcing(f,fe,fx,s,d,p,info)
% sets the value of soil hydraulic parameters
%
% Inputs:
%	- p.SAND/SILT/CLAY/DEPTH/+ the Saxton parameters that are in the json
%
% Outputs:
%   - p.pSoil.thetaSat/kSat/psiSat/sSat
%   - p.pSoil.thetaFC/kFC/psiFC/sFC
%   - p.pSoil.thetaWP/kWP/psiWP/sWP
%
% Modifies:
% 	- None
% 
% References:
%	- Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
% Estimating generalized soil-water characteristics from texture. 
% Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
% http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 21.11.2019
%
%% 
nSoilLayers                         =   info.tem.model.variables.states.w.nZix.wSoil;
s.wd.p_soilTexture_CLAY             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_SAND             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_SILT             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_ORGM             =   info.tem.helpers.arrays.onespixzix.w.wSoil;


% fCLAY   =   f.CLAY;
% fSAND   =   f.SAND;
% fSILT   =   f.SILT;
% fORGM   =   f.ORGM;
% size(fCLAY == nSoilLayers)
vars = {'CLAY','SAND','SILT','ORGM'};
for vn = 1:numel(vars)
    vari = vars{vn};
    if size(f.(vari),2) == nSoilLayers
        dat = f.(vari);
        disp([pad('prec_soilTexture_forcing',20) ' |  the vertical profile of soil texture properties and discretization match. Using the observed profile.'])
    else
        datTmp                      =   mean(f.(vari),2)
        dat                         =   repmat(datTmp,1,nSoilLayers)
        disp([pad('prec_soilTexture_forcing',20) ' |  the vertical profile of soil texture properties do not match the discretization...
                    of soil layers in modelStructure.json. Using average of all layers for setting soil properties'])
    end        
    for sl      =   1:nSoilLayers
        eval(['s.wd.p_soilTexture_' vari '(:,sl)  = dat(:,sl);']);
    end
end

% s.wd.p_soilTexture_CLAY =  f.CLAY .* info.tem.helpers.arrays.onespixzix.w.wSoil;
% s.wd.p_soilTexture_SAND =  f.SAND .* info.tem.helpers.arrays.onespixzix.w.wSoil;
% s.wd.p_soilTexture_SILT =  f.SILT .* info.tem.helpers.arrays.onespixzix.w.wSoil;
% s.wd.p_soilTexture_ORGM =  f.ORGM .* info.tem.helpers.arrays.onespixzix.w.wSoil;
% end
% p.soilTexture.CLAY =   .* info.tem.helpers.arrays.onespix;
% p.soilTexture.SAND =   .* info.tem.helpers.arrays.onespix;
% p.soilTexture.SILT =   .* info.tem.helpers.arrays.onespix;
% p.soilTexture.ORGM =   .* info.tem.helpers.arrays.onespix;

end