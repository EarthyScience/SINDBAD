function [dum] = writeOutput(info,f,fe,fx,s,d,p)
% writes the output of SINDBAD model run in different formats (.mat or .nc)
%
% Usages:
%   [dum] = writeOutput(info,f,fe,fx,s,d,p);
%
% Requires:
%   - the info: with the field info.tem.model.variables.to.write
%   - the sindbad fluxes and diagnostics (fx and d)
% Purposes:
%   - reads the forcing data from a defined DataPath
%       - DataPath can be a .nc or .mat file, or a folder with such files
%       - reads all variables defined in info.tem.forcing.variableNames
%       - loads a file only once and reads all variables needed from this
%       file
%       - in case a folder is given, the variable is read from each file of
%       this folder and overwritten in the output
%   - applies unit conversions if defined
%   - does NOT account for space and time extraction/mismatch/etc.
%
% Conventions:
%   - the SourceVariableName needs to be exactly what is loaded from a
%     .mat file (e.g. ExpStruct.Forcing.Tair if Tair is stored within a
%     structure in the -mat file) or from a .nc file
%   - if a variable cannot be read, a default value is applied
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% References:
%
%
% Versions:
%   - 1.0: 12.12.2018

%%
inputRefVar             =   info.tem.model.output.inputRef;
inputRefPath            =   info.tem.forcing.variables.(inputRefVar).dataPathFull;
datinfo                 =   ncinfo(inputRefPath);
dims                    =   datinfo.Dimensions;
vars                    =   datinfo.Variables;

%% Variables and output path
var2write               =   info.tem.model.variables.to.write;
pthSave                 =   info.experiment.modelOutputDirPath;
if ~exist(pthSave,'dir')
    mkdir(pthSave);
end
% if all output are written in one file for all years of simulation 
if ~info.tem.model.flags.runForwardYearly
    filename=[pthSave '/' info.experiment.name '_' info.experiment.domain '_' info.experiment.runDate info.tem.model.output.dataFormat];
    if exist(filename,'file')
        delete(filename);
    end
end
%%
for varn                =   1:numel(var2write)
    var                 =   var2write{varn};
    varNameSplit        =   strsplit(var,'.');
    varName             =   varNameSplit{end};
    
    if info.tem.model.flags.runForwardYearly
        filename=[pthSave '/' info.experiment.name '_' info.experiment.domain '_' varName '_' num2str(info.tem.model.time.runYear) info.tem.model.output.dataFormat];
        if exist(filename,'file')
            delete(filename);
        end
    end
    crStr= ['nccreate(''' filename ''',' '''' varName '''' ',' '''Dimensions''' ',' '{']; %longitude' rows 'latitude' cols 'time' time},'Datatype','single','DeflateLevel',7);
    
    eval(['datMain=' var ';'])
    datMain=squeeze(datMain);
    if ndims(datMain) < 3
        for dn              =   1:length(dims)
            dimName         =   dims(dn).Name;
            dimSize         =   dims(dn).Length;
            if dn == length(dims)
                endStr='}';
            else
                endStr=',';
            end
            crStr           =   [crStr '''' dimName  '''' ',' num2str(dimSize) endStr];
        end
    else
        addDims=struct;
        for dn              =   1:length(dims)
            dimName         =   dims(dn).Name;
            dimSize         =   dims(dn).Length;
            if dn == 2
                for dne=2:ndims(datMain)-1
                    crStr           =   [crStr '''level' num2str(dne-1) ''',' num2str(size(datMain,dne)) ','];
                    addDims.(['level' num2str(dne-1)]).size=size(datMain,dne);
                end
            end
            if dn == length(dims)
                endStr='}';
            else
                endStr=',';
            end
            crStr           =   [crStr '''' dimName  '''' ',' num2str(dimSize) endStr];
        end
        addDimsNames=fieldnames(addDims);
        for aN=1:numel(addDimsNames)
            addDim=addDimsNames{aN};
            addDimSize=addDims.(addDim).size;
            addDimCrStr= ['nccreate(''' filename ''',''' addDim ''',''Dimensions'',{''' addDim ''',' num2str(addDimSize) '},''Datatype'',''double'',''DeflateLevel'',' num2str(7) ')']; %longitude' rows 'latitude' cols 'time' time},'Datatype','single','DeflateLevel',7);
            eval(addDimCrStr)
            dimArr = 1:addDimSize;
            ncwrite(filename , ['' addDim ''] ,dimArr);
        end
        
        
    end
    crStr=[crStr ',''Datatype'',''' info.tem.model.rules.arrayPrecision ''',''DeflateLevel'',' num2str(7) ');'];
    %     crStr
    eval(crStr)
    varscreate={'latitude' 'longitude' 'time'};
    
    for vn = 1:length(vars)
        varsInfo=vars(vn);
        if any(ismember(varscreate,varsInfo.Name))
            crStrV=['nccreate(''' filename ''',' '''' varsInfo.Name '''' ',' '''Dimensions''' ',' '{']; %longitude' rows 'latitude' cols 'time' time},'Datatype','single','DeflateLevel',7);
            dimsV=varsInfo.Dimensions;
            for dnV              =   1:length(dimsV)
                dimNameV         =   dimsV(dnV).Name;
                dimSizeV         =   dimsV(dnV).Length;
                if dnV == length(dimsV)
                    endStr='}';
                else
                    endStr=',';
                end
                crStrV           =   [crStrV '''' dimNameV  '''' ',' num2str(dimSizeV) endStr];
            end
            crStrV=[crStrV ',''Datatype'',''' varsInfo.Datatype ''',''DeflateLevel'',' num2str(7) ');'];
            %             crStrV
            eval(crStrV)
            
            datVar = ncread(inputRefPath,varsInfo.Name);
            ncwrite(filename,['' varsInfo.Name ''],datVar);
            if strcmpi(varsInfo.Name,'time')
                ncwriteatt(filename,'time','units','days since 1582-10-15 00:00');
                ncwriteatt(filename,'time','calendar','gregorian');
                ncwriteatt(filename,'time','long_name','time');
            elseif strcmpi(varsInfo.Name,'longitude')
                ncwriteatt(filename,'longitude','bounds',[min(datVar) max(datVar)]);
                ncwriteatt(filename,'longitude','units','degrees_east');
                ncwriteatt(filename,'longitude','long_name','longitude');
            elseif strcmpi(varsInfo.Name,'latitude')
                ncwriteatt(filename,'latitude','bounds',[min(datVar) max(datVar)]);
                ncwriteatt(filename,'latitude','units','degrees_north');
                ncwriteatt(filename,'latitude','long_name','latitude');
            end
            
        end
    end
    ncwrite(filename,['' varName ''],datMain);
end
dum='';
end