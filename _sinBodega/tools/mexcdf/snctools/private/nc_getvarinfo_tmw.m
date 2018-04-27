function Dataset = nc_getvarinfo_tmw ( arg1, arg2 )
% TMW backend for NC_GETVARINFO

if ischar(arg1) && ischar(arg2)
	% We were given a char filename and a char varname.

	ncfile = arg1;
	varname = arg2;


    ncid=netcdf.open(ncfile,nc_nowrite_mode);
    try
        varid = netcdf.inqVarID(ncid, varname);
        Dataset = get_varinfo_tmw ( ncid,  varid );
    catch me
        netcdf.close(ncid);
        rethrow(me);
    end
    
    netcdf.close(ncid);

elseif isnumeric ( arg1 ) && isnumeric ( arg2 )
	% We were given a numeric file handle and a numeric id.

	ncid = arg1;
	varid = arg2;

	Dataset = get_varinfo_tmw ( ncid,  varid );

else
	error ( 'SNCTOOLS:NC_GETVARINFO:tmw:badTypes', ...
	        'Must have either both character inputs, or both numeric.' );
end


return




