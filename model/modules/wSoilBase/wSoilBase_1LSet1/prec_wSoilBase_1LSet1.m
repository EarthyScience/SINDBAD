function [f,fe,fx,s,d,p] = prec_wSoilBase_1LSet1(f,fe,fx,s,d,p,info)
nSoilLayers            = info.tem.model.variables.states.w.nZix.wSoil;
soilDepths             = p.wSoilBase.layerDepths;

if numel(soilDepths) ~=  nSoilLayers
    error('the number of soil layers in modelStructure.json does not match with soil depths specified in wSoilBase')
end
fe.wSoilBase.soilDepths          = zeros(nSoilLayers,1);
fe.wSoilBase.nsoilLayers            = nSoilLayers;

for sl = 1:nSoilLayers
fe.wSoilBase.soilDepths(sl,1) = soilDepths(sl);
end

end %function 