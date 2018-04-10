function values = nc_attget(ncfile, varname, attribute_name )
%NC_ATTGET  Get the values of a NetCDF attribute.
%
%   att_value = nc_attget(ncfile, varname, attribute_name) retrieves the
%   specified attribute from the variable given by varname in the file
%   specified by ncfile.  In order to retrieve a global attribute, either
%   specify -1 for varname or NC_GLOBAL.
%
%   The following examples require R2008b or higher for the example file.
%
%   Example:  retrieve a variable attribute.
%       values = nc_attget('example.nc','peaks','description');
%
%   Example:  retrieve a global attribute.
%       cdate = nc_attget('example.nc',nc_global,'creation_date');
%
%   See also nc_attput.


backend = snc_read_backend(ncfile);
switch(backend)
	case 'tmw'
		values = nc_attget_tmw(ncfile,varname,attribute_name);
    case 'tmw_hdf4'
        values = nc_attget_hdf4(ncfile,varname,attribute_name);
	case 'java'
		values = nc_attget_java(ncfile,varname,attribute_name);
	case 'mexnc'
		values = nc_attget_mexnc(ncfile,varname,attribute_name);
	otherwise
		error('SNCTOOLS:NC_ATTGET:unhandledBackend', ...
		      '%s is not a recognized backend for SNCTOOLS.', ...
			  backend);
end


return



%--------------------------------------------------------------------------
function data = nc_attget_hdf4(hfile,varname,attname)
sd_id = hdfsd('start',hfile,'read');
if sd_id < 0
    error('SNCTOOLS:attget:hdf4:start', 'START failed on %s.', hfile);
end

if isnumeric(varname);
    obj_id = sd_id;
else
    
    idx = hdfsd('nametoindex',sd_id,varname);
    if idx < 0
        error('SNCTOOLS:attget:hdf4:nametoindex', ...
            'NAMETOINDEX failed on %s, %s.', varname, hfile);
    end
    
    sds_id = hdfsd('select',sd_id,idx);
    if sds_id < 0
        error('SNCTOOLS:attget:hdf4:select', ...
            'SELECT failed on %s, %s.', varname, hfile);
    end
    
    obj_id = sds_id;
end

attr_idx = hdfsd('findattr',obj_id,attname);
if attr_idx < 0
    if ischar(varname)
        hdfsd('endaccess',sds_id);
    end
    hdfsd('end',sd_id);
    error('SNCTOOLS:attget:hdf4:findattr', ...
        'Attribute "%s" does not exist.', attname);
end

[data,status] = hdfsd('readattr',obj_id,attr_idx);
if status < 0
    if ischar(varname)
        hdfsd('endaccess',sds_id);
    end
    hdfsd('end',sd_id);
    error('SNCTOOLS:attget:hdf4:readattr', ...
        'READATTR failed on %s, %s, %s.', hfile, varname, attname);
end


if ischar(varname);
    status = hdfsd('endaccess',sds_id);
    if status < 0
        error('SNCTOOLS:attput:hdf4:endaccess', ...
            'ENDACCESS failed on %s.', varname);
    end
end

status = hdfsd('end', sd_id);
if status < 0
    error('SNCTOOLS:attget:hdf4:end', 'END failed on %s.', hfile);
end



%--------------------------------------------------------------------------
function values = nc_attget_mexnc(ncfile, varname, attribute_name )

[ncid, status] =mexnc('open', ncfile, nc_nowrite_mode );
if ( status ~= 0 )
    ncerror = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:OPEN', ncerror );
end

switch class(varname)
case { 'double' }
    varid = varname;

case 'char'
    varid = figure_out_varid ( ncid, varname );

otherwise
    error ( 'SNCTOOLS:NC_ATTGET:badType', 'Must specify either a variable name or NC_GLOBAL' );

end


funcstr = determine_funcstr(ncid,varid,attribute_name);

%
% And finally, retrieve the attribute.
[values, status]=mexnc(funcstr,ncid,varid,attribute_name);
if ( status ~= 0 )
    ncerror = mexnc ( 'strerror', status );
    err_id = ['SNCTOOLS:NC_ATTGET:MEXNC:' funcstr ];
    error ( err_id, ncerror );
end

status = mexnc('close',ncid);
if ( status ~= 0 )
    ncerror = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:CLOSE', ncerror );
end


return;











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function funcstr = determine_funcstr(ncid,varid,attribute_name)
% This function is for the mex-file backend.  Determine which netCDF function
% string we invoke to retrieve the attribute value.

[dt, status]=mexnc('inq_atttype',ncid,varid,attribute_name);
if ( status ~= 0 )
    mexnc('close',ncid);
    ncerror = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:INQ_ATTTYPE', ncerror );
end

switch ( dt )
case nc_double
    funcstr = 'GET_ATT_DOUBLE';
case nc_float
    funcstr = 'GET_ATT_FLOAT';
case nc_int
    funcstr = 'GET_ATT_INT';
case nc_short
    funcstr = 'GET_ATT_SHORT';
case nc_byte
    funcstr = 'GET_ATT_SCHAR';
case nc_char
    funcstr = 'GET_ATT_TEXT';
otherwise
    mexnc('close',ncid);
    error ( 'SNCTOOLS:NC_ATTGET:badDatatype', 'Unhandled datatype ID %d', dt );
end

return





%===============================================================================
%
% Did the user do something really stupid like say 'global' when they meant
% NC_GLOBAL?
function varid = figure_out_varid ( ncid, varname )

if isempty(varname)
    varid = nc_global;
    return;
end

if ( strcmpi(varname,'global') )
    [varid, status] = mexnc ( 'inq_varid', ncid, varname ); %#ok<ASGLU>
    if status 
        %
        % Ok, the user meant NC_GLOBAL
        warning ( 'SNCTOOLS:nc_attget:doNotUseGlobalString', ...
                  'Please consider using the m-file NC_GLOBAL.M instead of the string ''%s''.', varname );
        varid = nc_global;
        return;
    end
end

[varid, status] = mexnc ( 'inq_varid', ncid, varname );
if ( status ~= 0 )
    mexnc('close',ncid);
    ncerror = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:INQ_VARID', ncerror );
end

