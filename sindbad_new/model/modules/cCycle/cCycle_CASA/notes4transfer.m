




x 0) runTEM/runCore/...
1) clean the cCycle
    CASA -> simple
2) spinup modules...
3) make cTauBase cFlowBase
4) clean NPP and RA
5) cAlloc
6) psoil -> pSoil pSoil_global/pVeg_global
7) suggest pEco




cAlloc -> 
cAllocfwSoil
cAllocfTsoil
cAllocfNut
cAllocfTreeCover

c.cEco -> c.c ...


x s.cPools(ii).value -> s.c.cEco(:,zix)
x    check that the indexing of s.c.cEco is zix

fx.cNpp(ii).value(:,tix)    -> s.cd.cNPP(:,zix) 

same for RA)

pSoil_global


POTcOUT(:,2) -> s.cd.cOutPot

fx.cEfflux(zix).value(:,tix)
fx.cEfflux(idonor).value(:,tix)

fx.cEfflux


fe.cCycle.kpool(zix).value -> p.cCycle.k(:,zix)

fe.cCycle.DecayRate(zix).value(:,tix));
p.cCycle.(['annk' poolname{zix}]);
fe.cCycle.annkpool(zix).value
fe.cCycle.kpool(zix).value
zix = 5:14
ctransfer(ii).xtrEFF is obsolete
most of fe.cCycle -> p.cCycle
ctransfer -> cTransfer
fe.cCycle.kfEnvTs(5).value -> disappears
    fe.cCycle.kpool(5).value  .* fe.cTaufTsoil.fT -> p.cCycle.k(5) .* fe.cTaufTsoil.fT

compute LAI and compute fapr and read the fpar and lai streams s.cd.lai

when applying hte environemntal constraints use too fe.cCycle.kfEnvTs(ii).value	= max(min(fe.cCycle.kfEnvTs(ii).value,1),0);
    for ii = 5:14
        fe.cCycle.kfEnvTs(ii).value	= max(min(fe.cCycle.kfEnvTs(ii).value,1),0);
    end


    coreTEM needs a 
        cTauBase
        cFlowBase
    
    
cCycle_simple


fe.cCycle.kfEnvTs(6).value  = fe.cCycle.kpool(6).value  .* fe.RHfTsoil.fT	.* p.cCycle.LIGEFF;
fe.cCycle.kfEnvTs(7).value  = fe.cCycle.kpool(7).value  .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(8).value  = fe.cCycle.kpool(8).value  .* fe.RHfTsoil.fT   .* p.cCycle.LIGEFF;
fe.cCycle.kfEnvTs(9).value  = fe.cCycle.kpool(9).value  .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(10).value	= fe.cCycle.kpool(10).value .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(11).value	= fe.cCycle.kpool(11).value .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(12).value	= fe.cCycle.kpool(12).value .* fe.RHfTsoil.fT;;


% need to check the runCoreTEM for spinup conditions