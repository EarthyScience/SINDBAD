function [f,fe,fx,s,d,p] = prec_roInf_none(f,fe,fx,s,d,p,info)
% sets infiltration excess runoff to zeros
fx.roInf = info.tem.helpers.arrays.zerospixtix;
end

