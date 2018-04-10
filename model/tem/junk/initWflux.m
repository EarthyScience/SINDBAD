function fx = initWflux(fx,info)
% #########################################################################
% FUNCTION	: initWflux
% 
% PURPOSE	: initialize the variable that holds the ecosystem carbon pools 
% 
% REFERENCES:
% 
% CONTACT	: Nuno
% 
% #########################################################################
% initial value for fluxes - is this the preallocate???
fx.Qinf     = info.helper.zeros2d;
fx.Qint     = info.helper.zeros2d;
fx.Qsat     = info.helper.zeros2d;
fx.Qb       = info.helper.zeros2d;
fx.Qgwrec   = info.helper.zeros2d;
fx.Qsnow    = info.helper.zeros2d;
fx.Transp   = info.helper.zeros2d;
fx.ESoil    = info.helper.zeros2d;
fx.Subl     = info.helper.zeros2d;
end % function