%precomputation handler
%clear all

pthModules='M:\people\mjung\sindbad-git\Code4Core\Modules\';
pthPrecsGen='M:\people\mjung\sindbad-git\Code4Tem\PrecsGen\';
pthCodeGen='M:\people\mjung\sindbad-git\GeneratedCode\';
pthCore='M:\people\mjung\sindbad-git\Code4Core\SINDBAD_CORE_MJ.m';


NonDefaultApproaches={'SnowCover_binary','RunoffInfE_MJ',...        
    'LightEffectGPP_none','RdiffEffectGPP_Turner','TempEffectGPP_TEM'};

paramsOpt={'p.SOIL.Depth1','p.Transp.g1'};

info=struct; %the only input of the TEM should be info
info.paths.Modules=pthModules;
info.paths.PrecGen=pthPrecsGen;
info.paths.GenCode=pthCodeGen;
info.paths.Core=pthCore;

info.opt.Pnames=paramsOpt;
info.NonDefaultApproaches=NonDefaultApproaches;

[info]=SetupInfoModelStructure(info);
% %set up p struct
% %should read the params from an excel file and the VEG and SOIL etc params
% %from somewhere ales
% %[p]=info.params.ImportFun(info);


% 
% 
% 
% %get list of params to be optimised
% 
% 
% 
% %collect related Prec and module stuff (do in correct order)
% [precsGen,precs,modules]=ImportPrecsModules(pthPrecsGen,pthModules,ModuleNames,Approaches);
% 
% [precsGen]=GetInputOutputFromCode(precsGen);
% [precs]=GetInputOutputFromCode(precs);
% [modules]=GetInputOutputFromCode(modules);
% 
% 
% %Preallocate fe,fx,s,d
% %[fe,fx,s,d]=PreAllocateModelStructs(precs,modules,ntime,nspace);
% 
% %ini p struct
% %p should be created from an xls file which contains all parameters of all
% %possible model structure combinations
% %[p]=IniParamStructModules(precs,modules);%p.SOIL, p.VEG etc not in yet
% 
% %check which precomputations need to be done always and which only once
% %(relevant for optimisation)
% [precsGen,precs]=CheckPrecompAlways(precsGen,precs,paramsOpt);
% 
% ctim=datevec(now);
% tim=[num2str(ctim(1)) '_' num2str(ctim(2)) '_' num2str(ctim(3)) '_' num2str(ctim(4)) '_' num2str(ctim(5)) '_' num2str(round(ctim(6)))];
% 
% 
% [funh_core,funh_prcO]=WriteCode(pthCodeGen,tim,precsGen,precs,modules);
% info.msi.core=funh_core;
% info.msi.prc=funh_prcO;
% 
% %
% % %write code
% % CodePth=[pthCodeGen 'Prec_Once_' tim '.m'];
% % DoAlways=0;
% % [PrecOnce_funh]=WriteCode(CodePth,precsGen,precs,DoAlways);
% % info.prciO.fun=PrecOnce_funh;
% %
% % CodePth=[pthCodeGen 'Prec_Always_' tim '.m'];
% % DoAlways=1;
% % [PrecAlways_funh]=WriteCode(CodePth,precsGen,precs,DoAlways);
% % info.prciA.fun=PrecAlways_funh;
% %
% % CodePth=[pthCodeGen 'Modules_' tim '.m'];
% % DoAlways=1;
% % IsCore=1;
% % [Mod_funh]=WriteCode(CodePth,[],modules,DoAlways);
% % info.msi.core.fun=Mod_funh;
% 
% %define info model structure
% ms=struct;
% for i=1:length(modules)
%     
%     eval(['ms.' char(ModuleNames(i)) '=modules(i);'])
% end
% info.ms=ms;
% 
% 
% %to be done: copy all fields
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
%         
%         %prcA(cntA).fun=precsGen(i).fun;
%         cntA=cntA+1;
%     else
%         
%         for j=1:length(fn)
%             eval(['prcO(cntO).' char(fn(j)) '=precsGen(i).' char(fn(j)) ';']);
%         end
%         
%         %prcO(cntO).fun=precsGen(i).fun;
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
%         %prcA(cntA).fun=precs(i).fun;
%         cntA=cntA+1;
%     else
%         
%         for j=1:length(fn)
%             eval(['prcO(cntO).' char(fn(j)) '=precs(i).' char(fn(j)) ';']);
%         end
%         
%         %prcO(cntO).fun=precs(i).fun;
%         cntO=cntO+1;
%     end
% end
% 
% info.prcA=prcA;
% info.prcO=prcO;



%get the forcing
%[f]=info.Forcing.ImportFun(info);

%Preallocate fe,fx,s,d
%[fe,fx,s,d]=PreAllocateModelStructs(info);


%run model
if info.flags.GenCode
    %do precompo
    [fe,fx,d,p]=info.msi.prc(f,fe,fx,s,d,p,info);
    %do core
    [s, fx, d] = info.msi.core(f,fe,fx,s,d,p,info);
    
else
    
    %do precompo
    for i=1:length(info.prcO)
        [fe,fx,d,p]=info.prcO(i).fun(f,fe,fx,s,d,p,info);
    end
    
    [s, fx, d] = core(f,fe,fx,s,d,p,info);
    
end

%do the precomp Once




%checks:
%- all required forcing available?
%compatibility of modules

%write inlined core and precomps
%forcing dims
ntime=3650; %horizontal
nspace=1; %vertical


%[f,s]=GenerateRandomForcing(precs,modules,ntime,nspace);

