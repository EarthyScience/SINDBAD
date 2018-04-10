function test_nc_iscoordvar ( )
% TEST_NC_ISCOORDVAR:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests should fail
% test 1:  no input arguments
% test 2:  1 input
% test 3:  too many inputs
% test 5:  not a netcdf file
% test 6:  empty netcdf file
% test 8:  given variable is not present  
% test 9:  given variable's dimension is not of the same name
% test 10:  given variable has more than one dimension
%
% test 11:  netcdf file has singleton variable, but no dimensions.
% test 12:  given variable has one dimension of the same name


testroot = fileparts(mfilename('fullpath'));

fprintf('Testing NC_ISCOORDVAR... ');

ncfile = fullfile(testroot,'testdata/empty.nc');
test_no_inputs;
test_only_one_input (ncfile);
test_too_many_inputs(ncfile);
test_not_netcdf_file;
test_empty_ncfile (ncfile);

ncfile = fullfile(testroot,'testdata/iscoordvar.nc');
test_variable_not_present (ncfile);
test_not_a_coordvar (ncfile);
test_var_has_2_dims (ncfile);

test_singleton_variable (ncfile);
test_coordvar (ncfile);

fprintf('OK\n');

return









%--------------------------------------------------------------------------
function test_no_inputs()
try
	nc_iscoordvar;
catch %#ok<CTCH>
    return
end
error('failed');





%--------------------------------------------------------------------------
function test_only_one_input ( ncfile )

try
	nc_iscoordvar ( ncfile );
catch %#ok<CTCH>
    return
end
error('failed');







%--------------------------------------------------------------------------
function test_too_many_inputs( ncfile )

try
	nc_iscoordvar ( ncfile, 'blah', 'blah2' );
catch %#ok<CTCH>
    return
end
error('failed');












%--------------------------------------------------------------------------
function test_not_netcdf_file (  )

try
	nc_iscoordvar ( 'test_iscoordvar.m', 't' );
catch %#ok<CTCH>
    return
end
error('failed');








%--------------------------------------------------------------------------
function test_empty_ncfile ( ncfile )

try
	nc_iscoordvar ( ncfile, 't' );
catch %#ok<CTCH>
    return
end
error('failed');












%--------------------------------------------------------------------------
function test_variable_not_present( ncfile )

try
	nc_iscoordvar ( ncfile, 'y' );
catch %#ok<CTCH>
    return
end
error('failed');










%--------------------------------------------------------------------------
function test_not_a_coordvar ( ncfile )

% 2nd set of tests should succeed
% test 9:  given variable's dimension is not of the same name

b = nc_iscoordvar ( ncfile, 'u' );
if ( b ~= 0 )
	error('incorrect result.');
end
return






%--------------------------------------------------------------------------
function test_var_has_2_dims ( ncfile )

b = nc_iscoordvar ( ncfile, 's' );
if ( ~b )
	error ( 'incorrect result.\n' );
end
return







%--------------------------------------------------------------------------
function test_singleton_variable ( ncfile )

yn = nc_iscoordvar ( ncfile, 't' );
if ( yn )
	error ( 'incorrect result.\n'  );
end

return






%--------------------------------------------------------------------------
function test_coordvar ( ncfile )

b = nc_iscoordvar ( ncfile, 's' );
if ~b
	error ( 'incorrect result.\n'  );
end

return









