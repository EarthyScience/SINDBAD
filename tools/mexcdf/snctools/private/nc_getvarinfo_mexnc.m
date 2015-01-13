function Dataset = nc_getvarinfo_mexnc ( arg1, arg2 )
% MEXNC backend for NC_GETVARINFO

% If we are here, then we must have been given something local.
if ischar(arg1) && ischar(arg2)

	ncfile = arg1;
	varname = arg2;


	[ncid,status ]=mexnc('open',ncfile,nc_nowrite_mode);
	if status ~= 0
    	ncerr = mexnc('strerror', status);
	    error ( 'SNCTOOLS:NC_VARGET:MEXNC:OPEN', ncerr );
	end


	[varid, status] = mexnc('INQ_VARID', ncid, varname);
	if ( status ~= 0 )
    	ncerr = mexnc('strerror', status);
	    mexnc('close',ncid);
	    error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID', ncerr );
	end

	
	Dataset = get_varinfo ( ncid,  varid );

	%
	% close whether or not we were successful.
	mexnc('close',ncid);


elseif isnumeric ( arg1 ) && isnumeric ( arg2 )

	ncid = arg1;
	varid = arg2;

	Dataset = get_varinfo ( ncid,  varid );

else
	error ( 'SNCTOOLS:NC_GETVARINFO:badTypes', ...
	        'Must have either both character inputs, or both numeric.' );
end


return




