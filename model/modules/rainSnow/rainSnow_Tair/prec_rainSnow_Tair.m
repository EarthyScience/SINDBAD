function [f,fe,fx,s,d,p] = prec_rainSnow_Tair(f,fe,fx,s,d,p,info)
rain                    =   f.Rain;
tair                    =   f.Tair;
snow                    =   info.tem.helpers.arrays.zerospixtix;
tmp                     =   tair < p.rainSnow.Tair_thres;
snow(tmp)               =   rain(tmp);
rain(tmp)               =  0.;



fe.rainSnow.rain        =   rain;
fe.rainSnow.snow        =   snow;

end % function

