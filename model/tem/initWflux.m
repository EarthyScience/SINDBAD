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
% initial value for pools
S           = zeros(info.forcing.size);
fx.Qinf     = S;
fx.Qint     = S;
fx.Qsat     = S;
fx.Qb       = S;
fx.Qgwrec   = S;
fx.Qsnow    = S;
fx.Transp   = S;
fx.ESoil    = S;
fx.Subl     = S;
end % function