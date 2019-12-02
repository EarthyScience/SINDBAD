function [f,fe,fx,s,d,p] = prec_roSurf_none(f,fe,fx,s,d,p,info)
% sets surface runoff (roSurf) from the storage to zeros
fx.roSurf = info.tem.helpers.arrays.zerospixtix;
end
