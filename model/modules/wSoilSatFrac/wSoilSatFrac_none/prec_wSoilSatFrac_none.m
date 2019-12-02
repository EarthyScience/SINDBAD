function [f,fe,fx,s,d,p] = prec_wSoilSatFrac_none(f,fe,fx,s,d,p,info)
% sets the s.wd.wSoilSatFrac (saturated soil fraction) to zeros (pix,1)
s.wd.wSoilSatFrac   =   info.tem.helpers.arrays.zerospix;
end