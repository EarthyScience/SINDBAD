function [fe,fx,d,p] = Prec_DemandGPP_mult(f,fe,fx,s,d,p,info)

% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)


%stress scalers are combined in a multiplicative way


%check if time series or spatial
if info.forcing.size(2)>1
    %is spatial
    scall=zeros(info.forcing.size(1),info.forcing.size(2),3);
    scall(:,:,1)= d.TempEffectGPP.TempScGPP;
    scall(:,:,2)= d.VPDEffectGPP.VPDScGPP;
    scall(:,:,3)= d.LightEffectGPP.LightScGPP;
    
    d.DemandGPP.AllScGPP =prod(scall,3);
else
    %is time series
    scall=vertcat( d.TempEffectGPP.TempScGPP , d.VPDEffectGPP.VPDScGPP , d.LightEffectGPP.LightScGPP );
    d.DemandGPP.AllScGPP=prod(scall,1);
end

d.DemandGPP.gppE = f.FAPAR .* f.PAR .* d.RdiffEffectGPP.rueGPP .* d.DemandGPP.AllScGPP;

end