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
fracRoot2SoilD         = p.wSoilBase.fracRoot2SoilD;
if numel(soilDepths) ~=  nSoilLayers
    error('the number of soil layers in modelStructure.json does not match with soil depths specified in wSoilBase')
end
fe.wSoilBase.nsoilLayers        = nSoilLayers;

fe.wSoilBase.wFC                = info.tem.helpers.arrays.onespixzix.w.wSoil;
fe.wSoilBase.wWP                = info.tem.helpers.arrays.onespixzix.w.wSoil;
fe.wSoilBase.wSat               = info.tem.helpers.arrays.onespixzix.w.wSoil;
fe.wSoilBase.fracRoot2SoilD     = info.tem.helpers.arrays.onespixzix.w.wSoil;
fe.wSoilBase.soilDepths         = info.tem.helpers.arrays.onespixzix.w.wSoil;


for v = {'Alpha','Beta'}
    fe.wSoilBase.(v{:}) = info.tem.helpers.arrays.onespixzix.w.wSoil;
end

for v = {'k','theta','psi'}
    for v1 = {'FC','WP','Sat'}
        fe.wSoilBase.([v{:} v1{:}])     =   info.tem.helpers.arrays.onespixzix.w.wSoil;
    end
end

for sl = 1:nSoilLayers
    fe.wSoilBase.wFC(:,sl)              =   p.pSoil.thetaFC .* soilDepths(sl);
    fe.wSoilBase.wWP(:,sl)              =   p.pSoil.thetaWP .* soilDepths(sl);
    fe.wSoilBase.wSat(:,sl)             =   p.pSoil.thetaSat .* soilDepths(sl);
    fe.wSoilBase.soilDepths(:,sl)       =   soilDepths(sl);
    fe.wSoilBase.fracRoot2SoilD(:,sl)   =   fe.wSoilBase.fracRoot2SoilD(:,sl) .* fracRoot2SoilD(sl);
    fe.wSoilBase.Alpha(:,sl)            =   p.pSoil.Alpha;
    fe.wSoilBase.Beta(:,sl)             =   p.pSoil.Beta;
    fe.wSoilBase.kSat(:,sl)             =   p.pSoil.kSat;
    fe.wSoilBase.kFC(:,sl)              =   p.pSoil.kFC;
    fe.wSoilBase.kWP(:,sl)              =   p.pSoil.kWP;
    fe.wSoilBase.psiSat(:,sl)           =   p.pSoil.psiSat;
    fe.wSoilBase.psiFC(:,sl)            =   p.pSoil.psiFC;
    fe.wSoilBase.psiWP(:,sl)            =   p.pSoil.psiWP;
    fe.wSoilBase.thetaSat(:,sl)         =   p.pSoil.thetaSat;
    fe.wSoilBase.thetaFC(:,sl)          =   p.pSoil.thetaFC;
    fe.wSoilBase.thetaWP(:,sl)          =   p.pSoil.thetaWP;
%--> sujan: this cannot be used because setupcode cannot get the variable
%names and will throw I/O mismatch error
%     for v = {'Alpha','Beta'}
%         fe.wSoilBase.(v{:})(:,sl) = p.pSoil.(v{:});
%     end
%     for v = {'k','theta','psi'}
%         for v1 = {'FC','WP','Sat'}
%             fe.wSoilBase.([v{:} v1{:}])(:,sl)	= p.pSoil.([v{:} v1{:}]);
%         end
%     end
end

fe.wSoilBase.wAWC	= fe.wSoilBase.wFC - fe.wSoilBase.wWP;

end %function