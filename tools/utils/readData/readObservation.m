function [dataStructure] = readObservation(info)
% Usages:
%   [outStructure] = readObservation(info);
%   [obs]          = readObservation(info);
%
% Output:
%   - depending on defined data paths in the info:
%       - obs.(variable).data: the data itself
%       - obs.(variable).unc: the data uncertainty
%       - obs.(variable).qflag: the quality flag
%
% Requires:
%   - the info: with the field info.opti.constraints
%
% Purposes:
%   - reads the observational constraints from a defined DataPath
%       - DataPath can be a .nc or .mat file, or a folder with such files
%       - reads all variables defined in info.opti.constraints.variableNames
%       - loads a file only once and reads all variables needed from this
%       file
%       - in case a folder is given, the variable is read from each file of
%       this folder and overwritten in the output
%   - reads the data itself, and uncertainty data (unc) and quality flags (qflag) if a
%   DataPath for them is given
%   - applies unit conversions if defined
%   - does NOT account for space and time extraction/mismatch/etc.
%
% Conventions:
%   - the SourceVariableName needs to be exactly what is loaded from a
%     .mat file (e.g. ExpStruct.Forcing.Tair if Tair is stored within a
%     structure in the -mat file) or from a .nc file
%   - if a variable cannot be read, a default value is given
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% References:
%
%
% Versions:
%   - 1.0 on 09.07.2018

dataStructure = struct;
allDataPaths  = cell(1);
allVars       = cell(1);
varFlag       = cell(1);
% uncVars       = cell(1);
% qflagVars     = cell(1);

% time stuff -> different for optimization?
[xDay ]  = createDateVector(info.tem.model.time.sDate, info.tem.model.time.eDate, info.tem.model.time.step);


% get data paths
if ~isempty(info.opti.constraints.oneDataPath)
    dataPaths   = {info.opti.constraints.oneDataPath};
    allVars     = [allVars info.opti.constraints.variableNames{:}];
    tmp         = num2cell(zeros(1, numel(info.opti.constraints.variableNames)));
    varFlag     = [varFlag tmp{:}];
    for vv = info.opti.constraints.variableNames'
        % get uncertainty
        if isfield(info.opti.constraints.variables.(vv{1}),'unc') && ~isempty(info.opti.constraints.variables.(vv{1}).unc)
            allVars      =  [allVars vv{1}];
            varFlag      =  [varFlag 1];
        end
        % get quality flag paths
        if isfield(info.opti.constraints.variables.(vv{1}),'qflag') && ~isempty(info.opti.constraints.variables.(vv{1}).qflag)
            allVars      =  [allVars vv{1}];
            varFlag      =  [varFlag 2];
        end
    end
    idxVar      = ones(1, numel(allVars)-1);
    
else
    
    for vv = info.opti.constraints.variableNames'
        % of the variables
        allDataPaths =  [allDataPaths info.opti.constraints.variables.(vv{1}).data.dataPath];
        allVars      =  [allVars vv{1}];
        varFlag      =  [varFlag 0];
        % get uncertainty paths
        if isfield(info.opti.constraints.variables.(vv{1}),'unc')
            if isfield(info.opti.constraints.variables.(vv{1}).unc, 'dataPath') && ~isempty(info.opti.constraints.variables.(vv{1}).unc.dataPath)
                %uncVars      =  [uncVars vv{1}];
                allDataPaths =  [allDataPaths info.opti.constraints.variables.(vv{1}).unc.dataPath];
                allVars      =  [allVars vv{1}];
                varFlag      =  [varFlag 1];
            end
        end
        % get quality flag paths
        if isfield(info.opti.constraints.variables.(vv{1}),'qflag')
            if isfield(info.opti.constraints.variables.(vv{1}).qflag, 'dataPath') && ~isempty(info.opti.constraints.variables.(vv{1}).qflag.dataPath)
                %qflagVars       =  [qflagVars vv{1}];
                allDataPaths    =  [allDataPaths info.opti.constraints.variables.(vv{1}).qflag.dataPath];
                allVars      =  [allVars vv{1}];
                varFlag      =  [varFlag 2];
            end
        end
    end
    
    allDataPaths = allDataPaths(2:end);
    
    %allVars      = [info.opti.constraints.variableNames' uncVars(2:end) qVars(2:end)];
    %varFlag      = [zeros(1,numel(info.opti.constraints.variableNames')) ones(1,numel(uncVars)-1)];
    
    [dataPaths, idxData, idxVar]  = unique(allDataPaths);
end

allVars      = allVars(2:end);
varFlag      = varFlag(2:end);

% loop over unique data paths
% not covered when all input in the same folder but in different files

for ii=1:numel(dataPaths)
    dPath   = dataPaths{ii};
    inVars  = allVars(idxVar==ii);
    % is data path a folder or file?
    if exist(dPath, 'dir')
        dContent = dir(dPath);
        dFiles  = {dContent(~[dContent.isdir]).name};
        dFiles  = strcat(dPath,dFiles);
    elseif exist(dPath, 'file')
        dFiles = {dPath};
    else
        error(['ERROR FILEMISS : readInput : ' dPath ' does not exists!'])
    end
    
    % loop over files
    for ff=1:numel(dFiles)
        [pathstr,name,ext] = fileparts(dFiles{ff});
        
        switch ext
            case '.mat'
                load(dFiles{ff})
                for vv=1:numel(inVars)
                    % loop over variables
                    % check if data or uncertainty
                    if varFlag{vv} == 0
                        fn = 'data';
                    elseif varFlag{vv} == 1
                        fn = 'unc';
                    elseif varFlag{vv} == 2
                        fn = 'qflag';
                    end
                    
                    try
                        tarVar = inVars{vv};
                        srcVar = info.opti.constraints.variables.(tarVar).(fn).sourceVariableName;
                        % assign variable + do conversions etc. -> without eval?!
                        dataStructure.(tarVar).(fn) = eval(srcVar);
                        try
                            dataStructure.(tarVar).(fn) =  eval([ 'dataStructure.' tarVar '.' fn ' .'  info.opti.constraints.variables.(tarVar).(fn).source2sindbadUnit ';']);
                        catch
                            disp(['MISS: readObservation: Units of variable ' tarVar '.' fn ' not converted. Keeping the original values.']);
                        end
                    catch
                        disp(['MISS: readObservation: Variable ' tarVar '.' fn ' not found.']);
                    end
                    
                end
            case '.nc'
                for vv=1:numel(inVars)
                    % loop over variables
                    % check if data or uncertainty
                    if varFlag{vv} == 0
                        fn = 'data';
                    elseif varFlag{vv} == 1
                        fn = 'unc';
                    elseif varFlag{vv} == 2
                        fn = 'qflag';
                    end
                    
                    try
                        tarVar = inVars{vv};
                        srcVar = info.opti.constraints.variables.(tarVar).(fn).sourceVariableName;
                        dataStructure.(tarVar).(fn) = squeeze(ncread(dFiles{ff},srcVar))';
                        try
                            dataStructure.(tarVar).(fn) =  eval([ 'dataStructure.' tarVar '.' fn ' .'  info.opti.constraints.variables.(tarVar).(fn).source2sindbadUnit ';']);
                       catch
                            disp(['MISS: readObservation: Units of variable ' tarVar '.' fn ' not converted. Keeping the original values.']);
                        end
                    catch
                        disp(['MISS: readObservation: Variable ' tarVar '.' fn ' not found.']);
                    end
                end
                
            otherwise
                disp(['WARN FILEMISS : readObservation : format of ' dFiles{ff} ' is not supported!'])
        end
        
        % handle time?
        % handle space?
        
        
    end
    
end

end


