function [f,fe,fx,s,d,p] = dyna_QinfExc_Jung(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung
% 
% INPUT
% Qinf      : infiltration excess runoff [mm/time] - what runs off because
%           the precipitation intensity is to high for it to inflitrate in
%           the soil.
%           (fx.Qinf)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% OUTPUT
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% NOTES: NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT
% TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!!
% NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT
% TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! 
% 
% #########################################################################

% everything is precomputed
s.wd.WBP = s.wd.WBP - fx.Qinf(:,tix);

end