function [f,fe,fx,s,d,p] = prec_rainSnow_forcing(f,fe,fx,s,d,p,info)

fe.rainSnow.rain     =   f.Rain;
fe.rainSnow.snow     =   (p.rainSnow.SF_scale .* info.tem.helpers.arrays.onespixtix) .* f.Snow; % *ones as parameter has one value for each pixelf.Snow;

end % function

