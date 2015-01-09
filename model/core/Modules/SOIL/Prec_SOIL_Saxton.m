function [fe,fx,d,p]=Prec_SOIL_Saxton(f,fe,fx,s,d,p,info)

WPT     = calc_soilm_prms(p.SOIL.CLAY, p.SOIL.SAND, p.SOIL.SLDP, 'wpt');
FC      = calc_soilm_prms(p.SOIL.CLAY, p.SOIL.SAND, p.SOIL.SLDP, 'fc');
AWC     = FC - WPT;

p.SOIL.AWC1     = AWC .* p.SOIL.Sup2Total;
p.SOIL.AWC2     = AWC .* (1 - p.SOIL.Sup2Total);
p.SOIL.AWC      = AWC;
p.SOIL.AWC12    = p.SOIL.AWC1 + p.SOIL.AWC2;

end % function