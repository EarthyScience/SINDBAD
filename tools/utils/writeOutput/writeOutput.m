function [dum] = writeOutput(info,f,fe,fx,s,d,p)
% Writes the output of SINDBAD model run in different formats (.mat or .nc)
%
% Usages:
%   [dum] = writeOutput(info,f,fe,fx,s,d,p);
%
% Requires:
%   - the info: with the field info.tem.model.variables.to.write
%   (output.json)
%   - the sindbad fluxes and diagnostics (fx and d)
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
%   - date vector should be present in info for .nc outout
%       - should be same size as nTix as all the output variables will be the
%       same
%   - one file per variable
%   - one file per variable per year if runForwardYearly == 1
%   - can only write the variables with a maximum of 4 dimensions
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
%
% Versions:
%   - 1.0: 12.12.2018
%   - 1.1: 11.11.2019 (skoirala): handling of time, space, and .mat output


%%
%% Variables and output path
if isempty(info.tem.model.output.dataFormat)
    disp([pad('MODEL OUT',20,'left') ' : ' pad('writeOutput',20) ' | info.tem.model.output.dataFormat is empty. No output files will be written.'])
else
    var2write               =   info.tem.model.code.variables.to.write;
    pthSave                 =   info.experiment.modelOutputDirPath;
    if ~exist(pthSave,'dir')
        mkdirx(pthSave);
    end
    if strcmp(info.tem.model.output.dataFormat,'.nc')
            disp([pad('MODEL OUT',20,'left') ' : ' pad('writeOutput',20) ' | Writing SINDBAD output in netCDF(.nc) format'])
            writeNetCDF(var2write,pthSave,info,f,fe,fx,s,d,p)
    else
            disp([pad('MODEL OUT',20,'left') ' : ' pad('writeOutput',20) ' | Writing SINDBAD output in matlab (.mat) format'])
            writeMat(var2write,pthSave,info,f,fe,fx,s,d,p)
    end    
end
dum='';
end
%%function to write the mat data
function writeMat(var2write,pthSave,info,f,fe,fx,s,d,p)
% write one file per variable per year in .mat format
%%
    for varn                =   1:numel(var2write)
        var                 =   var2write{varn};
        varNameSplit        =   strsplit(var,'.');
        varName             =   varNameSplit{end};
        if info.tem.model.flags.runForwardYearly
            filename        =   [pthSave '/' info.experiment.name '_' info.experiment.domain '_' varName '_' num2str(info.tem.model.time.runYear) '.mat'];
        else
            filename        =   [pthSave '/' info.experiment.name '_' info.experiment.domain '_' varName '.mat'];
        end
        if exist(filename,'file')
            delete(filename);
        end
        eval([varName '=' var ';'])
        crStr= ['save(''' filename ''',' '''' varName '''' ',' '''-v7.3''' ');'];        
        eval(crStr)        
    end
end

%%function to write the netcdf data
function writeNetCDF(var2write,pthSave,info,f,fe,fx,s,d,p)
    % if all output are written in one file for all years of simulation
    %     varsInput                   =   datinfo.Variables; %information of variables in reference input file
    %% --> loop through the list of variables
    if isfield(info.tem.helpers.dimension,'space')
        if isfield(info.tem.helpers.dimension.space,'latVec') && isfield(info.tem.helpers.dimension.space,'lonVec')
            useLatLon               =   true;
        else
            useLatLon               =   false;
        end
    end
    
    for varn                    =   1:numel(var2write)
        varSel                  =   var2write{varn};
        varNameSplit            =   strsplit(varSel,'.');
        varName                 =   varNameSplit{end};
        %--> create filename: add year in the filename if the model is run
        % forward with forcing per year
        if info.tem.model.flags.runForwardYearly
            filename=[pthSave '/' info.experiment.name '_' info.experiment.domain '_' varName '_' num2str(info.tem.model.time.runYear) info.tem.model.output.dataFormat];
        else
            filename=[pthSave '/' info.experiment.name '_' info.experiment.domain '_' varName info.tem.model.output.dataFormat];
        end
        if exist(filename,'file')
            delete(filename);
        end
        eval(['datMain=' varSel ';'])
        if ndims(datMain)       <  5
            %--> open the netCDF file for writing
            ncid = netcdf.create(filename,'NC_WRITE');
            %--> define the common dimensions for arrays of all sizes
            dimidpix        =   netcdf.defDim(ncid,'pix',info.tem.helpers.sizes.nPix);
            pix_ID          =   netcdf.defVar(ncid,'pix','float',[dimidpix]);
            if useLatLon

                lat_ID      =   netcdf.defVar(ncid,'latitude','float',[dimidpix]);
                lon_ID      =   netcdf.defVar(ncid,'longitude','float',[dimidpix]);
            end
            
            dimidtime       =   netcdf.defDim(ncid,'time',info.tem.helpers.sizes.nTix);
            time_ID         =   netcdf.defVar(ncid,'time','float',[dimidtime]);
            netcdf.putAtt(ncid,time_ID,'long_name','time axis');
            netcdf.putAtt(ncid,time_ID,'units','days since 0000-01-01');
            
            %--> define and add arrays of different sizes
            
            if ndims(datMain)   ==  2
                var_ID          =   netcdf.defVar(ncid,varName,'float',[dimidpix dimidtime]);
                netcdf.endDef(ncid);
                netcdf.putVar(ncid,var_ID,datMain);
            end
            if ndims(datMain)   ==  3
                dimidlevel      =   netcdf.defDim(ncid,'level',size(datMain,2));
                level_ID        =   netcdf.defVar(ncid,'level','float',[dimidlevel]);
                var_ID          =   netcdf.defVar(ncid,varName,'float',[dimidpix dimidlevel dimidtime]);
                netcdf.endDef(ncid);
                netcdf.putVar(ncid,level_ID,1:1:size(datMain,2));
                netcdf.putVar(ncid,var_ID,datMain);
            end
            if ndims(datMain)   == 4
                dimidlevel1     =   netcdf.defDim(ncid,'level1',size(datMain,2));
                dimidlevel2     =   netcdf.defDim(ncid,'level2',size(datMain,3));
                level1_ID       =   netcdf.defVar(ncid,'level1','float',[dimidlevel1]);
                level2_ID       =   netcdf.defVar(ncid,'level2','float',[dimidlevel2]);
                var_ID          =   netcdf.defVar(ncid,varName,'float',[dimidpix dimidlevel1 dimidlevel2 dimidtime]);
                
                netcdf.endDef(ncid);
                netcdf.putVar(ncid,level1_ID,1:1:size(datMain,2));
                netcdf.putVar(ncid,level2_ID,1:1:size(datMain,3));
                netcdf.putVar(ncid,var_ID,datMain);
            end
            
            %% write the variables/values of the dimensions
            if useLatLon
                netcdf.putVar(ncid,lat_ID,info.tem.helpers.dimension.space.latVec);
                netcdf.putVar(ncid,lon_ID,info.tem.helpers.dimension.space.lonVec);
            end
            netcdf.putVar(ncid,pix_ID,1:1:info.tem.helpers.sizes.nPix);
            netcdf.putVar(ncid,time_ID,datenum(info.tem.helpers.dates.day));
            netcdf.close(ncid)
            disp([pad('MODEL OUT',20,'left') ' : ' pad('writeOutput',20) ' | Wrote ' varSel ' to ' filename])

        else
            disp([pad('CRIT MODEL OUT',20,'left') ' : ' pad('writeOutput',20) ' | ' varName ' is ' numstr(ndims(datMain)) '-dimensional. Writing netCDF outputput is only supported until 4-dimensional data. Skipping the variable'])
        end
        
    end
end