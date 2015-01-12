function test_nc_adddim ( ncfile )
% TEST_NC_ADD_DIMENSION
%
% Test 1:  no inputs
% test 2:  too many inputs
% test 3:  first input not a netcdf file
% test 4:  2nd input not character
% test 5:  3rd input not numeric
% test 6:  3rd input is negative
% Test 7:  Add a normal length dimension.
% Test 7.1:  Add a normal length dimension to a netcdf-4 classic file.
% Test 8:  Add an unlimited dimension.
% Test 8.1:  Add an unlimited dimension to a netcdf-4 classic file.
% test 9:  named dimension already exists (should fail)
% test 9.1:  named dimension already exists (netcdf-4 classic, should fail)

if nargin == 0
	ncfile = 'foo_test_nc_adddim.nc';
end

fprintf('Testing NC_ADDDIM ...\n' );

v = version('-release');
switch(v)
	case{'14','2006a','2006b'}
	    fprintf('\tSome negative tests filtered out on version %s.\n', v);
    otherwise
		test_nc_adddim_neg;
end
run_nc3_tests(ncfile);
run_nc4_tests(ncfile);



%--------------------------------------------------------------------------
function run_nc3_tests(ncfile)
test_add_regular_dimension ( ncfile );                 % #7
test_add_unlimited ( ncfile );                         % #8
test_dimension_already_exists ( ncfile );              % #9

return




%--------------------------------------------------------------------------
function run_nc4_tests(ncfile)

if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end

test_add_regular_dimension_nc4_classic ( ncfile );     % #7.1
test_add_unlimited_nc4_classic ( ncfile );             % #8.1
test_dimension_already_exists_nc4_classic ( ncfile );  % #9.1

return






%--------------------------------------------------------------------------
function test_add_regular_dimension ( ncfile )

% test 7:  add a normal dimension
create_empty_file ( ncfile, nc_clobber_mode );
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

return


















%--------------------------------------------------------------------------
function test_add_unlimited ( ncfile )
% test 8:  add an unlimited dimension
create_empty_file ( ncfile, nc_clobber_mode );
nc_adddim ( ncfile, 't', 0 );

%
% Now check that the new dimension are there.
d = nc_getdiminfo ( ncfile, 't' );
if ( ~strcmp(d.Name,'t') )
	error ( '%s:  nc_adddim failed on fixed dimension add name', mfilename  );
end
if ( d.Length ~= 0 )
	error ( '%s:  nc_adddim failed on fixed dimension add length', mfilename  );
end
if ( d.Unlimited ~= 1  )
	error ( '%s:  nc_adddim incorrectly classified the dimension', mfilename  );
end

return











%--------------------------------------------------------------------------
function test_add_unlimited_nc4_classic ( ncfile )
% Add a dimension to a netcdf-4 classic file

% Don't run the test if the netcdf library version is less than 4.0
v = mexnc('inq_libvers');
if v(1) ~= '4'
	fprintf('filtering out test_add_regular_dimension_nc4_classic when the netcdf library version is less thang 4.0\n' );
	return
end

nc_create_empty ( ncfile, nc_netcdf4_classic );
nc_adddim ( ncfile, 't', 0 );

%
% Now check that the new dimension are there.
d = nc_getdiminfo ( ncfile, 't' );
if ( ~strcmp(d.Name,'t') )
	error ( '%s:  nc_adddim failed on fixed dimension add name', mfilename  );
end
if ( d.Length ~= 0 )
	error ( '%s:  nc_adddim failed on fixed dimension add length', mfilename  );
end
if ( d.Unlimited ~= 1  )
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










%--------------------------------------------------------------------------
function test_dimension_already_exists ( ncfile )

% test 9:  try to add a dimension that is already there
create_empty_file ( ncfile, nc_clobber_mode );
nc_adddim ( ncfile, 't', 0 );
try
	nc_adddim ( ncfile, 't', 0 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');







%--------------------------------------------------------------------------
function test_dimension_already_exists_nc4_classic ( ncfile )

nc_create_empty ( ncfile, nc_netcdf4_classic );
nc_adddim ( ncfile, 't', 0 );
try
	nc_adddim ( ncfile, 't', 0 );
catch %#ok<CTCH>
    return
end
error ( 'succeeded when it should have failed.');







