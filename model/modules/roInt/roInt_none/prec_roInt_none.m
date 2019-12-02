function [f,fe,fx,s,d,p] = prec_roInt_none(f,fe,fx,s,d,p,info)
% sets interflow runoff to zeros
fx.roInt = info.tem.helpers.arrays.zerospixtix;
end