function [f,fe,fx,s,d,p] = prec_roOverland_none(f,fe,fx,s,d,p,info)
% sets overland runoff to zeros
fx.roOverland = info.tem.helpers.arrays.zerospixtix;
end

