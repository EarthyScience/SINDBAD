function [fe,fx,d,p] = Prec_TempEffectRH_Q10(f,fe,fx,s,d,p,info)
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
%     TsM     = iniQ10 .^ ((p.TempEffectRH.Tref - TrefPap) ./ 10);
% else
    TsM     = 1;
% end



% CALCULATE EFFECT OF TEMPERATURE ON SOIL CARBON FLUXES
fe.TempEffectRH.fT	= p.TempEffectRH.Q10 .^ ((f.Tair - p.TempEffectRH.Tref) ./ 10) .* TsM; 

end % function