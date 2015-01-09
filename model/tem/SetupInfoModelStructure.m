function [info]=SetupInfoModelStructure(info)

%pthPrecsGen=info.paths.PrecGen;
pthModules=info.paths.core;
%pthCore=[pthModules 'core.m'];
paramsOpt=info.opti.ParNames;
pthCodeGen=info.paths.genCode;

%[ModuleNames]=GetModuleNamesFromCore(pthCore);
ModuleNames=info.modules;

Approaches=info.approaches;
%collect related Prec and module stuff (do in correct order)
[precs,modules]=ImportPrecsModules(pthModules,ModuleNames,Approaches);

%[precsGen]=GetInputOutputFromCode(precsGen);
[precs]=GetInputOutputFromCode(precs);
[modules]=GetInputOutputFromCode(modules);

[AllInputs,AllOutputs]=GetAllInputsOutputs(precs,modules);

info.variables.input=AllInputs;
info.variables.output=AllOutputs;
info.variables.all=unique(vertcat(AllInputs,AllOutputs));
%[IsCompatible]=check_ModelIntegrity(AllInputs,AllOutputs);

%check which precomputations need to be done always and which only once
%(relevant for optimisation)
[precs]=CheckPrecompAlways(precs,paramsOpt);


%ctim=datevec(now);
%tim=[num2str(ctim(1)) '_' num2str(ctim(2)) '_' num2str(ctim(3)) '_' num2str(ctim(4)) '_' num2str(ctim(5)) '_' num2str(round(ctim(6)))];
tim=info.experimentName;

[funh_core,funh_prcO]=WriteCode(pthCodeGen,tim,precsGen,precs,modules);
info.code.msi.core=funh_core;
info.code.msi.preComp=funh_prcO;

%define info model structure
ms=struct;
for i=1:length(modules)    
    eval(['ms.' char(ModuleNames(i)) '=modules(i);'])
end
info.code.ms=ms;
info.code.preComp=precs;

[IsCompatible]=check_ModelIntegrity(info);

% 
% prcA=struct;
% prcO=struct;
% cntA=1;
% cntO=1;
% for i=1:length(precsGen)
%     fn=fieldnames(precsGen(i));
%     if precsGen(i).DoAlways
%         
%         for j=1:length(fn)
%             eval(['prcA(cntA).' char(fn(j)) '=precsGen(i).' char(fn(j)) ';']);
%         end
%         
%         cntA=cntA+1;
%     else
%         
%         for j=1:length(fn)
%             eval(['prcO(cntO).' char(fn(j)) '=precsGen(i).' char(fn(j)) ';']);
%         end
%         
%         cntO=cntO+1;
%     end
% end
% 
% for i=1:length(precs)
%     fn=fieldnames(precs(i));
%     if precs(i).DoAlways
%         
%         for j=1:length(fn)
%             eval(['prcA(cntA).' char(fn(j)) '=precs(i).' char(fn(j)) ';']);
%         end
%         
%         cntA=cntA+1;
%     else
%         
%         for j=1:length(fn)
%             eval(['prcO(cntO).' char(fn(j)) '=precs(i).' char(fn(j)) ';']);
%         end
%         
%         cntO=cntO+1;
%     end
% end
% 
% info.prcA=prcA;
% info.prcO=prcO;

end