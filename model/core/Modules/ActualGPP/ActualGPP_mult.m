function [fx,s,d] = ActualGPP_mult(f,fe,fx,s,d,p,info,i)
% #########################################################################
% FUNCTION	: 
% 
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: Martin
% 
% INPUT     :
% 
% OUTPUT    :
% 
% #########################################################################


%multiply DemandGPP with soil moisture sress scaler (is the same as taking
%the min of DemandGPP and SupplyGPP)
fx.gpp(:,i) = d.DemandGPP.gppE(:,i) .* d.SMEffectGPP.SMScGPP(:,i);


end