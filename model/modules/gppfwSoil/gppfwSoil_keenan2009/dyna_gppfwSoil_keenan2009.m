function [f,fe,fx,s,d,p] = dyna_gppfwSoil_keenan2009(f,fe,fx,s,d,p,info,tix)
    p.fSM.Smax  = pSite.fwESoil.maxAWC .* p.fSM.sSmax;
    p.fSM.Smin  = p.fSM.Smax .* p.fSM.sSmin;

    d.gppfwSoil.SMScGPP(:,tix) = min(max(((max(SM,p.fSM.Smin)-p.fSM.Smin)./(p.fSM.Smax-p.fSM.Smin)).^p.gppfwSoil.q,0),1);  

end