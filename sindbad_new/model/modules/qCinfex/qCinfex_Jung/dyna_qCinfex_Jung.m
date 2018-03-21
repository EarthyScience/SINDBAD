function [fx,s,d] = dyna_qCinfex_Jung(f,fe,fx,s,d,p,info,tix)
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
%           (d.Temp.WBP)
% 
% OUTPUT
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES: NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT
% TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!!
% NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT
% TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! NOT TESTED!!!! 
% 
% #########################################################################

% everything is precomputed
d.Temp.WBP = d.Temp.WBP - fx.Qinf(:,tix);

end