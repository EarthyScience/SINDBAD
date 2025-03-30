function [f,fe,fx,s,d,p] = prec_cAllocfNut_none(f,fe,fx,s,d,p,info)
% set the pseudo-nutrient limitation to 1
fe.cAllocfNut.minWLNL= info.tem.helpers.arrays.onespixtix;
end
