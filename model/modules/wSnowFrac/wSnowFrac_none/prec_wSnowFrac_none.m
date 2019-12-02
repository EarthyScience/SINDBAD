function [f,fe,fx,s,d,p] = prec_wSnowFrac_none(f,fe,fx,s,d,p,info,tix)
% sets the s.w.snow and s.wd.wSnowFrac (snow fraction) to zeros (pix,1)
s.w.wSnow       = info.tem.helpers.arrays.zerospix;
s.wd.wSnowFrac  = info.tem.helpers.arrays.zerospix;
end
