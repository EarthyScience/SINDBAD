function [f,fe,fx,s,d,p] = prec_evapSoil_none(f,fe,fx,s,d,p,info)
% sets the soil evaporation to zeros
fx.evapSoil = info.tem.helpers.arrays.zerospixtix;
end