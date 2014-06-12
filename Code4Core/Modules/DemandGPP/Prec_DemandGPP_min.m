function [fe,fx,d,p]=Prec_DemandGPP_min(f,fe,fx,s,d,p,info);

%stress scalers are combined as the minimum (which limits most)

%check if time series or spatial
if info.Forcing.Size(2)>1
    %is spatial
    scall=zeros(info.Forcing.Size(1),info.Forcing.Size(2),3);
    scall(:,:,1) = d.TempEffectGPP.TempScGPP;
    scall(:,:,2) = d.VPDEffectGPP.VPDScGPP;
    scall(:,:,3) = d.LightEffectGPP.LightScGPP;
    
    d.DemandGPP.AllScGPP = min(scall,[],3);
else
    %is time series
    scall=vertcat( d.TempEffectGPP.TempScGPP , d.VPDEffectGPP.VPDScGPP , d.LightEffectGPP.LightScGPP );
    d.DemandGPP.AllScGPP = min(scall,[],1);
end

d.DemandGPP.gppE = f.FAPAR .* f.PAR .* d.RdiffEffectGPP.rueGPP .* d.DemandGPP.AllScGPP;

end