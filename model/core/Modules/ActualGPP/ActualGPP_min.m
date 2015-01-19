function [fx,s,d] = ActualGPP_min(f,fe,fx,s,d,p,info,i)
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
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% 
% OUTPUT    :
% 
% #########################################################################


%calculate the minimum of all stress scalers 
scall=horzcat( d.TempEffectGPP.TempScGPP(:,i) , d.VPDEffectGPP.VPDScGPP(:,i) , d.LightEffectGPP.LightScGPP(:,i) , d.SMEffectGPP.SMScGPP(:,i) );
d.ActualGPP.AllScGPP(:,i) = min(scall,[],2);
%... and multiply with apar and rue
fx.gpp(:,i) = f.FAPAR(:,i) .* f.PAR(:,i) .* d.RdiffEffectGPP.rueGPP(:,i) .* d.ActualGPP.AllScGPP(:,i);


end