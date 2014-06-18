%precomputation handler
%clear all

pthModules='M:\people\mjung\sindbad-git\Code4Core\Modules\';
pthPrecsGen='M:\people\mjung\sindbad-git\Code4Tem\PrecsGen\';
pthCodeGen='M:\people\mjung\sindbad-git\GeneratedCode\';
pthCore='M:\people\mjung\sindbad-git\Code4Core\core.m';

path(path,'M:\people\mjung\sindbad-git\Code4Core\')

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
SBvariablesSave={'all'};%put here the variables that you want to save e.g. {'s.wGW','d.DemandGPP.gppE','fx.ECanop')


[info]=SetupInfoModelStructure(info);

% %set up p struct
% %should read the params from an excel file and the VEG and SOIL etc params
% %from somewhere ales
% %[p]=info.params.ImportFun(info);


[IsCompatible]=check_ModelIntegrity(info);

%get the forcing
%[f]=info.Forcing.ImportFun(info);

%Preallocate fe,fx,s,d
%[fe,fx,s,d]=PreAllocateModelStructs(info);

ntime=3650; %horizontal
nspace=1; %vertical

info.Forcing.Size=[nspace ntime];

[f,fe,fx,s,d,p]=IniDummyVariables4Test(info,ntime,nspace);


%if info.flags.GenCode == 1
    %do precompo
    tic
for i=1:10    
    
    
    [fe,fx,d,p]=info.msi.prc(f,fe,fx,s,d,p,info);
    %do core
    [s, fx, d] = info.msi.core(f,fe,fx,s,d,p,info);
    
end
   toc
   
   [ProblemVariablesNumeric]=Check_numeric(f,fe,fx,s,d,p,info.Variables.All);
   
   
   [f_o,fe_o,fx_o,s_o,d_o,p_o]=GatherOutput(f,fe,fx,s,d,p,SBvariablesSave);
   
 tic
for i=1:10
    %else
   
    %do precompo
    for ii=1:length(info.prcO)
        [fe,fx,d,p]=info.prcO(ii).fun(f,fe,fx,s,d,p,info);
    end
    
    [s, fx, d] = core(f,fe,fx,s,d,p,info);
   
%end
end
toc
    





info.flags.GenCode=1;

%run model
if info.flags.GenCode == 1
    %do precompo
    tic
    [fe,fx,d,p]=info.msi.prc(f,fe,fx,s,d,p,info);
    %do core
    [s, fx, d] = info.msi.core(f,fe,fx,s,d,p,info);
    toc
else
    tic
    %do precompo
    for i=1:length(info.prcO)
        [fe,fx,d,p]=info.prcO(i).fun(f,fe,fx,s,d,p,info);
    end
    
    [s, fx, d] = core(f,fe,fx,s,d,p,info);
    toc
end

%do the precomp Once




%checks:
%- all required forcing available?
%compatibility of modules

%write inlined core and precomps
%forcing dims


%[f,s]=GenerateRandomForcing(precs,modules,ntime,nspace);

