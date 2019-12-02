function [f,fe,fx,s,d,p] = prec_roBase_none(f,fe,fx,s,d,p,info)
% sets the base runoff to zeros
fx.roBase   =   info.tem.helpers.arrays.zerospixtix;
end