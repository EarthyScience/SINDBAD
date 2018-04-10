function fileinfo = nc_info ( ncfile )
%NC_INFO  Return information about a NetCDF file.
%   fileinfo = nc_info(ncfile) returns metadata about the netCDF file
%   ncfile.  fileinfo is a structure with four fields.
%
%       Filename  - a string containing the name of the file.
%       Format    - a string describing the file format.
%       Dimension - a struct array describing the netCDF dimensions.
%       Dataset   - a struct array describing the netCDF variables.
%       Attribute - a struct array describing the global attributes.
%
%   Each Dimension element is itself a struct containing the following
%   fields.
%       
%        Name      - A string containing the name of the dimension.
%        Length    - A scalar value, the size of this dimension
%        Unlimited - Set to 1 if the dimension is the record dimension, set 
%                    to 0 otherwise.
%
%   Each Dataset element is itself a struct containing the following
%   fields.
%
%        Name      - A string containing the name of the variable.
%        Nctype    - A number specifying the NetCDF datatype of this
%                    variable.
%        Dimension - A cell array with the names of the dimensions upon 
%                    which this variable depends.
%        Unlimited - Either 1 if the variable has an unlimited dimension
%                    or 0 if not.
%        Size      - Array that describes the size of each dimension upon 
%                    which this dataset depends.
%        Attribute - A struct array describing the variable attributes.
%                        
%    Each Attribute element is itself a struct and contains the following 
%    fields.
%
%        Name      - A string containing the name of the attribute.
%        Value     - Either a string or a double precision value 
%                    corresponding to the value of the attribute.
%
%   Example:  Retrieve the metadata in the example file that ships with
%   R2008b.
%       info = nc_info('example.nc');
%
%   See also nc_dump.



[backend,fmt] = snc_read_backend(ncfile);

switch(backend)
	case 'tmw'
		fileinfo = nc_info_tmw(ncfile);
    case 'tmw_hdf4'
        fileinfo = nc_info_tmw_hdf4(ncfile);
	case 'java'
		fileinfo = nc_info_java(ncfile);
	case 'mexnc'
		fileinfo = nc_info_mexnc(ncfile);
	otherwise
		error('SNCTOOLS:nc_info:unhandledBackend', ...
		      '%s is not a recognized backend.', backend );
end

fileinfo.Format = fmt;

return











%--------------------------------------------------------------------------
function fileinfo = nc_info_tmw_hdf4(hdf4file)

% Get the full path name.
fid = fopen(hdf4file,'r');
fullfile = fopen(fid);
fclose(fid);

[pathstr,name,ext] = fileparts(hdf4file); %#ok<ASGLU>
fileinfo.Filename = hdf4file; % [name ext];

sd_id = hdfsd('start',fullfile,'read');
if sd_id < 0
    error('SNCTOOLS:nc_info:hdf4:startFailed', ...
        'start failed on %s.\n', hdf4file);
end

[ndatasets,nglobal_attr,status] = hdfsd('fileinfo',sd_id);
if status < 0
    hdfsd('end',sd_id);
    error('SNCTOOLS:nc_info:hdf4:fileinfoFailed', ...
        'fileinfo failed on %s.\n', hdf4file);
end

dim_count = 0;
dataset_count = 0;
for idx = 0:ndatasets-1
    
    sds_id = hdfsd('select',sd_id,idx);
    if sds_id < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:nc_info:hdf4:selectFailed', ...
            'select failed on dataset with index %d\n', idx);
    end

	[sds_name,sds_rank,sds_dimsizes,dtype_wr,nattrs,status] = hdfsd('getinfo',sds_id); %#ok<ASGLU>
    if status < 0
        hdfsd('endaccess',sds_id);
        hdfsd('end',sd_id);
        error('SNCTOOLS:nc_info:hdf4:getinfoFailed', ...
            'getinfo failed on dataset with index %d\n', idx);
    end

	% Look at each dimension
	for dimidx = 0:sds_rank-1

        dimid = hdfsd('getdimid',sds_id,dimidx);
        if dimid < 0
            hdfsd('endaccess',sds_id);
            hdfsd('end',sd_id);
            error('SNCTOOLS:varput:hdf4:getdimidFailed', 'GETDIMID failed on %s.', varname);
        end
        [dname,dcount,ddatatype,dattrs,status] = hdfsd('diminfo',dimid); %#ok<ASGLU>
        if status < 0
            hdfsd('endaccess',sds_id);
            hdfsd('end',sd_id);
            error('SNCTOOLS:varput:hdf4:diminfoFailed', 'DIMINFO failed');
        end

		% Do we already have it?
		if (dim_count > 0) && any(strcmp(dname,{fileinfo.Dimension.Name}))
			continue;
		else
			dim_count = dim_count + 1;
			fileinfo.Dimension(dim_count).Name = dname;
			if isinf(dcount)
				fileinfo.Dimension(dim_count).Unlimited = true;
                if isinf(sds_dimsizes(dimidx+1))
                   fileinfo.Dimension(dim_count).Length = 0;
                else
                    fileinfo.Dimension(dim_count).Length = sds_dimsizes(dimidx+1);
                end
			else
				fileinfo.Dimension(dim_count).Unlimited = false;
				fileinfo.Dimension(dim_count).Length = dcount;
			end
		end

	end
    
	dataset_count = dataset_count + 1;
    fileinfo.Dataset(dataset_count) = nc_getvarinfo_hdf4(sd_id,sds_id);
    
    status = hdfsd('endaccess',sds_id);
    if status < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:nc_info:hdf4:endaccessFailed', ...
            'endaccess failed on dataset with index %d\n', idx);
    end
end

fileinfo.Attribute = get_hdf4_attributes(sd_id,nglobal_attr);

status = hdfsd('end',sd_id);
if status < 0
    error('SNCTOOLS:nc_info:hdf4:endFailed', ...
        'end failed on %s.\n', hdf4file);
end

%--------------------------------------------------------------------------

function fileinfo = nc_info_tmw ( ncfile )

[p,name,ext] = fileparts(ncfile); %#ok<ASGLU>
fileinfo.Filename = ncfile; %[name ext];

ncid=netcdf.open(ncfile, nc_nowrite_mode );
[ndims, nvars, ngatts] = netcdf.inq(ncid);


%
% Get the dimensions
if ndims == 0
	Dimension = struct ( [] );
else
	if ndims > 0
		Dimension(1)=nc_getdiminfo_tmw ( ncid, 0 );
	end
	Dimension = repmat ( Dimension, ndims,1 );
	for dimid = 1:ndims-1
		Dimension(dimid+1)=nc_getdiminfo_tmw ( ncid, dimid );
	end
end



%
% Get the global attributes.
if ngatts == 0
	fileinfo.Attribute = struct([]);
else
	if ngatts > 0
		Attribute(1) = nc_get_attribute_struct_tmw ( ncid, nc_global, 0 );
	end
	Attribute = repmat ( Attribute, ngatts, 1 );
	for attnum = 1:ngatts-1
		Attribute(attnum+1) = nc_get_attribute_struct_tmw ( ncid, nc_global, attnum );
	end
	fileinfo.Attribute = Attribute;
end





%
% Get the variable information.
if nvars == 0
	Dataset = struct([]);
else
	if ( nvars > 0 )
		Dataset(1) = nc_getvarinfo_tmw ( ncid, 0 );
	end
	Dataset = repmat ( Dataset, nvars, 1 );
	for varid=1:nvars-1
		Dataset(varid+1) = nc_getvarinfo_tmw ( ncid, varid );
	end
end

fileinfo.Dimension = Dimension;
fileinfo.Dataset = Dataset;


netcdf.close(ncid);


return








%--------------------------------------------------------------------------
function fileinfo = nc_info_mexnc ( ncfile )


fileinfo.Filename = ncfile;

[ncid, status]=mexnc('open', ncfile, nc_nowrite_mode );
if status ~= 0
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_INFO:MEXNC:OPEN', ncerr );
end



[ndims, nvars, ngatts, record_dimension, status] = mexnc('INQ', ncid); %#ok<ASGLU>
if status ~= 0
    ncerr = mexnc('strerror', status);
    mexnc('close',ncid);
    error ( 'SNCTOOLS:NC_INFO:MEXNC:INQ', ncerr );
end


%
% Get the dimensions
if ndims == 0
	Dimension = struct ( [] );
else
	if ndims > 0
		Dimension(1)=nc_getdiminfo_mexnc ( ncid, 0 );
	end
	Dimension = repmat ( Dimension, ndims,1 );
	for dimid = 1:ndims-1
		Dimension(dimid+1)=nc_getdiminfo_mexnc ( ncid, dimid );
	end
end



%
% Get the global attributes.
if ngatts == 0
	fileinfo.Attribute = struct([]);
else
	if ngatts > 0
		Attribute(1) = nc_get_attribute_struct ( ncid, nc_global, 0 );
	end
	Attribute = repmat ( Attribute, ngatts, 1 );
	for attnum = 1:ngatts-1
		Attribute(attnum+1) = nc_get_attribute_struct ( ncid, nc_global, attnum );
	end
	fileinfo.Attribute = Attribute;
end





%
% Get the variable information.
if nvars == 0
	Dataset = struct([]);
else
	if ( nvars > 0 )
		Dataset(1) = nc_getvarinfo_mexnc ( ncid, 0 );
	end
	Dataset = repmat ( Dataset, nvars, 1 );
	for varid=1:nvars-1
		Dataset(varid+1) = nc_getvarinfo_mexnc ( ncid, varid );
	end
end

fileinfo.Dimension = Dimension;
fileinfo.Dataset = Dataset;


mexnc('close',ncid);


return









