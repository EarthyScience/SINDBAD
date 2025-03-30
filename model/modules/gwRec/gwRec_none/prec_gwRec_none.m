function [f,fe,fx,s,d,p] = prec_gwRec_none(f,fe,fx,s,d,p,info)
% set the GW recharge to zeros
fx.gwRec = info.tem.helpers.arrays.zerospixtix;
end