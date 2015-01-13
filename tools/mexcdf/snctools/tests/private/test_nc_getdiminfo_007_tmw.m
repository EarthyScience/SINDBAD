function test_nc_getdiminfo_007_tmw(ncfile);

    ncid = netcdf.open(ncfile,nc_nowrite_mode);
	try
    	diminfo = nc_getdiminfo ( ncid, 25000 );
	catch me
    	netcdf.close(ncid );
		return
	end
	error('succeeded when it should have failed');
