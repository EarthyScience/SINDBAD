function [dataStructure,info] = readForcing(info)
% reads the forcing data (.mat or .nc) from dataPath
%
% Usages:
%   [outStructure] = readForcing(info);
%   [f]      = readForcing(info);
%
% Requires:
%   - the info: with the field info.tem.forcing
%
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
%   - Tina Trautmann (ttraut)
%
% References:
%
%
% Versions:
%   - 1.0 on 09.07.2018
%   - 1.1: 12.12.2018: sujan: added info as output to get the lat/lon from
%   input into info.tem.model.space.latVec and lonVec
%   - 1.2: 12.11.2019: sujan: handling of dimensions to be used in netCDF
%   output (info.tem.model.
%   input into info.tem.model.space.latVec and lonVec

%%

dataStructure                       =    struct;
allDataPaths                        =   cell(1);
variables                           =   fields(info.tem.forcing.variables);

% time stuff -> different for optimization?
xDay                                =   info.tem.helpers.dates.day;

% get data paths
if ~isempty(info.tem.forcing.oneDataPath)
    dataPaths                       =   {info.tem.forcing.oneDataPath};
    idxVar                          =    ones(1, numel(variables));
else
    for vv                          =   variables'
        if info.tem.model.flags.runForwardYearly
            fileEnd                 =   [num2str(info.tem.model.time.runYear) info.tem.forcing.variables.(vv{1}).dataFormat];
        else
            fileEnd                 =   '';
        end
        dataPathFull                =   [info.tem.forcing.variables.(vv{1}).dataPath fileEnd];
        allDataPaths                =   [allDataPaths dataPathFull];
    end
    allDataPaths                    =   allDataPaths(2:end);
    [dataPaths, idxData, idxVar]    =   unique(allDataPaths);
end


% loop over unique data paths
% not covered when all input in the same folder but in different files

for ii                              =   1:numel(dataPaths)
    dPath                           =   dataPaths{ii};
    inVars                          =   variables(idxVar==ii);
    % is data path a folder or file?
    if exist(dPath, 'dir')
        dContent                    =    dir(dPath);
        dFiles                      =    {dContent(~[dContent.isdir]).name};
        dFiles                      =    strcat(dPath,dFiles);
    elseif exist(dPath, 'file')
        dFiles                      =    {dPath};
    else
        error([pad('CRIT FILEMISS',20,'left') ' : ' pad('readForcing',20) ' | ' dPath ' does not exist'])
    end
    
    % loop over files
    for ff=1:numel(dFiles)
        [pathstr,name,ext]          =    fileparts(dFiles{ff});
        
        switch ext
            case '.mat'
                dataMat             =    load(dFiles{ff});
                for vv              =   1:numel(inVars)
                    % loop over variables
                    try
                        tarVar      =    inVars{vv};
                        srcVar      =    info.tem.forcing.variables.(tarVar).sourceVariableName;
                        % assign variable + do conversions etc. -> without eval?!
                        dataStructure.(tarVar)          =    dataMat.(srcVar);
                        try
                            dataStructure.(tarVar)      =    eval(['dataStructure.' tarVar ' .'  info.tem.forcing.variables.(tarVar).source2sindbadUnit ';']);
                        catch
                            disp([pad('WARN DATAMISS',20,'left') ' : ' pad('readForcing',20) ' | Units of forcing variable ' tarVar ' not converted. Keeping the original values'])
                        end
                    catch
                        error([pad('CRIT DATAMISS',20,'left') ' : ' pad('readForcing',20) ' | Variable ' tarVar ' not found in ' dFiles{ff}])
                    end
                end
                % add lat and lon if available in the mat file (changed by
                % sujan on 12.11.2019
                if ~isfield(info.tem.helpers,'dimension')
                    varList              =  fieldnames(dataMat);
                    [latVar,lonVar]      =  getLatLonVar(info, varList);
                    if ~isempty(latVar) && ~isempty(lonVar)
                        info.tem.helpers.dimension.space.latVec     =   dataMat.(latVar);
                        info.tem.helpers.dimension.space.lonVec     =   dataMat.(lonVar);
                        info.tem.helpers.dimension.space.reso       =   nanmean(diff(info.tem.helpers.dimension.space.latVec));
                    else
                        disp([pad('WARN DATAMISS',20,'left') ' : ' pad('readForcing',20) ' | Spatial information is not found in input mat structure.'])                        
                    end
                end
                
                %  TINA: add dates.day (should exist in the spinup forcing!)
                try
                    dataStructure.dates                 =    dataMat.dates;
                catch
                    disp([pad('WARN DATAMISS',20,'left') ' : ' pad('readForcing',20) ' | Time information (dates.day) missing in input data. May cause problems with spinup.'])
                end
                
            case '.nc'
                for vv=1:numel(inVars)
                    % loop over variables
                    try
                        tarVar                          =    inVars{vv};
                        srcVar                          =    info.tem.forcing.variables.(tarVar).sourceVariableName;
                        %                         info.tem.helpers.dimension.time.timeVec     =   ncread(dFiles{ff},'time');
                        dataStructure.(tarVar)          =    squeeze(ncread(dFiles{ff},srcVar))';
                        try
                            dataStructure.(tarVar)      =  eval(['dataStructure.' tarVar ' .'  info.tem.forcing.variables.(tarVar).source2sindbadUnit ';']);
                        catch
                            disp([pad('WARN DATAMISS',20,'left') ' : ' pad('readForcing',20) ' | Units of forcing variable ' tarVar ' not converted. Keeping the original values'])
                        end
                    catch
                        error([pad('CRIT DATAMISS',20,'left') ' : ' pad('readForcing',20) ' | Variable ' tarVar ' not found in ' dFiles{ff}])
                    end
                end
                if ~isfield(info.tem.helpers,'dimension')
                    fileInfo             =  ncinfo(dFiles{ff});
                    varList              =  {fileInfo.Variables(:).Name};
                    [latVar,lonVar]      =  getLatLonVar(info, varList);
                    if ~isempty(latVar) && ~isempty(lonVar)
                        info.tem.helpers.dimension.space.latVec     =   ncread(dFiles{ff},latVar);
                        info.tem.helpers.dimension.space.lonVec     =   ncread(dFiles{ff},lonVar);
                        info.tem.helpers.dimension.space.reso       =   nanmean(diff(info.tem.helpers.dimension.space.latVec));
                    else
                        disp([pad('WARN DATAMISS',20,'left') ' : ' pad('readForcing',20) ' | Spatial information is not found in input netCDF data'])                        
                    end
                end
                
            otherwise
                error([pad('CRIT DATA',20,'left') ' : ' pad('readForcing',20) ' | format of ' dFiles{ff} ' is not supported. Provide data in .nc or .mat formats'])
        end
    end
    
end

dataStructure.Year                                      =    year(xDay);
    
end

function [latVar,lonVar] = getLatLonVar(info,varList)
    % a function to return the name of latitude and longitude variables in
    % the input files based on common variants hard-coded below
    latList              =  {'lati','lat','latitude','LATI','LAT','LATITUDE','Latitude'};
    lonList              =  {'longi','lon','longitude','LONGI','LON','LONGITUDE','Longitude'};
    latVar               =  '';
    lonVar               =  '';
    for vn = 1:numel(varList)
        varNameL = varList{vn};
        if startsWith(varNameL,'L') || startsWith(varNameL,'l')
            if ismember(varNameL,latList)
                latVar     =   varNameL;
            end
            if ismember(varNameL,lonList)
                lonVar     =   varNameL;
            end
        end
    end
end
