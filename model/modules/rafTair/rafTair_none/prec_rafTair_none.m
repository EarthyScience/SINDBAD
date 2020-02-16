function [f,fe,fx,s,d,p] = prec_rafTair_none(f,fe,fx,s,d,p,info)
% sets the effect of temperature on RA to none (ones=no effect)
fe.rafTair.fT    = info.tem.helpers.arrays.onespixtix;
end
