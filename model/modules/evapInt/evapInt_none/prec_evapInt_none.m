function [f,fe,fx,s,d,p] = prec_evapInt_none(f,fe,fx,s,d,p,info)
% sets the interception evaporation to zeros
fx.evapInt   = info.tem.helpers.arrays.zerospixtix;
end