function [fe,fx,d,p] = prec_rhFtemp_Q10(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: 
% 
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: Nuno
% 
% #########################################################################


% NOTE, WE NEED TO CHECK THIS CODE OUT! NORMALIZATION FOR TREF WHEN
% OPTIMIZING Q10: NEEDED!!!

% TrefPap = 30;
% if ~exist('deltaTref', 'var')
%     Tref    = mean(f.Tair(isnan(f.Tair) == 0));
%     TsM     = iniQ10 .^ ((p.rhFtemp.Tref - TrefPap) ./ 10);
% else
    TsM     = 1;
% end



% CALCULATE EFFECT OF TEMPERATURE ON psoilR CARBON FLUXES
fe.rhFtemp.fT	= p.rhFtemp.Q10 .^ ((f.Tair - p.rhFtemp.Tref) ./ 10) .* TsM; 

end % function