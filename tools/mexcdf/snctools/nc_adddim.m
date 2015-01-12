function nc_adddim(ncfile,dimname,dimlen)
%nc_adddim:  adds a dimension to an existing netcdf file
%   nc_adddim(FILE,dimname,dimlen) adds a dimension with a particular
%   length to the file.  If dimlen is zero, the dimension will be 
%   unlimited.  If FILE is an HDF4 file, a coordinate variable will be
%   created as well.
%
%   Example:  create a netcdf file with a longitude dimension with length 
%   360, a latitude dimension with length 180, and an unlimited time 
%   dimension.
%       nc_create_empty('myfile.nc');
%       nc_adddim('myfile.nc','latitude',360);
%       nc_adddim('myfile.nc','longitude',180);
%       nc_adddim('myfile.nc','time',0);
%
%   Example:  create an HDF4 file with longitude, latitude, and time 
%   coordinate variables.
%       nc_create_empty('myfile.hdf','hdf4');
%       nc_adddim('myfile.hdf','latitude',360);
%       nc_adddim('myfile.hdf','longitude',180);
%       nc_adddim('myfile.hdf','time',0);
%     
% See also:  nc_addvar.

    
backend = snc_write_backend(ncfile);
switch(backend)
    case 'tmw'
    	nc_adddim_tmw(ncfile,dimname,dimlen);
    case 'tmw_hdf4'
    	nc_adddim_hdf4(ncfile,dimname,dimlen);
    case 'mexnc'
    	nc_adddim_mex(ncfile,dimname,dimlen);
    otherwise
        error('SNCTOOLS:adddim:unhandledBackend', ...
            'Encountered an unhandled backend string, ''%s''', backend);
end

return


%--------------------------------------------------------------------------
function nc_adddim_hdf4(hfile,dimname,dimlen)

if ~exist(hfile,'file')
	sd_id = hdfsd('start',hfile,'create');
else
	sd_id = hdfsd('start',hfile,'write');
end

if sd_id < 0
    error('SNCTOOLS:addDim:hdf4:startFailed', ...
        'START failed on %s.\n', hfile);
end


% Is there already a dataset with this name?
idx = hdfsd('nametoindex',sd_id,dimname);
if idx >=0
    hdfsd('end',sd_id);
    error('SNCTOOLS:addDim:hdf4:badName', ...
        'There is already a dataset with this name, "%s".\n', dimname);
end

% is it unlimited?  Netcdf conventions make this -1.
unlimited = false;
if (dimlen == -1) || (dimlen == 0) || isinf(dimlen)
    unlimited = true;
    create_arg = inf;
else
    create_arg = dimlen;
end
sds_id = hdfsd('create',sd_id,dimname,class(dimlen),1,create_arg);
if sds_id < 0
    hdfsd('end',sd_id);
    error('SNCTOOLS:addVar:hdf4:startFailed', ...
        'CREATE failed on %s.\n', hfile);
end


% ok, now make it a dimension as well
dimid = hdfsd('getdimid',sds_id,0);
if dimid < 0
    hdfsd('endaccess',sds_id);
    hdfsd('end',sd_id);
    error('SNCTOOLS:addDim:hdf4:getdimidFailed', ...
        'GETDIMID failed on %s, %s.\n', dimname, hfile);
end

status = hdfsd('setdimname',dimid,dimname);
if status < 0
    hdfsd('endaccess',sds_id);
    hdfsd('end',sd_id);
    error('SNCTOOLS:addDim:hdf4:setdimnameFailed', ...
        'SETDIMNAME failed on %s.\n', hfile);
end


status = hdfsd('endaccess',sds_id);
if status < 0
    hdfsd('end',sd_id);
    error('SNCTOOLS:addDim:hdf4:endaccessFailed', ...
        'ENDACCESS failed on %s.\n', hfile);
end

status = hdfsd('end',sd_id);
if status < 0
    error('SNCTOOLS:addDim:hdf4:endFailed', ...
        'END failed on %s, \"%s\".\n', hfile);
end
return

%-----------------------------------------------------------------------
function nc_adddim_mex(ncfile,dimname,dimlen)
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if status
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:nc_adddim:openFailed';
    error ( error_id, ncerr );
end

status = mexnc ( 'redef', ncid );
if status
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:nc_adddim:redefFailed';
    error ( error_id, ncerr );
end

[dimid, status] = mexnc ('def_dim',ncid,dimname,dimlen); %#ok<ASGLU>
if status
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:nc_adddim:defdimFailed';
    error ( error_id, ncerr );
end

status = mexnc ( 'enddef', ncid );
if status
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:nc_adddim:enddefFailed';
    error ( error_id, ncerr );
end


status = mexnc ( 'close', ncid );
if status 
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:nc_adddim:closeFailed';
    error ( error_id, ncerr );
end



return












