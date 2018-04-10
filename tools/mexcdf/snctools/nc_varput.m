function nc_varput(ncfile,varname,data,varargin )
%NC_VARPUT:  Writes data into a netCDF file.
%
%   NC_VARPUT(NCFILE,VARNAME,DATA) writes the matlab variable DATA to
%   the variable VARNAME in the netCDF file NCFILE.  The main requirement
%   here is that DATA have the same dimensions as the netCDF variable.
% 
%   NC_VARPUT(NCFILE,VARNAME,DATA,START,COUNT) writes DATA contiguously, 
%   starting at the zero-based index START and with extents given by
%   COUNT.
%
%   NC_VARPUT(NCFILE,VARNAME,DATA,START,COUNT,STRIDE) writes DATA  
%   starting at the zero-based index START with extents given by
%   COUNT, but this time with strides given by STRIDE.  If STRIDE is not
%   given, then it is assumes that all data is contiguous.
%
%   Setting the preference 'PRESERVE_FVD' to true will compel MATLAB to 
%   display the dimensions in the opposite order from what the C utility 
%   ncdump displays.  Writing large data becomes much more efficient in
%   this case.
% 
%   Example:
%       nc_create_empty('myfile.nc');
%       nc_adddim('myfile.nc','longitude',360);
%       varstruct.Name = 'longitude';
%       varstruct.Nctype = 'double';
%       varstruct.Dimension = { 'longitude' };
%       nc_addvar('myfile.nc',varstruct);
%       nc_varput('myfile.nc','longitude',[-180:179]');
%
%   Example:  write only two values to 'longitude'.
%       data = [0 1]';
%       start = 180;
%       count = 2;
%       nc_varput('myfile.nc','longitude',data,start,count);
%
%   See also nc_varget, nc_create_empty, nc_adddim, nc_addvar.



[start, count, stride] = parse_and_validate_args(ncfile,varname,varargin{:});

%% for vectors make row/columnwise irrelevent
if isvector(data)
    vinfo = nc_getvarinfo(ncfile,varname);
    if numel(vinfo.Size) == 1
        data = reshape(data,[numel(data) 1]);
    end
end

%% write
backend = snc_write_backend(ncfile);
switch(backend)
	case 'tmw'
		nc_varput_tmw(ncfile,varname,data,start,count,stride);
	case 'tmw_hdf4'
		nc_varput_hdf4(ncfile,varname,data,start,count,stride);
	case 'mexnc'
		nc_varput_mexnc(ncfile,varname,data,start,count,stride);
end

return





%-----------------------------------------------------------------------
function nc_varput_hdf4(hfile,varname,data,start,edges,stride)

sd_id = hdfsd('start',hfile,'write');
if sd_id < 0
    error('SNCTOOLS:varput:hdf4:startFailed', ...
        'START failed on %s.', hfile);
end

idx = hdfsd('nametoindex',sd_id,varname);
if idx < 0
    hdfsd('end',sd_id);
    error('SNCTOOLS:varput:hdf4:nametoindexFailed', ...
        'Unable to index %s.', varname);
end

sds_id = hdfsd('select',sd_id, idx);
if sds_id < 0
    hdfsd('end',sd_id);
    error('SNCTOOLS:varput:hdf4:selectFailed', ...
        'SELECT failed on %s.', varname);
end

[sds_name,sds_rank,sds_dimsizes,dtype_wr,nattrs,status] = hdfsd('getinfo',sds_id); %#ok<ASGLU>
if status < 0
    hdfsd('endaccess',sds_id);
    hdfsd('end',sd_id);
    error('SNCTOOLS:varput:hdf4:getinfoFailed', ...
        'GETINFO failed on %s.', varname);
end




% 


%
% calibrate the data so as not to lose precision
[cal,cal_err,offset,offset_err,data_type,status] = hdfsd('getcal',sds_id); %#ok<ASGLU>
if ( status ~= -1 )
    if getpref('SNCTOOLS','USE_STD_HDF4_SCALING',false);
        data = double(data)/cal + offset; 
    else
        % Use standard CF convention scaling.
        data = (double(data) - offset)/cal;
    end
end	

%
% Locate any NaNs.  If any exist, set them to the FillValue
nan_inds = find ( isnan(data) );
if ( ~isempty(nan_inds) )
    [fill_value,status] = hdfsd('getfillvalue',sds_id);
    if status < 0
        
        % Is missing value defined?
        attr_idx = hdfsd('findattr',sds_id,'missing_value');
        if ( attr_idx < 0 )
            hdfsd ( 'endaccess', sds_id );
            hdfsd ( 'end', sd_id );
    	    error('SNCTOOLS:varput:hdf4:getfillvalueFailed', ...  
		    	'The data has NaN values, but neither _FillValue nor missing_value is defined.');
        else
            [fill_value,status] = hdfsd('readattr',sds_id,attr_idx);
            if (status < 0)
                hdfsd ( 'endaccess', sds_id );
                hdfsd ( 'end', sd_id );
                error('SNCTOOLS:varput:hdf4:readattrFailed', ...
                    'READATTR failed on missing_value.');
            end
        end

    end
    data(nan_inds) = double(fill_value) * ones(size(nan_inds));
end


%
% convert to the proper data type
switch ( dtype_wr )
    case 'uint8',
        data_wr = uint8(data);

    case 'int8',
        data_wr = int8(data);

    case 'uint16',
        data_wr = uint16(data);

    case 'int16',
        data_wr = int16(data);

    case 'uint32',
        data_wr = uint32(data);

    case 'int32',
        data_wr = int32(data);

    case 'float',
        data_wr = single(data);

    case 'float32',
        data_wr = single(data);

    case 'single',
        data_wr = single(data);

    case 'float64',
        data_wr = double(data);

    case 'double',
        data_wr = double(data);

    otherwise,
        hdfsd ( 'endaccess', sds_id );
        hdfsd ( 'end', sd_id );
    	error('SNCTOOLS:varput:hdf4:unhandledDatatype', ...  
			'Unhandled datatype.' );

end


if isempty(start)
    start = zeros(1,sds_rank);
    edges = ones(1,sds_rank);
    for j = 1:sds_rank
        edges(j) = size(data_wr,j);
    end
    stride = ones(1,sds_rank);
end

% attempt to write the data set.  
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    start = fliplr(start);
    edges = fliplr(edges);
    stride = fliplr(stride);
else
    % Need to permute it first.
    data_wr = permute ( data_wr, fliplr( 1:length(size(data_wr)) ) );
end

try
	status = hdfsd('writedata',sds_id, start, stride, edges, data_wr);
	if status < 0
	    hdfsd ( 'endaccess', sds_id );
	    hdfsd ( 'end', sd_id );
	    error('SNCTOOLS:varput:hdf4:writedataFailed', ...
	        'WRITEDATA failed on %s.\n', varname);
	end
catch %#ok<CTCH>
    hdfsd ( 'endaccess', sds_id );
    hdfsd ( 'end', sd_id );
    error('SNCTOOLS:varput:hdf4:writedataFailed', ...
	      'Encountered an error when writing to %s.', varname);
end


status = hdfsd('endaccess',sds_id);
if status < 0
    hdfsd('end',sd_id);
    error('SNCTOOLS:varput:hdf4:endaccessFailed', ...
    'ENDACCESS failed on %s.\n', hfile);
end
status = hdfsd('end',sd_id);
if status < 0
    error('SNCTOOLS:attput:hdf4:endFailed', ...
        'END failed on %s, "%s".\n', hfile, hdf4_error_msg);
end
return





%-----------------------------------------------------------------------
function nc_varput_mexnc( ncfile, varname, data, start,count,stride )


[ncid, status] = mexnc('open', ncfile, nc_write_mode);
if (status ~= 0)
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARPUT:MEXNC:OPEN', ncerr );
end




%
% check to see if the variable already exists.  
[varid, status] = mexnc('INQ_VARID', ncid, varname );
if ( status ~= 0 )
    mexnc ( 'close', ncid );
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARPUT:MEXNC:INQ_VARID', ncerr );
end


[dud,var_type,nvdims,var_dim,dud, status]=mexnc('INQ_VAR',ncid,varid); %#ok<ASGLU>
if status ~= 0 
    mexnc ( 'close', ncid );
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARPUT:MEXNC:INQ_VAR', ncerr );
end


v = nc_getvarinfo ( ncfile, varname );
nc_count = v.Size;



[start, count] = nc_varput_validate_indexing(ncid,nvdims,data,start,count,stride,true);

%
% check that the length of the start argument matches the rank of the variable.
if length(start) ~= length(nc_count)
    mexnc ( 'close', ncid );
    error ( 'SNCTOOLS:NC_VARPUT:badIndexing', ...
              'Length of START index (%d) does not make sense with a variable rank of %d.\n', ...
              length(start), length(nc_count) );
end



%
% Figure out which write routine we will use. 
if isempty(start) || (nvdims == 0)
    write_op = 'put_var';
    if (numel(data) ~= prod(v.Size))
    	mexnc ( 'close', ncid );
        error ( 'SNCTOOLS:NC_VARPUT:MEXNC:varput:dataSizeMismatch', ...
	        'Attempted to write wrong amount of data to %s.', v.Name );
    end
elseif isempty(count)
    write_op = 'put_var1';
    if ( numel(data) ~= 1 )
    	mexnc ( 'close', ncid );
        error ( 'SNCTOOLS:NC_VARPUT:MEXNC:putVara:dataSizeMismatch', ...
	        'Amount of data to be written to %s does not match up with count argument.', ...
            v.Name );        
    end
elseif isempty(stride)
    write_op = 'put_vara';
    if (numel(data) ~= prod(count))
    	mexnc ( 'close', ncid );
        error ( 'SNCTOOLS:NC_VARPUT:MEXNC:putVara:dataSizeMismatch', ...
	        'Amount of data to be written to %s does not match up with count argument.', ...
            v.Name );
    end
else
    write_op = 'put_vars';
    if (numel(data) ~= prod(count))
    	mexnc ( 'close', ncid );
        error ( 'SNCTOOLS:NC_VARPUT:MEXNC:putVars:dataSizeMismatch', ...
	        'Amount of data to be written to %s does not match up with count argument.', ...
            v.Name );
    end    
end



data = handle_scaling(ncid,varid,data);
data = handle_fill_value ( ncid, varid, data );

preserve_fvd = getpref('SNCTOOLS','PRESERVE_FVD',false);
if preserve_fvd
    start = fliplr(start);
    count = fliplr(count);
    stride = fliplr(stride);
else
    data = permute(data,fliplr(1:ndims(data)));
end

write_the_data(ncid,varid,start,count,stride,write_op,data);


status = mexnc ( 'close', ncid );
if ( status ~= 0 )
    error ( 'SNCTOOLS:nc_varput:close', mexnc('STRERROR',status));
end


return




%-------------------------------------------------------------------------
function [start, count, stride] = parse_and_validate_args(ncfile,varname,varargin)

%
% Set up default outputs.
start = [];
count = [];
stride = [];


switch length(varargin)
case 2
    start = varargin{1};
    count = varargin{2};

case 3
    start = varargin{1};
    count = varargin{2};
    stride = varargin{3};

end



%
% Error checking on the inputs.
if ~ischar(ncfile)
    error ( 'SNCTOOLS:NC_VARPUT:badInput', 'the filename must be character.' );
end
if ~ischar(varname)
    error ( 'SNCTOOLS:NC_VARPUT:badInput', 'the variable name must be character.' );
end

if ~isnumeric ( start )
    error ( 'SNCTOOLS:NC_VARPUT:badInput', 'the ''start'' argument must be numeric.' );
end
if ~isnumeric ( count )
    error ( 'SNCTOOLS:NC_VARPUT:badInput', 'the ''count'' argument must be numeric.' );
end
if ~isnumeric ( stride )
    error ( 'SNCTOOLS:NC_VARPUT:badInput', 'the ''stride'' argument must be numeric.' );
end


return








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = handle_scaling(ncid,varid,data)
% HANDLE_MEX_SCALING
%     If there is a scale factor and/or  add_offset attribute, convert the data
%     to double precision and apply the scaling.
%

[dud, dud, status] = mexnc('INQ_ATT', ncid, varid, 'scale_factor' ); %#ok<ASGLU>
if ( status == 0 )
    have_scale_factor = 1;
else
    have_scale_factor = 0;
end
[dud, dud, status] = mexnc('INQ_ATT', ncid, varid, 'add_offset' ); %#ok<ASGLU>
if ( status == 0 )
    have_add_offset = 1;
else
    have_add_offset = 0;
end

%
% Return early if we don't have either one.
if ~(have_scale_factor || have_add_offset)
    return;
end

scale_factor = 1.0;
add_offset = 0.0;


if have_scale_factor
    [scale_factor, status] = mexnc ( 'get_att_double', ncid, varid, 'scale_factor' );
    if ( status ~= 0 )
        mexnc ( 'close', ncid );
        ncerr = mexnc('strerror', status);
        error ( 'SNCTOOLS:NC_VARPUT:MEXNC:GET_ATT_DOUBLE', ncerr );
    end
end

if have_add_offset
    [add_offset, status] = mexnc ( 'get_att_double', ncid, varid, 'add_offset' );
    if ( status ~= 0 )
        mexnc ( 'close', ncid );
        ncerr = mexnc('strerror', status);
        error ( 'SNCTOOLS:NC_VARPUT:MEXNC:GET_ATT_DOUBLE', ncerr );
    end
end

[var_type,status]=mexnc('INQ_VARTYPE',ncid,varid);
if status ~= 0 
    mexnc ( 'close', ncid );
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARPUT:MEXNC:INQ_VARTYPE', ncerr );
end

data = (double(data) - add_offset) / scale_factor;

%
% When scaling to an integer, we should add 0.5 to the data.  Otherwise
% there is a tiny loss in precision, e.g. 82.7 should round to 83, not 
% .
switch var_type
    case { nc_int, nc_short, nc_byte, nc_char }
        data = round(data);
end


return






















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = handle_fill_value(ncid,varid,data)

[vartype, status] = mexnc('INQ_VARTYPE', ncid, varid);
if status ~= 0
    mexnc ( 'close', ncid );
    ncerr = mexnc('strerror', status);
    error('SNCTOOLS:nc_varput:mexnc:inqVarTypeFailed', ncerr );
end

%
% Handle the fill value.  We do this by changing any NaNs into
% the _FillValue.  That way the netcdf library will recognize it.
[att_type, dud, status] = mexnc('INQ_ATT', ncid, varid, '_FillValue' ); %#ok<ASGLU>
if ( status == 0 )

    if att_type ~= vartype
        warning('SNCTOOLS:nc_varget:mexnc:missingValueMismatch', ...
                'The _FillValue datatype is wrong and will not be honored.');
        return
	end

    switch ( class(data) )
    case 'double'
        funcstr = 'get_att_double';
    case 'single'
        funcstr = 'get_att_float';
    case 'int32'
        funcstr = 'get_att_int';
    case 'int16'
        funcstr = 'get_att_short';
    case 'int8'
        funcstr = 'get_att_schar';
    case 'uint8'
        funcstr = 'get_att_uchar';
    case 'char'
        funcstr = 'get_att_text';
    otherwise
        mexnc ( 'close', ncid );
        error ( 'SNCTOOLS:NC_VARPUT:unhandledDatatype', ...
            'Unhandled datatype for fill value, ''%s''.', ...
            class(data) );
    end

    [fill_value, status] = mexnc(funcstr,ncid,varid,'_FillValue' );
    if ( status ~= 0 )
        mexnc ( 'close', ncid );
        ncerr = mexnc('strerror', status);
        err_id = [ 'SNCTOOLS:NC_VARPUT:MEXNC:' funcstr ];
        error ( err_id, ncerr );
    end


    data(isnan(data)) = fill_value;

end

    













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_the_data(ncid,varid,start,count,stride,write_op,pdata)

%
% write the data
switch ( write_op )

    case 'put_var1'
        switch ( class(pdata) )
        case 'double'
            funcstr = 'put_var1_double';
        case 'single'
            funcstr = 'put_var1_float';
        case 'int32'
            funcstr = 'put_var1_int';
        case 'int16'
            funcstr = 'put_var1_short';
        case 'int8'
            funcstr = 'put_var1_schar';
        case 'uint8'
            funcstr = 'put_var1_uchar';
        case 'char'
            funcstr = 'put_var1_text';
        otherwise
            mexnc('close',ncid);
            error ( 'SNCTOOLS:NC_VARPUT:unhandledMatlabType', ...
                'unhandled data class %s\n', ...
                class(pdata));
        end
        status = mexnc (funcstr, ncid, varid, start, pdata );

    case 'put_var'
        switch ( class(pdata) )
        case 'double'
            funcstr = 'put_var_double';
        case 'single'
            funcstr = 'put_var_float';
        case 'int32'
            funcstr = 'put_var_int';
        case 'int16'
            funcstr = 'put_var_short';
        case 'int8'
            funcstr = 'put_var_schar';
        case 'uint8'
            funcstr = 'put_var_uchar';
        case 'char'
            funcstr = 'put_var_text';
        otherwise
            mexnc('close',ncid);
            error ( 'SNCTOOLS:NC_VARPUT:unhandledMatlabType', ...
                'unhandled data class %s\n', class(pdata)  );
        end
        status = mexnc (funcstr, ncid, varid, pdata );
    
    case 'put_vara'
        switch ( class(pdata) )
        case 'double'
            funcstr = 'put_vara_double';
        case 'single'
            funcstr = 'put_vara_float';
        case 'int32'
            funcstr = 'put_vara_int';
        case 'int16'
            funcstr = 'put_vara_short';
        case 'int8'
            funcstr = 'put_vara_schar';
        case 'uint8'
            funcstr = 'put_vara_uchar';
        case 'char'
            funcstr = 'put_vara_text';
        otherwise
            mexnc('close',ncid);
            error ( 'SNCTOOLS:NC_VARPUT:unhandledMatlabType',...
                'unhandled data class %s\n', class(pdata) );
        end
        status = mexnc (funcstr, ncid, varid, start, count, pdata );

    case 'put_vars'
        switch ( class(pdata) )
        case 'double'
            funcstr = 'put_vars_double';
        case 'single'
            funcstr = 'put_vars_float';
        case 'int32'
            funcstr = 'put_vars_int';
        case 'int16'
            funcstr = 'put_vars_short';
        case 'int8'
            funcstr = 'put_vars_schar';
        case 'uint8'
            funcstr = 'put_vars_uchar';
        case 'char'
            funcstr = 'put_vars_text';
        otherwise
            mexnc('close',ncid);
            error ( 'SNCTOOLS:NC_VARPUT:unhandledMatlabType', ...
                'unhandled data class %s\n', class(pdata) );
        end
        status = mexnc (funcstr, ncid, varid, start, count, stride, pdata );

    otherwise 
        mexnc ( 'close', ncid );
        error ( 'SNCTOOLS:NC_VARPUT:unhandledWriteOp', ...
            'unknown write operation''%s''.\n', write_op );


end

if ( status ~= 0 )
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_VARPUT:writeOperationFailed', ...
        'write operation ''%s'' failed with error ''%s''.', ...
        write_op, ncerr);
end

return
