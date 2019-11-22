function [f,fe,fx,s,d,p] = prec_wSoilBase_4LSet1(f,fe,fx,s,d,p,info)
% sets the value of soil hydraulic parameters
%
% Inputs:
%   - p.pSoil.thetaSat/kSat/psiSat/sSat
%   - p.pSoil.thetaFC/kFC/psiFC/sFC
%   - p.pSoil.thetaWP/kWP/psiWP/sWP
%
% Outputs:
%   - same as inputs per layer of soil depth in s.wd.p_wSoilBase_(parameter_name)
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
s.wd.p_wSoilBase_nsoilLayers        =   nSoilLayers;

s.wd.p_wSoilBase_wFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wWP                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_fracRoot2SoilD     =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_soilDepths         =   info.tem.helpers.arrays.onespixzix.w.wSoil;

s.wd.p_wSoilBase_Alpha              =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_Beta               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kWP                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_psiSat             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_psiFC              =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_psiWP              =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_thetaSat           =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_thetaFC            =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_thetaWP            =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% 
% for v = {'Alpha','Beta'}
%     s.wd.p_wSoilBase_(v{:}) = info.tem.helpers.arrays.onespixzix.w.wSoil;
% end
% 
% for v = {'k','theta','psi'}
%     for v1 = {'FC','WP','Sat'}
%         s.wd.p_wSoilBase_([v{:} v1{:}])     =   info.tem.helpers.arrays.onespixzix.w.wSoil;
%     end
% end

for sl = 1:nSoilLayers
    s.wd.p_wSoilBase_wFC(:,sl)              =   p.pSoil.thetaFC .* soilDepths(sl);
    s.wd.p_wSoilBase_wWP(:,sl)              =   p.pSoil.thetaWP .* soilDepths(sl);
    s.wd.p_wSoilBase_wSat(:,sl)             =   p.pSoil.thetaSat .* soilDepths(sl);
    s.wd.p_wSoilBase_soilDepths(:,sl)       =   soilDepths(sl);
    s.wd.p_wSoilBase_fracRoot2SoilD(:,sl)   =   s.wd.p_wSoilBase_fracRoot2SoilD(:,sl) .* fracRoot2SoilD(sl);
    s.wd.p_wSoilBase_Alpha(:,sl)            =   p.pSoil.Alpha;
    s.wd.p_wSoilBase_Beta(:,sl)             =   p.pSoil.Beta;
    s.wd.p_wSoilBase_kSat(:,sl)             =   p.pSoil.kSat;
    s.wd.p_wSoilBase_kFC(:,sl)              =   p.pSoil.kFC;
    s.wd.p_wSoilBase_kWP(:,sl)              =   p.pSoil.kWP;
    s.wd.p_wSoilBase_psiSat(:,sl)           =   p.pSoil.psiSat;
    s.wd.p_wSoilBase_psiFC(:,sl)            =   p.pSoil.psiFC;
    s.wd.p_wSoilBase_psiWP(:,sl)            =   p.pSoil.psiWP;
    s.wd.p_wSoilBase_thetaSat(:,sl)         =   p.pSoil.thetaSat;
    s.wd.p_wSoilBase_thetaFC(:,sl)          =   p.pSoil.thetaFC;
    s.wd.p_wSoilBase_thetaWP(:,sl)          =   p.pSoil.thetaWP;
%--> sujan: this cannot be used because setupcode cannot get the variable
%names and will throw I/O mismatch error
%     for v = {'Alpha','Beta'}
%         s.wd.p_wSoilBase_(v{:})(:,sl) = p.pSoil.(v{:});
%     end
%     for v = {'k','theta','psi'}
%         for v1 = {'FC','WP','Sat'}
%             s.wd.p_wSoilBase_([v{:} v1{:}])(:,sl)	= p.pSoil.([v{:} v1{:}]);
%         end
%     end
end

s.wd.p_wSoilBase_wAWC	= s.wd.p_wSoilBase_wFC - s.wd.p_wSoilBase_wWP;

end %function