function [f,fe,fx,s,d,p] = prec_evapSub_none(f,fe,fx,s,d,p,info)
% sets the snow sublimation to zeros
fx.evapSub=info.tem.helpers.arrays.zerospixtix;
end