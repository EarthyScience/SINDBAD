function nc_attput(ncfile,varname,attname,attval)
%NC_ATTPUT  Writes attribute to netCDF file.
%   NC_ATTPUT(NCFILE,VARNAME,ATTNAME,ATTVAL) writes the data in ATTVAL to
%   the attribute ATTNAME of the variable VARNAME of the netCDF file
%   NCFILE. VARNAME should be the name of a netCDF VARIABLE, but one can
%   also use the mnemonic nc_global to specify a global attribute. 
%
%   The attribute datatype will match that of the class of ATTVAL.  So if
%   if you want to have a 16-bit short integer attribute, make the class of
%   ATTVAL to be INT16.
%
%   Example:  create an empty netcdf file and then write a global
%   attribute.
%       nc_create_empty('myfile.nc');
%       attval = sprintf('created on %s', datestr(now));
%       nc_attput('myfile.nc',nc_global,'history',attval);
%       nc_dump('myfile.nc');
%
%   Example:  write a global attribute to an HDF4 file.
%       srcfile = fullfile(matlabroot,'toolbox','matlab','demos','example.hdf')
%       copyfile(srcfile,'myfile.hdf');
%       fileattrib('myfile.hdf','+w');
%       nc_attput('myfile.hdf',nc_global,'timestamp',datestr(now));
%       nc_dump('myfile.hdf');
%
%   See also nc_attget.
%

backend = snc_write_backend(ncfile);
switch backend
    case 'mexnc'
        nc_attput_mex(ncfile,varname,attname,attval);
    case 'tmw_hdf4'
        nc_attput_hdf4(ncfile,varname,attname,attval);
    otherwise
        nc_attput_tmw(ncfile,varname,attname,attval);
end


return




%--------------------------------------------------------------------------
function nc_attput_hdf4(hfile,varname,attname,attval)
sd_id = hdfsd('start',hfile,'write');
if sd_id < 0
    error('SNCTOOLS:attput:hdf4:startFailed', ...
        'START failed on %s.\n', hfile);
end

if varname == -1
    obj_id = sd_id;
else
    idx = hdfsd('nametoindex',sd_id,varname);
    if idx < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:nc_info:hdf4:nametoindexFailed', ...
            'Unable to index %s.\n', varname);
    end
    obj_id = hdfsd('select',sd_id,idx);
    if  obj_id < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:nc_info:hdf4:selectFailed', ...
            'Unable to select %s.\n', varname);
    end
end

% Is it a predefined attribute?
switch(attname)
    case 'long_name'
         [label,unit,format,coordsys,status] = hdfsd('getdatastrs',obj_id,1000); %#ok<ASGLU>
        if ( status < 0 )
            unit = '';
            format = '';
            coordsys = '';
        end
        label = attval;
        status = hdfsd('setdatastrs',obj_id,label,unit,format,coordsys);
        if ( status < 0 )
            if varname == -1
                hdfsd('endaccess',obj_id);
            end
            hdfsd('end',sd_id);
            error('SNCTOOLS:hdf4:getdatstrsFailed', ...
                'Unable to set datastrings.' );
        end
        
    case 'units'
         [label,unit,format,coordsys,status] = hdfsd('getdatastrs',obj_id,1000); %#ok<ASGLU>
        if ( status < 0 )
            label = '';
            format = '';
            coordsys = '';
        end
        unit = attval;
        status = hdfsd('setdatastrs',obj_id,label,unit,format,coordsys);
        if ( status < 0 )
            if varname == -1
                hdfsd('endaccess',obj_id);
            end
            hdfsd('end',sd_id);
            error('SNCTOOLS:hdf4:getdatstrsFailed', ...
                'Unable to set datastrings.' );
        end
     
    case 'format'
        [label,unit,format,coordsys,status] = hdfsd('getdatastrs',obj_id,1000); %#ok<ASGLU>
        if ( status < 0 )
            unit = '';
            label = '';
            coordsys = '';
        end
        format = attval;
        status = hdfsd('setdatastrs',obj_id,label,unit,format,coordsys);
        if ( status < 0 )
            if varname == -1
                hdfsd('endaccess',obj_id);
            end
            hdfsd('end',sd_id);
            error('SNCTOOLS:hdf4:getdatstrsFailed', ...
                'Unable to set datastrings.' );
        end
   
    case 'coordsys'
        [label,unit,format,coordsys,status] = hdfsd('getdatastrs',obj_id,100); %#ok<ASGLU>
        if ( status < 0 )
            unit = '';
            format = '';
            label = '';
        end
        coordsys = attval;
        status = hdfsd('setdatastrs',obj_id,label,unit,format,coordsys);
        if ( status < 0 )
            if varname == -1
                hdfsd('endaccess',obj_id);
            end
            hdfsd('end',sd_id);
            error('SNCTOOLS:hdf4:getdatstrsFailed', ...
                'Unable to set datastrings.' );
        end      
        
    case 'scale_factor'
        [cal,cal_err,offset,offset_err,data_type,status] = hdfsd('getcal',obj_id); %#ok<ASGLU>
        if ( status < 0 )
            cal_err = 0;
            offset = 0;
            offset_err = 0;
            data_type = 'double';
        end
        status = hdfsd('setcal',obj_id,attval,cal_err,offset,offset_err,data_type);
        if ( status < 0 )
            if varname == -1
                hdfsd('endaccess',obj_id);
            end
            hdfsd('end',sd_id);
            error('SNCTOOLS:hdf4:getcalFailed', ...
                'Unable to set calibration.' );
        end
        
    case 'add_offset'
        [cal,cal_err,offset,offset_err,data_type,status] = hdfsd('getcal',obj_id); %#ok<ASGLU>
        if ( status < 0 )
            cal = 1;
            cal_err = 0;
            offset_err = 0;
            data_type = 'double';
        end
        status = hdfsd('setcal',obj_id,cal,cal_err,attval,offset_err,data_type);
        if ( status < 0 )
            if varname == -1
                hdfsd('endaccess',obj_id);
            end
            hdfsd('end',sd_id);
            error('SNCTOOLS:hdf4:getcalFailed', ...
                'Unable to set calibration.' );
        end
  
    case 'valid_range'
        [rmax,rmin,status] = hdfsd('getrange',obj_id); 
        if ( status < 0 )
            rmax = attval(2);
            rmin = attval(1);
        end
        status = hdfsd('setrange',obj_id,rmax,rmin);
        if ( status < 0 )
            if varname == -1
                hdfsd('endaccess',obj_id);
            end
            hdfsd('end',sd_id);
            error('SNCTOOLS:hdf4:getrangeFailed', ...
                'Unable to set calibration.' );
        end
        
    case '_FillValue'
        status = hdfsd('setfillvalue',obj_id,attval);
        
    otherwise
        status = hdfsd('setattr',obj_id,attname,attval);
end

if status < 0
    if varname == -1
        hdfsd('endaccess',obj_id);
    end
    hdfsd('end',sd_id);
    error('SNCTOOLS:attput:hdf4:setattrFailed', ...
        'SETATTR failed on %s.\n', hfile);
end

if varname ~= -1
    status = hdfsd('endaccess',obj_id);
    if status < 0
        hdfsd('end',sd_id);
        error('SNCTOOLS:attput:hdf4:endaccessFailed', ...
            'ENDACCESS failed on %s.\n', hfile);
    end
end
status = hdfsd('end',sd_id);
if status < 0
    error('SNCTOOLS:attput:hdf4:endFailed', ...
        'END failed on %s, "%s".\n', hfile, hdf4_error_msg);
end
return

%--------------------------------------------------------------------------
function msg = hdf4_error_msg()
ecode = hdfhe('value',1);
msg = hdfhe('string',ecode);
return

%-----------------------------------------------------------------------
function nc_attput_mex ( ncfile, varname, attribute_name, attval )

[ncid, status] =mexnc( 'open', ncfile, nc_write_mode );
if  status ~= 0 
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:badFile', ncerr );
end


%
% Put into define mode.
status = mexnc ( 'redef', ncid );
if ( status ~= 0 )
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:REDEF', ncerr );
end


if isnumeric(varname)
    varid = varname;
else
    [varid, status] = mexnc ( 'inq_varid', ncid, varname );
    if ( status ~= 0 )
        mexnc ( 'close', ncid );
        ncerr = mexnc ( 'strerror', status );
        error ( 'SNCTOOLS:NC_ATTGET:MEXNC:INQ_VARID', ncerr );
    end
end



%
% Figure out which mexnc operation to perform.
switch class(attval)

    case 'double'
        funcstr = 'put_att_double';
        atttype = nc_double;
    case 'single'
        funcstr = 'put_att_float';
        atttype = nc_float;
    case 'int32'
        funcstr = 'put_att_int';
        atttype = nc_int;
    case 'int16'
        funcstr = 'put_att_short';
        atttype = nc_short;
    case 'int8'
        funcstr = 'put_att_schar';
        atttype = nc_byte;
    case 'uint8'
        funcstr = 'put_att_uchar';
        atttype = nc_byte;
    case 'char'
        funcstr = 'put_att_text';
        atttype = nc_char;
    otherwise
        error ( 'SNCTOOLS:NC_ATTGET:unhandleDatatype', ...
            'attribute class %s is not handled by %s', ...
             class(attval), mfilename );
end

status = mexnc ( funcstr, ncid, varid, attribute_name, atttype, length(attval), attval);
if ( status ~= 0 )
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status ); 
    error ( ['SNCTOOLS:NC_ATTGET:MEXNC:' upper(funcstr)], ...
        'PUT_ATT operation failed:  %s', ncerr );
end



%
% End define mode.
status = mexnc ( 'enddef', ncid );
if ( status ~= 0 )
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:ENDDEF', ncerr );
end


status = mexnc('close',ncid);
if ( status ~= 0 )
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:CLOSE', ncerr );
end


return;



