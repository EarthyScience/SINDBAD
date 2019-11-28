function [f,fe,fx,s,d,p] = prec_evapSoil_none(f,fe,fx,s,d,p,info)
% sets the soil evaporation to zero
fx.evapSoil = info.tem.helpers.arrays.zerospixtix;
end