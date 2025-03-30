function [f,fe,fx,s,d,p] = prec_roSat_none(f,fe,fx,s,d,p,info)
% set the saturation excess runoff to zeros
fx.roSat = info.tem.helpers.arrays.zerospixtix;
end