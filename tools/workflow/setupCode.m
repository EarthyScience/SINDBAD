function [info] = setupCode(info)
% setup the model structure and generate the code and info necessary for
% TEM
%
% Requires:
%   - info.tem.model.modules: structure with approaches, order does not matter
%   - info.tem.model.paths.coreTEM: path including m file name
%   - info.tem.model.paths.modules: path to modules with '/' at end
%   - info.optem.params.names: list of params to optimise
%   - info.tem.model.variables.to.store
%   - info.tem.model.flags.genredMemCode
%
% Purposes:
%   - Creates the fields of info related to model structure
%       - generates the code for the selected modules and approaches.
%       -
% Conventions:
%   - Requires strict following of the conventions of structure of sindbad objects
%       - p.[ModuleName].[VariableName]
%       - d.[VariableName]
%       - d.storedStates.[StateVariableName]
%       - fe.[ModuleName].[VariableName]
%       - fx.[VariableName]
%       - s.[ElementName(d)].[VariableName]: c for carbon, w, d for state variables that are not storages
%
% Created by:
%   - Martin Jung (mjung)
%   - Sujan Koirala (skoirala)
%
% References:
%   -
%
% Versions:
%   - 1.0 on 10.04.2018

%%
%--> get code and set handles;
[info,precStruct,moduleStruct]      =    setupModules(info);

%--> interpret code, get various variables etc
[info,precStruct,moduleStruct] =    getVariablesFromCode(info,precStruct,moduleStruct);

if info.tem.model.flags.genRedMemCode
    varsToRedMem               =   info.tem.model.code.variables.to.redMem;
    [moduleStruct]             =   redMemModules(moduleStruct,varsToRedMem);
end
%--> check which precomputations need to be done always and which only once
%   (relevant for optimisation), i.e. split precomps between Once and Always
%   check integrity of model structure
%   put things into info
[info]                          =   setupModel(info,moduleStruct,precStruct);

%--> generate code
%   issue with hardcoded modules in writing code for spinup.
%   easy to change once respective field in info is available (which modules
%   to do)
if info.tem.model.flags.genCode
    [info]      =    writeCode(info);
end

%--> Adding the function handles of raw core and precomp to the info (ncarval, skoirala: 19/04/2018)
[~,rawCoreName]                                    =    fileparts(info.tem.model.paths.coreTEM);
info.tem.model.code.rawMS.precOnce.funHandle       =    @runPrecOnceTEM;
info.tem.model.code.rawMS.coreTEM.funHandle        =    str2func(rawCoreName);
info.tem.spinup.code.rawMS.precOnce.funHandle      =    @runPrecOnceTEM4Spinup;
info.tem.spinup.code.rawMS.coreTEM.funHandle       =    @coreTEM4Spinup;
% info.tem.spinup.code.rawMS.precOnce.funHandle      =    @runPrecOnceTEM;
% %sujan
% info.tem.spinup.code.rawMS.coreTEM.funHandle       =    str2func(rawCoreName);
%<--

end

%%
function [moduleStruct]     =    redMemModules(moduleStruct,varsToRedMem)
% - find the modules which have these variables in redMem mode
% - check for the existences of variables to define with 1 in time dimension
%%
for i   =   1:length(moduleStruct)
    funCont                     =   moduleStruct(i).funContent;
    [funCont]                   =   redMemFunCont(funCont,varsToRedMem);
    moduleStruct(i).funContent  =   funCont;
end
end
function [info]     =   setupModel(info,moduleStruct,precStruct)

%--> check which precomputations need to be done always and which only once
%    (relevant for optimisation)
if info.tem.model.flags.runOpti
    paramsOpt                   =   info.opti.params.names;
else
    paramsOpt                   =   {};
end

[precStruct]                =   checkPrecAlways(precStruct,paramsOpt);

%--> ModuleNames=fieldnames(moduleStruct);
%   define info model structure
ms                          =       struct;
for i=1:length(moduleStruct)
    cmn             =   moduleStruct(i).moduleName;
    eval(['ms.' cmn '=moduleStruct(i);'])
end
info.tem.model.code.ms      =   ms;
info.tem.model.code.prec    =   precStruct;
[IsCompatible]              =   checkModelIntegrity(info);
end

%%
function [info,precStruct,moduleStruct]=getVariablesFromCode(info,precStruct,moduleStruct);

[precStruct]                                    =   getInputOutputFromModelCode(precStruct);
[moduleStruct]                                  =   getInputOutputFromModelCode(moduleStruct);
[AllInputs,AllOutputs,AllOutputsPrec]           =   getAllModelInputsOutputs(precStruct,moduleStruct);

info.tem.model.code.variables.moduleInputs      =   AllInputs;
info.tem.model.code.variables.moduleOutputs     =   AllOutputs;
info.tem.model.code.variables.moduleAll         =   unique(vertcat(AllInputs,AllOutputs));

%--> for memory efficiency identify variables where we actually need the
%   temporal information; check variables of fx. and d. which are not output
%   of precomp, and which are not to store
%   take union of variables to riwte and variables to store and put as
%   variables to store
writeVars_longName                              =   info.tem.model.variables.to.write;
storeVars_longName                              =   info.tem.model.variables.to.store;
storeVars_longName                              =   unique(vertcat(storeVars_longName(:),...
                                                    writeVars_longName(:)));
%--> sujan on 16.11.2019: add the storage variables in variables.to.write
%to variables.to.store. This only works if the write variables are given as
%s.w.wSoil rather than d.storedStates.wSoil 
% storeVarsfromWriteVars={};
% for wv = 1:numel(writeVars_longName)
%     wVar = writeVars_longName{wv};
%     if contains('s.',wVar)
%         storeVarsfromWriteVars(end+1) = wVar;
%     end
%     if contains('d.storedStates',wVar)
%     tmp    = strsplit(wVar,'.');
%     dVar   =    tmp(end);
%     if startsWith(dVar,'w')
%     end
       
% end

info.tem.model.variables.to.store                               =   storeVars_longName;
[storeStates_longSource,storeStates_longDestination]            =   getStatesToStore(storeVars_longName);
info.tem.model.code.variables.to.storeStatesSource              =   storeStates_longSource;
info.tem.model.code.variables.to.storeStatesDestination         =   storeStates_longDestination;

[variablesToRedMem]                                             =   getVariablesToRedMem(storeVars_longName,AllOutputsPrec,AllOutputs);
info.tem.model.code.variables.to.redMem                         =   variablesToRedMem(:);

%% variables to sum
sumVars                                                         =   info.tem.model.variables.to.sum; %--> sujan moved the fields from info.tem.model.varsToSum

sumVars_longDestination                                         =   {''};
sumVars_codeLines                                               =   {''};
fn_sumVars                                                      =   fieldnames(sumVars);
addKeepVar                                                      =   {''};

cnt_keep                                                        =   1;

cnt                                                             =   1;
for ii  =   1:length(fn_sumVars)
    %sVarFlag=false;
    sumVars_longDestination(ii)                                 =   cellstr([sumVars.(char(fn_sumVars(ii))).destination '.' char(fn_sumVars(ii))]);
    
    if startsWith(sumVars_longDestination(ii),['s.'])
        %        sVarFlag=true;
        cCL                                                     =   [char(sumVars_longDestination(ii)) '=0'];
        tmp                                                     =   startsWith(AllOutputs,sumVars.(char(fn_sumVars(ii))).components);
        cComps                                                  =   AllOutputs(tmp);
        if sumVars.(char(fn_sumVars(ii))).balance
            % [s.prev.s_wd_wTWS]
            addKeepVar(cnt_keep)                                =   cellstr(['s.prev.' char(regexprep(sumVars_longDestination(ii),'\.','_'))]);
        end
        
        for j   =   1:length(cComps)
            cstr                                                =   ['+sum(' char(cComps(j)) ',2)'];
            
            cCL                                                 =   [cCL cstr];
        end
        cCL                                                     =   [cCL ';'];
        sumVars_codeLines(cnt)                                  =   cellstr(cCL);
        cnt                                                     =   cnt+1;
        
    else
        cCL                                                     =   [char(sumVars_longDestination(ii)) '(:,tix)=0'];
        cComps                                                  =   sumVars.(char(fn_sumVars(ii))).components;
        
            for j = 1:length(cComps)
        
            if ismember(cComps(j),info.tem.model.code.variables.moduleAll)
                if info.tem.model.flags.genRedMemCode && ismember(cComps(j),info.tem.model.code.variables.to.redMem)
                    cstr                                        =   ['+' char(cComps(j)) '(:,1)'];
                else
                    cstr                                        =   ['+' char(cComps(j)) '(:,tix)'];
                end
                cCL                                             =   [cCL cstr];
            end
        end
        cCL                                                     =   [cCL ';'];
        sumVars_codeLines(cnt)                                  =   cellstr(cCL);
        cnt                                                     =   cnt+1;
    end
end

info.tem.model.code.variables.to.sum.codeLines                  =   sumVars_codeLines;

%add the new variables to output variables such that they can be created.
%the new variables will however NOT be listed in
%info.tem.model.code.variables !!!
AllOutputs                                                      =   vertcat(AllOutputs,sumVars_longDestination(:));
%info.tem.model.code.variables.moduleInputs      =   AllInputs;
info.tem.model.code.variables.moduleOutputs                     =   AllOutputs;
info.tem.model.code.variables.moduleAll                         =   unique(vertcat(AllInputs,AllOutputs));

%%
%--> check if supplied write and store variables exist in the code
varsAllAll              =    unique(vertcat(AllOutputs,info.tem.model.code.variables.moduleAll(:),info.tem.model.variables.forcingInput(:),info.tem.model.variables.paramInput(:)));
problemVars             =   setdiff(storeVars_longName,varsAllAll);
if ~isempty(problemVars)
    for ii      =   1:length(problemVars)
%         if ~contains(char(problemVars(ii)),'d.storedStates.')
        if isempty(strfind(char(problemVars(ii)),'d.storedStates.'))
            %sujan (allowing storedstates)
            sstr    =   [pad('CRIT MODSTR',20) ' : ' pad('setupCode',20) ' | ' char(problemVars(ii)) ' does not exist in selected Model Structure (from ModelStructure.json) | Check output[.json] config file for variables to store and to write'];
            error(sstr)
        else
            sstr    =   [pad('WARN MODSTR',20) ' : ' pad('setupCode',20) ' | EXCEPTION: for ' char(problemVars(ii)) ' in variables.to.write | taken from output[.json] config file'];
            disp(sstr)
        end
    end
end


%%
AllVars                                                         =   unique(vertcat(AllInputs,AllOutputs,addKeepVar(:)));
[keptVars_longSource,keptVars_longDestination,keptVars_short]   =   getVariablesToKeep(AllVars);
info.tem.model.code.variables.to.keepSource                     =   keptVars_longSource;
info.tem.model.code.variables.to.keepDestination                =   keptVars_longDestination;
info.tem.model.code.variables.to.keepShortName                  =   keptVars_short;

%%

%%


%--> variables to create: all outputs except s. and p.
tf                                                              =   ~startsWith(AllOutputs,{'s.','p.'});

%--> skoirala: adding roTotal and evapTotal to variables to create
allOuts                                                         =   AllOutputs(tf);
allOuts{end+1}                                                  =   'fx.roTotal';
allOuts{end+1}                                                  =   'fx.evapTotal';
info.tem.model.code.variables.to.create                         =   allOuts;

% --> sujan (11.11.2019): check of the variables to write. Make sure the
% variables to write from output.json appears in the code. Also, all the
% variables to output from s. structure will be replaced by d.storedStates
% fields, as these variables will be automatically stored with the
% preceding sections of this function
writeVariables                                                  =   {};
for vn                                                          =   1:numel(writeVars_longName)
    vName                                                           =   writeVars_longName{vn};
    if ismember(vName,varsAllAll)
        if startsWith(vName,'s.')
            tmp                                                         =   strsplit(vName,'.');
            vNameShort                                                  =   tmp{3};
            vNameE                                                       =   ['d.storedStates.' vNameShort];
            writeVariables                                              =   [writeVariables,vNameE];
        else
            writeVariables                                              =   [writeVariables,vName];
        end
    else
        sstr    =   [pad('WARN VAR MISS',20) ' : ' pad('setupCode',20) ' | ' vName ' is set as an output variable in output.json but does not exist in the selected Model Structure'];
        disp(sstr)
        
    end
end
info.tem.model.code.variables.to.write                          =   writeVariables;
% --> sujan end of variables to write

end
%%
function [variablesToRedMem] = getVariablesToRedMem(storeVars_longName,AllOutputsPrec,AllOutputs)
% variables to remember are those fluxes or diagnostics (fx., d.,) which are
% not 'needed' outputs. not needed means a) not to store, and b) no output of a
% precomputation. considering b) is necessary because it would break the
% precomp part

%%
tmp                     =   unique(vertcat(AllOutputsPrec,storeVars_longName(:)));
varsFlat                =   setdiff(AllOutputs,tmp);
tf                      =   startsWith(varsFlat,{'fx.','d.'});
variablesToRedMem       =   varsFlat(tf);

end

%%
function [ModuleNamesCore,CodeCore]     =   getCodeCore(pthCore)
% - get the contents of coreTEM
% - get the names of the modules called in coreTEM

%%
[CodeCore]              =   readMfunctionContents(pthCore);

%mfinfo = mfileread(pthCore);
%CodeCore=mfinfo.code;
%look for 'ms.' and '.fun'

st                      =   strfind(CodeCore,'ms.');
en                      =   strfind(CodeCore,'.fun');
ModuleNamesCore         =   {''};
cnt                     =   1;
for i   =   1:length(CodeCore)
    if ~isempty(st{i}) && ~isempty(en{i})
        cs                      =   char(CodeCore(i));
        ModuleNamesCore(cnt,1)  =   cellstr(cs(st{i}+3:en{i}-1));
        cnt                     =   cnt+1;
    end
end
end

%%
function [C]    =   readMfunctionContents(mpth)
% - opens a m file and return its content

%%
%fid = fopen(mpth);
%C = textscan(fid, '%s', 'delimiter', '?','CommentStyle','%'); %%check if mlint does extract the comments (2018-01-18)
%fclose(fid);
%C=C{1};

mfinfo              =   mfileread(mpth);
C                   =   mfinfo.code;

%--> check if last line is 'end' or 'return';
if strncmp(C(end),'return',6) || strncmp(C(end),'end',3)
    C               =   C(2:end-1);
else
    C               =   C(2:end);
end

%--> find mfunctions in directory
[pathstr,name,ext]  =   fileparts(mpth);
mf                  =   dir([pathstr '/' '*.m']);

%--> check if you find it in C
for ii  =   1:length(mf)
    
    [pathstr2,name,ext]     =    fileparts(mf(ii).name);     % Comment: on Linux, this line
    % will only work for absolute paths
    
    tmp                     =   regexp(C,[name '\s*(']); %added '(' to make sure its a function call and not e.g. confused with an error message
    
    for iii     =   1:length(tmp)
        
        if ~isempty(tmp{iii})               %something found
            P1              =   C(1:iii-1);
            [P2]            =   readMfunctionContents([pathstr '/' mf(ii).name]);
            P3              =   C(iii+1:end);
            %--> sujan and nuno: the array sizes were 1 x N when other
            % functions were being called from within an approach. So, try-catch has been added
            %  original                      C               =   vertcat(P1,P2,P3);
            
            try
                C           =   vertcat(P1,P2,P3);
            catch
                try
                    C       =   vertcat(P1',P2',P3');
                catch
                    sstr    =   [pad('CRIT MODSTR',20) ' : ' pad('setupCode:readMfunctionContents',20) ' | probably a broken line with "..." in the code, or a function called more than one time in the same module_approach'];
                    error(sstr)
                end
            end
            %<--
        end
    end
end
end

%%
function [info,precStruct,moduleStruct]  =   setupModules(info)
% - checks if module names in coreTEM and info (from json config) are
%   consistent

%%
[info,isConsistentModules,moduleNamesCore]      =   checkModuleConsistency(info);

% moduleNamesCore contains the correct order which is important here

pthModules                                      =   info.tem.model.paths.modulesDir;
precStruct                                      =   struct;
moduleStruct                                    =   struct;

cntP    =   1;
cntM    =   1;
for i   =   1:length(moduleNamesCore)
    capproachName               =   info.tem.model.modules.(moduleNamesCore{i}).apprName;
    mo_ap                       =   [char(moduleNamesCore(i)) '_' capproachName];
    
    cpth                        =   [pthModules char(moduleNamesCore(i)) '/' mo_ap '/'];
    
    cpthm                       =   [cpth mo_ap '.m'];
    %full exists
    flagFullExists              =   exist(cpthm,'file')==2;
    
    if info.tem.model.modules.(char(moduleNamesCore(i))).runFull && flagFullExists==1
        %do for Modules
        %cpthm=[cpth mo_ap '.m'];
        %get the code and stuff
        [moduleStruct]                      =   getModelCode(cpthm,moduleStruct,cntM);
        moduleStruct(cntM).runAlways        =   1;
        moduleStruct(cntM).moduleName       =   char(moduleNamesCore(i));
        % sujan: added the use4spinup field to non-preconce modules
        if isfield(info.tem.model.modules.(moduleStruct(cntM).moduleName),'use4spinup')
            moduleStruct(cntM).use4spinup = info.tem.model.modules.(moduleStruct(cntM).moduleName).use4spinup;
        else
            moduleStruct(cntM).use4spinup=0;
        end
        % sujan: added the use4spinup field to non-preconce modules (end)
        cntM                                =   cntM+1;
    else
        %file doesn't exist
        if flagFullExists == 0
            tmp_moap                        =   strsplit(mo_ap,'_');
            msg                             =   [pad('MISS MODSTR',20) ' : ' pad('setupCode',20) ' | ' pad(mo_ap,35) ' | (full_) not found , using (dyna_) and (prec_) in model/modules/' char(tmp_moap{1}) '/' mo_ap];
            disp(msg)
        end
        
        cpthm                               =   [cpth 'dyna_' mo_ap '.m'];
        
        flagDynaExists=exist(cpthm,'file') == 2;
        if ~flagDynaExists
            msg                             =   [pad('CRIT MODSTR',20) ' : ' pad('setupCode',20) ' | ' mo_ap '.m (dyna) not found | if only fullfile exists, change runFull flag to true in config (modelStructure.json)'];
            error(msg)
        end
        
        %get the code and stuff
        [moduleStruct]                      =   getModelCode(cpthm,moduleStruct,cntM);
        moduleStruct(cntM).runAlways        =   1;
        moduleStruct(cntM).moduleName       =   char(moduleNamesCore(i));
        
        % sujan: added the use4spinup field to non-preconce modules
        if isfield(info.tem.model.modules.(moduleStruct(cntM).moduleName),'use4spinup')
            moduleStruct(cntM).use4spinup   =   info.tem.model.modules.(moduleStruct(cntM).moduleName).use4spinup;
        else
            moduleStruct(cntM).use4spinup   =   0;
        end
        % sujan: added the use4spinup field to non-preconce modules (end)
        cntM                                =   cntM+1;
        %this allows for multiple (complementary! - not overlapping!) precomps
        %with something after the approach name and before '.m'
        Pxl                                 =   dir([cpth 'prec_' mo_ap '*.m']);
        
        for j   =   1:length(Pxl)
            precStruct(cntP).runAlways      =   0;
            precStruct(cntP).moduleName     =   char(moduleNamesCore(i));
            % sujan: added the use4spinup field to preconce modules
            if isfield(info.tem.model.modules.(precStruct(cntP).moduleName),'use4spinup')
                precStruct(cntP).use4spinup   =   info.tem.model.modules.(precStruct(cntP).moduleName).use4spinup;
            else
                precStruct(cntP).use4spinup   =   0;
            end
            % sujan: added the use4spinup field to preconce modules (end)
            
            %do for Prec
            %get the code and stuff
            [precStruct]                    =   getModelCode([cpth Pxl(j).name],precStruct,cntP);
            cntP                            =   cntP+1;
        end
        
    end
end
end

%%
function [codeStruct]   =   getModelCode(xpth,codeStruct,cnt)

[pathstr, FunName, ext]     =    fileparts(xpth);
%--> set path
path(path,pathstr);
%--> generate handle
codeStruct(cnt).funHandle   =   str2func(FunName);
%--> get contents of function
[funCont]                   =   readMfunctionContents([pathstr '/' FunName '.m']);
%mfinfo = mfileread([pathstr '/' FunName '.m']);
%funCont=mfinfo.code;
[funCont]                   =   beautifyFunCont(funCont);
codeStruct(cnt).funContent  =   funCont;
codeStruct(cnt).funPath     =   cellstr(pathstr);
codeStruct(cnt).funName     =   cellstr(FunName);
end

%%
function [codeStruct]=getInputOutputFromModelCode(codeStruct)
% + Get the list of input and output from each approach
% + Requires strict following of the conventions of structure of sindbad objects
%       + p.[ModuleName].[VariableName]
%       + d.[VariableName]
%       + d.storedStates.[StateVariableName]
%       + fe.[ModuleName].[VariableName]
%       + fx.[VariableName]
%       + s.[ElementName(d)].[VariableName]: c for carbon, w, d for state variables that are not storages

sstr    =   {...
    '\<p\.\w[\w\d_]*\.\w[\w\d_]*',...
    '\<d\.\w[\w\d_]*\.\w[\w\d_]*',...
    '\<fe\.\w[\w\d_]*\.\w[\w\d_]*',...    '\<fe\.\w[\w\d_]*',...
    '\<f\.\w[\w\d_]*',...
    '\<fx\.\w[\w\d_]*',...
    '\<s\.\w[\w\d_]*\.\w[\w\d_]*'};

for i   =   1:length(codeStruct)
    Output          =   {[]};
    Input           =   {[]};
    cntI            =   1;
    cntO            =   1;
    
    [starteq]       =   regexp(codeStruct(i).funContent,'=');
    [startComment]  =   regexp(codeStruct(i).funContent,'%');
    
    for j   =   1:length(sstr)
        
        %         [matchstart,matchend,tokenindices,matchstring,tokenstring, tokenname,splitstring] =regexp(precs(i).funCont,sstr(j));
        [matchstart,matchend,tokenindices,matchstring,tokenstring, tokenname]   =   regexp(codeStruct(i).funContent,sstr(j));
        
        v               =   find(cellfun(@isempty,matchstart)==0);
        for k   =   1:length(v)
            cv          =   v(k);
            cl          =   length(matchstart{cv});
            cmstart     =   matchstart{cv};
            ceq         =   starteq{cv};
            try
                ceq         =   ceq(1);
            catch
                error(['ERR : in function : ' codeStruct(i).funName{1} ...
                    ' : in line : ' codeStruct(i).funContent{cv}])
            end
            cstring     =   matchstring{cv};
            ccomment    =   startComment{cv};
            if ~isempty(ccomment)
                ccomment    =   ccomment(1);
            else
                ccomment    =   Inf;
            end
            for l   =   1:cl
                if cmstart(l) < ceq
                    %is output
                    Output(cntO,1)      =   cstring(l);
                    cntO                =   cntO+1;
                else
                    if cmstart(l) < ccomment
                        Input(cntI,1)   =   cstring(l);
                        cntI            =   cntI+1;
                    end
                    %is input
                    
                end
            end
            
        end
        
    end
    if ~isempty(Input{1})
        codeStruct(i).funInput          =   unique(Input);
    end
    if ~isempty(Output{1})
        codeStruct(i).funOutput         =   unique(Output);
    end
    
end

end

%%
function [AllInputs,AllOutputs,AllOutputsPrec]  =   getAllModelInputsOutputs(precStruct,moduleStruct)

AllInputs       =   [];
AllOutputs      =   [];

for i   =   1:length(precStruct)
    AllInputs       =   vertcat(AllInputs,precStruct(i).funInput);
    AllOutputs      =   vertcat(AllOutputs,precStruct(i).funOutput);
end

AllOutputsPrec      =   unique(AllOutputs);

for i   =   1:length(moduleStruct)
    AllInputs       =   vertcat(AllInputs,moduleStruct(i).funInput);
    AllOutputs      =   vertcat(AllOutputs,moduleStruct(i).funOutput);
end

AllInputs           =   unique(AllInputs);
AllOutputs          =   unique(AllOutputs);
end

%%
function [info,isConsistentModules,moduleNamesCore]     =   checkModuleConsistency(info);
pthCore                         =   info.tem.model.paths.coreTEM;

[moduleNamesCore,CodeCore]      =   getCodeCore(pthCore);
infoModules                     =   info.tem.model.modules;
%moduleNames=fieldnames(infoModules);

%assign approaches to modules
approachNames                   =   moduleNamesCore;

%if module name exists in config file but not in coreTEM: error
moduleNamesConfig               =   fieldnames(infoModules);
unknownModules                  =   setdiff(moduleNamesConfig,moduleNamesCore);
if isempty(unknownModules)
    isConsistentModules         =   1;
else
    isConsistentModules         =   0;
    for ii  =   1:length(unknownModules)
        emsg    =   [pad('MISMATCH MODSTR',20) ' : module ' char(unknownModules(ii)) ' not found in specified coreTEM.m (check modelStructure.json)'];
        warning(emsg)
    end
    error([pad('CRIT MODSTR',20) ' | ' unknownModules{:} ': Cannot execute model with inconsistent module names in config and corresponding coreTEM.m (check modelStructure.json)'])
end

%--> sujan: 15.11.2019: added default of simple for get, keep, and storestates
% modules. These do not have any other approaches, and always needed to be
% set in modelStructure as simple. Now, that redundancy is fixed.
    simpleModules = {'keepStates', 'getStates', 'storeStates', 'wBalance'};

for ii  =   1:length(moduleNamesCore)
    %if module name exists in coreTEM but not in config file: assume 'dummy'
    %approach
    
    if isfield(infoModules,moduleNamesCore(ii))
        approachNames(ii)       =   cellstr(infoModules.(moduleNamesCore{ii}).apprName);
    %sujan
    elseif ismember(moduleNamesCore(ii),simpleModules)
        approachNames(ii)                               =   cellstr('simple');
        infoModules.(moduleNamesCore{ii}).apprName      =   'simple';
        infoModules.(moduleNamesCore{ii}).runFull       =   true;  
        infoModules.(moduleNamesCore{ii}).use4spinup    =   true;  
    %sujan
    else
        approachNames(ii)                               =   cellstr('dummy');
        infoModules.(moduleNamesCore{ii}).apprName      =   'dummy';
        infoModules.(moduleNamesCore{ii}).runFull       =   true;
    end
end

info.tem.model.modules                                  =   infoModules;
end

%%
function [funCont]  =   beautifyFunCont(funCont)

%
% funCont         =   regexprep(funCont,'=',' = ');
funCont         =   regexprep(funCont,'=','='); %sujan to avoid replacing <=,>=,~= by < =, > =, and ~ =

tf              =   endsWith(funCont,';');
rtf             =   tf==0;
tmp             =   funCont(rtf);
for i   =   1:length(tmp)
    tmp{i}      =   [tmp{i} ';'];
end
funCont(rtf)    =   tmp;
end

%%
function [funCont]  =   redMemFunCont(funCont,varsToRedMem)

for i   =   1:length(varsToRedMem)
    cvar    =   char(varsToRedMem(i));
    cexpr   =   [cvar '\(\s*:\s*,\s*tix\s*\)'];
    crep    =   [cvar '(:,1)'];
    funCont =   regexprep(funCont,cexpr,crep);
end

end

%%
function [longNames]    =   shortVariableName2fullSindbadNames(shortNames,longNamesAll)

tfd                         =   startsWith(longNamesAll,'d.prev.');
tfs                         =   startsWith(longNamesAll,'s.prev.');
tfa                         =   or(tfd,tfs);
longNames                   =   shortNames;

for i   =   1:length(longNamesAll)
    if ~tfa(i)
        cvar                =   char(longNamesAll(i));
        cvar_sp             =   split(cvar,'.');
        cvar_sh             =   cvar_sp(end);
        tf                  =   strcmp(cvar_sh,shortNames);
        if any(tf)
            longNames(tf)   =   cellstr(cvar);
        end
    end
end

end

%%
function [keptVars_longSource,keptVars_longDestination,keptVars_short]  =   getVariablesToKeep(AllVars)
% get the list of variables to keep by looking at code and location of
% s.prev, d.prev
%
%

%all as if to keep
AllVarsKeepShort         =   regexprep(AllVars,'\.','_');


tf          =   startsWith(AllVars,{'d.prev.','s.prev.'});

keptVars    =   AllVars(tf);
if isempty(keptVars)
    keptVars_longSource         =   [];
    keptVars_longDestination    =   [];
    keptVars_short              =   [];
else
    keptVars_split              =   split(keptVars,'.',2);
    keptVars_short              =   keptVars_split(:,end);
    
    keptVars_longSource       =   keptVars_short;
    keptVars_longDestination    =   keptVars_short;
    
    for i   =   1:length(keptVars_longSource)
        tf2=strcmp(keptVars_short(i),AllVarsKeepShort);
        keptVars_longSource(i)=AllVars(tf2);
        
        if startsWith(keptVars_longSource(i),'s.')
            keptVars_longSource(i)      =    cellstr([char(keptVars_longSource(i)) ';']);
            keptVars_longDestination(i) =   cellstr(['s.prev.' char(AllVarsKeepShort(tf2))]);
        else
            keptVars_longSource(i)      =   cellstr([char(keptVars_longSource(i)) '(:,tix);']);
            keptVars_longDestination(i) =   cellstr(['d.prev.' char(AllVarsKeepShort(tf2))]);
        end
    end
end
end

%%
function [storeStates_longSource,storeStates_longDestination]   =   getStatesToStore(storeVars_longName);

tf                          =   startsWith(storeVars_longName,'s.');
storeStates_longSource      =   storeVars_longName(tf);
tmp                         =   split(storeStates_longSource,'.');
storeStates_short           =   tmp(:,end);
storeStates_longDestination =   storeStates_longSource;

for i   =   1:length(storeStates_longDestination)
    if sum(strcmp(char(storeStates_short(i)),{'p_cFlowAct_A','p_cFlowAct_F','p_cFlowAct_E'}))>0
        % note NC hardcodded : @nc...
        storeStates_longDestination(i)      =   cellstr(['d.storedStates.' char(storeStates_short(i)) '(:,:,:,tix)']);
    else
        storeStates_longDestination(i)      =   cellstr(['d.storedStates.' char(storeStates_short(i)) '(:,:,tix)']);
    end
    storeStates_longSource{i}           =   [storeStates_longSource{i} ';'];
end
end

%%
function [info]     =   writeCode(info)

%write two functions: precomp once and core (contains precomp always)

%coreTEM (includes precomps 'always')
validModules                                    =   []; % if empty, do all which are in info
pthGenCode                                      =   info.tem.model.paths.genCode.coreTEM;
[funhCore,funhPrecOnce]                         =   writeGenCodeCore(info,validModules,pthGenCode);
info.tem.model.code.genMS.coreTEM.funHandle     =   funhCore;
info.tem.model.code.genMS.precOnce.funHandle    =   funhPrecOnce;

%coreTEM4spinup (includes precomps 'always')
moduleList      = fields(info.tem.model.modules);
% validModules                                    =   {'raAct','cCycle'};
validModules    =  {''};
cnt             =   1;
for mod         =   1:numel(moduleList)
    if isfield(info.tem.model.modules.(moduleList{mod}),'use4spinup')
        if info.tem.model.modules.(moduleList{mod}).use4spinup
            
            validModules{cnt}   = char(moduleList(mod));
            cnt                 = cnt + 1;
        end
    end
end
pthGenCode                                      =   info.tem.spinup.paths.genCode.coreTEM;
[funhCore,funhPrecOnce]                         =   writeGenCodeCore(info,validModules,pthGenCode);
info.tem.spinup.code.genMS.coreTEM.funHandle    =   funhCore;
info.tem.spinup.code.genMS.precOnce.funHandle   =   funhPrecOnce;

end

%%
function [fid]  =   writePrecContents(precs,doAlways,validModules,fid)

%doAlways=1;
for j   =   1:length(precs)
    %cn=precs(j).funName;
    %tmp=splitZstr(char(cn),'_');
    %cn=tmp(2);
    tf          =   strcmp(precs(j).moduleName,validModules);
    if precs(j).runAlways==doAlways && max(tf)==1
        [fid]   =   writeFunContent(precs(j),fid);
    end
end

end

%%
function mfinfo     =   mfileread(file)
%MFINFO = MFILEREAD(filename);
%
% MFILEREAD reads an m-file and returns its code and comment part
%
% More specifically, it returns a struct MFINFO with the fields
% FILENAME  .. name of m-file
% LINECOUNT .. the number of non-empty lines in the m-file
% TEXT .. compact representation of whole text line by line, excluding empty lines
% CODE .. compact representation of code only in a cell
% COMMENT .. compact representation of comments only in a  cell

% Comments are identified as the part of text after the first %-character which is not part of string

%
% (c) 19-12-2010, Mathias Benedek

% changed by NC
% same rules of comments for the "..."

code            =   '';
comm            =   '';
mtext           =   '';
linecount       =   0;

% read the file line by line
k               =   0;
tlinef          =    {};
fid             =    fopen(file);
while 1
    k           =    k + 1;
    tline       =    fgets(fid);
    if ~ischar(tline),   break,   end
    tlinef{k}   =    tline;
    mtext           =    [mtext, tline, char(13)];
    if ~isempty(tline)
        linecount   =    linecount+1;
    end
end
fclose(fid);

% remove multiple lines...
k           =   1;
while k < numel(tlinef)
    tline   =    rmComm(strtrim(tlinef{k}),0,true);
    newk    =    k + 1;
    if isempty(tline)
        tlinef{k}    =   '';
        k           =   newk;
        continue
    end
    % Find first "..." that is not part of string
    pcts_idx        =   strfind(tline,'...');
    if pcts_idx
        % identify comments
        comm_idx    =   length(tline);
        for ii      =   pcts_idx
            c_idx   =   strfind(tline(1:ii),'''');
            if mod(length(c_idx),2) == 0  % even number of ' -characters
                comm_idx    =   ii;
                break;
            end
        end
        % cat the next line in case ... is present
        if comm_idx > 1 && comm_idx<length(tline)
            tlinef{k}       =   [strtrim(tline(1:comm_idx-1)), tlinef{min([k+1 numel(tlinef)])}, char(13)];
            if numel(tlinef)>k
                tlinef(k+1) =   [];
                newk        =   k;
            end
        end
    end
    k                       =   newk;
end
mfinfo.tlinef               =   tlinef;

% comment explicitly the block comments
str2f                       =   '%{';
commNow                     =   false;
commNext                    =   false;
for i   =   1:numel(tlinef)
    tline           =   tlinef{i};
    if ~ischar(tline),   break,   end
    tline           =   strtrim(tline);
    pcts_idx        =   strfind(tline,str2f);
    if isequal(pcts_idx,1) && strcmp(str2f,'%{')
        commNow     =   true;
        commNext    =   true;
        str2f       =   '%}';
    elseif isequal(pcts_idx,1) && strcmp(str2f,'%}')
        commNow     =   true;
        commNext    =   false;
        str2f       =   '%{';
    end
    if commNow
        tlinef{i}   =   ['% ' tlinef{i}];
    end
    if ~commNext
        commNow     =   false;
    end
end

% remove line comments
code                =   cell(size(tlinef));
codek   =   1;
l2k     =   [];
for i   =   1:numel(tlinef)
    tline           =   tlinef{i};
    if ~ischar(tline),   break,   end
    [tline,codek]    =   rmComm(strtrim(tlinef{i}),codek,false);
    if ~isempty(tline)
        code{codek} =   tline;
    end
end
code = code(~cellfun('isempty',code));
% outputs
mfinfo.filename     =   file;
mfinfo.linecount    =   linecount;
mfinfo.text         =   strtrim(mtext);
mfinfo.code         =   strtrim(code);
end

%%
function [outLine,codek]    =   rmComm(tline,codek,isMultiLine)
outLine                 =   '';
% Find first percent sign that is not part of string
pcts_idx                =   strfind(tline,'%');
if sum(strcmp(strtrim(tline),{'%{','%}'})) > 0 && isMultiLine
    outLine             =   tline;
    pcts_idx            =   false;
end
if pcts_idx
    comm_idx            =   length(tline);
    for ii              =   pcts_idx
        c_idx           =   strfind(tline(1:ii),'''');
        if mod(length(c_idx),2) == 0  % even number of ' -characters
            comm_idx    =   ii;
            break;
        end
    end
    % extract the code
    if comm_idx > 1 && comm_idx < length(tline)
        outLine         =   strtrim(tline(1:comm_idx-1));
        codek           =   codek + 1;
    end
    if comm_idx > 1 && comm_idx == length(tline)
        outLine         =   strtrim(tline(1:comm_idx));
        codek           =   codek + 1;
    end
else
    outLine             =   strtrim(tline);
    codek               =   codek + 1;
end
end

%%
function [fid] = write_prec_StoreStates_simple(info, fid)
    % write the chunk of code in prec_ to create arrays to be stored into d.storedStates
    % by sujan
    %--> added by sujan on 09.11.2019 to handle creation of array in generated
    %code
cvars_source            =   info.tem.model.code.variables.to.storeStatesSource;
cvars_destination       =   info.tem.model.code.variables.to.storeStatesDestination;

%--> added by sujan on 09.11.2019 to handle creation of array in generated
%code
    fprintf(fid, '%s\n', '% prec_storeStates_simple');
fprintf(fid, '%s\n', 'numTimeStr = info.tem.helpers.sizes.nTix;');
for ij                  =    1:numel(cvars_source)
    var2ss              =   cvars_source{ij}(1:end-1);
    var2sdtmp           =   strsplit(cvars_destination{ij},'(');
    var2sd              =   var2sdtmp{1};
    evalStr             =   [var2sd ' = reshape(repelem(' var2ss ',1,' 'numTimeStr' '),[size(' var2ss '),' 'numTimeStr' ']);'];
    fprintf(fid, '%s\n', evalStr);
end

end

%%
function [fid] = write_wBalance_simple(info, fid)
    % write code for doing the water balance
    % by sujan: 22.03.2021
    fprintf(fid, '%s\n', ' % wBalance_simple');
    %--> the total precipitation input
    if ismember('fe.rainSnow.snow', info.tem.model.code.variables.moduleAll)
        fprintf(fid, '%s\n', 'precip=fe.rainSnow.rain(:,tix)+fe.rainSnow.snow(:,tix);');
    else
        fprintf(fid, '%s\n', 'precip=fe.rainSnow.rain(:,tix);');
    end

    fprintf(fid, '%s\n', 'dS=s.wd.wTotal-s.prev.s_wd_wTotal;');
    fprintf(fid, '%s\n', 'd.wBalance.wBal(:,tix) = precip-fx.roTotal(:,tix)-fx.evapTotal(:,tix)-dS;');

end

%%
function [fid] = writeStoreStates_simple(info, fid)
    fprintf(fid, '%s\n', '% dyna_storeStates_simple');
    cvars_source = info.tem.model.code.variables.to.storeStatesSource;
    cvars_destination = info.tem.model.code.variables.to.storeStatesDestination;

for ii  =   1:length(cvars_source)
    sstr                =   [char(cvars_destination(ii)) ' = ' char(cvars_source(ii))];
    fprintf(fid, '%s\n', sstr);
end


end

%%
function [fid]  =   writeSumVariables_simple(info,fid)

fprintf(fid, '%s\n', '%sumVariables_simple');

CL=info.tem.model.code.variables.to.sum.codeLines;
for ii  =   1:length(CL)
    sstr            =   char(CL(ii));
        fprintf(fid, '%s\n', sstr);
    
end

end


%%
function [fid]  =   writeKeepStates_simple(info,fid)
% generate the code for writing the .prev fields of s and d at the
% beginning of every time sep

cvars_source            =    info.tem.model.code.variables.to.keepSource;
cvars_destination       =   info.tem.model.code.variables.to.keepDestination;

fprintf(fid, '%s\n', '%keepStates_simple');

for ii  =   1:length(cvars_source)
    sstr                =   [char(cvars_destination(ii)) ' = ' char(cvars_source(ii))];
    fprintf(fid, '%s\n', sstr);
end


end

%%
function [fid]  =   writeFunContent(funStruct,fid)
str             =   ['%' char(funStruct.funName)];
fprintf(fid, '%s\n', str);

for i   =   1:length(funStruct.funContent)
    fprintf(fid, '%s\n',funStruct.funContent{i});
end
end

%%
function [funhCore,funhPrecOnce]    =   writeGenCodeCore(info,validModules,CodePth)

if isempty(validModules)
    validModules                =   fieldnames(info.tem.model.code.ms);
end

%CodePth=info.tem.model.paths.genCode.coreTEM;
[genCorePath,genCoreName,~]     =   fileparts(CodePth);

if~exist(genCorePath,'dir'),mkdirx(genCorePath);end

if exist(CodePth,'file') == 2 
    delete(CodePth);
end

pthCore                         =   info.tem.model.paths.coreTEM;
[ModuleNamesCore,CodeCore]      =   getCodeCore(pthCore);

fid                             =   fopen(CodePth, 'wt');

%write the core
str                             =   ['function [f,fe,fx,s,d,p] = ' genCoreName '(f,fe,fx,s,d,p,info);'];
fprintf(fid, '%s\n', str);
% sujan: adding information inside the file of the generated code
if contains(genCoreName,'c_SU')
    infoAdd = 'spinup';
else
    infoAdd = 'forward run';
end
% end sujan adding info

str2                         =   ['% Automatically generated core function for ' infoAdd ' of the selected model structure and settings of SINDBAD'];
fprintf(fid, '%s\n', str2);


str                             =   '%%%starting with prec (always)%%%';
fprintf(fid, '%s\n', str);

precs                           =   info.tem.model.code.prec;
doAlways                        =   1;
[fid]                           =   writePrecContents(precs,doAlways,validModules,fid);

%go until line 'for tix'
tmp                             =   find(startsWith(CodeCore,'for tix'));
%first instance
iistart                         =   tmp(1);

%for each line in code core check if you find module name
%if yes: inline fun contents
%if no: write code line of core

for ii  =   iistart:length(CodeCore)
    %find module name in code core line
    st                          =   strfind(CodeCore{ii},'ms.');
    en                          =   strfind(CodeCore{ii},'.fun');
    
    if ~isempty(st) && ~isempty(en)
        %found a module
        cs                      =   char(CodeCore(ii));
        cModuleNameCore         =   cellstr(cs(st+3:en-1));
        tmp                     =   strcmp(cModuleNameCore,validModules);
        %is a valid module
        if any(tmp)
            moduleStruct        =   info.tem.model.code.ms.(char(cModuleNameCore));
            
            switch char(moduleStruct.funName)
                
                case 'storeStates_simple'
                    [fid]           =   writeStoreStates_simple(info,fid);
                case 'keepStates_simple'
                    [fid]           =   writeKeepStates_simple(info,fid);
                case 'sumVariables_simple'
                    [fid]           =   writeSumVariables_simple(info,fid);
                    case 'wBalance_simple'
                        [fid] = write_wBalance_simple(info, fid);
                otherwise
                    [fid]           =   writeFunContent(moduleStruct,fid);
            end
            
            %             if strcmp(moduleStruct.funName,'storeStates_simple')
            %                 [fid]           =   writeStoreStates_simple(info,fid);
            %             else
            %                 [fid]           =   writeFunContent(moduleStruct,fid);
            %             end
        end
    else
        fprintf(fid, '%s\n',CodeCore{ii});
    end
end

str                         =   'end';
fprintf(fid, '%s\n', str);

fclose(fid);

path(path,genCorePath);
funhCore                    =   str2func(genCoreName);

%%%%%%%%%%%%%%%%%precOnce

genPrecOnceName             =    ['p_' genCoreName(3:end)];
% sujan: adding information inside the file of the generated code
if contains(genPrecOnceName,'p_SU')
    infoAdd = 'spinup';
else
    infoAdd = 'forward run';
end
% end sujan adding info
CodePth                     =   [genCorePath '/' genPrecOnceName '.m'];

if exist(CodePth,'file')
    delete(CodePth);
end

fid                         =   fopen(CodePth, 'wt');

%write ...
str                         =   ['function [f,fe,fx,s,d,p]=' genPrecOnceName '(f,fe,fx,s,d,p,info);'];
fprintf(fid, '%s\n', str);
str2                         =   ['% Automatically generated PrecOnce function for ' infoAdd ' of the selected model structure and settings of SINDBAD'];
fprintf(fid, '%s\n', str2);

doAlways                    =   0;
[fid]                       =   writePrecContents(precs,doAlways,validModules,fid);

    [fid] = write_prec_StoreStates_simple(info, fid);
str                         =   ['end'];
fprintf(fid, '%s\n', str);

fclose(fid);

funhPrecOnce                =   str2func(genPrecOnceName);

%sujan: autoindent the generated code automatically
% genPrecOnceName
% CodePth

% autoIndentMfile(genPrecOnceName);
% autoIndentMfile(CodePth);

end

%%
function [precs]    =   checkPrecAlways(precs,paramsOpt)

%loop from top to bottom
for i   =   1:length(precs)
    %if input is a param that is optimised --> flag (precomp always)
    
    %a= ismember(precs(i).params.Names,paramsOpt);
    if ~isempty(precs(i).funInput)
        a                                       =   ismember(precs(i).funInput,paramsOpt);
        if sum(a)>0
            precs(i).runAlways                  =   1;
            
            %check if any other prec down in the sequence requires an input which
            %is the output of this prec; if so --> flag for DEPENDENT prec (precomp always)
            for j   =   i+1:length(precs)
                if ~isempty(precs(j).funInput)
                    a                           =   ismember(precs(j).funInput,precs(i).funOutput);
                    if any(a)
                        precs(j).runAlways      =   1;
                    end
                end
            end
        end
    end
    %find all precs where and input from d,fx,fe is their output
    %if in any of them an optimised param --> flag (precomp always)
end

end

%%
function [IsCompatible]     =   checkModelIntegrity(info)

%Compatibility is here simply assessed by checking if all inputs by
%fe,fx,d,s,f,p are also some output of the same or another function (order of
%computations is not checked);


AllInputs               =   info.tem.model.code.variables.moduleInputs;
AllOutputs              =   info.tem.model.code.variables.moduleOutputs;

%add Input variables that are read in to Outputs
%AllInputs=unique(vertcat(AllInputs,info.tem.model.variables.forcingInput(:),info.tem.model.variables.paramInput(:)));
AllOutputs              =   unique(vertcat(AllOutputs,info.tem.model.variables.forcingInput(:),info.tem.model.variables.paramInput(:)));

%--> added by sujan on martin's suggestion (2018/04/25) on skipping .prev variables in
% check of model integrity that gave false results. The .prev don't need to be an output of another
% module because they are implicitly treated by keepStates_simple approach
tf                      =   startsWith(AllInputs,{'s.prev.','d.prev.'});
AllInputs               =   AllInputs(~tf);
%<--
%--> get rid of the ones that start with 'p.','f.'
%   k=strfind(AllInputs,'p.');
%   kk=strfind(AllInputs,'f.');
%   tf=cellfun(@isempty,k) & cellfun(@isempty,kk);
%   AllInputs=AllInputs(tf);

moduleStruct            =   info.tem.model.code.ms;
precStruct              =   info.tem.model.code.prec;

%problem variables are those that are an input to a module but no output
%of a previous module, i.e. variables in AllInputs that do not appear
%in AllOutputs

ProblemVars             =   setdiff(AllInputs,AllOutputs);

if isempty(ProblemVars)
    IsCompatible        =   1;
    
else
    IsCompatible        =   0;
    
    modules             =   fieldnames(moduleStruct);
    
    %check in detail each ProblemVariable
    for ii  =   1:length(ProblemVars)
        %modules
        for iii     =   1:length(modules)
            cInput      =   moduleStruct.(char(modules(iii))).funInput;
            tmp2        =   strcmp(ProblemVars(ii),cInput);
            if any(tmp2)
                disp([pad('I/O MISMATCH MODSTR',20) ' : ' pad('setupCode',20) ': checkModelIntegrity | ' ProblemVars{ii} ' is input to ' modules{iii} ' but is not an output of any module'])
            end
        end
        
        %precomps
        for iii     =   1:length(precStruct)
            tmp2        =   strcmp(ProblemVars(ii),precStruct(iii).funInput);
            if any(tmp2)
                disp([pad('I/O MISMATCH MODSTR',20) ' : ' pad('setupCode',20) ': checkModelIntegrity | preComputation: ' ProblemVars{ii} ' is input to ' precStruct(iii).funName{1} ' but is not available'])
            end
        end
    end

        error([pad('I/O MISMATCH MODSTR', 20) ' : ' pad('setupCode', 20) ': checkModelIntegrity | Model Structure Error - Mismatch of Inputs and Ouputs in above Approaches'])
    end

end
