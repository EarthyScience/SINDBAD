function nc_addvar(ncfile,varstruct)
%NC_ADDVAR:  add variable to NetCDF or HDF4 file.
%
%   nc_addvar(FILE,VARSTRUCT) adds a variable described by varstruct to a 
%   netcdf or HDF4 file.  VARSTRUCT is a structure with the following
%   fields:
%
%      Name       - name of netcdf variable.
%      Datatype   - datatype of the variable.  This should be one of
%                   'double', 'float', 'int', 'short', or 'byte', or
%                   'char'. If omitted, this defaults to 'double'.
%      Dimension  - a cell array of dimension names.
%      Attribute  - a structure array.  Each element has two fields, 'Name'
%                   and 'Value'.
%      Chunking   - defines the chunk size.  This can only be used with 
%                   netcdf-4 files.  The default value is [], which
%                   specifies no chunking.
%      Shuffle    - if non-zero, the shuffle filter is turned on.  The
%                   default value is off.  This can only be used with
%                   netcdf-4 files.
%      Deflate    - specifies the deflate level and should be between 0 and
%                   9.  Defaults to 0, which turns the deflate filter off.
%                   This can only be used with netcdf-4 files.
%
%   Note that if FILE is an HDF4 file, and if you wish to create a
%   coordinate variable, then NC_ADDDIM has already done this for you.
%
%   Example:  create a variable called 'earth' that depends upon two 
%   dimensions, 'lat' and 'lon'.
%      nc_create_empty('myfile.nc');
%      nc_adddim('myfile.nc','lon',361);
%      nc_adddim('myfile.nc','lat',181);
%      varstruct.Name = 'earth';
%      varstruct.Datatype = 'double';
%      varstruct.Dimension = { 'lat','lon' };
%      nc_addvar('myfile.nc',varstruct);
%
%   Example:  create an HDF file with a dataset called 'earth' that depends
%   upon two dimensions, 'lat' and 'lon'.  Recall that the HDF form creates
%   coordinate variables when defining dimensions.
%      nc_create_empty('myfile.hdf','hdf4');
%      nc_adddim('myfile.hdf','lon',361);
%      nc_adddim('myfile.hdf','lat',181);
%      v.Name = 'earth';
%      v.Datatype = 'double';
%      v.Dimension = { 'lat','lon' };
%      nc_addvar('myfile.hdf',v);
%
%   See also nc_adddim.



if  ~ischar(ncfile) 
    error ( 'SNCTOOLS:NC_ADDVAR:badInput', 'file argument must be character' );
end

if ( ~isstruct(varstruct) )
    error ( 'SNCTOOLS:NC_ADDVAR:badInput', '2nd argument must be a structure' );
end


varstruct = validate_varstruct ( varstruct );


backend = snc_write_backend(ncfile);
switch ( backend )
	case 'mexnc'
		nc_addvar_mexnc(ncfile,varstruct);
	case 'tmw_hdf4'
		nc_addvar_hdf4(ncfile,varstruct);
	otherwise
		nc_addvar_tmw(ncfile,varstruct);
end

% Now just use nc_attput to put in the attributes
for j = 1:length(varstruct.Attribute)
    attname = varstruct.Attribute(j).Name;
    attval = varstruct.Attribute(j).Value;
    nc_attput ( ncfile, varstruct.Name, attname, attval );
end




%--------------------------------------------------------------------------
function nc_addvar_hdf4(hfile,varstruct)

sd_id = hdfsd('start',hfile,'write');
if sd_id < 0
    error('SNCTOOLS:addVar:hdf4:startFailed', ...
        'START failed on %s.\n', hfile);
end

% determine the lengths of the named dimensions
num_dims = length(varstruct.Dimension);
dim_sizes = zeros(1,num_dims);
dimids = zeros(1,num_dims);
dim_names = varstruct.Dimension;

% have to reverse the order of the dimensions if we want to preserve the
% fastest varying dimension and keep it consistent.
if getpref('SNCTOOLS','PRESERVE_FVD',false)
	dim_names = fliplr(dim_names);
end

for j = 1:num_dims
	
	idx = hdfsd('nametoindex',sd_id,dim_names{j});
    if idx < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:addVar:hdf4:nametoindexFailed', ...
            'NAMETOINDEX failed on %s, \"%s\".\n', dim_names{j}, hfile);
    end

	dim_sds_id = hdfsd('select',sd_id,idx);
    if dim_sds_id < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:addVar:hdf4:selectFailed', ...
            'SELECT failed on %s, \"%s\".\n', dim_names{j}, hfile);
    end

    dimids(j) = j-1;
	[name,rank,dim_sizes(j),dtype,nattrs,status] = hdfsd('getinfo',dim_sds_id); %#ok<ASGLU>
    if status < 0
        hdfsd('endaccess',dim_sds_id);
        hdfsd('end',sd_id);
        error('SNCTOOLS:addVar:hdf4:getinfoFailed', ...
            'GETINFO failed on %s, \"%s\".\n', dim_names{j}, hfile);
    end

    status = hdfsd('endaccess',dim_sds_id);
    if status < 0
        error('SNCTOOLS:addVar:hdf4:endaccessFailed', ...
            'ENDACCESS failed on %s, \"%s\".\n', dim_names{j}, hfile);
    end

end




sds_id = hdfsd('create',sd_id,varstruct.Name,varstruct.Datatype,num_dims,dim_sizes);
if sds_id < 0
    hdfsd('end',sd_id);
    error('SNCTOOLS:addVar:hdf4:createFailed', ...
        'CREATE failed on %s, \"%s\".\n', varstruct.Name, hfile);
end

% Attach the named dimensions to the dataset.
for j = 1:num_dims
    dimid = hdfsd('getdimid',sds_id,dimids(j));
    if dimid < 0
        hdfsd('endaccess',sds_id);
        hdfsd('end',sd_id);
        error('SNCTOOLS:addVar:getdimidFailed', ...
            'GETDIMID failed.');
            
    end
    
    status = hdfsd('setdimname',dimid,dim_names{j});
    if status < 0
        hdfsd('endaccess',sds_id);
        hdfsd('end',sd_id);
        error('SNCTOOLS:addVar:hdf4:setdimFailed', ...
            'SETDIM failed on %s, \"%s\".\n', varstruct.Name, hfile);
    end
end



status = hdfsd('endaccess',sds_id);
if status < 0
    error('SNCTOOLS:addVar:hdf4:endaccessFailed', ...
        'ENDACCESS failed on %s, \"%s\".\n', varstruct.Name, hfile);
end

status = hdfsd('end',sd_id);
if status < 0
    error('SNCTOOLS:addVar:hdf4:endFailed', ...
        'END failed on %s, \"%s\".\n', hfile);
end
return








%--------------------------------------------------------------------------
function nc_addvar_tmw(ncfile,varstruct)

ncid = netcdf.open(ncfile, nc_write_mode );

%
% determine the dimids of the named dimensions
num_dims = length(varstruct.Dimension);
dimids = zeros(1,num_dims);
for j = 1:num_dims
    dimids(1,j) = netcdf.inqDimID(ncid, varstruct.Dimension{j} );
end

% If we are old school, we need to flip the dimensions.
if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
    dimids = fliplr(dimids);
end

%
% go into define mode
netcdf.reDef(ncid);

% Prefer to use Datatype instead of Nctype.
if isfield(varstruct,'Datatype')
    netcdf.defVar(ncid, varstruct.Name, varstruct.Datatype, dimids );
else 
    % Backwards compatible mode.
    netcdf.defVar(ncid, varstruct.Name, varstruct.Nctype, dimids );
end


netcdf.endDef(ncid );
netcdf.close(ncid );







    
%--------------------------------------------------------------------------
function nc_addvar_mexnc(ncfile,varstruct)

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 )
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:OPEN', ...
        'OPEN failed on %s, ''%s''', ncfile, ncerr);
end

%
% determine the dimids of the named dimensions
num_dims = length(varstruct.Dimension);
dimids = zeros(num_dims,1);
for j = 1:num_dims
    [dimids(j), status] = mexnc ( 'dimid', ncid, varstruct.Dimension{j} );
    if ( status ~= 0 )
        mexnc ( 'close', ncid );
        ncerr = mexnc ( 'strerror', status );
        error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:DIMID', ncerr );
    end
end

% If preserving the fastest varying dimension in mexnc, we have to 
% reverse their order.
if getpref('SNCTOOLS','PRESERVE_FVD',false)
	dimids = flipud(dimids);
end


status = mexnc ( 'redef', ncid );
if ( status ~= 0 )
    ncerr = mexnc ( 'strerror', status );
    mexnc ( 'close', ncid );
    error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:REDEF', ncerr );
end

% We prefer to use 'Datatype' instead of 'Nctype', but we'll try to be 
% backwards compatible.
if isfield(varstruct,'Datatype')
    [varid, status] = mexnc ( 'DEF_VAR', ncid, varstruct.Name, ...
        varstruct.Datatype, num_dims, dimids );
else
    [varid, status] = mexnc ( 'DEF_VAR', ncid, varstruct.Name, ...
        varstruct.Nctype, num_dims, dimids );
end
if ( status ~= 0 )
    ncerr = mexnc ( 'strerror', status );
    mexnc ( 'endef', ncid );
    mexnc ( 'close', ncid );
    error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:DEF_VAR', ncerr );
end

if ~isempty(varstruct.Chunking)

	if getpref('SNCTOOLS','PRESERVE_FVD',false)
		chunking = fliplr(varstruct.Chunking);
	else
		chunking = varstruct.Chunking;
	end
	if ( numel(chunking) ~= num_dims) 
    	mexnc ( 'endef', ncid );
	    mexnc ( 'close', ncid );
	    error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:defVarChunking', ...
		   'Chunking size does not jive with number of dimensions.');
	end

	status = mexnc('DEF_VAR_CHUNKING',ncid,varid,'chunked',chunking);
	if ( status ~= 0 )
	    ncerr = mexnc ( 'strerror', status );
		mexnc ( 'endef', ncid );
	    mexnc ( 'close', ncid );
		error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:DEF_VAR_CHUNKING', ncerr );
	end
end

if (varstruct.Shuffle || varstruct.Deflate)

    status = mexnc('DEF_VAR_DEFLATE',ncid,varid, varstruct.Shuffle,varstruct.Deflate,varstruct.Deflate);
    if ( status ~= 0 )
        ncerr = mexnc ( 'strerror', status );
    	mexnc ( 'endef', ncid );
        mexnc ( 'close', ncid );
    	error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:DEF_VAR_DEFLATE', ncerr );
    end
end

status = mexnc ( 'enddef', ncid );
if ( status ~= 0 )
    ncerr = mexnc ( 'strerror', status );
    mexnc ( 'close', ncid );
    error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:ENDDEF', ncerr );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 )
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ADDVAR:MEXNC:CLOSE', ncerr );
end





return




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varstruct = validate_varstruct ( varstruct )

%
% Check that required fields are there.
% Must at least have a name.
if ~isfield ( varstruct, 'Name' )
    error ( 'SNCTOOLS:NC_ADDVAR:badInput', ...
	        'structure argument must have at least the ''Name'' field.' );
end

%
% Check that required fields are there.
% Default datatype is double
if ~isfield(varstruct,'Datatype')
    if ~isfield ( varstruct, 'Nctype' )
        varstruct.Datatype = 'double';
    else
        varstruct.Datatype = varstruct.Nctype;
    end

end

%
% Are there any unrecognized fields?
fnames = fieldnames ( varstruct );
for j = 1:length(fnames)
    fname = fnames{j};
    switch ( fname )

    case { 'Datatype', 'Nctype', 'Name', 'Dimension', 'Attribute', ...
            'Storage', 'Chunking', 'Shuffle', 'Deflate', 'DeflateLevel' }

        %
        % These are used to create the variable.  They are ok.
        
    case { 'Unlimited', 'Size', 'Rank' }
        %
        % These come from the output of nc_getvarinfo.  We don't 
        % use them, but let's not give the user a warning about
        % them either.

    otherwise
        warning('SNCTOOLS:nc_addvar:unrecognizedFieldName', ...
            '%s:  unrecognized field name ''%s''.  Ignoring it...\n', mfilename, fname );
    end
end


% If the datatype is not a string.
% Change suggested by Brian Powell
if ( isa(varstruct.Datatype, 'double') && varstruct.Datatype < 7 )
    types={ 'byte' 'char' 'short' 'int' 'float' 'double'};
    varstruct.Datatype = char(types(varstruct.Datatype));
end


%
% Check that the datatype is known.
switch ( varstruct.Datatype )
    case { 'NC_DOUBLE', 'double', ...
            'NC_FLOAT', 'float', ...
            'NC_INT', 'int',  ...
            'NC_SHORT', 'short', ...
            'NC_BYTE', 'byte', ...
            'NC_CHAR', 'char'  }
        % Do nothing
    case 'single'
        varstruct.Datatype = 'float';
    case 'int32'
        varstruct.Datatype = 'int';
    case 'int16'
        varstruct.Datatype = 'short';
    case { 'int8','uint8' }
        varstruct.Datatype = 'byte';
        
    otherwise
        error ( 'SNCTOOLS:NC_ADDVAR:unknownDatatype', 'unknown type ''%s''\n', mfilename, varstruct.Datatype );
end


%
% Check that required fields are there.
% Default Dimension is none.  Singleton scalar.
if ~isfield ( varstruct, 'Dimension' )
    varstruct.Dimension = [];
end

%
% Check that required fields are there.
% Default Attributes are none
if ~isfield ( varstruct, 'Attribute' )
    varstruct.Attribute = [];
end

if ~isfield(varstruct,'Storage')
    varstruct.Storage = 'contiguous';
end

if ~isfield(varstruct,'Chunking')
    varstruct.Chunking = [];
end

if ~isfield(varstruct,'Shuffle')
    varstruct.Shuffle = 0;
end

if ~isfield(varstruct,'Deflate')
    varstruct.Deflate = 0;
end

if ~isfield(varstruct,'DeflateLevel')
    varstruct.DeflateLevel = 0;
end

