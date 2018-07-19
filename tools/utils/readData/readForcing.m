function [dataStructure] = readForcing(info)
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
%   - Tina Trautmann (ttraut@bgc-jena.mpg.de) 
% 
% References: 
%    
% 
% Versions: 
%   - 1.0 on 09.07.2018 

%%
dataStructure = struct;
allDataPaths  = cell(1); 
variables = fields(info.tem.forcing.variables);

% time stuff -> different for optimization?
xDay = info.tem.helpers.dates.day;
   
% get data paths
if ~isempty(info.tem.forcing.oneDataPath)
    dataPaths = {info.tem.forcing.oneDataPath};
    idxVar = ones(1, numel(variables));
else
    for vv = variables'
        allDataPaths =  [allDataPaths info.tem.forcing.variables.(vv{1}).dataPath];
    end
    allDataPaths = allDataPaths(2:end);
    [dataPaths, idxData, idxVar]  = unique(allDataPaths);
end


% loop over unique data paths
% not covered when all input in the same folder but in different files

for ii=1:numel(dataPaths)
    dPath   = dataPaths{ii};
    inVars  = variables(idxVar==ii);
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
                    try 
                        tarVar = inVars{vv};
                        srcVar = info.tem.forcing.variables.(tarVar).sourceVariableName;
                        % assign variable + do conversions etc. -> without eval?!
                        dataStructure.(tarVar) = eval(srcVar);
                        try
                            dataStructure.(tarVar) =  eval(['dataStructure.' tarVar ' .'  info.tem.forcing.variables.(tarVar).source2sindbadUnit ';']);
                        catch
                            disp(['MISS: readForcing: Units of forcing variable ' tarVar ' not converted. Keeping the original values.']);
                        end
                    catch
                        error(['MISS: readForcing: Variable ' tarVar ' not found.']);
                    end
                end
            case '.nc'
                 for vv=1:numel(inVars)
                    % loop over variables
                    try
                        tarVar = inVars{vv};
                        srcVar = info.tem.forcing.variables.(tarVar).sourceVariableName;
                        dataStructure.(tarVar) = ncread(dFiles{ff},srcVar)';
                        try
                           dataStructure.(tarVar) =  eval(['dataStructure.' tarVar ' .'  info.tem.forcing.variables.(tarVar).source2sindbadUnit ';']);
                        catch
                           disp(['MISS: readForcing: Units of forcing variable ' tarVar ' not converted. Keeping the original values.']);
                        end
                    catch
                        if tarVar == 'LAI'
                            dataStructure.(tarVar) = ones(1,length(xDay));
                            disp(['MISS: readForcing: Variable ' tarVar ' not found. Setting a constant value.']);
                        else
                        error(['MISS: readForcing: Variable ' tarVar ' not found.']);
                        end
                    end
                 end 
                 
            otherwise
                disp(['WARN FILEMISS : readForcing : format of ' dFiles{ff} ' is not supported!'])
        end
    
% handle time?
% handle space?


    end
    
end

dataStructure.Year                    = year(xDay);

end


