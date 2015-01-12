function test_nc_adddim_neg()
% negative testing for NC_ADDDIM that involves try/catch

ncfile = 'foo.nc';
test_no_inputs ();                               
test_too_many_inputs ( ncfile );                 
test_not_netcdf_file ( ncfile );                 
test_2nd_input_not_char ( ncfile );              
test_3rd_input_not_numeric ( ncfile );           
test_3rd_input_negative ( ncfile );              
test_add_regular_dimension_nc4_classic ( ncfile );


%--------------------------------------------------------------------------
function test_no_inputs ()
try
	nc_adddim;
catch %#ok<CTCH>
	return
end
error('succeeded when it should have failed');






%--------------------------------------------------------------------------
function test_too_many_inputs ( ncfile )


create_empty_file ( ncfile, nc_clobber_mode );
try
	nc_adddim ( ncfile, 'x', 10, 12 );
catch %#ok<CTCH>
	return
end
error('succeeded when it should have failed.');










%--------------------------------------------------------------------------
function test_not_netcdf_file ( ncfile )

fid = fopen(ncfile,'wb');
fwrite(fid,magic(5),'integer*4');
fclose(fid);

try
	nc_adddim(ncfile,'x',3);
catch %#ok<CTCH>
	return
end
error('Failed to catch non-netcdf file.');












%--------------------------------------------------------------------------
function test_2nd_input_not_char ( ncfile )

% test 4:  2nd input not char
create_empty_file ( ncfile, nc_clobber_mode );
try
	nc_adddim ( ncfile, 3, 3 );
catch %#ok<CTCH>
    return
end
error ('succeeded when it should have failed.');












%--------------------------------------------------------------------------
function test_3rd_input_not_numeric ( ncfile )

% test 5:  3rd input not numeric
create_empty_file ( ncfile, nc_clobber_mode );
try
	nc_adddim ( ncfile, 't', 't' );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');










%--------------------------------------------------------------------------
function test_3rd_input_negative ( ncfile )

create_empty_file ( ncfile, nc_clobber_mode );
try
	nc_adddim ( ncfile, 't', -1 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');






%--------------------------------------------------------------------------
function test_add_regular_dimension_nc4_classic ( ncfile )

% Don't run the test if the netcdf library version is less than 4.0
try
	v = mexnc('inq_libvers');
	if v(1) ~= '4'
		return
	end
catch %#ok<CTCH>
	% assume we don't have mexnc
	return
end

% add a normal dimension
nc_create_empty ( ncfile, nc_netcdf4_classic );
nc_adddim ( ncfile, 't', 5 );

%
% Now check that the new dimension are there.
d = nc_getdiminfo ( ncfile, 't' );
if ( ~strcmp(d.Name,'t') )
	error ( '%s:  nc_adddim failed on fixed dimension add name', mfilename  );
end
if ( d.Length ~= 5 )
	error ( '%s:  nc_adddim failed on fixed dimension add length', mfilename  );
end
if ( d.Unlimited ~= 0  )
	error ( '%s:  nc_adddim incorrectly classified the dimension', mfilename  );
end

% make sure it is hdf5
fid = fopen(ncfile,'r');
x = fread(fid,4,'uint8=>char');
fclose(fid);

if ~strcmp(x(2:4)','HDF')
	error('Did not create a netcdf-4 file');
end
return








