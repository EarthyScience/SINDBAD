function [info]=SetupInfoModelStructure(info)

%this needs to be changed!!!!
DefaultApproaches={'SnowCover_HTESSEL','Sublimation_GLEAM','SnowMelt_simple','Interception_Gash','RunoffInfE_MJ',...
    'SaturatedFraction_none','RunoffSat_Zhang','RechargeSoil_TopBottom','RunoffInt_simple','RechargeGW_simple',...
    'BaseFlow_simple','SoilMoistureGW_none','SoilEvap_simple','SupplyTransp_Federer',...
    'LightEffectGPP_Maekelae2008','RdiffEffectGPP_Turner','TempEffectGPP_CASA','VPDEffectGPP_Medlyn','DemandGPP_mult',...
    'SMEffectGPP_Medlyn','ActualGPP_mult','Transp_Medlyn','RootUptake_TopBottom'};


pthPrecsGen=info.paths.PrecGen;
pthModules=info.paths.Modules;
pthCore=info.paths.Core;
paramsOpt=info.opt.Pnames;
pthCodeGen=info.paths.GenCode;

NonDefaultApproaches=info.NonDefaultApproaches;

[ModuleNames]=GetModuleNamesFromCore(pthCore);

%overwrite the default approaches and make sure everything is in correct
%order
[info]=SortOutApproaches(info,ModuleNames,DefaultApproaches,NonDefaultApproaches);

Approaches=info.Approaches;
%collect related Prec and module stuff (do in correct order)
[precsGen,precs,modules]=ImportPrecsModules(pthPrecsGen,pthModules,ModuleNames,Approaches);

[precsGen]=GetInputOutputFromCode(precsGen);
[precs]=GetInputOutputFromCode(precs);
[modules]=GetInputOutputFromCode(modules);

[IsCompatible]=CheckModelIntegrity(precsGen,precs,modules);

%check which precomputations need to be done always and which only once
%(relevant for optimisation)
[precsGen,precs]=CheckPrecompAlways(precsGen,precs,paramsOpt);

ctim=datevec(now);
tim=[num2str(ctim(1)) '_' num2str(ctim(2)) '_' num2str(ctim(3)) '_' num2str(ctim(4)) '_' num2str(ctim(5)) '_' num2str(round(ctim(6)))];


[funh_core,funh_prcO]=WriteCode(pthCodeGen,tim,precsGen,precs,modules);
info.msi.core=funh_core;
info.msi.prc=funh_prcO;

%define info model structure
ms=struct;
for i=1:length(modules)    
    eval(['ms.' char(ModuleNames(i)) '=modules(i);'])
end
info.ms=ms;

prcA=struct;
prcO=struct;
cntA=1;
cntO=1;
for i=1:length(precsGen)
    fn=fieldnames(precsGen(i));
    if precsGen(i).DoAlways
        
        for j=1:length(fn)
            eval(['prcA(cntA).' char(fn(j)) '=precsGen(i).' char(fn(j)) ';']);
        end
        
        cntA=cntA+1;
    else
        
        for j=1:length(fn)
            eval(['prcO(cntO).' char(fn(j)) '=precsGen(i).' char(fn(j)) ';']);
        end
        
        cntO=cntO+1;
    end
end

for i=1:length(precs)
    fn=fieldnames(precs(i));
    if precs(i).DoAlways
        
        for j=1:length(fn)
            eval(['prcA(cntA).' char(fn(j)) '=precs(i).' char(fn(j)) ';']);
        end
        
        cntA=cntA+1;
    else
        
        for j=1:length(fn)
            eval(['prcO(cntO).' char(fn(j)) '=precs(i).' char(fn(j)) ';']);
        end
        
        cntO=cntO+1;
    end
end

info.prcA=prcA;
info.prcO=prcO;

end