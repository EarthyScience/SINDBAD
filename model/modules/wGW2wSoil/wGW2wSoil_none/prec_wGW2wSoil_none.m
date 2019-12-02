function [f,fe,fx,s,d,p] = prec_wGW2wSoil_none(f,fe,fx,s,d,p,info)
% sets the groundwater capillary flux to zeros
fx.gwCflux       =  info.tem.helpers.arrays.zerospixtix;
end