function [f,fe,fx,s,d,p] = prec_tranAct_none(f,fe,fx,s,d,p,info)
% sets the actual transpiration to zeros
fx.tranAct = info.tem.helpers.arrays.zerospixtix;
end