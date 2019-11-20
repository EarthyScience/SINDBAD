function [f,fe,fx,s,d,p] = prec_wSoilBase_1LSet1(f,fe,fx,s,d,p,info)
% annual turnover rates
nSoilLayers            = info.tem.model.variables.states.w.nZix.wSoil;
soilDepths             = p.wSoilBase.layerDepths;

if numel(soilDepths) ~=  nSoilLayers
    error('the number of soil layers in modelStructure.json does not match with soil depths specified in wSoilBase')
end
fe.wSoilBase        = zeros(nSoilLayers,1);
for sl = 1:nSoilLayers
fe.wSoilBase(sl,1) = soilDepths(sl);
end

end %function 