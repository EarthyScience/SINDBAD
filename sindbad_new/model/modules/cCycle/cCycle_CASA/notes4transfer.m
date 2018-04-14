we need a script to check that 
    all modules have a none (at least prec_(module)_none empty)
    all modules that have a prec have a dyna
psoil -> pSoil pSoil_global/pVeg_global
suggest pEco (in addition to psoil)
we need the handle to the coreTEMfile that is to be ran if we decide to run the model not using the generated code.

I need helpers for some approaches (or some place to put stuff that does not fall in the convention, e.g. order of the carbon fluxes, or indexes of pools that are metabolic and so on

everything that is [pix zix] but is a parameter we have two options p.(module).(parameterName) or d.cd.p_(module)_(parameterName) or d.wd.p_(module)_(parameterName)

define an approach for the spinup (e.g. spin_module_approach to replace dyna_module_approach or module_approach)

effCLAY
    SOIL_MIC -> cMicSoil
    SLOW -> cSoilSlow
s.cd.cEcoEfflux(:,zix) needs to be zeros in the begining of each loop

make a cTauAct
make a cFlowAct
cAlloc -> cAllocAct
need checking the inputs and outputs of the functions that i did are correct - don't replace just, give warning...
end %function
am I doubling the place where I calculate RA?
zix for cSoil won't work... we need to have a way ti say nonVeg...
cTauf?_none must be ones(nPix,nZix)
convert all BGME to kfwSoil

p.cCycle.cTransfer -> p.cFlow.cTransfer


the transfer matrix goes to cFlowAct
the turnover rates go to cTauAct

idea... the cCycle.cTransfer,k, override the parameters from the simple approach...



d.cTaufwSoil.kfwSoil -> d.cTaufwSoil.kfwSoil
fe.cTaufTsoil.fT -> fe.cTaufTsoil.kfTsoil
x 0) runTEM/runCore/...
1) clean the cCycle
    CASA -> simple
2) spinup modules...
3) make cTauBase cFlowBase
x 4) clean NPP and RA
x 5) cAlloc


p.cCycle.cTransfer

% cAlloc -> 
% cAllocfwSoil
% cAllocfTsoil
% cAllocfNut
% cAllocfTreeCover



x s.cPools(ii).value -> s.c.cEco(:,zix)
x    check that the indexing of s.c.cEco is zix
x fx.cNpp(ii).value(:,tix)    -> s.cd.cNPP(:,zix) 
x    same for RA)
x fx.cEfflux(ii).value(:,tix) -> s.cd.cEcoEfflux(:,zix)
x    flux out of the cCycle_simple
x        fx.RA
x        fx.RH
x        fx.NPP
x    calc update NPP goes away
x fx.cEfflux(ii).maintenance(:,tix) -> s.cd.RA_M(:,zix)
x fx.cEfflux(ii).growth(:,tix) -> s.cd.RA_G(:,zix)
x d.cAlloc.c2pool(ii).value(:,tix) -> s.cd.cAlloc(:,zix)
X    needs to merge teh prec and dyna
x calcAdjAllocation -> cAllocfTreeCover
x C2N -> C2N(zix)
x TempEffectRAact -> RAfTair
x make all dependent on air temeprature for easy and merge stuff...
x pSoil_global :  no need there is already saxton
x POTcOUT(:,2) -> s.cd.cOutPot
x fx.cEfflux(zix).value(:,tix)
x fx.cEfflux(idonor).value(:,tix)
x fx.cEfflux

make with the funny lists...
c.Veg.Root.F
c.Veg.Root.C







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
    
    
    
    check loops of all variables changed...

compute LAI and compute fapr and read the fpar and lai streams s.cd.lai

when applying hte environemntal constraints use too fe.cCycle.kfEnvTs(ii).value	= max(min(fe.cCycle.kfEnvTs(ii).value,1),0);
    for ii = 5:14
        fe.cCycle.kfEnvTs(ii).value	= max(min(fe.cCycle.kfEnvTs(ii).value,1),0);
    end


    coreTEM needs a 
        cTauBase
        cFlowBase
    
    dyna_RAact_Thornley2000A merge prec with dyna
cCycle_simple

info.timeScale.stepsPerDay

fe.cCycle.kfEnvTs(6).value  = fe.cCycle.kpool(6).value  .* fe.RHfTsoil.fT	.* p.cCycle.LIGEFF;
fe.cCycle.kfEnvTs(7).value  = fe.cCycle.kpool(7).value  .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(8).value  = fe.cCycle.kpool(8).value  .* fe.RHfTsoil.fT   .* p.cCycle.LIGEFF;
fe.cCycle.kfEnvTs(9).value  = fe.cCycle.kpool(9).value  .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(10).value	= fe.cCycle.kpool(10).value .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(11).value	= fe.cCycle.kpool(11).value .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(12).value	= fe.cCycle.kpool(12).value .* fe.RHfTsoil.fT;;

for the spinup store these ones somewhere:
    d.cd.RAact_km4su


% need to check the runCoreTEM for spinup conditions