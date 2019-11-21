function [f,fe,fx,s,d,p] = prec_wSoilBase_3LSet1(f,fe,fx,s,d,p,info)
% sets the value of soil hydraulic parameters
%
% Inputs:
%   - p.pSoil.thetaSat/kSat/psiSat/sSat
%   - p.pSoil.thetaFC/kFC/psiFC/sFC
%   - p.pSoil.thetaWP/kWP/psiWP/sWP
%
% Outputs:
%   - same as inputs per layer of soil depth in fe.wSoilBase.(parameter_name)
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
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%   - Nuno Carvalhais (ncarval@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 21.11.2019
%
%% 

nSoilLayers            = info.tem.model.variables.states.w.nZix.wSoil;
soilDepths             = p.wSoilBase.layerDepths;

if numel(soilDepths) ~=  nSoilLayers
    error('the number of soil layers in modelStructure.json does not match with soil depths specified in wSoilBase')
end
fe.wSoilBase.soilDepths     = soilDepths;
fe.wSoilBase.nsoilLayers    = nSoilLayers;

fe.wSoilBase.sFC            = info.tem.helpers.arrays.onespixzix.w.wSoil;
fe.wSoilBase.sWP            = info.tem.helpers.arrays.onespixzix.w.wSoil;
fe.wSoilBase.sSat           = info.tem.helpers.arrays.onespixzix.w.wSoil;


for v = {'Alpha','Beta'}
    fe.wSoilBase.(v{:}) = info.tem.helpers.arrays.onespixzix.w.wSoil;
end

for v = {'k','theta','psi'}
    for v1 = {'FC','WP','Sat'}
        fe.wSoilBase.([v{:} v1{:}]) = info.tem.helpers.arrays.onespixzix.w.wSoil;
    end
end

for sl = 1:nSoilLayers
    fe.wSoilBase.sFC(:,sl)        = p.pSoil.thetaFC .* soilDepths(sl);
    fe.wSoilBase.sWP(:,sl)        = p.pSoil.thetaWP .* soilDepths(sl);
    fe.wSoilBase.sSat(:,sl)       = p.pSoil.thetaSat .* soilDepths(sl);
    for v = {'Alpha','Beta'}
        fe.wSoilBase.(v{:})(:,sl) = p.pSoil.(v{:});
    end
    for v = {'k','theta','psi'}
        for v1 = {'FC','WP','Sat'}
            fe.wSoilBase.([v{:} v1{:}])(:,sl)	= p.pSoil.([v{:} v1{:}]);
        end
    end
end

fe.wSoilBase.sAWC	= fe.wSoilBase.sFC - fe.wSoilBase.sWP;

end %function